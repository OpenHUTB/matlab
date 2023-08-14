function inTestObj=copySettings(inTestObj,fromTestObj)




    inId=inTestObj.id;
    fromId=fromTestObj.id;

    cloneProps={'.label','.mlSetupCmd','.mcdcMode','.forceBlockReductionOff','.mldref_enable',...
    '.mldref_excludeTopModel','.mldref_excludedModels','.covExternalEMLEnable',...
    '.covSFcnEnable','.cutPath','.excludeInactiveVariants'};

    copy_cv_obj_properties(inId,fromId,cloneProps);

    inTestObj.filter=fromTestObj.filter;

    inTestObj.settings=fromTestObj.settings;

    settingsFields={'logicBlkShortcircuit',...
    'useTimeInterval','intervalStartTime','intervalStopTime',...
    'covBoundaryRelTol','covBoundaryAbsTol'};
    for idx=1:numel(settingsFields)
        cfn=settingsFields{idx};
        inTestObj.getSlcovSettings.(cfn)=fromTestObj.getSlcovSettings.(cfn);
    end

    function copy_cv_obj_properties(destId,srcId,propList)

        valList=cell(1,length(propList));

        [valList{:}]=cv('get',srcId,propList{:});

        propVal=cell(1,2*length(propList));
        propVal(1:2:end)=propList;
        propVal(2:2:end)=valList;

        cv('set',destId,propVal{:});
