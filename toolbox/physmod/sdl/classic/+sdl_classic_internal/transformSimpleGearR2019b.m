function[outData]=transformSimpleGearR2019b(inData)





    outData.NewBlockPath='';
    outData.NewInstanceData=[];


    instanceData=inData.InstanceData;
    [parameterNames{1:length(instanceData)}]=instanceData.Name;


    Ratio_index=strcmp('Ratio',parameterNames);
    instanceData(Ratio_index).Name='ratio';


    Reversing_index=strcmp('Reversing',parameterNames);
    Reversing=instanceData(Reversing_index).Value;

    if strcmp(Reversing,'off')
        rotation_direction='1';
    else
        rotation_direction='2';
    end

    instanceData(Reversing_index).Name='rotation_direction';
    instanceData(Reversing_index).Value=rotation_direction;


    instanceData(end+1).Name='SourceFile';
    instanceData(end).Value='sdl.gears.simple_gear';


    outData.NewInstanceData=instanceData;

end
