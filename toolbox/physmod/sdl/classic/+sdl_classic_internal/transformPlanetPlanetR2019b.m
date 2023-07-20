function[outData]=transformPlanetPlanetR2019b(inData)





    outData.NewBlockPath='';
    outData.NewInstanceData=[];


    instanceData=inData.InstanceData;
    [parameterNames{1:length(instanceData)}]=instanceData.Name;


    Ratio_index=strcmp('Ratio',parameterNames);
    instanceData(Ratio_index).Name='ratio';


    instanceData(end+1).Name='SourceFile';
    instanceData(end).Value='sdl.gears.planetary_subcomponents.planet_planet';


    outData.NewInstanceData=instanceData;

end


