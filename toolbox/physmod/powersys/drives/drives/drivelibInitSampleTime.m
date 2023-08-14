function outputSampleTime=drivelibInitSampleTime(block)










    sys=getfullname(bdroot(block));
    outputSampleTime=[];
    inLibrary=strcmp(get_param(sys,'BlockDiagramType'),'library');
    if~inLibrary
        PowerguiInfo=powericon('getPowerguiInfo',sys,block);
        if isempty(PowerguiInfo.BlockName)



            outputSampleTime=50e-6;
            return
        end
        if PowerguiInfo.Continuous||PowerguiInfo.Phasor
            if~strcmp(get_param(sys,'SimulationStatus'),'stopped')
                error(message('physmod:powersys:drives:InvalidSimulationMode'));


                set_param(PowerguiInfo.BlockName,'SimulationMode','Discrete');

                set_param(PowerguiInfo.BlockName,'SampleTime','1e-6');
                PowerguiInfo.Ts=1e-6;
            else
                return
            end
        end
        outputSampleTime=PowerguiInfo.Ts;



        if ischar(outputSampleTime)
            error(message('physmod:powersys:common:GreaterThan','powergui','Sample time','0'));
        elseif outputSampleTime<=0.0
            error(message('physmod:powersys:common:GreaterThan','powergui','Sample time','0'));
        elseif isempty(outputSampleTime)
            error(message('physmod:powersys:common:GreaterThan','powergui','Sample time','0'));
        end
    end