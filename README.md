# LeagueRoster Pedia

## Description

A Rails 8 application for browsing professional League of Legends teams and their rosters. Data is sourced from [Leaguepedia](https://lol.fandom.com/wiki/League_of_Legends_Esports_Wiki), the community-driven League of Legends esports wiki.

Teams are organized by region (LCK, LPL, LEC, LCS, etc.) with unique geometric logo designs. Each team displays its full roster with player information including IGN, real name, role, and contract details.

**Features:**
- Regional team browsing with horizontal scrolling sections
- Geometric team logo placeholders with team-specific colors
- Quick-view modal for team rosters
- Detailed team pages with full player information
- Admin panel for managing team data sources and syncing
- Search functionality across teams and players
- Background job processing with Solid Queue

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd leagueroster_pedia
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up environment variables:
   ```bash
   cp env.example .env
   ```
   Edit `.env` with your configuration values.

4. Set up the database:
   ```bash
   bin/rails db:setup
   ```

5. Start the development server:
   ```bash
   bin/dev
   ```

## Admin

The admin panel is accessible at `/admin` and is protected by HTTP Basic Authentication.

Configure your admin credentials in `env.example` (copy to `.env`):
- `ADMIN_USERNAME`
- `ADMIN_PASSWORD`

## Tests

Run the test suite:
```bash
bin/rails test
```