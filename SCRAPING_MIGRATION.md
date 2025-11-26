# Migration from Cargo API to Web Scraping

## Summary

The LeaguepediaService has been rewritten to use Nokogiri web scraping instead of the Cargo API to avoid rate limiting issues.

## Changes Made

### 1. Service Rewrite (`app/services/leaguepedia_service.rb`)

**Before:** Used Cargo API with `action=cargoquery` endpoints
**After:** Scrapes HTML pages using Nokogiri

#### Key Changes:

- Removed Cargo API query logic
- Added Nokogiri HTML parsing
- Implemented rate limiting (2.5 seconds between requests)
- Added robust error handling for missing pages and parse errors

#### Public Interface (UNCHANGED):

```ruby
service = LeaguepediaService.new

# Fetch team data - returns hash or nil
team_data = service.fetch_team_by_name("T1")
# => { "Name" => "T1", "Short" => "T1", "Region" => "Korea", ... }

# Fetch roster data - returns array of player hashes
roster_data = service.fetch_team_roster("T1")
# => [{ "ID" => "Faker", "Name" => "Lee Sang-hyeok", "Role" => "Mid", ... }, ...]
```

### 2. Data Extraction Strategy

#### Team Pages (`/wiki/TeamName`)
Extracts from team infobox:
- **Name**: From `<h1 class="mw-page-title-main">`
- **Short**: From infobox row labeled "Short", "Abbreviation", or "Tag"
- **Region**: From infobox row labeled "Region"
- **Image**: From first `<img>` in infobox
- **Website**: From infobox row labeled "Website"
- **IsDisbanded**: Detected from page content (searches for "disbanded", "inactive", "dissolved")

#### Roster Extraction
1. Finds roster table by looking for:
   - Sections with ID `#Roster`, `#Current_Roster`, `#Active_Roster`
   - Tables with "roster" in preceding heading
   - Tables containing player links
2. Extracts player names from links: `<a href="/wiki/PlayerName">`
3. Filters out non-player pages (files, categories, seasons, etc.)
4. Limits to 15 players max

#### Player Pages (`/wiki/PlayerName`)
Extracts from player infobox:
- **ID**: Player IGN from page title
- **Name**: Real name from infobox
- **Country**: From infobox
- **Nationality**: From infobox
- **Age**: From infobox or calculated from birthdate
- **Birthdate**: From infobox
- **Role**: From infobox (Top, Jungle, Mid, Bot, Support)
- **IsCurrent**: Always '1' (scraped from current roster)
- **DateJoin**: Set to `nil` (not available from player pages)

### 3. Rate Limiting

Built-in rate limiting prevents overwhelming the server:
- **Delay**: 2.5 seconds between HTTP requests
- **Tracking**: Records timestamp of last request
- **Enforcement**: Sleeps if needed before next request

Example: Fetching a 5-player roster takes ~12.5 seconds minimum (1 team page + 5 player pages * 2.5s)

### 4. Error Handling

The service gracefully handles:
- **404 errors**: Returns `nil` for teams, `[]` for rosters
- **Missing infoboxes**: Returns `nil` with warning log
- **Network timeouts**: Returns `nil` with error log
- **Parse errors**: Logs error and continues
- **Invalid dates**: Returns `nil` for unparseable dates

### 5. Testing

Comprehensive test suite added at `test/services/leaguepedia_service_test.rb`:

**Coverage includes:**
- Team data extraction (happy path + edge cases)
- Roster extraction with multiple players
- Player data parsing
- Rate limiting verification
- Error handling (404, 500, timeouts)
- Infobox format variations
- Link filtering (excludes files, categories, etc.)
- Roster size limiting
- Disbanded team detection

**Running tests:**
```bash
bin/rails test test/services/leaguepedia_service_test.rb
```

### 6. Testing Tools

#### Automated Tests
Uses WebMock to stub HTTP requests for fast, reliable testing without hitting live site.

#### Manual Testing Rake Task
Test with real data (use sparingly):

```bash
# Test with T1 (default)
bin/rails test_scraping:run

# Test with specific team
bin/rails test_scraping:run[GenG]
```

This hits the live Leaguepedia site, so use responsibly.

### 7. Dependencies

**Added:**
- `webmock` gem (test group) - for stubbing HTTP requests in tests

**Already present:**
- `httparty` - for making HTTP requests
- `nokogiri` (v1.18.10) - for HTML parsing

## Usage Examples

### Syncing a Team
The existing rake task still works:

```bash
bin/rails sync_details:run[T1]
```

This will:
1. Fetch team data from `/wiki/T1`
2. Save team to database
3. Extract player names from roster table
4. Fetch each player's data (with 2.5s delay between requests)
5. Save all players to database

### Manual Usage in Console

```ruby
service = LeaguepediaService.new

# Get team info
team = service.fetch_team_by_name("T1")
puts team["Region"]  # => "Korea"

# Get roster
roster = service.fetch_team_roster("T1")
roster.each do |player|
  puts "#{player['ID']} - #{player['Name']} (#{player['Role']})"
end
# Outputs:
# Faker - Lee Sang-hyeok (Mid)
# Keria - Ryu Min-seok (Support)
# ...
```

## Potential Issues & Solutions

### Issue: Player names not extracted correctly
**Cause:** Roster table format differs from expected structure
**Solution:** The service tries multiple selectors and fallbacks. Check logs for warnings.

### Issue: Infobox data missing
**Cause:** Wiki page uses different infobox HTML structure
**Solution:** Service handles multiple formats. May need to add new selectors if format changes.

### Issue: Age calculation wrong
**Cause:** Birthdate format not parseable
**Solution:** Service logs errors and returns `nil` for unparseable dates

### Issue: Too many/few players in roster
**Cause:** Link filtering logic too strict/loose
**Solution:** Adjust filters in `extract_roster_player_names` method

## Performance Notes

- **Team page fetch**: ~0.5s + rate limit delay
- **Player page fetch**: ~0.5s + rate limit delay per player
- **Full team sync (5 players)**: ~15-20 seconds total
- **Memory usage**: Minimal (Nokogiri parses incrementally)

## Comparison: API vs Scraping

| Aspect | Cargo API (Old) | Web Scraping (New) |
|--------|----------------|-------------------|
| Rate Limiting | Frequent 429 errors | Self-imposed 2.5s delay |
| Reliability | Unstable during high traffic | Stable (just HTML) |
| Data Freshness | Real-time | Real-time |
| Maintenance | None (API stable) | May break if HTML changes |
| Speed | Fast (single request) | Slower (multiple requests) |
| Data Coverage | Complete | Good (some fields unavailable) |

## Future Improvements

1. **Caching**: Cache player data to avoid re-fetching unchanged players
2. **Parallel Fetching**: Fetch multiple players concurrently (with rate limiting)
3. **HTML Change Detection**: Monitor for wiki template changes
4. **Fallback to API**: Use API as fallback if scraping fails
5. **More Robust Selectors**: Add more selector patterns for different wiki formats

## Rollback Plan

If scraping causes issues, you can temporarily rollback by:
1. Restore the previous version of `leaguepedia_service.rb` from git history
2. The rest of the codebase remains unchanged

```bash
git checkout HEAD~1 app/services/leaguepedia_service.rb
```
