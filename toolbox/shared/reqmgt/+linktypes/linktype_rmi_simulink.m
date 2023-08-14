function linkType=linktype_rmi_simulink




    linkType=ReqMgr.LinkType;
    linkType.Registration=mfilename;


    linkType.Label=getString(message('Slvnv:reqmgt:linktype_rmi_simulink:LinkableDomainLabel'));


    linkType.IsFile=0;
    linkType.Extensions={'.mdl','.slx'};


    linkType.LocDelimiters='@';
    linkType.Version='';


    linkType.NavigateFcn=@NavigateFcn;
    linkType.SelectionLinkFcn=@SelectionLinkFcn;
    linkType.BrowseFcn=@BrowseObjects;
    linkType.ContentsFcn=@ContentsFcn;
    linkType.IsValidDocFcn=@IsValidDocFcn;
    linkType.IsValidIdFcn=@IsValidIdFcn;
    linkType.IsValidDescFcn=@IsValidDescFcn;
    linkType.CreateURLFcn=@CreateURLFcn;
    linkType.UrlLabelFcn=@UrlLabelFcn;
    linkType.DocDateFcn=@DocDateFcn;
    linkType.ResolveDocFcn=@ResolveDocFcn;
    linkType.ItemIdFcn=@ItemIdFcn;




    linkType.SelectionLinkLabel=getString(message('Slvnv:reqmgt:linktype_rmi_simulink:LinkToCurrent'));
end

function NavigateFcn(hostmodel,locationStr)
    [~,modelname]=fileparts(hostmodel);
    if rmisl.isComponentHarness(hostmodel)


        modelPath=hostmodel;
    elseif rmisl.isHarnessIdString(hostmodel)

        rmisl.harnessIdToEditorName(hostmodel,true);
        modelPath=hostmodel;
    elseif rmisl.isHarnessIdString(locationStr)

        open_system(hostmodel);


        [~,hostModelName]=fileparts(hostmodel);
        inHarnessSID=rmisl.harnessIdToEditorName([hostModelName,locationStr],true);
        if isempty(inHarnessSID)

            msg=getString(message('Slvnv:reqmgt:rmiobjnavigate:ErrorNoHarness'));
            title=getString(message('Slvnv:reqmgt:rmiobjnavigate:UnresolvedItem'));
            errordlg(msg,title);
            return;
        end
        [modelPath,locationStr]=strtok(inHarnessSID,':');
    elseif rmifa.isFaultIdString(locationStr)
        rmifa.navigate(hostmodel,locationStr);
        return;
    else
        if~rmisl.isSimulinkModelLoaded(modelname)
            open_system(hostmodel);
        elseif~strcmp(get_param(modelname,'Open'),'on')
            open_system(modelname);
        end
        modelPath=get_param(modelname,'FileName');
    end

    if length(locationStr)>1



        if exist('rmi.Informer','class')==8&&rmi.Informer.isVisible()
            restoreInformer=true;
        else
            restoreInformer=false;
        end


        if locationStr(1)=='@'
            sid=locationStr(2:end);
        else
            sid=locationStr;
        end

        if any(sid=='~')

            [rangeId,blkId]=slreq.utils.getShortIdFromLongId(sid);
            rmicodenavigate([modelname,blkId],rangeId);

        else

            [sid,tail]=strtok(sid,'.');
            if~isempty(tail)
                rmiobjnavigate(modelPath,sid,str2double(tail(2:end)));
            else
                if any(sid==',')

                    sids=textscan(sid,'%s','Delimiter',',');
                    rmiobjnavigate(modelPath,sids{1}{:});
                else
                    rmiobjnavigate(modelPath,sid);
                end
            end
        end


        if restoreInformer
            rmi.Informer.makeVisible();
        end
    end
end

function req=SelectionLinkFcn(objH,make2way,allowMultiselect)
    if nargin<3
        allowMultiselect=true;
    end
    req=[];

    target=rmisl.intraLinkMenus('get');
    errorThrownAlready=false;
    if isempty(target)
        isRmiSelection=false;

        [target,isSf]=rmisl.getSelection();


        if~isempty(target)


            try
                if isstruct(target)&&isfield(target,'selectedText')

                    req=rmisl.makeReq(target);
                    return;
                elseif sysarch.isZCPort(target)
                    req=rmi.createEmptyReqs(length(target));
                    for i=1:length(target)
                        req(i)=rmisl.makeReq(target(i));
                    end
                    return;
                else
                    [target,errorOrWarning]=rmi.canlink(target);
                    errorThrownAlready=errorOrWarning==2;
                end
            catch ex
                errordlg(ex.message,...
                getString(message('Slvnv:reqmgt:linktype_rmi_simulink:RequirementsUseCurrent')));
                return;
            end

            tmptarget=slreq.utils.getRMISLTarget(target);
            if~isequal(tmptarget,target)

                target=tmptarget;
                sr=sfroot;
                if sr.isValidSlObject(target)
                    isSf=false;
                else
                    isSf=true;
                end
            end

            for i=1:length(target)
                if rmisl.isObjectUnderCUT(target(i))



                    if isSf
                        sr=sfroot;
                        sfObj=sr.idToHandle(target(i));
                        target(i)=rmisl.harnessToModelRemap(sfObj);
                    else
                        slObj=get(target(i),'Object');
                        ownerObj=rmisl.harnessToModelRemap(slObj);
                        target(i)=ownerObj.Handle;
                    end
                end
            end
        end
    else
        isRmiSelection=true;
    end


    if isempty(target)
        if~errorThrownAlready




            errordlg(...
            getString(message('Slvnv:reqmgt:linktype_rmi_simulink:SelectionLinkNoObjects')),...
            getString(message('Slvnv:reqmgt:linktype_rmi_simulink:RequirementsUseCurrent')));
        end
        return;
    end


    if~ischar(objH)&&~isa(objH,'Simulink.DDEAdapter')&&any(target==objH)
        errordlg(...
        getString(message('Slvnv:reqmgt:linktype_rmi_simulink:CannotLinkToItself')),...
        getString(message('Slvnv:reqmgt:linktype_rmi_simulink:RequirementsUseCurrent')));
        return;
    end


    if~allowMultiselect&&length(target)>1
        errordlg(...
        getString(message('Slvnv:reqmgt:linktype_rmi_simulink:SelectionLinkTooManyObjects')),...
        getString(message('Slvnv:reqmgt:linktype_rmi_simulink:RequirementsUseCurrent')));
        return;
    end


    if isRmiSelection
        rmisl.intraLinkMenus({});
    elseif~isSf&&any(rmisl.is_signal_builder_block(target))
        errordlg(...
        getString(message('Slvnv:rmi:editReqs:CannotEditSigBuilder')),...
        getString(message('Slvnv:reqmgt:linktype_rmi_simulink:RequirementsUseCurrent')));
        return;
    end

    req=rmi.createEmptyReqs(length(target));
    for i=1:length(target)
        req(i)=rmisl.makeReq(target(i));
    end

    if make2way&&~slreq.internal.isSlreqItem(objH)
        srcType=rmiut.resolveType(objH);
        if strcmp(srcType,'simulink')&&~ischar(objH)

            action_highlight('clear');
            rmisl.intraLink(target,objH);
            rmiut.hiliteAndFade(target);
        else
            for i=1:length(target)
                returnLink=rmi.makeReq(objH,target(i),srcType);
                rmi.catReqs(target(i),returnLink);
            end
        end
    end
end

function mdlName=BrowseObjects()









    extensions='*.mdl;*.slx;';
    [fileName,pathName]=uigetfile(...
    {extensions,getString(message('Slvnv:reqmgt:linktype_rmi_simulink:SimulinkModelExtensions',extensions));...
    '*.*',getString(message('Slvnv:reqmgt:linktype_rmi_simulink:AllFilesExtensions'))},...
    getString(message('Slvnv:reqmgt:linktype_rmi_simulink:SelectRequirementHostModel')));

    if isempty(fileName)||~ischar(fileName)
        mdlName='';
        return;
    else

        open_system(fullfile(pathName,fileName));

        if ispc
            reqmgt('winFocus',['^',getString(message('Slvnv:reqmgt:rmidlg_mgr:LinkEditor',''))]);
        end

        [~,mdlName]=fileparts(fileName);
    end
end

function[labels,depths,locations]=ContentsFcn(modelName)


    try
        modelH=get_param(modelName,'Handle');
    catch ex %#ok<NASGU>

        load_system(modelName);
        modelH=get_param(modelName,'Handle');
    end
    [objs,parents,isSf]=rmisl.getObjectHierarchy(modelH);
    depths=rmisl.getDepths(parents);
    total_objects=length(depths);
    skip=false(total_objects,1);


    allIsSigB=false(total_objects,1);
    allIsSigB(~isSf)=rmisl.is_signal_builder_block(objs(~isSf));
    sigbCnt=sum(allIsSigB);
    if sigbCnt>0
        removeIdx=rmisl.getChildIndices(parents,allIsSigB);
        skip(removeIdx)=true;
    end


    allIsDisabled=false(total_objects,1);
    skip(1)=true;
    allIsDisabled(~isSf&~skip)=~strcmp(get_param(objs(~isSf&~skip),'AncestorBlock'),'');
    skip(1)=false;
    if any(allIsDisabled)
        removeIdx=rmisl.getChildIndices(parents,allIsDisabled);
        skip(removeIdx)=true;
    end


    labels=cell(total_objects,1);
    locations=cell(total_objects,1);
    if any(isSf)
        sfRoot=Stateflow.Root;
    end
    labels{1}=modelName;
    locations{1}=':';
    for i=2:total_objects
        if skip(i)
            continue;
        end
        if isSf(i)
            objLabel=sf('get',objs(i),'.labelString');
            obj=sfRoot.idToHandle(objs(i));
            if~isempty(obj)
                if any(strcmp(class(obj),{'Stateflow.Chart','Stateflow.EMChart',...
                    'Stateflow.TruthTable','Stateflow.TruthTableChart'}))

                    sid='';
                else
                    sid=Simulink.ID.getSID(obj);
                end
            else
                sid='';
            end
        else
            objLabel=get_param(objs(i),'Name');
            sid=Simulink.ID.getSID(objs(i));
        end
        labels{i}=rmiut.filterChars(objLabel,false);
        if isempty(sid)
            skip(i)=true;
        else
            [~,locations{i}]=strtok(sid,':');
        end
    end


    if sigbCnt>0
        sigbIdx=find(allIsSigB&~skip);
        shift=0;
        for i=1:length(sigbIdx)
            idx=sigbIdx(i);
            [~,~,~,tabNames]=signalbuilder(objs(idx));
            totalTabs=length(tabNames);
            newLabels=cell(totalTabs,1);
            newDepths=depths(idx+shift)*ones(totalTabs,1);
            newLocations=cell(totalTabs,1);
            for j=1:totalTabs
                newLabels{j}=sprintf('%s - %s',labels{idx+shift},tabNames{j});
                newLocations{j}=sprintf('%s.%d',locations{idx+shift},j);
            end
            labels=[labels(1:idx+shift-1);newLabels;labels(idx+shift+1:end)];
            depths=[depths(1:idx+shift-1);newDepths;depths(idx+shift+1:end)];
            locations=[locations(1:idx+shift-1);newLocations;locations(idx+shift+1:end)];
            skip=[skip(1:idx+shift-1);false(totalTabs,1);skip(idx+shift+1:end)];
            shift=shift+totalTabs-1;
        end
    end


    if any(skip)
        labels(skip)=[];
        depths(skip)=[];
        locations(skip)=[];
    end
end

function success=IsValidDocFcn(doc,~)
    if rmisl.isHarnessIdString(doc)

        harnessName=rmisl.harnessIdToEditorName(doc,false);
        success=~isempty(harnessName);
    else

        if exist(doc,'file')==4
            success=true;
        else
            success=false;
        end
    end
end

function success=IsValidIdFcn(doc,locationStr)
    harnessToClose='';
    if rmisl.isHarnessIdString(doc)

        harnessName=rmisl.harnessIdToEditorName(doc,false);

        try
            void=get_param(harnessName,'Handle');%#ok<NASGU>
            doc=harnessName;
        catch ex %#ok<NASGU>
            try
                parentH=get_param(strtok(doc,':'),'Handle');
                [doc,harnessToClose]=rmisl.componentHarnessMgr('open',parentH,harnessName);
            catch ex %#ok<NASGU>
                success=false;
                return;
            end
        end
    end


    handle=rmisl.rmiIdToHandle(doc,locationStr);
    success=~isempty(handle);

    if~isempty(harnessToClose)
        rmisl.componentHarnessMgr('close',harnessToClose);
    end
end


function[success,newDescr]=IsValidDescFcn(doc,locationStr,currDescr)
    harnessToClose='';
    if rmisl.isHarnessIdString(doc)

        harnessName=rmisl.harnessIdToEditorName(doc,false);

        try
            void=get_param(harnessName,'Handle');%#ok<NASGU>
            doc=harnessName;
        catch ex %#ok<NASGU>
            try
                parentH=get_param(strtok(doc,':'),'Handle');
                [doc,harnessToClose]=rmisl.componentHarnessMgr('open',parentH,harnessName);
            catch ex %#ok<NASGU>
                success=false;
                return;
            end
        end
    end

    handle=rmisl.rmiIdToHandle(doc,locationStr);
    [~,description]=rmi.objinfo(handle);
    my_chars=double(description);
    description(my_chars<32|my_chars==127)=' ';
    if strcmp(description,currDescr)
        success=true;
        newDescr='';
    else
        success=false;
        newDescr=description;
    end

    if~isempty(harnessToClose)
        rmisl.componentHarnessMgr('close',harnessToClose);
    end
end

function url=CreateURLFcn(mdl,~,location)
    isHarnessId=rmisl.isHarnessIdString(mdl);
    if~isHarnessId
        [~,mdl]=fileparts(mdl);
    end
    if isempty(location)
        if isHarnessId
            url=sprintf('matlab:%s',['rmiobjnavigate(''',mdl,''','''');']);
        else
            url=sprintf('matlab:open_system(''%s'');',mdl);
        end
    else
        if location(1)=='@'
            location=location(2:end);
        end
        if strcmp(location,':')
            url=sprintf('matlab:open_system(''%s'');',mdl);
        else
            if any(location=='.')
                [location,grpInfo]=strtok(location,'.');
                navcmd=['rmiobjnavigate(''',mdl,''',''',location,''',',grpInfo(2:end),');'];
            else
                navcmd=['rmiobjnavigate(''',mdl,''',''',location,''');'];
            end
            url=sprintf('matlab:%s',navcmd);
        end
    end
end

function label=UrlLabelFcn(doc,docId,location)
    if rmisl.isHarnessIdString(doc)

        doc=rmisl.harnessIdToEditorName(doc,true);
        docId=doc;
    end
    if isempty(location)||strcmp(location,':')
        label=getString(message('Slvnv:reqmgt:linktype_rmi_simulink:SimulinkDiagram',doc));
    else
        if rmisl.isSimulinkModelLoaded(doc)
            try


                [obj,grpInfo,docId]=rmisl.rmiIdToHandle(doc,location);
                if isempty(obj)


                    label=getString(message('Slvnv:reqmgt:LinkSet:updateContents:LocationInDoc',location,docId));
                    return;
                end
            catch Mex
                if strcmp(Mex.identifier,'Simulink:utility:objectDestroyed')

                    rmiut.warnNoBacktrace('Slvnv:RptgenRMI:execute:SidUnresolved',[doc,location]);
                    label=getString(message('Slvnv:RptgenRMI:execute:SidUnresolved',[doc,location]));
                else

                    warning(Mex.identifier,'%s',Mex.message);
                    label=Mex.message;
                end
                return;
            end
            [objName,objType]=rmi.objname(obj);
            if isempty(docId)
                [~,docName]=fileparts(doc);
                label=[docName,', ',objName,' (',objType,')'];
            else
                label=[docId,', ',objName,' (',objType,')'];
            end
            if~isempty(grpInfo)
                label=getString(message('Slvnv:reqmgt:linktype_rmi_simulink:SignalGroup',label,grpInfo(2:end)));
            end
        else

            if isempty(docId)
                label=getString(message('Slvnv:RptgenRMI:execute:SidInModelNotLoaded',location,doc));
            else
                label=getString(message('Slvnv:RptgenRMI:execute:SidInModelNotLoaded',location,docId));
            end
        end
    end
end

function dateString=DocDateFcn(doc)
    [mPath,mName,mExt]=fileparts(doc);

    if rmisl.isSimulinkModelLoaded(mName)
        dateString=get_param(mName,'LastModifiedDate');
    else
        if isempty(mPath)&&isempty(mExt)
            mInfo=dir(which(doc));
        else
            mInfo=dir(doc);
        end
        if isempty(mInfo)
            dateString='';
        else
            dateString=mInfo.date;
        end
    end
end

function[docPath,isRel]=ResolveDocFcn(doc,~)
    if rmisl.isHarnessIdString(doc)

        docPath=rmisl.harnessIdToEditorName(doc,true);
    else
        modelPath=which(doc);
        if isempty(modelPath)
            warning(message('Slvnv:reqmgt:linktype_rmi_simulink:UnresolvedModel',doc));
            docPath='';
        else
            docPath=modelPath;
        end
    end
    isRel=false;
end

function out=ItemIdFcn(host,in,mode)



    if isempty(strtok(in))
        if mode
            out='';
        else

            [~,out]=fileparts(host);
        end
        return;
    end
    if in(1)=='@'
        isNamedItem=true;
        in=in(2:end);
    else
        isNamedItem=false;
    end

    if isempty(host)
        if mode
            error(message('Slvnv:reqmgt:rmidlg_apply:NoValidSelectionIn','Simulink'));
        else
            out=in;
            return;
        end
    end
    if mode
        if~isempty(regexp(strtok(in),'^:\d[:\d\.]*','once'))
            out=strtok(in);
        else
            sid=locObjToSid(strtrim(in));
            if isempty(sid)
                out=in;
            else
                out=sid;
            end
        end
    else
        out=in;
        [~,slName]=fileparts(host);
        if any(strcmp(inmem,'slroot'))
            loadedSystems=find_system('type','block_diagram');
        else
            loadedSystems={};
        end
        if any(strcmp(loadedSystems,slName))
            subIdInfo=regexp(strtok(in),'^(:\d[:\d]*)\.(\d+)$','tokens');
            if~isempty(subIdInfo)
                in=subIdInfo{1}{1};
                tab=[', group ',subIdInfo{1}{2}];
            else
                tab='';
            end
            try
                if rmisl.isSidString([slName,strtok(in)])
                    objH=rmisl.sidToHandle(slName,strtok(in));
                    sid=strtok(in);
                else
                    sid=locObjToSid(strtrim(in));
                    if~isempty(sid)
                        objH=rmisl.sidToHandle(slName,sid);
                    else
                        objH=[];
                    end
                end
            catch ex %#ok<NASGU>
                objH=[];
            end
            if~isempty(objH)
                [objName,objType]=rmi.objname(objH);
                out=[sid,' (',objName,', ',objType,tab,')'];
            end
        end
        if isNamedItem
            out=['@',out];
        end
    end
end

function result=locObjToSid(obj)
    if~any(obj=='/')

        curSys=gcs;
        if~isempty(curSys)
            obj=[curSys,'/',obj];
        end
    end
    [isSf,objH]=rmi.resolveobj(obj);
    if~isempty(objH)
        [~,result]=rmidata.getRmiKeys(objH,isSf);
    else
        result='';
    end
end
