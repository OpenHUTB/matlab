function BlockChoice=MeasurementBlockInit(block)







    BlockChoice='Complex';

    if nargout==0








        return
    end


    if isequal('running',get_param(bdroot(block),'simulationStatus'))
        return
    end

    Parameters=Simulink.Mask.get(block).Parameters;
    OutputType=strcmp(get_param(block,'MaskNames'),'OutputType')==1;

    if strcmp('on',get_param(block,'PhasorSimulation'))

        Parameters(OutputType).Visible='on';

        switch get_param(block,'OutputType')

        case 'Complex'
            BlockChoice='Complex';

        case{'Real-Imag','Real_Imag'}
            BlockChoice='Real-Imag';

        case{'Magnitude-Angle','Magnitude-angle'}
            BlockChoice='Magnitude-Angle';

        case 'Magnitude'
            BlockChoice='Magnitude';

        end
    else

        Parameters(OutputType).Visible='off';
    end