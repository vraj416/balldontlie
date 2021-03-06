# frozen_string_literal: true

class GameQuery
  attr_reader :params

  def initialize(params: {})
    @params = {
      'dates' => [],
      'seasons' => [],
      'team_ids' => []
    }.merge(params)
  end

  def games
    scope = Game.all

    scope = dates(scope) if params['dates'].any?
    scope = seasons(scope) if params['seasons'].any?
    scope = team_ids(scope) if params['team_ids'].any?
    scope = postseason(scope) unless params['postseason'].nil?
    scope = start_date(scope) if params['start_date']
    scope = end_date(scope) if params['end_date']

    scope
  end

  private

  def dates(scope)
    scope.where(date: params['dates'])
  end

  def seasons(scope)
    scope.where(season: params['seasons'])
  end

  def team_ids(scope)
    scope.joins(:home_team, :visitor_team).where(
      'teams.public_id in (?) or visitor_teams_games.public_id in (?)',
      params['team_ids'],
      params['team_ids']
    )
  end

  def postseason(scope)
    scope.where(postseason: params['postseason'])
  end

  def start_date(scope)
    scope.where('date >= ?', params['start_date'])
  end

  def end_date(scope)
    scope.where('date <= ?', params['end_date'])
  end
end
