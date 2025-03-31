% =======================================================
% Traffic Light Duration Control System
% =======================================================

% Junction definitions
junction(junctionA, [north, south, east, west]).    % Main junction with congestion propagation
junction(junctionB, [north, south, east, west]).    % Adjacent junction to junctionA
junction(junctionC, [north, south, east, west]).    % Junction for pedestrian priority scenario
junction(junctionD, [north, south, east, west]).    % Junction with no adjacent congestion

% ----------------------------------
% Sensor Facts for Each Scenario
% ----------------------------------

% -- Junction A: Emergency override and congestion propagation scenario --
% For emergency override, the north lane has an emergency vehicle.
sensor(junctionA, north, vehicle_count, 25).
sensor(junctionA, north, emergency_vehicle, yes).  % Triggers emergency override
sensor(junctionA, south, vehicle_count, 5).
sensor(junctionA, east, vehicle_count, 15).
sensor(junctionA, west, vehicle_count, 10).

% -- Junction B: Adjacent junction (congested) --
sensor(junctionB, north, vehicle_count, 35).  % High count to trigger congestion propagation
sensor(junctionB, south, vehicle_count, 12).
sensor(junctionB, east, vehicle_count, 8).
sensor(junctionB, west, vehicle_count, 10).

% -- Junction C: Pedestrian priority scenario --
sensor(junctionC, east, vehicle_count, 12).
sensor(junctionC, east, pedestrian_waiting, 3).  % At least 2 pedestrians waiting
% Note: No emergency_vehicle fact here so pedestrian rule can apply.

% -- Junction D: Default scenario (neither emergency nor adjacent congestion) --
sensor(junctionD, west, vehicle_count, 9).

% ----------------------------------
% Global Conditions
% ----------------------------------

% Current time (rush hour: between 7 and 10 AM)
current_time(8, 30).

% Weather condition: rain (affects yellow duration)
current_weather(rain).

% Adjacent junction relationship (for congestion propagation)
adjacent(junctionA, junctionB).

% =======================================================
% Green Light Duration Rules
% =======================================================

% Rule 1: Emergency vehicle override (highest priority)
green_duration(Junction, Direction, 60) :-
    sensor(Junction, Direction, emergency_vehicle, yes), !.

% Rule 2: Pedestrian priority (applies if 2+ pedestrians waiting in the same lane
% and no emergency vehicle in that lane)
green_duration(Junction, Direction, 20) :-
    sensor(Junction, Direction, pedestrian_waiting, Pedestrians),
    Pedestrians >= 2,
    \+ sensor(Junction, Direction, emergency_vehicle, yes), !.

% Rule 3: Congestion propagation from an adjacent junction
% If any sensor in an adjacent junction shows a high vehicle count, reduce duration.
green_duration(Junction, Direction, ReducedDuration) :-
    adjacent(Junction, AdjacentJunction),
    sensor(AdjacentJunction, _, vehicle_count, AdjacentCount),
    AdjacentCount >= 30,  % Adjacent junction is congested
    density_based_duration(Junction, Direction, OriginalDuration),
    Reduced is OriginalDuration - 10,
    ReducedDuration is max(10, Reduced), !.

% Rule 4: Time-based default duration (rush hour: 7-10 AM)
green_duration(_, _, Duration) :-
    current_time(Hour, _),
    Hour >= 7, Hour < 10,
    !,
    Duration = 40.

% Rule 5: Density-based adjustment (default scenario)
green_duration(Junction, Direction, Duration) :-
    density_based_duration(Junction, Direction, Duration).

% Density-based duration rule based on vehicle count
density_based_duration(Junction, Direction, Duration) :-
    sensor(Junction, Direction, vehicle_count, Count),
    ( Count >= 20 -> Duration = 50 ;
      Count >= 10 -> Duration = 40 ;
      Duration = 30 ).

% =======================================================
% Yellow Light Duration Rules (Weather Adaptation)
% =======================================================

yellow_duration(_, Duration) :-
    current_weather(rain),
    !,
    Duration = 5.  % Longer yellow light in rain
yellow_duration(_, 3).  % Default yellow light duration

% =======================================================
% Example Queries to Test Each Scenario (commented out):
% =======================================================
%
% 1. Emergency Override Scenario (junctionA, north lane):
%    % ?- green_duration(junctionA, north, Duration).
%    % Expected: Duration = 60.
%
% 2. Congestion Propagation Scenario (junctionA, east lane):
%    % ?- green_duration(junctionA, east, Duration).
%    % Expected: density_based_duration gives 40, reduced by 10 -> Duration = 30.
%
% 3. Pedestrian Priority Scenario (junctionC, east lane):
%    % ?- green_duration(junctionC, east, Duration).
%    % Expected: Duration = 20.
%
% 4. Default Time/Density-Based Scenario (junctionD, west lane):
%    % ?- green_duration(junctionD, west, Duration).
%    % Expected: Falls back to density_based_duration (Count = 9, so Duration = 30)
%    %              or time-based rule (40) if no congestion rule applies.
%
% 5. Yellow Light Duration in Rain:
%    % ?- yellow_duration(junctionA, Duration).
%    % Expected: Duration = 5.
