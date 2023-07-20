function ec_mpt_listener_cb(blockDiagramObj,listenerObj)













    dataObjectUsage=[];

    mdlRefTargetType=...
    get_param(blockDiagramObj.getFullName,'ModelReferenceTargetType');


    isModelRefTarget=~strcmp(mdlRefTargetType,'NONE');




    if ec_mpt_enabled(blockDiagramObj.getFullName)

        ec_debug=0;

        try
            eventName=listenerObj.EventName;

            if strcmp(eventName,'EnginePostRTWCompFileNames')==1


                dataObjectUsage=...
                get_param(blockDiagramObj.getFullName,'DataObjectsUsage');


                if ec_debug==1
                    buf=ec_data_user_dump(dataObjectUsage);
                    disp(buf);
                end

                modelName=blockDiagramObj.getFullName;
                isRightClickBuild=false;


                h=blockDiagramObj.SubsystemHdlForRightClickBuild;
                if~isempty(h)&&h>0
                    isRightClickBuild=true;
                    while~isempty(get_param(h,'Parent'))
                        h=get_param(get_param(h,'Parent'),'Handle');
                    end
                    modelName=get_param(h,'Name');
                end


                if isModelRefTarget
                    mdl_infoStruct=coder.internal.infoMATFileMgr('load','binfo',...
                    modelName,'RTW');
                else
                    if~isRightClickBuild
                        mdl_infoStruct=coder.internal.infoMATFileMgr('load','binfo',...
                        modelName,'NONE');
                    else

                        mdl_infoStruct=coder.internal.infoMATFileMgr('load','binfo',...
                        blockDiagramObj.getFullName,'NONE');
                    end
                end

                dataObjectOwnershipRecord.ModelNames=mdl_infoStruct.modelRefsAll;
                dataObjectOwnershipRecord.ModelNames{end+1}=modelName;



                mdlRefs=mdl_infoStruct.modelRefs;
                bld_infoStructsOfmdlRefs={};
                dataObjectMapSharednessInMdlRefs=containers.Map('KeyType','char',...
                'ValueType','any');
                for k=1:length(mdlRefs)
                    bld_infoStructsOfmdlRefs{k}=coder.internal.infoMATFileMgr(...
                    'load','binfo',...
                    mdlRefs{k},'RTW');%#ok

                    loc_updateDataObjectSharednessMapUponMdlRefs(dataObjectMapSharednessInMdlRefs,...
                    bld_infoStructsOfmdlRefs{k}.DataObjectAutoAndFileScopeSharedness);
                end


                ec_symbol_db_reg(dataObjectUsage,blockDiagramObj.getFullName);

                errMsg='';
                try
                    [dataObjectUsage,newDataObjectMapStruct]=ec_data_placement(...
                    dataObjectUsage,blockDiagramObj.getFullName,modelName,...
                    dataObjectMapSharednessInMdlRefs);


                    newDataObjectOwnershipMap=newDataObjectMapStruct.ExportedScopeOwnership;
                    newDataObjectSharednessMap=newDataObjectMapStruct.AutoAndFileScopeSharedness;




                    namesOfDataObjectsToCheck=newDataObjectOwnershipMap.keys;
                    for k=1:length(mdlRefs)

                        newDataObjectOwnershipMap=loc_updateDataObjectOwnerSettingMap(...
                        newDataObjectOwnershipMap,...
                        bld_infoStructsOfmdlRefs{k}.DataObjectOwnerSetting);
                    end

                    dataObjectOwnershipRecord.OwnershipMap=newDataObjectOwnershipMap;

                catch e
                    errMsg=e.message;
                end


                if~isempty(errMsg)

                    dataObjectUsage.UsageCheckError.Message=errMsg;
                else


                    [errMsg,errId]=loc_verifyDataObjectOwnershipSetting(dataObjectOwnershipRecord,dataObjectUsage,...
                    namesOfDataObjectsToCheck,modelName,isModelRefTarget);
                    if~isempty(errMsg)
                        if strcmp(errId,'Simulink:mpt:MPTInvalidOwnerSettingForInternalData')
                            dataObjectUsage.UsageCheckError.Message=DAStudio.message(errId,modelName,errMsg);
                        else
                            dataObjectUsage.UsageCheckError.Message=DAStudio.message(errId,errMsg);
                        end
                    else


                        [errMsg,errId]=loc_verifyDataObjectFileScopeSharedness(...
                        newDataObjectSharednessMap);
                        if~isempty(errMsg)
                            dataObjectUsage.UsageCheckError.Message=DAStudio.message(errId,modelName,errMsg);
                        end
                    end
                end



                set_param(blockDiagramObj.getFullName,'DataObjectsUsage',dataObjectUsage);


                if isModelRefTarget
                    if isempty(errMsg)

                        dataObjectOwnerSettingStruct=loc_getdataObjectOwnerSettingInfoStruct(...
                        dataObjectOwnershipRecord.OwnershipMap);

                        dataObjectSharednessStruct=loc_getdataObjectSharednessInfoStruct(...
                        newDataObjectSharednessMap);
                    else

                        dataObjectOwnerSettingStruct=loc_getEmptyDataObjectOwnerSettingStruct();
                        dataObjectSharednessStruct=loc_getEmptyDataObjectSharednessStruct();
                    end


                    coder.internal.infoMATFileMgr(...
                    'updateField','binfo',...
                    modelName,'RTW','DataObjectOwnerSetting',...
                    dataObjectOwnerSettingStruct);


                    coder.internal.infoMATFileMgr(...
                    'updateField','binfo',...
                    modelName,'RTW','DataObjectAutoAndFileScopeSharedness',...
                    dataObjectSharednessStruct);
                end

            end

        catch ME

            rethrow(ME);
        end
    end

    rtwprivate('rtwattic','AtticData','dataObjectUsage',dataObjectUsage);




    function ownerSettingStruct=loc_getdataObjectOwnerSettingInfoStruct(dataObjectOwnerMap)
        ownerSettingStruct=loc_getEmptyDataObjectOwnerSettingStruct();
        names=dataObjectOwnerMap.keys;
        for k=1:length(names)
            value=dataObjectOwnerMap(names{k});

            ownerSettingStruct(k).name=names{k};
            ownerSettingStruct(k).type=value.Type;
            ownerSettingStruct(k).rootIOSignal=value.RootIOSignal;
            ownerSettingStruct(k).dataStore=value.DataStore;
            ownerSettingStruct(k).owner=value.Owner;
            ownerSettingStruct(k).ownerFound=value.OwnerFound;
        end



        function dataObjectOwnerMap=loc_updateDataObjectOwnerSettingMap(dataObjectOwnerMap,s_refmdl)

            assert(isfield(s_refmdl,'name'));
            for k=1:length(s_refmdl)


                dataName=s_refmdl(k).name;
                s.Type=s_refmdl(k).type;
                s.RootIOSignal=s_refmdl(k).rootIOSignal;
                s.DataStore=s_refmdl(k).dataStore;
                s.Owner=s_refmdl(k).owner;
                s.OwnerFound=s_refmdl(k).ownerFound;
                if~dataObjectOwnerMap.isKey(dataName)

                    dataObjectOwnerMap(dataName)=s;
                else

                    value=dataObjectOwnerMap(dataName);
                    assert(value.Type==s.Type,...
                    ['data ''',dataName,''' fails assertion on DataObjectType']);
                    assert(value.DataStore==s.DataStore,...
                    ['data ''',dataName,''' fails assertion on DataStore']);
                    assert(strcmp(value.Owner,s.Owner),...
                    ['data ''',dataName,''' fails assertion on DataOwner']);
                    if s.OwnerFound
                        value.OwnerFound=true;
                    end


                    if value.Type==1
                        value.PropagatedSignalLevel=value.PropagatedSignalLevel+1;
                    end
                    dataObjectOwnerMap(dataName)=value;
                end
            end


            function s=loc_getEmptyDataObjectOwnerSettingStruct()
                s=struct('name',{},'type',{},'rootIOSignal',{},'dataStore',{},'owner',{},'ownerFound',{});



                function result=loc_isGlobalSignal(theMapRecord,dataObjectUsage,modelName)
                    dataObjName=theMapRecord.DataObjectName;

                    result=false;
                    found=false;
                    for i=1:length(dataObjectUsage.DataObject)
                        if(1==strcmp(dataObjName,dataObjectUsage.DataObject(i).Name))
                            found=true;
                            break;
                        end
                    end

                    if(found)
                        findVarsResult=Simulink.findVars(modelName,'Name',dataObjectUsage.DataObject(i).Name,...
                        'SearchMethod','Cached');

                        result=strcmp(findVarsResult.SourceType,'base workspace');

                    end



                    function[errMsg,errId]=loc_verifyDataObjectOwnershipSetting(ownershipRecord,dataObjectUsage,...
                        dataNames,modelName,isModelRefTarget)

                        errMsg='';
                        errId='';


                        modelNames=ownershipRecord.ModelNames;
                        typeNames={'Signal','Parameter','State'};

                        errMsg1='';
                        errMsg2='';
                        errMsg3='';

                        paramList={};
                        for idx=1:length(dataNames)
                            dataName=dataNames{idx};
                            thisMapRecord=ownershipRecord.OwnershipMap(dataName);
                            if thisMapRecord.Type==2

                                paramList{end+1}=dataName;%#ok
                            end
                        end


                        dataUsedByModelsMap=containers.Map('KeyType','char','ValueType','any');

                        for idx=1:length(dataNames)
                            dataName=dataNames{idx};
                            thisMapRecord=ownershipRecord.OwnershipMap(dataName);


                            typeIdx=thisMapRecord.Type;
                            assert(typeIdx>=1&&typeIdx<=3);
                            typeName=typeNames{typeIdx};

                            dataObjName=thisMapRecord.DataObjectName;

                            mwks=get_param(modelName,'ModelWorkspace');

                            if strcmp(typeName,'Parameter')&&~isempty(dataObjName)&&mwks.hasVariable(dataObjName)
                                isOwnerValid=strcmp(thisMapRecord.Owner,"")||strcmp(thisMapRecord.Owner,modelName);
                                if~isOwnerValid
                                    errMsg3=[errMsg3,DAStudio.message('Simulink:mpt:MPTInvalidOwnerSettingEntry',typeName,dataObjName,thisMapRecord.Owner)];
                                end
                            else
                                if thisMapRecord.OwnerFound
                                    assert(ismember(thisMapRecord.Owner,modelNames));
                                    if strcmp(modelName,thisMapRecord.Owner)&&isModelRefTarget
                                        if strcmp(typeName,'Parameter')

                                            errMsg2=[errMsg2,loc_verifyModelRefOwnerUsesParamData(dataName,...
                                            typeName,thisMapRecord.Owner,paramList,dataUsedByModelsMap)];%#ok
                                        end
                                    end
                                    continue;
                                end


                                ownerName=thisMapRecord.Owner;


                                if(typeIdx==1&&~thisMapRecord.RootIOSignal)...
                                    ||(typeIdx==3&&~thisMapRecord.DataStore&&~loc_isGlobalSignal(thisMapRecord,dataObjectUsage,modelName))



                                    errMsg1=[errMsg1,loc_errorOwnerNotOnHierarchy(dataName,typeName,ownerName)];%#ok
                                end


                                if~isModelRefTarget






                                    errMsg2=[errMsg2,loc_verifyOwnerNotOnHierarchy(dataName,typeName,ownerName,modelNames)];%#ok
                                end
                            end
                        end

                        if~isempty(errMsg1)
                            errMsg=errMsg1;
                            errId='Simulink:mpt:MPTInvalidOwnerSettingForInternalData';
                            return;
                        end

                        if~isempty(errMsg2)
                            errMsg=errMsg2;
                            errId='Simulink:mpt:MPTInvalidOwnerSettingForBoundaryData';
                            return;
                        end

                        if~isempty(errMsg3)
                            errMsg=errMsg3;
                            errId='Simulink:mpt:MPTInvalidOwnerSettingForMdlWksData';
                            return;
                        end


                        function errMsg=loc_verifyOwnerNotOnHierarchy(dataName,dataType,dataOwner,modelNames)
                            errMsg='';
                            if ismember(dataOwner,modelNames)


                                errMsg=DAStudio.message('Simulink:mpt:MPTInvalidOwnerSettingEntry',dataType,dataName,dataOwner);
                            end


                            function errMsg=loc_errorOwnerNotOnHierarchy(dataName,dataType,dataOwner)
                                errMsg=DAStudio.message('Simulink:mpt:MPTInvalidOwnerSettingEntry',dataType,dataName,dataOwner);



                                function errMsg=loc_verifyModelRefOwnerUsesParamData(dataName,dataType,...
                                    ownerModel,paramList,dataUsedByModelsMap)
                                    errMsg='';
                                    if dataUsedByModelsMap.isKey(ownerModel)

                                        dataList=dataUsedByModelsMap(ownerModel);
                                    else
                                        dataList=ec_get_usedWSParams(ownerModel,paramList);
                                        dataUsedByModelsMap(ownerModel)=dataList;%#ok
                                    end

                                    if~ismember(dataName,dataList)
                                        errMsg=DAStudio.message('Simulink:mpt:MPTInvalidOwnerSettingEntry',dataType,dataName,ownerModel);
                                    end


                                    function loc_updateDataObjectSharednessMapUponMdlRefs(dataObjectSharednessMap,s_refmdl)

                                        assert(isfield(s_refmdl,'name'));
                                        for k=1:length(s_refmdl)


                                            dataName=s_refmdl(k).name;
                                            s.Type=s_refmdl(k).type;
                                            s.RootIOSignal=s_refmdl(k).rootIOSignal;
                                            s.DataStore=s_refmdl(k).dataStore;
                                            s.DataScope=s_refmdl(k).dataScope;
                                            s.Shared=s_refmdl(k).shared;

                                            if~dataObjectSharednessMap.isKey(dataName)
                                                dataObjectSharednessMap(dataName)=s;
                                            else


                                                value=dataObjectSharednessMap(dataName);
                                                assert((value.Type==s.Type),...
                                                ['data ''',dataName,''' fails assertion on DataObjectType']);
                                                assert((value.RootIOSignal==s.RootIOSignal),...
                                                ['data ''',dataName,''' fails assertion on RootIOSignal']);
                                                assert((value.DataStore==s.DataStore),...
                                                ['data ''',dataName,''' fails assertion on DataStore']);
                                                assert(strcmp(value.DataScope,s.DataScope),...
                                                ['data ''',dataName,''' fails assertion on DataScope']);
                                                if s.Shared
                                                    value.Shared=true;
                                                end
                                                dataObjectSharednessMap(dataName)=value;
                                            end

                                        end


                                        function s=loc_getEmptyDataObjectSharednessStruct()
                                            s=struct('name',{},'type',{},'rootIOSignal',{},'dataStore',{},'dataScope',{},'shared',{});




                                            function[errMsg,errId]=loc_verifyDataObjectFileScopeSharedness(...
                                                dataObjectAutoAndFileScopeSharednessMap)

                                                errMsg='';
                                                errId='';

                                                dataNames=dataObjectAutoAndFileScopeSharednessMap.keys;
                                                invalidNames='';
                                                for idx=1:length(dataNames)
                                                    dataName=dataNames{idx};
                                                    thisMapRecord=dataObjectAutoAndFileScopeSharednessMap(dataName);



                                                    if strcmp(thisMapRecord.DataScope,'File')&&(thisMapRecord.Shared&&~thisMapRecord.IsDefaultMapped)
                                                        if isempty(invalidNames)
                                                            invalidNames=dataName;
                                                        else
                                                            invalidNames=[invalidNames,', ',dataName];%#ok
                                                        end
                                                    end
                                                end

                                                if~isempty(invalidNames)
                                                    errMsg=invalidNames;
                                                    errId='RTW:tlc:InvalidFileScopeForSharedData';
                                                    return;
                                                end



                                                function sharednessStruct=loc_getdataObjectSharednessInfoStruct(dataObjectSharednessMap)
                                                    sharednessStruct=loc_getEmptyDataObjectSharednessStruct();
                                                    names=dataObjectSharednessMap.keys;
                                                    for k=1:length(names)
                                                        value=dataObjectSharednessMap(names{k});
                                                        sharednessStruct(k).name=names{k};
                                                        sharednessStruct(k).type=value.Type;
                                                        sharednessStruct(k).rootIOSignal=value.RootIOSignal;
                                                        sharednessStruct(k).dataStore=value.DataStore;
                                                        sharednessStruct(k).dataScope=value.DataScope;
                                                        sharednessStruct(k).shared=value.Shared;
                                                    end



