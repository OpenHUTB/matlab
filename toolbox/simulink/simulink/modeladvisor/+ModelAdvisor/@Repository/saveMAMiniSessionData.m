function saveMAMiniSessionData(obj)
    PerfTools.Tracer.logMATLABData('MAGroup','Save MA Mini Session Data',true);

    if~isa(obj.MAObj,'Simulink.ModelAdvisor')
        DAStudio.error('ModelAdvisor:engine:DBCannotAccessMA');
    end

    [recordCellArray,taskCellArray,TaskAdvisorCellArray,ResultDetailsCellArray]=obj.prepareMAData;

    emitDataCell={'recordCellArray',recordCellArray,'taskCellArray',taskCellArray,...
    'TaskAdvisorCellArray',TaskAdvisorCellArray,'MAExplorerPosition',obj.MAObj.MAExplorerPosition};
    obj.overwriteLatestData('MdladvInfo',emitDataCell{:});

    obj.saveMAResultDetails(ResultDetailsCellArray);

    PerfTools.Tracer.logMATLABData('MAGroup','Save MA Mini Session Data',false);
end
