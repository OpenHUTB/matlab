function[userDataClassName,CSCSource]=...
    getTargetUserDataSpecs(topFilespec,filespecs,configsetEntryIDs,...
    entryValueClsName)%#ok 






















    userDataClassName='';
    CSCSource='';

    assert(numel(configsetEntryIDs)==numel(filespecs));


    if numel(filespecs)~=numel(unique(filespecs))
        return;
    end
    dd=Simulink.dd.open(topFilespec);
    closure=dd.DependencyClosure;
    if numel(filespecs)~=numel(closure)
        return;
    end









    assert(~isempty(configsetEntryIDs));
    configset=Simulink.dd.getConfigsetObj(topFilespec,configsetEntryIDs{1});
    sysfile=get_param(configset,'SystemTargetFile');
    for i=2:numel(configsetEntryIDs)
        thisConfigset=Simulink.dd.getConfigsetObj(topFilespec,configsetEntryIDs{i});
        if~strcmp(sysfile,get_param(thisConfigset,'SystemTargetFile'))
            return;
        end
    end


    if slfeature('SLDataDictionarySetCSCSource')>0
        userDataClassName=get_param(configset,'UserDataClassName');
    end


    if slfeature('SLDataDictionarySetUserData')>0
        CSCSource=get_param(configset,'CSCSource');
    end

end

