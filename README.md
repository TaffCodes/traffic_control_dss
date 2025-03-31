# Traffic Control Decision Support System

An intelligent traffic light control system implemented in Prolog that optimizes traffic flow based on real-time conditions and multiple decision factors.

## Overview

This system determines optimal traffic light timings by considering:
- Emergency vehicle presence
- Pedestrian waiting counts  
- Traffic density
- Weather conditions
- Rush hour periods
- Adjacent junction congestion

## Prerequisites

- [SWI-Prolog](https://www.swi-prolog.org/Download.html) (Version 8.0 or higher)
- Windows OS

## Installation

1. Clone or download this repository
2. Navigate to the project directory:
```cmd
cd traffic_control_dss
```

## Usage

1. Start SWI-Prolog from the project directory:
```cmd
swipl
```

2. Load the program:
```prolog
?- consult('traffic.pl').
```

3. Example queries:
```prolog
% Get green light duration for north direction at junctionA
?- green_duration(junctionA, north, Duration).

% Check yellow light duration during current weather
?- yellow_duration(junctionA, Duration).
```

## System Rules

The system implements the following priority-based rules:

1. **Emergency Override** (Highest Priority)
   - 60-second green light for emergency vehicles
   - Overrides all other conditions

2. **Pedestrian Priority**
   - 20-second green light when ≥2 pedestrians waiting
   - Only active when no emergency vehicles present

3. **Congestion Management**
   - Adjusts timing based on adjacent junction traffic
   - Reduces duration by 10s when adjacent traffic >30 vehicles

4. **Time-Based Control**
   - Rush hour (7-10 AM): 40-second default
   - Off-peak: 30-second default

5. **Density-Based Adjustment**
   - High density (≥20 vehicles): 50 seconds
   - Medium density (≥10 vehicles): 40 seconds
   - Low density: 30 seconds

6. **Weather Adaptation**
   - Rain: 5-second yellow light
   - Normal: 3-second yellow light

## Sample Output

```prolog
?- green_duration(junctionA, north, Duration).
Duration = 60.  % Emergency vehicle present

?- yellow_duration(junctionA, Duration).
Duration = 5.   % Rainy conditions
```

## File Structure

- `traffic_dss.pl` - Main Prolog source file containing rules and facts
- `README.md` - Project documentation


## Author

Ideated by Group 4, BSc. Computer Science - CU - Class of 2025
