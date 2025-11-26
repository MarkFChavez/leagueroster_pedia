# LeagueRoster Pedia

A Rails 8 application that displays professional League of Legends teams and their rosters, with data sourced from Leaguepedia using their Cargo API.

## Features

- **Homepage**: Browse professional LoL teams organized by region
- **Team Pages**: View detailed team information with complete roster details
- **Player Information**: See player IGN, real name, role, nationality, age, and join date
- **Simple Syncing**: One-command sync for individual teams
- **Auto-detect Region**: Automatically determines team's region from Leaguepedia
- **Team Logos**: Display team logos from Leaguepedia's CDN

## Technology Stack

- **Rails 8.0.4** - Web framework
- **SQLite** - Database
- **Tailwind CSS** - Styling
- **HTTParty** - HTTP client for API requests
- **Solid Queue** - Background job processing (Rails 8 built-in)

## Prerequisites

- Ruby 3.2.2 or higher
- Rails 8.0.4
- SQLite3

## Installation

1. Navigate to the project directory:
```bash
cd leagueroster_pedia
```

2. Install dependencies:
```bash
bundle install
```

3. Set up the database:
```bash
rails db:create db:migrate
```

4. Seed sample data (optional):
```bash
rails db:seed
```

This will create sample data for T1, HLE, and G2 Esports with some of their players.

## Running the Application

Start the Rails server with Tailwind CSS:
```bash
bin/dev
```

The application will be available at http://localhost:3000

## Syncing Real Data from Leaguepedia

Sync individual teams using the simple rake task:

```bash
bin/rails sync_details:run[T1]
bin/rails sync_details:run[G2]
bin/rails "sync_details:run[Hanwha Life Esports]"
```

**How it works:**
1. Searches Leaguepedia for the team by name
2. Auto-detects the team's region
3. Fetches current roster and player details
4. Saves everything to the database

**Note:** Team names are case-sensitive. Use the exact name from Leaguepedia.

## Important Notes

### Rate Limiting

- Leaguepedia's API has rate limits (~50 requests/minute)
- Each team sync makes only 2 API calls (team info + roster)
- Rate limit errors are handled with exponential backoff
- Wait a few minutes between syncs if you hit rate limits

### Data Persistence

- Data is cached in SQLite database
- Re-syncing a team updates existing data
- Each sync updates the `last_synced_at` timestamp

## Project Structure

```
leagueroster_pedia/
├── app/
│   ├── controllers/
│   │   └── teams_controller.rb          # Main controller for teams
│   ├── models/
│   │   ├── team.rb                      # Team model
│   │   └── player.rb                    # Player model
│   ├── jobs/
│   │   └── sync_leaguepedia_data_job.rb # Background sync job
│   ├── services/
│   │   └── leaguepedia_service.rb       # API integration service
│   └── views/
│       └── teams/
│           ├── index.html.erb           # Homepage
│           └── show.html.erb            # Team detail page
├── db/
│   ├── migrate/                         # Database migrations
│   └── seeds.rb                         # Sample seed data
└── lib/
    └── tasks/
        └── sync_details.rake            # Rake task for syncing teams
```

## API Integration

This app uses the **Leaguepedia Cargo API** to fetch data:

- **Base URL**: https://lol.fandom.com/api.php
- **Tables Used**:
  - `Teams` - Team information
  - `Players` - Player biographical data
  - `Tenures` - Player-team relationships

### Example API Query

```ruby
service = LeaguepediaService.new
team_data = service.fetch_team_by_name('T1')
roster = service.fetch_team_roster('T1')
```

## Routes

- `/` - Homepage (teams index)
- `/teams/:id` - Team detail page with roster

## Development

### Running Tests
```bash
rails test
```

### Rails Console
```bash
rails console
```

### Check Routes
```bash
rails routes
```

## Future Enhancements

Potential features to add:
- Player detail pages with career history
- Historical roster data and transfers
- Tournament results and statistics
- Search functionality
- Filter by multiple criteria
- Automatic periodic syncing with scheduled jobs
- Player images from Leaguepedia

## Troubleshooting

**Rate limit errors:**
- Wait a few minutes before retrying
- The app automatically handles rate limits with exponential backoff
- Syncing one team at a time minimizes rate limit issues

**Team not found:**
- Check team name spelling (case-sensitive)
- Use exact name from Leaguepedia
- Example: `"Hanwha Life Esports"` not `"HLE"`

**No data showing:**
- Run `rails db:seed` for sample data (T1, HLE, G2)
- Or sync teams from Leaguepedia: `bin/rails sync_details:run[T1]`

**Server won't start:**
- Make sure you're using `bin/dev` (not `rails server`) to start Tailwind CSS
- Check that all migrations have run: `rails db:migrate`

## License

This project is created for educational purposes.
