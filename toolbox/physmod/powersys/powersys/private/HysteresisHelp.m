function[HelpText,HelpTitle]=HysteresisHelp(language)






    tool={'The Hysteresis design tool is a graphical user interface (GUI) that allow you to view and edit a hysteresis';
    'characteristic for the saturable core of the Saturable Transformer blocks. It is defined by a set of parameters';
    'that you edit with this GUI. The characteristic includes the saturation region located at the limits of the';
    'hysteresis loop. The characteristic is saved into MAT file that are used by the Saturable Transformer, the Three-Phase';
    'Two Windings Transformer, and the Three-Phase Three Windings Transformer blocks.';
    ' ';
    'You can build as many characteristics as you want and save them in different MAT files names.';
    'You can use the same charactersitic for all of your transformer blocks, or you can use different ones';
    'for each transformer block in the circuit.';
    ' ';
    'You need to check the "Simulate Hysteresis" checkbox in the masks of the transformer blocks and specify a MAT file';
    'to be used by the model';
    ' ';
    'A default characteristic is first displayed when you open the GUI. You can load an exisiting hystersis curve';
    'via the "File" menu. This default characteristic is stored in the demo directory of the PSB.'};

    parameters={'The following parameters need to be defined for the hysteresis characteristic:';
    ' ';
    'Segments';
    '   The number of linear segments used to define the hysteresis loop.';
    'Remnant flux';
    '   The positive flux for a null current.';
'   It is identified by a + mark in the plot.'
    'Saturation flux';
    '   The positive value of the flux that limits the hysteresis loop and where';
    '   the saturation begin. It is identified by a * mark in the plot.';
    'Saturation current';
    '   The current value corresponding to the Saturation flux value. It is identified';
    '   by a * mark in the plot.';
    'Coercive current';
    '   The positive value of the current for a null flux. It is identified by a x';
    '   mark in the plot.';
    'Flux slope at the coercive current';
    '   The slope of the flux at the coercive current point.';
    'Saturation region currents';
    '   Specify a vector of current values that defines the saturation region of the';
    '   characteristic. The first point must be equal to the Saturation current value.';
    '   The number of specified points must be equal to the number of points specified in the';
    '   Saturation region fluxes vector. You only need to specify the positive region of the saturation.';
    'saturation region fluxes';
    '   Specify a vector of flux values that defines the saturation region of the';
    '   characteristic. The first point must be equal to the Saturation flux value.';
    '   The number of specified points must be equal to the number of points specified in the';
    '   Saturation region currents vector. You only need to specify the positive region of the saturation.';
    'Transformer Nominal parameters';
    '   The nominal parameters of the target transformer. These parameters are used to convert';
    '   the units from pu to SI, or from SI to pu. Enter the nominal power, the phase-to-ground';
    '   RMS voltage, and the nominal frequency of the transformer.';
    'Parameter units';
    '   Select pu to convert the SI units into pu units. Select SI to convert the pu';
    '   units into SI units. The conversion is based on the specified nominal parameters.';
    ' ';
    'The last two parameters are used to convert the parameters from pu to SI units. It means that you can first enter';
    'The pu parameters, then convert them to SI units based on the nominal transformer parameters. You can also start by';
'entering the SI parameters and convert them later to pu parameters.'
    ' ';
    'When the parameters are entered you can click on the "Display" button to visualize the hysteresis characteristic.';
    'Don''t forget to save it in a MAT file if you want to use it in a simulation.'};

    File={'You can load or save hysteresis characteristics in different MAT files.'};

    EMTP={'You can save the hysteresis characteristic in a format suitable to the EMTP (Electromagnetic Transient Program)';
    'Type 96 element (Pseudononlinear Hysteretic Reactor) in a text file to be imported in the EMTP data file.';
    'The last point of the characteristic is defined as the second point of the saturation region data.'};

    tolerances={'The tolerances tool is an advanced tool mainly used to minimize the generation';
    'of superfluous very small internal loops or new trajectories because they have little effect and';
    'they consume computer memory space (the model can memorize at any time up to 50 embedded minor loops).';
    'The TOL_F parameter is the tolerance value used to detect if after a flux reversal the operating point remains';
    'on the same minor loop or a new embedded loop is created. The smaller the value lesser is the effect on the normal';
    'trajectory behavior. The bigger the value lesser is the generated number of embedded minor loops. Try a value between';
    'zero and 0.01% of the maximum flux Fs. Finally, when the distance between the I coordinate of the actual point of reversal';
    'and the previous-to-last is less than TOL_I then evolution within these two points will follow a line-segment ';
    'instead of a loop.'};

    Animation={'The animation tool can be used to visualize how the simulation of the';
    'hysteresis is performed by Simscape Electrical Specialized Power Systems. This is an optional tool that is not necessary';
    'for the model parameterization. The initial trajectory will be calculated according to the defined';
    'Start flux and the Sign of the slope (dF/dI). The model assumes that the last reversal';
'point before Start was situated on the major loop. The operating point will travel till the Stop'
    'flux. Define a new Stop flux and push the Simulation button or the Reset button to restart'};

    HelpText={'HYSTERESIS TOOL',tool;
    'PARAMETERS',parameters;
    'MENU: FILE',File;
    'MENU:  SPECIAL --> EMTP',EMTP;
    'MENU:  SPECIAL --> TOOLS --> TOLERANCES',tolerances;
    'MENU:  SPECIAL --> TOOLS --> ANIMATION',Animation};

    HelpTitle='Help for the Hysteresis design tool';