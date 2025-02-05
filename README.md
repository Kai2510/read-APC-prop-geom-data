[![View Read APC propellers performance data on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://it.mathworks.com/matlabcentral/fileexchange/127833-read-apc-propellers-performance-data)

# Read APC propeller performance data
This repository includes functions and test scripts to import and process APC propeller performance data file in MATLAB. 
The two fuctions, namely `readAPCgeom` and `readAPCperf` can be used separately. 
See the test script file to explore how it works. Examples includes:
- plotting all performance data (propeller coefficients and forces)
- interpolating the available data at specific RPM or airspeed

![example](https://user-images.githubusercontent.com/52099779/232206371-5da17179-9c1c-43dc-ae23-cafc77d81a24.png)

# Definition of The Propellers' Geometry & Performance File by APC corp.

The Geometry file has 13 columns.
```
THE QUOTED PITCH REFLECTS, IN GENERAL, ANGULAR MEASURE AS DEFINED WITH A FLAT BOTTOM SURFACE.
THIS WILL AGREE WITH A PRATHER GAGE MEASUREMENT OVER MOST OF THE EFFECTIVE PORTION OF THE BLADE. (NOTE: QUOTED=INPUT)
THE LE-TE MEASURE IS DEFINED IN TERMS OF LEADING EDGE AND TRAILING EDGE (MOLD) PARTING LINE DATUMS.
THE PRATHER MEASURE REFLECTS THE MOST LIKELY PITCH INTERPRETATION FROM A PITCH MEASUREMENT DEVICE. THAT RESTS AGAINST THE LOWER SURFACE.
// Quoted = Input 是设计桨距， LE-TE是根据模具分型线测量出来的前后缘连线（弦线）对应的桨距，Prather是桨距规(Prather Gauge)测出来的桨距。
SWEEP IS DEFINED WITH (MOLD) LE PARTING LINE.
ZHIGH IS HIGHEST ELEVATION ON TOP SURFACE.  // Z_High
TWIST IS DEFINED WITH (MOLD) LE AND TE PARTING LINE DATUMS.
CHORD IS THE LENGTH BETWEEN (MOLD) LE AND TE PARTING LINES.
CGY IS MASS OFFSET, FORE-AFT. CGZ IS MASS OFFSET, ELEVATION.
```
The additional informations such as density, natural frequency, etc. is dropped. Maybe will be added in further development.

The Performance file has 15 columns, giving `Power`, `Torque`, `Thrust` in both imperial and metric units. Here are the notes in APC corp's file. 

```
J=V/nD (advance ratio)                                                                                                                                                     
Ct=T/(rho * n**2 * D**4) (thrust coef.)                                                                                                                                    
Cp=P/(rho * n**3 * D**5) (power coef.)                                                                                                                                     
Pe=Ct*J/Cp (efficiency)                                                                                                                                                    
V  (model speed in MPH)                                                                                                                                                    
Mach (at prop tip)                                                                                                                                                         
Reyn (at 75% of span)                                                                                                                                                      
FOM (Figure of Merit)  
```


### Notes
Developed and tested with MATLAB R2022b. 

APC propellers performance and geometry data can be found on the website: [https://www.apcprop.com/technical-information/performance-data/](https://www.apcprop.com/technical-information/performance-data/) [https://www.apcprop.com/technical-information/file-downloads/](https://www.apcprop.com/technical-information/file-downloads/)

All the interpolations in the test script files are made with the native ``scatteredInterpolant`` MATLAB function. Given the available performance data, where datasets at lower RPM provide results in an airspeed range narrower than data at higher RPM, it may be wise to disable the extrapolation of the ``scatteredInterpolant`` function. For instance, the ``testFunction.m`` uses the ``scatteredInterpolant`` function with default methods and may provide bumpy plots at the highest velocities, while the ``testPerfo1.m`` and the ``testPerfo2.m`` script files are more advanced, providing data normalization before interpolation, and avoiding jumps in the plots.
