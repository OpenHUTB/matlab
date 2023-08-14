function check_for_non_contig_outputs_from_slfcns(machineId)


















    r=sfroot;
    machineH=r.idToHandle(machineId);
    charts=machineH.find('-isa','Stateflow.Chart');

    err=0;
    for iCh=1:length(charts)
        err=checkInsideChart(charts(iCh))||err;
    end



    if err
        DAStudio.error('Stateflow:slinsf:NonContiguousError');
    end

    function err=checkInsideChart(chartH)
        simFcns=chartH.find('-isa','Stateflow.SLFunction');
        err=0;
        for i=1:length(simFcns)
            err=checkInsideSLFunction(simFcns(i))||err;
        end
    end

    function err=checkInsideSLFunction(simFcnH)
        err=0;
        subsysH=simFcnH.getDialogProxy;
        outputPorts=subsysH.find('-depth',1,'-isa','Simulink.Outport');
        for i=1:length(outputPorts)
            err=checkAnOutputPort(outputPorts(i))||err;
        end

    end

    function err=checkAnOutputPort(outputH)
        sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
        try
            actSources=outputH.getActualSrc;
        catch ME
            if~strcmpi(ME.identifier,'Simulink:Engine:EI_EINotEnabled')
                rethrow(ME);
            end









            actSources=outputH.getActualSrc;
        end


        if size(actSources,1)<2
            err=0;
            return
        end



        err=1;

        parent=outputH.Parent;
        name=outputH.Name;

        message=DAStudio.message('Stateflow:translate:NonContiguousOutputPort',name,parent);


        sldiagviewer.reportError(message,'Component','Simulink','Category','Interface');
    end

end
