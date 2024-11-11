
# Leaderboard Aggregate App (LAA)

The Leaderboard Aggregate App (LAA) enabled users to see the combined height records of kitesurfing big air jumps from a variety of leaderboards e.g. Surfr, Woo etc.

## Sources

### Surfr

#### Leaderboard

https://surfr-leaderboard.vercel.app/

#### API

https://kiter-271715.appspot.com/leaderboards/list/height/alltime/0?accesstoken=e16a0f15-67c5-4306-81a5-0c554a55a222

### Woo

#### Leaderboard

https://leaderboards.woosports.com/kite/bigair?mt=height&sd=1357002000&ed=1713830400&co=&cy=&sp=&ge=&ht=null

Note: Params above ^^ are for kiting big air all time jumps.

Note: The woo leaderboard app is pretty flakey on some browsers.

#### API

https://prod3.apiwoo.com/leaderboardsHashtags?offset=0&page_size=50&feature=height&game_type=big_air

## Design

Designed as a React app with some vanilla JS to aggregate the results.

```text
ruby -> aggregate.rb -------> aggregated_results.json
                                           ^
user (browser) -----> sinatra_app ---------|
```

## Development

### Phase 1

Retrieve and aggregate the results from all leaderboards.

#### Common Format

Each jump result should contain the following fields (if possible):

- Position (in leaderboard)
- Name (of the rider)
- Height (of the jump)
- Location (of the jump)
- Date (of the jump)
- Gender (of the rider)
- Country (of the rider)
- ImageURL (of the rider)
- Source (Surfr etc)

A results enumerable will contain all results to be displayed, sorted by jump height.

#### Pseudo Code

> aggregate.rb

```
aggregate_results() -> aggregated_results.json
```

- Create an instance of common Results (enumerable)
- For each leaderboard URL:
    - `GET <API_URL>` JSON response containing all results
    - For each result object:
        - Transform to a common Result object
        - Append result to common Results enumerable
- Sort results by height (highest jump first)
- Write the results to `aggregated_results.json` file at root of repo

### Phase 2

Create a sinatra app to display the aggregated results.

- Read results from `aggregated_results.json`
- Display the results in a sexy table
- User can now see and interact with the aggregated Results
- Results will be updated every 24 hours

To update the `aggregated_results.json` file every 24 hours we can use a server thread:

```ruby
Thread.new do
  loop {
    sleep 1.day

    if ENV["AGGREGATE_RESULTS"]
      aggregate_results() # -> aggregated_results.json
    end
  }
end

# Start server...
```

#### Endpoints

- `GET /` (index page displays results)
- `GET /aggregated.json`
- `GET /aggregate` (requiring basic HTTP auth)
- `GET /health`