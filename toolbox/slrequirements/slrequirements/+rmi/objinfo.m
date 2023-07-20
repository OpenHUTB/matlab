function[navcmd,dispStr,bitmap]=objinfo(obj)


















    if builtin('_license_checkout','Simulink_Requirements','quiet')
        error(message('Slvnv:reqmgt:util_objinfo:LicenseRequired'));
    end

    linkSettings=rmi.settings_mgr('get','linkSettings');

    if ischar(obj)||length(obj)==1

        if nargout==1
            navcmd=one_object_info(obj,linkSettings.modelPathStorage);
        else
            [navcmd,dispStr]=one_object_info(obj,linkSettings.modelPathStorage);
        end
    else



        numObjs=length(obj);
        dispStrings=cell(numObjs,1);
        models=cell(numObjs,1);
        guids=cell(numObjs,1);
        idxs=cell(numObjs,1);
        for i=1:numObjs
            [~,dispStrings{i},models{i},guids{i},idxs{i}]=one_object_info(obj(i),linkSettings.modelPathStorage);
        end
        [uniqueModels,~,map]=unique(models);
        numModels=length(uniqueModels);
        all_objects_info=['''',uniqueModels{1},''''];
        for i=1:numModels
            if i>1
                all_objects_info=[all_objects_info,',''!',uniqueModels{i},''''];%#ok<AGROW>
            end
            myGuids=guids(map==i);
            myIdxs=idxs(map==i);
            for j=1:length(myGuids)
                if isempty(myIdxs{j})
                    all_objects_info=[all_objects_info,',''',myGuids{j},''''];%#ok<AGROW>
                else
                    all_objects_info=[all_objects_info,',''',myGuids{j},''',',myIdxs{j}];%#ok<AGROW>
                end
            end
        end
        navcmd=['rmiobjnavigate(',all_objects_info,');'];


        dispStr=[num2str(numObjs),' links: ',dispStrings{1}];
        for i=2:length(dispStrings)
            dispStr=[dispStr,', ',dispStrings{i}];%#ok<AGROW>
        end
    end

    if nargout==3&&linkSettings.slrefCustomized
        bitmap=linkSettings.slrefUserBitmap;
    else
        bitmap='';
    end
end


function[navcmd,dispStr,modelStr,guidstr,idx]=one_object_info(obj,modelPathStorage)

    navcmd='';
    dispStr='';
    modelStr='';
    guidstr='';
    idx='';

    isZCPort=sysarch.isZCPort(obj);


    if ischar(obj)

        matches=regexp(obj,'^(\d+)@(.+$)','tokens');
        if~isempty(matches)
            obj=matches{1}{2};
            idx=matches{1}{1};
        end
    end


    if rmide.isDataEntry(obj)
        [navcmd,dispStr,modelStr,guidstr]=rmide.getObjInfo(obj,modelPathStorage);
        return;
    end


    if ischar(obj)&&rmisl.isHarnessIdString(obj)
        [~,objH,info]=rmisl.resolveObjInHarness(obj);
        if isempty(objH)
            dispStr=getString(message('Slvnv:slreq:HarnessObjectNotAvailable',info));
        else
            [navcmd,dispStr,modelStr,guidstr,idx]=one_object_info(objH,modelPathStorage);
        end
        return;
    end


    if rmifa.isFaultInfoObj(obj)
        [navcmd,dispStr,modelStr,guidstr]=rmifa.getObjInfo(obj,modelPathStorage);
        return;
    end

    try
        if isZCPort
            modelH=bdroot(obj);
            objH=obj;
            isSf=false;
            isSigBuilder=false;
        else
            [modelH,objH,isSf,isSigBuilder]=rmisl.resolveObj(obj);
        end
    catch ME %#ok<NASGU>
        dispStr=getString(message('Slvnv:rmi:resolveobj:ERRORFailedResolveObject'));
        return
    end

    modelName=get_param(modelH,'Name');
    modelName4nav=modelName;




    if rmidata.isExternal(modelH)
        if isZCPort
            guidstr=sysarch.getIdForLinking(objH);
        else
            [rmName,guidstr]=rmidata.getRmiKeys(objH,isSf);



            if~strcmp(rmName,modelName)&&rmisl.isHarnessIdString(guidstr)
                modelName4nav=rmName;
            end
        end
    else




        if~isSf&&objH~=modelH
            if strcmp(get_param(objH,'StaticLinkStatus'),'implicit')
                referenceBlock=get_param(objH,'ReferenceBlock');
                libName=strtok(referenceBlock,'/');
                load_system(libName);
                objH=get_param(referenceBlock,'Handle');
                [navcmd,dispStr,modelStr,guidstr]=one_object_info(objH,modelPathStorage);
                return;
            end
        end
        if isSf
            if isa(obj,'Stateflow.Data')
                reqStr='';
            else
                reqStr=sf('get',objH,'.requirementInfo');
            end
        else
            reqStr=get_param(objH,'RequirementInfo');
        end
        if isempty(reqStr)

            if nargout>1

                preserve_dirty=Simulink.PreserveDirtyFlag(modelH,'blockDiagram');
            else
                preserve_dirty=[];
            end
            guidstr=rmi.guidGet(objH);

            if isempty(guidstr)
                if strcmpi(get_param(modelH,'BlockDiagramType'),'library')

                    if strcmpi(get_param(modelH,'lock'),'on')
                        if rmisl.isUnlocked(modelH,(nargout>1))
                            guidstr=rmi.guidGet(objH);
                        end
                        if isempty(guidstr)&&nargout==1


                            error(message('Slvnv:rmisl:isUnlocked:LibraryIsLocked'));
                        end
                    end
                end
            end
            delete(preserve_dirty);
        else
            guidstr=reqmgt('guidGet',reqStr);
        end
    end

    if strcmp(modelPathStorage,'absolute')
        modelStr=get_param(modelName4nav,'FileName');
    else
        [~,mdlName,mdlExt]=rmisl.modelFileParts(modelName4nav,false);
        modelStr=[mdlName,mdlExt];
    end


    if isempty(guidstr)
        navcmd='';
        if isSf
            msg=message('Slvnv:reqmgt:util_objinfo:UnsupportedStateflowObj',sf('get',objH,'.name'));
            warning(msg);
            dispStr=getString(msg);
            return;
        elseif strcmp(get_param(objH,'type'),'block_diagram')


        else
            msg=message('Slvnv:reqmgt:util_objinfo:UnsupportedSimulinkObj',get_param(objH,'Name'));
            warning(msg);
            dispStr=getString(msg);
            return;
        end
    end

    if isSigBuilder
        if isempty(idx)
            actIdx=signalbuilder(objH,'ActiveGroup');
            idx=num2str(actIdx);
        end
        navcmd=['rmiobjnavigate(''',modelStr,''',''',guidstr,''',',idx,');'];
    else
        navcmd=['rmiobjnavigate(''',modelStr,''',''',guidstr,''');'];
    end

    if nargout<2
        return;
    end

    if isSf
        objIsa=sf('get',objH,'.isa');
        sfisa=rmisf.sfisa;
        switch(objIsa)
        case sfisa.chart
            chartId=objH;

            sfr=sfroot;
            chartObj=sfr.idToHandle(chartId);
            if isa(chartObj,'Stateflow.ReactiveTestingTableChart')
                objType=getString(message('Slvnv:rmi:resolveobj:TestSequence'));
            elseif isa(chartObj,'Stateflow.StateTransitionTableChart')
                objType=getString(message('Slvnv:rmi:resolveobj:StateTransitionTable'));
            else
                objType='Chart';
            end
            objName='';
        case sfisa.state
            [chartId,objName]=sf('get',objH,'.chart','.name');
            if sfprivate('is_part_of_reactive_testing_table_chart',objH)
                objType='Step';
            else
                objType='State';
            end
        case sfisa.transition
            chartId=sf('get',objH,'.chart');
            if Stateflow.ReqTable.internal.isRequirementsTable(chartId)
                objType='Specification Block';
                objName=Stateflow.ReqTable.internal.TableManager.getSummaryFromObject(chartId,objH);
            else
                objType='Transition';
                objName=sf('get',objH,'.labelString');
            end
        end

        if objIsa~=sfisa.data
            objParent=sf('get',chartId,'.name');
            if isempty(objName)
                dispStr=[modelName,'/',objParent,' (',objType,')'];
            else
                objName=cr2space(objName);
                dispStr=[modelName,'/',objParent,'/',objName,' (',objType,')'];
            end


            if length(dispStr)>60
                parentsList=strsplit(objParent,'/');
                if length(parentsList)>1


                    dispStr=strrep(dispStr,['/',objParent],['/.../',parentsList{end}]);
                end
            end

        else
            dispStr=modelName;
        end
    else
        fullname=getfullname(objH);
        if sysarch.isComponent(objH)
            objType='Component';
        elseif sysarch.isZCPort(objH)
            objType='Port';
            fullname=sysarch.getSummary(guidstr,modelName);
        else
            objType=rmisl.slBlockType(objH);
        end
        if length(fullname)>60
            if strcmp(objType,'annotation')
                objName=cr2space(get(objH,'PlainText'));
            else
                objName=cr2space(get_param(objH,'Name'));
            end
            parentH=get_param(get_param(objH,'parent'),'Handle');
            if(parentH==modelH)
                dispStr=[modelName,'/',objName,'  (',objType,')'];
            else
                objParent=cr2space(get_param(parentH,'Name'));
                grandparentH=get_param(get_param(parentH,'parent'),'Handle');
                if(grandparentH==modelH)
                    dispStr=[modelName,'/',objParent,'/',objName,'  (',objType,')'];
                else
                    dispStr=[modelName,'/.../',objParent,'/',objName,'  (',objType,')'];
                end
            end
        else
            dispStr=[cr2space(fullname),'  (',objType,')'];
        end
    end
end

function out=cr2space(out)
    out(out==newline)=' ';
end
