function cv_remove_sfhighlight(modelcovId)





    [~,mexFiles]=inmem;
    if~any(strcmp(mexFiles,'sf'))
        return;
    end

    try
        modelName=SlCov.CoverageAPI.getModelcovName(modelcovId);
        machineId=sf('find','all','machine.name',modelName);
    catch Mex %#ok<NASGU>
        machineId=[];
    end

    if~isempty(machineId)
        remove_single_machine_highlight(machineId);
        linkMachineIds=get_linked_machines(machineId);
        for mId=linkMachineIds(:)'
            remove_single_machine_highlight(mId);
        end
    end



    function linkMachineIds=get_linked_machines(machineId)

        linkCharts=sf('get',machineId,'.linkCharts');
        linkH=sf('get',linkCharts,'.handle');
        refH=get_param(get_param(linkH,'ReferenceBlock'),'Handle');
        if iscell(refH)
            refH=[refH{:}];
        end

        libModelH=unique(bdroot(refH));

        linkMachineIds=[];
        for modelH=libModelH(:)'
            if iscell(modelH)
                modelName=modelH{1};
            else
                modelName=get_param(modelH,'Name');
            end

            try
                id=sf('find','all','machine.name',modelName);
            catch Mex %#ok<NASGU>
                id=[];
            end

            if~isempty(id)&&id>0
                linkMachineIds(end+1)=id;%#ok<AGROW>
            end
        end


        function remove_single_machine_highlight(machineId)
            sf('ClearAltStyles',machineId);
            sf('Redraw',machineId);


