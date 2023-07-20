function hilite_partition(mdl,taskName)



    modelName=get_param(mdl,'Name');
    tcg=sltp.TaskConnectivityGraph(modelName);

    rateTaskMap=tcg.getCachedRateIndexTaskIdxMap;

    stl=Simulink.SampleTimeLegend;

    for rateIdx=0:tcg.getNumRates(taskName)-1
        displayIndex=tcg.getRateDisplayIndex(taskName,rateIdx);
        sourceBlocks=tcg.getSourceBlockSIDs(taskName);
        colorBits=tcg.getRateColor(taskName,rateIdx);


        idx=[rateTaskMap.rateIdx]==displayIndex;
        blocks=[rateTaskMap(idx).AllBlocks(:).Path];


        blocks=horzcat(blocks,...
        cell2mat(Simulink.ID.getHandle(strcat([modelName,':'],sourceBlocks))'));

        if~isempty(blocks)

            hilite_data=struct;
            hilite_data.modelName=modelName;
            hilite_data.colorRGB=round(double([...
            bitand(bitshift(colorBits,-24),255),...
            bitand(bitshift(colorBits,-16),255),...
            bitand(bitshift(colorBits,-8),255)...
            ])/255,2);
            hilite_data.Value=tcg.getRateSpec(taskName,rateIdx);
            hilite_data.Annotation={tcg.getRateAnnotation(taskName,rateIdx)};
            hilite_data.type='all';

            hilite_data.hilitePathSet=blocks;


            stl.hilite_system_legend(hilite_data,rateIdx>0);
        end
    end


    MG2.Util.waitForGui;
end
