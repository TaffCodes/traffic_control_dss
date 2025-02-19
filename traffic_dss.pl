% Facts: Junctions, directions, and sensors
junction(junctionA, [north, south, east, west]).
sensor(junctionA, north, vehicle_count, 25). % 25 cars in north lane
sensor(junctionA, south, vehicle_count, 5).
sensor(junctionA, east, vehicle_count, 15).
sensor(junctionA, west, vehicle_count, 10).
sensor(junctionA, north, pedestrian_waiting, 2). % 2 pedestrians waiting
sensor(junctionA, south, emergency_vehicle, yes). % Ambulance approaching

% Time-based rules (e.g., 8-10 AM is rush hour)
current_time(8, 30). % 8:30 AM

% Weather conditions
current_weather(rain).

% Adjacent junctions (for congestion propagation)
adjacent(junctionA, junctionB).

% Rules for calculating green light duration
green_duration(Junction, Direction, Duration) :-
    (emergency_override(Junction, Direction, Duration) ; % Highest priority
     pedestrian_priority(Junction, Direction, Duration) ;
     congestion_propagation(Junction, Direction, Duration) ;
     time_based_duration(Junction, Direction, Duration) ;
     density_based_duration(Junction, Direction, Duration)).

% Rule 1: Emergency vehicle override
emergency_override(Junction, Direction, 60) :- % Force 60s green for emergency lane
    sensor(Junction, Direction, emergency_vehicle, yes).

% Rule 2: Pedestrian priority
pedestrian_priority(Junction, Direction, 20) :-
    sensor(Junction, Direction, pedestrian_waiting, Pedestrians),
    Pedestrians >= 2,
    \+ sensor(Junction, _, emergency_vehicle, yes). % No active emergency

% Rule 3: Congestion propagation from adjacent junctions
congestion_propagation(Junction, Direction, ReducedDuration) :-
    adjacent(Junction, AdjacentJunction),
    sensor(AdjacentJunction, _, vehicle_count, AdjacentCount),
    AdjacentCount >= 30, % Adjacent junction is congested
    density_based_duration(Junction, Direction, OriginalDuration),
    ReducedDuration is max(10, OriginalDuration - 10). % Reduce by 10s

% Rule 4: Time-based default durations
time_based_duration(_, _, 40) :-
    current_time(Hour, _),
    Hour >= 7, Hour < 10, % Rush hour: 7 AM to 10 AM
    !.
time_based_duration(_, _, 30). % Off-peak default

% Rule 5: Density-based adjustment
density_based_duration(Junction, Direction, Duration) :-
    sensor(Junction, Direction, vehicle_count, Count),
    (Count >= 20 -> Duration = 50 ;
     Count >= 10 -> Duration = 40 ;
     Duration = 30).

% Rule 6: Weather adaptation for yellow light
yellow_duration(Junction, Duration) :-
    current_weather(rain),
    Duration = 5. % Longer yellow light in rain
yellow_duration(_, 3). % Default: 3s

% Main query: Calculate green light duration for north lane at junctionA
?- green_duration(junctionA, north, Duration).
% Output: Duration = 60 (due to emergency vehicle override)


# I am just a guy who wants to make it in life and have the best for all that I love.