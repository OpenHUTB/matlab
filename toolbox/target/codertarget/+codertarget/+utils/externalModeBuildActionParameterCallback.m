function val=externalModeBuildActionParameterCallback(hObj,varargin)






    data=get_param(hObj,'TemporaryCoderTargetData');
    if isfield(data,'TypeOfExternalModeRunning')&&...
        isequal(data.TypeOfExternalModeRunning,'stepbystep')
        val='Build';
    else
        val=locGetRegisteredBuildLoadAndRunAction(hObj);
    end


    function ret=locGetRegisteredBuildLoadAndRunAction(hObj)






        entries=codertarget.parameter.getBuildOptionsEntries(hObj);
        entriesFmt=regexprep(lower(entries),'[\s,]','');



        supportedEntriesFmt={'buildloadandrun','buildandrun','buildandexecute'};
        [~,idx]=intersect(entriesFmt,supportedEntriesFmt);
        ret=entries{idx};
    end
end