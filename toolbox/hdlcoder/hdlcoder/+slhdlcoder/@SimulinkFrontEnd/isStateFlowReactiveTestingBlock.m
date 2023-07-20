

function flag=isStateFlowReactiveTestingBlock(blockPath)



    flag=false;

    try
        blockName=hdlgetblocklibpath(blockPath);
        srcLib=strtok(blockName,'/');
        if(~any(strcmpi({'sflib','sltestlib'},srcLib)))
            return;
        end

        chartId=sfprivate('block2chart',blockPath);

    catch mEx %#ok<NASGU>

        return;
    end

    if chartId<=0


        return;
    end

    if Stateflow.STT.StateEventTableMan.isStateEventTableChart(chartId)

        flag=sfprivate('is_reactive_testing_table_chart',chartId);
    end
    return
end


