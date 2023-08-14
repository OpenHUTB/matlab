function result=rmidlg_mgr(sourceType,linkSource,reqs,varargin)




    persistent initialized objMap fileMap reqObjMap;

    if isempty(initialized)||~initialized
        objMap=containers.Map('KeyType','double','ValueType','any');
        fileMap=containers.Map('KeyType','char','ValueType','any');
        reqObjMap=containers.Map('KeyType','char','ValueType','any');
        initialized=true;
    end

    if strcmp(sourceType,'remove')

        if ischar(linkSource)
            isSelectible=false;
            if isKey(fileMap,linkSource)
                if strcmp(fileMap(linkSource).source,'matlab')
                    isSelectible=true;
                end
                remove(fileMap,linkSource);
            end

            if isSelectible
                rmiml.clearSelection(linkSource);
            end
        elseif isa(linkSource,'slreq.data.Requirement')
            if isKey(reqObjMap,linkSource.getUuid)
                remove(reqObjMap,linkSource.getUuid);
            end
        else
            for i=1:length(linkSource)
                objH=linkSource(i);
                if isKey(objMap,objH)
                    remove(objMap,objH);
                end
            end
        end
        return;
    elseif strcmp(sourceType,'close')

        if ischar(linkSource)

            activeItems=keys(fileMap);
            matchedIdx=find(strcmp(strtok(activeItems,'|'),linkSource));
            for i=1:length(matchedIdx)

                matchedItem=fileMap(activeItems{matchedIdx(i)});
                delete(matchedItem.dialogH);
            end
        end
        return;
    end


    dlgData=[];
    if ischar(linkSource)
        if isKey(fileMap,linkSource)
            value=fileMap(linkSource);
            if ishandle(value.dialogH)
                dlgData=value;
            else
                remove(fileMap,linkSource);
            end
        end
    elseif isa(linkSource,'slreq.data.Requirement')
        if isKey(reqObjMap,linkSource.getUuid)
            value=reqObjMap(linkSource.getUuid);
            if ishandle(value.dialogH)
                dlgData=value;
            else
                remove(reqObjMap,linkSource);
            end
        end
    else
        for i=1:length(linkSource)
            objH=linkSource(i);
            if isKey(objMap,objH)
                value=objMap(objH);
                if ishandle(value.dialogH)
                    myObjsH=unique(linkSource);
                    if length(value.objH)==length(myObjsH)&&all(value.objH==myObjsH)
                        dlgData=value;
                        break;
                    else
                        if isempty(sourceType)
                            if floor(objH)==objH
                                sourceType='stateflow';
                            else
                                sourceType='simulink';
                            end
                        end
                        question={...
                        getString(message('Slvnv:reqmgt:rmidlg_mgr:DialogAlreadyOpenFor',getObjectName(sourceType,objH))),...
                        getString(message('Slvnv:reqmgt:rmidlg_mgr:UnappliedLostIfContinue'))};

                        reply=questdlg(question,getString(message('Slvnv:rmisl:menus_rmi_object:EditAddLinks')),...
                        getString(message('Slvnv:reqmgt:rmidlg_mgr:Continue')),...
                        getString(message('Slvnv:reqmgt:rmidlg_mgr:Cancel')),...
                        getString(message('Slvnv:reqmgt:rmidlg_mgr:Cancel')));
                        if~isempty(reply)&&strcmp(reply,getString(message('Slvnv:reqmgt:rmidlg_mgr:Continue')))
                            delete(value.dialogH);


                        else
                            result=[];
                            return;
                        end
                    end
                else
                    remove(objMap,objH);
                end
            end
        end
    end

    if isempty(dlgData)


        if ischar(linkSource)
            dlgData.objH=linkSource;
        else
            dlgData.objH=unique(linkSource);
        end
        dlgData.source=sourceType;
        dlgData.dialogSrc=ReqMgr.LinkSet;
        dlgData.dialogSrc.reqItems={};
        dlgData.dialogSrc.title=getString(message('Slvnv:reqmgt:rmidlg_mgr:LinkEditor','...'));
        dlgData.dialogH=DAStudio.Dialog(dlgData.dialogSrc);


        switch length(varargin)
        case 0
            activeIndex=[];
            baseIndex=-1;
            count=-1;
        case 1
            activeIndex=varargin{1};
            baseIndex=-1;
            count=-1;
        case 3
            activeIndex=varargin{1};
            baseIndex=varargin{2};
            count=varargin{3};
        otherwise
            error(message('Slvnv:reqmgt:rmidlg_mgr:InvalidArgumentNumber'));
        end

        initalizeReqInterface(dlgData.dialogSrc,dlgData.dialogH,...
        sourceType,linkSource,reqs,activeIndex,baseIndex,count);



        if ischar(linkSource)

        elseif isa(linkSource,'slreq.data.Requirement')


        else






            [isSf,objH,~]=rmi.resolveobj(linkSource(1));
            modelH=rmisl.getmodelh(objH);
            if~isempty(modelH)
                if modelH==objH
                    mdlObj=get_param(objH,'Object');
                    dlgData.dialogSrc.listener=Simulink.listener(mdlObj,'ObjectBeingDestroyed',...
                    @(src,evt)rmi_delete_dialog(src,evt,dlgData));
                elseif isSf
                    rt=sfroot;
                    sfObj=rt.idToHandle(objH);
                    dlgData.dialogSrc.listener=Simulink.listener(sfObj,'ObjectBeingDestroyed',...
                    @(src,evt)rmi_delete_dialog(src,evt,dlgData));

                    for i=2:length(linkSource)
                        sfObj=rt.idToHandle(linkSource(i));
                        if~isempty(sfObj)
                            dlgData.dialogSrc.listener=[dlgData.dialogSrc.listener...
                            ,Simulink.listener(sfObj,'ObjectBeingDestroyed',...
                            @(src,evt)rmi_delete_dialog(src,evt,dlgData))];
                        end
                    end
                else
                    parentObj=get_param(get_param(objH,'Parent'),'Object');
                    objects=get_param(linkSource,'Object');
                    dlgData.dialogSrc.listener=Simulink.listener(parentObj,'ObjectChildRemoved',...
                    @(src,event)rmi_delete_dialog_by_parent(src,event,dlgData.dialogH,objects));
                end
            end
        end


        if ischar(linkSource)
            fileMap(linkSource)=dlgData;
        elseif isa(linkSource,'slreq.data.Requirement')
            reqObjMap(linkSource.getUuid)=dlgData;
        else
            for i=1:length(linkSource)
                objMap(linkSource(i))=dlgData;
            end
        end

    else



        dlgData.dialogH.refresh();
        if ispc()
            reqmgt('winFocus',[dlgData.dialogSrc.title,'.*']);
        end

    end

    result=dlgData.dialogH;
end

function rmi_delete_dialog(~,~,data)
    dialogH=data.dialogH;
    if ishandle(dialogH)
        delete(dialogH);
    end
end

function rmi_delete_dialog_by_parent(~,event,dialogH,object)
    if ishandle(dialogH)
        if iscell(object)

            for i=1:length(object)
                if object{i}==event.Child
                    delete(dialogH);
                    break;
                end
            end
        elseif object==event.Child
            delete(dialogH);
        end
    end
end

function initalizeReqInterface(dialogSrc,dialogH,sourceType,sourceObj,reqs,activeIndex,baseIndex,count)

    dialogSrc.reqItems=reqs;
    dialogSrc.objectH=sourceObj;
    dialogSrc.index=baseIndex;
    dialogSrc.count=count;
    dialogSrc.source=sourceType;

    dialogSrc.title=strrep(getDialogTitle(sourceType,sourceObj),newline,' ');

    userData=dialogSrc.dialogUD;
    userData.reqs=reqs;

    if activeIndex~=-1
        userData.activeReq=activeIndex;
    elseif~isempty(userData.reqs)
        userData.activeReq=1;
    else
        userData.activeReq=0;
    end


    userData.baseIndex=baseIndex;
    userData.count=count;


    dialogSrc.dialogUD=userData;

    dialogH.refresh();
end

function result=getDialogTitle(sourceType,srcObj)

    if ischar(srcObj)

        [fPath,remainder]=strtok(srcObj,'|');
        if rmisl.isSidString(fPath)
            fName=fPath;
            fExt='';
            parentShortName=fPath;
        else
            [~,fName,fExt]=fileparts(fPath);
            parentShortName=[fName,fExt];
        end
        switch sourceType
        case 'matlab'
            lineRangeInfo=getLineRange(fPath,remainder(2:end));
            bookmarkInfo=[parentShortName,' (',lineRangeInfo,')'];
            result=getString(message('Slvnv:reqmgt:rmidlg_mgr:LinkEditor',bookmarkInfo));
        case 'data'
            [~,~,ext]=fileparts(srcObj);
            result=getString(message('Slvnv:reqmgt:rmidlg_mgr:LinkEditor',[fName,':',ext(2:end)]));
        case 'testmgr'
            if strcmp(fExt,'.m')


                testCaseName=remainder(2:end);
            else

                testCaseName=stm.internal.getTestCaseNameFromUUIDAndTestFile(remainder(2:end),fPath);
            end
            result=getString(message('Slvnv:reqmgt:rmidlg_mgr:LinkEditor',[fName,': ',testCaseName]));
        case 'fault'
            [faultInfoObj,~]=rmifa.getFaultInfoObj([fName,fExt],remainder(2:end));
            result=getString(message('Slvnv:reqmgt:rmidlg_mgr:LinkEditor',faultInfoObj.Name));
        otherwise
            error(message('Slvnv:reqmgt:rmidlg_mgr:UnsupportedSourceType',sourceType));
        end
    elseif isa(srcObj,'slreq.data.Requirement')
        [adapter,artifactUri,artifactId]=srcObj.getAdapter();
        targetLabel=adapter.getSummary(artifactUri,artifactId);
        result=getString(message('Slvnv:reqmgt:rmidlg_mgr:LinkEditor',targetLabel));
    elseif isa(srcObj,'sm.internal.SafetyManagerNode')
        result=getString(message('Slvnv:reqmgt:rmidlg_mgr:LinkEditor',srcObj.getFileName()));
    else
        len=length(srcObj);
        if len>1
            result=getString(message('Slvnv:reqmgt:rmidlg_mgr:AddToSelected',num2str(len)));
        else
            objName=getObjectName(sourceType,srcObj);
            result=getString(message('Slvnv:reqmgt:rmidlg_mgr:LinkEditor',objName));
        end
    end
end

function name=getObjectName(sourceType,objH)
    if isa(objH,'Simulink.Object')
        name=objH.Name;
        if isempty(name)
            name=getString(message('Slvnv:reqmgt:rmidlg_mgr:Unnamed',class(objH)));
        end
    elseif isa(objH,'Simulink.Data')
        name=[class(objH),' object'];
    else
        switch sourceType
        case 'simulink'
            name=get_param(objH,'name');
        case 'stateflow'
            transitionIsa=sf('get','default','transition.isa');
            objIsa=sf('get',objH,'.isa');
            if objIsa==transitionIsa
                name=sf('get',objH,'.labelString');
            else
                name=sf('get',objH,'.name');
            end
        otherwise


            name=objH;
        end
    end
end

function lineRangeStr=getLineRange(fPath,locationInfo)
    lineRangeStr=locationInfo;
    try
        if any(locationInfo=='-')
            rangeHelper=slreq.mleditor.ReqPluginHelper.getInstance();
            charPositions=sscanf(locationInfo,'%d-%d');
            lineNumbers=rangeHelper.charPositionToLineNumber(fPath,charPositions);
        elseif any(locationInfo==':')
            lineNumbers=sscanf(locationInfo,'%d:%d');
        else
            textRange=slreq.getTextRange(fPath,locationInfo);
            lineNumbers=textRange.getLineRange();
        end
        lineRangeStr=getString(message('Slvnv:reqmgt:mdlAdvCheck:LineNumbersNN',lineNumbers(1),lineNumbers(end)));
    catch ex
        rmiut.warnNoBacktrace('Slvnv:RptgenRMI:ReqTable:execute:FailedToRetrieveDetailsFrom',locationInfo,ex.message);
    end
end


