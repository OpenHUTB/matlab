classdef DocumentAction




    properties(Constant,Access=protected)
        Map=containers.Map
        pIsLocked=lockClass
    end




    methods(Static)
        function insertNumericProperty(filePath)
            guardedSynchronizedMtreeActionWithPropName(filePath,...
            @matlab.system.editor.internal.PropertyAction.insertNumeric);
        end

        function insertTunableNumericProperty(filePath)
            guardedSynchronizedMtreeActionWithPropName(filePath,...
            @matlab.system.editor.internal.PropertyAction.insertTunableNumeric);
        end

        function insertLogicalProperty(filePath)
            guardedSynchronizedMtreeActionWithPropName(filePath,...
            @matlab.system.editor.internal.PropertyAction.insertLogical);
        end

        function enumDocument=insertEnumerationProperty(filePath,propName,...
            enumName,createNewEnum,defaultValue,setValues)
            if isstring(propName)
                propName=char(propName);
            end
            if isstring(enumName)
                enumName=char(enumName);
            end
            if isstring(defaultValue)
                defaultValue=char(defaultValue);
            end
            if isstring(setValues)
                setValues=setValues.split(",");
                setValues=cellstr(setValues);
            end
            if~iscell(setValues)
                setValues=cell(setValues);
            end

            guardedSynchronizedMtreeAction(filePath,...
            @matlab.system.editor.internal.PropertyAction.insertEnumeration,...
            propName,enumName,createNewEnum,defaultValue,setValues);

            if createNewEnum

                enumDocument=guardedFcn(filePath,...
                @matlab.system.editor.internal.NewDocumentTemplate.createEnumeration,...
                enumName,defaultValue,setValues);
            end
        end

        function insertPositiveIntegerProperty(filePath)
            guardedSynchronizedMtreeActionWithPropName(filePath,...
            @matlab.system.editor.internal.PropertyAction.insertPositiveInteger);
        end

        function insertPrivateProperty(filePath)
            guardedSynchronizedMtreeActionWithPropName(filePath,...
            @matlab.system.editor.internal.PropertyAction.insertPrivate);
        end

        function insertProtectedProperty(filePath)
            guardedSynchronizedMtreeActionWithPropName(filePath,...
            @matlab.system.editor.internal.PropertyAction.insertProtected);
        end

        function insertCustomProperty(filePath,setAccess,getAccess,attributes)
            if isstring(attributes)
                attributes=attributes.split(",");
                attributes=cellstr(attributes);
            end
            if isstring(setAccess)
                setAccess=char(setAccess);
            end
            if isstring(getAccess)
                getAccess=char(getAccess);
            end
            if~iscell(attributes)
                attributes=cell(attributes);
            end

            guardedSynchronizedMtreeActionWithPropName(filePath,...
            @matlab.system.editor.internal.PropertyAction.insertCustom,...
            setAccess,getAccess,attributes);
        end

        function insertState(filePath)
            guardedSynchronizedMtreeActionWithStateName(filePath,...
            @matlab.system.editor.internal.PropertyAction.insertDiscreteState);
        end

        function insertSystemObjectMethod(filePath,methodName)
            guardedSynchronizedMtreeAction(filePath,...
            @matlab.system.editor.internal.MethodAction.insert,methodName);
        end

        function removeSystemObjectMethod(filePath,methodName)
            guardedSynchronizedMtreeAction(filePath,...
            @matlab.system.editor.internal.MethodAction.remove,methodName);
        end

        function insertInput(filePath)
            guardedSynchronizedMtreeActionWithCode(filePath,...
            @matlab.system.editor.internal.IOAction.insertInput);
        end

        function insertOptionalInputs(filePath)
            guardedSynchronizedMtreeActionWithCode(filePath,...
            @matlab.system.editor.internal.IOAction.insertOptionalInputs);
        end

        function insertOutput(filePath)
            guardedSynchronizedMtreeActionWithCode(filePath,...
            @matlab.system.editor.internal.IOAction.insertOutput);
        end

        function insertOptionalOutputs(filePath)
            guardedSynchronizedMtreeActionWithCode(filePath,...
            @matlab.system.editor.internal.IOAction.insertOptionalOutputs);
        end

        function specifyTextIcon(filePath)
            guardedSynchronizedMtreeAction(filePath,...
            @matlab.system.editor.internal.IconAction.insertTextIcon);
        end

        function specifyImageIcon(filePath)
            guardedSynchronizedExternalDataFcn(filePath,'ImageFileChooser',...
            @matlab.system.editor.internal.IconAction.chooseImageIcon,filePath,@insertImageIcon);
        end

        function analyze(filePath,varargin)
            customTitleGuardedSynchronizedDocumentExternalDataFcn(filePath,...
            'MATLAB:system:Editor:AnalyzerErrorTitle',...
            'Analyzer',...
            @matlab.system.editor.internal.Analyzer.launch,varargin{:});
        end

        function showDialogPreview(filePath)
            customTitleGuardedSynchronizedDocumentExternalDataFcn(filePath,...
            'MATLAB:system:Editor:DialogPreviewErrorTitle',...
            'PreviewDialog',...
            @matlab.system.editor.internal.DialogPreview.launch);
        end
        function launchMaskEditor(filePath)
            customTitleGuardedSynchronizedDocumentExternalDataFcn(filePath,...
            'MATLAB:system:Editor:LaunchMaskEditorErrorTitle',...
            'LaunchMaskEditor',...
            @matlab.system.editor.internal.DialogPreview.launchMaskEditor);
        end

        function setFilePathChangeFcn(filePath,fcn)
            synchronizeDocumentImpl(filePath);
            putDataField(filePath,'FilePathChangeFcn',fcn);
        end

        function performSysobjupdate(filePath,varargin)
            if nargin>1
                clientId=varargin{1};
            else

                clientId='';
            end
            try

                filePath=strrep(filePath,'''','');


                [status,values]=fileattrib(filePath);
                assert(status==true);


                if~(values.UserWrite)
                    error(message('MATLAB:system:Editor:AnalyzerUpdateFileReadOnly',filePath));
                end



                [~,className]=matlab.system.editor.internal.DocumentAction.getInfoForFile(filePath);

                if strcmpi(className,"0")
                    error(message('MATLAB:system:Editor:AnalyzerUpdateTargetNotOnPath',filePath));
                end


                doc=matlab.desktop.editor.findOpenDocument(filePath);



                existingText=doc.Text;


                if doc.Modified
                    answer=questdlg(getString(message('MATLAB:system:Editor:AnalyzerFileSaveDialogDirtyLabel')),...
                    getString(message('MATLAB:system:Editor:AnalyzerUpdateTitleLabel')),...
                    getString(message('MATLAB:system:Editor:AnalyzerUpdateYesLabel')),...
                    getString(message('MATLAB:system:Editor:AnalyzerUpdateNoLabel')),...
                    getString(message('MATLAB:system:Editor:AnalyzerUpdateNoLabel')));
                    switch answer
                    case getString(message('MATLAB:system:Editor:AnalyzerUpdateYesLabel'))
                        doc.save;
                    case getString(message('MATLAB:system:Editor:AnalyzerUpdateNoLabel'))
                        error(message('MATLAB:system:Editor:AnalyzerUpdateSystemObjectUnsavedBuffer',filePath))
                    otherwise
                        return
                    end
                end



                doc.goToLine(intmax('int32'));
                endSelection=doc.Selection;


                updateInfo=matlab.system.internal.updateClass(className,[],false);


                if updateInfo.Changed


                    if(~isempty(updateInfo.Messages))
                        warning(strjoin(updateInfo.Messages,'\n'));
                        dialogMessage=getString(message('MATLAB:system:Editor:AnalyzerUpdateNextStepWithWarning',className));
                    else
                        dialogMessage=getString(message('MATLAB:system:Editor:AnalyzerUpdateNextStep',className));
                    end
                    replaceCmd={struct('Action','replace',...
                    'Text',updateInfo.Text,...
                    'StartLine',1,'StartColumn',1,'EndLine',endSelection(1),'EndColumn',endSelection(end))};
                    matlab.system.editor.internal.DocumentAction.processCmds(filePath,replaceCmd);



                    answer=questdlg(dialogMessage,...
                    getString(message('MATLAB:system:Editor:AnalyzerUpdateTitleLabel')),...
                    getString(message('MATLAB:system:Editor:AnalyzerUpdateYesLabel')),...
                    getString(message('MATLAB:system:Editor:AnalyzerUpdateNoLabel')),...
                    getString(message('MATLAB:system:Editor:AnalyzerUpdateNoLabel')));
                    doc.makeActive;
                    doc.save;

                    switch(answer)
                    case getString(message('MATLAB:system:Editor:AnalyzerUpdateYesLabel'))
                        [~,FName]=fileparts(filePath);
                        tempFileName=strcat(fullfile(tempdir,FName),'.m');
                        fileID=fopen(tempFileName,'w+');
                        fprintf(fileID,'%s',existingText);
                        fclose(fileID);
                        visdiff(tempFileName,filePath);
                    otherwise

                    end
                else

                    if isempty(updateInfo.Messages)
                        messageStr=getString(message('MATLAB:system:Editor:AnalyzerSystemObjectNotUpdated'));
                    else
                        warning(strjoin(updateInfo.Messages,'\n'));
                        messageStr=getString(message('MATLAB:system:Editor:AnalyzerSystemObjectNotUpdatedWithWarning'));
                    end
                    helpdlg(messageStr,...
                    getString(message('MATLAB:system:Editor:AnalyzerUpdateTitleLabel')));
                end
            catch Excep



                errordlg(...
                Excep.message,...
                getString(message('MATLAB:system:Editor:AnalyzerUpdateErrorTitle')),...
                'Modal');
            end
            matlab.system.editor.internal.Analyzer.publishSysObjUpdateStatus(clientId,"success");
        end
    end



    methods(Static,Hidden)
        function[isImplemented,iconMode]=initialize(filePath,mt)







            dataMap=matlab.system.editor.internal.DocumentAction.Map;
            if dataMap.isKey(filePath)
                data=dataMap(filePath);
                data.ParseTree=mt;
                data.ParseTreeNeedsRecompute=isempty(mt);
            else






                data=struct(...
                'ParseTree',mt,...
                'ParseTreeNeedsRecompute',isempty(mt),...
                'DocumentHandle',[],...
                'RtcId',[],...
                'MethodsInfo',[],...
                'PropertyCount',0,...
                'StateCount',0,...
                'PreviewDialog',[],...
                'Analyzer',[],...
                'ShowErrorDialog',[],...
                'FilePathChangeFcn',[],...
                'ImageFileChooser',[],...
                'LaunchMaskEditor',[]);
            end

            if~isempty(mt)
                data.MethodsInfo=getMethodsInfo(mt);
            end

            dataMap(filePath)=data;%#ok<NASGU>

            methodsInfo=data.MethodsInfo;
            if~isempty(methodsInfo)
                isImplemented=methodsInfo.IsImplemented;
                iconMode=methodsInfo.IconImplementation;
            else
                isImplemented=logical.empty();
                iconMode=0;
            end
        end

        function onSave(filePath,isNonSystemObject)
            try


                C=disableDestructorWarnings;%#ok<NASGU>

                if isNonSystemObject
                    cleanup(filePath);
                else
                    externalDataFcn(filePath,'PreviewDialog',...
                    @matlab.system.editor.internal.DialogPreview.refresh,filePath);
                end
            catch e %#ok<NASGU>
            end
        end

        function[isImplemented,iconMode]=onUpdate(filePath)





            try

                putDataField(filePath,'ParseTreeNeedsRecompute',true);
                mt=synchronizedFcn(filePath,@getParseTree,filePath);

                methodsInfo=getDataField(filePath,'MethodsInfo');

                externalDataFcn(filePath,'Analyzer',@refreshAnalyzer,filePath,mt,methodsInfo)

                isImplemented=methodsInfo.IsImplemented;
                iconMode=methodsInfo.IconImplementation;

            catch e %#ok<NASGU>


                allMethodNames=matlab.system.editor.internal.CodeTemplate.AllVisibleSystemObjectMethodNames;
                isImplemented=false(1,numel(allMethodNames));
                iconMode=0;

                if isPresent(filePath)&&~isempty(getDataField(filePath,'Analyzer'))
                    externalDataFcn(filePath,'Analyzer',@analyzerError);
                end
            end
        end

        function onFilePathChange(oldFilePath,newFilePath,document)









            dataMap=matlab.system.editor.internal.DocumentAction.Map;

            if isempty(oldFilePath)
                keys=string(dataMap.keys);
                keys=keys(keys.startsWith("u"));
                if~isempty(keys)
                    oldFilePath=keys(end).char;
                else
                    return;
                end
            end
            data=dataMap(oldFilePath);
            dataMap(newFilePath)=data;
            dataMap.remove(oldFilePath);

            isConfirmedSystem=false;
            if nargin<3
                document=[];
                if~isempty(newFilePath)
                    document=matlab.desktop.editor.findOpenDocument(newFilePath);
                end
            end

            if~isempty(document)
                isConfirmedSystem=matlab.system.editor.internal.isSystemObjectFile(newFilePath,document.Text);
            end

            if~isConfirmedSystem


                cleanup(newFilePath);
            else

                externalDataFcn(newFilePath,'PreviewDialog',...
                @matlab.system.editor.internal.DialogPreview.refresh,newFilePath);


                externalDataFcn(newFilePath,'Analyzer',@analyzerFilePathChange,newFilePath,data)


                fcn=data.FilePathChangeFcn;
                if~isempty(fcn)
                    fcn(newFilePath);
                end
            end
        end

        function onClose(filePath)
            try


                C=disableDestructorWarnings;%#ok<NASGU>                
                document=matlab.desktop.editor.findOpenDocument(filePath);
                if~isempty(document)&&document.Opened

                    dataMap=matlab.system.editor.internal.DocumentAction.Map;
                    oldFilePath=getFirstKeyOf(dataMap,@(v)v.DocumentHandle==document);
                    if~isempty(oldFilePath)
                        matlab.system.editor.internal.DocumentAction.onFilePathChange(oldFilePath,filePath,document);
                    end
                else
                    cleanup(filePath);



                    matlab.system.editor.internal.DocumentAction.cleanupClosedDocuments;
                end
            catch e %#ok<NASGU>
            end
        end

        function onCloseJS(filePath)
            try


                C=disableDestructorWarnings;%#ok<NASGU>                
                cleanup(filePath);



                matlab.system.editor.internal.DocumentAction.cleanupClosedDocuments;
            catch e %#ok<NASGU>
            end
        end

        function processCmds(filePath,cmds)
            data=getData(filePath);

            mtreeNeedsRecompute=false;

            if~isempty(data.RtcId)
                for n=1:numel(cmds)
                    action=cmds{n}.Action;
                    if any(strcmp(action,{'insert','replace'}))
                        mtreeNeedsRecompute=true;
                        break;
                    end
                end

                rtcID=data.RtcId;
                channel=strcat('/editor/sysobj/processCommands/',rtcID);
                message.publish(channel,cmds);
            else


                document=data.DocumentHandle;

                for k=1:numel(cmds)
                    cmd=cmds{k};
                    switch cmd.Action
                    case 'insert'
                        document.insertTextAtPositionInLine(cmd.Text,cmd.Line,cmd.Column);
                        mtreeNeedsRecompute=true;
                    case 'select'
                        document.Selection=[cmd.StartLine,cmd.StartColumn,cmd.EndLine,cmd.EndColumn];
                        document.makeActive();
                    case 'replace'
                        startPosition=document.JavaEditor.lineAndColumnToPosition(cmd.StartLine,cmd.StartColumn);
                        endPosition=document.JavaEditor.lineAndColumnToPosition(cmd.EndLine,cmd.EndColumn);
                        document.JavaEditor.replaceText(cmd.Text,startPosition,endPosition);
                        mtreeNeedsRecompute=true;
                    end
                end
            end


            if mtreeNeedsRecompute
                data.ParseTreeNeedsRecompute=true;
                putData(filePath,data);
            end
        end

        function[folderName,className]=getInfoForFile(fileLocation)


            nameResolver=matlab.internal.language.introspective.resolveName(char(fileLocation));
            if isempty(nameResolver.classInfo)
                folderName=string(0);
                className=string(0);
            else
                classPath=nameResolver.classInfo.minimalPath;
                index=cell2mat(regexpi(classPath,{'\+','@'},'once'));
                if~isempty(index)
                    minIndex=min(index);
                    classPath=nameResolver.classInfo.minimalPath(minIndex:end);
                end
                folderName=string(erase(nameResolver.nameLocation,...
                strcat(filesep,classPath)));
                className=string(nameResolver.resolvedTopic);
            end
        end

        function result=findMethod(filePath,methodName)
            mt=synchronizedFcn(filePath,@getParseTree,filePath);
            result=false;
            methodNode=matlab.system.editor.internal.MethodAction.findMethodNode(mt,methodName);
            if~isempty(methodNode)
                result=true;
            end
        end
    end




    methods(Static,Hidden)
        function goto(filePath,pos)
            guardedDocumentOpenFcn(filePath,@moveCursorAndFocus,pos);
            externalDataFcn(filePath,'Analyzer',@analyzerUpdateStatus);
        end

        function updateAnalyzer(filePath,isLaunch)
            mt=getParseTree(filePath);
            methodsInfo=getDataField(filePath,'MethodsInfo');
            externalDataFcn(filePath,'Analyzer',@analyzerUpdate,filePath,mt,methodsInfo,isLaunch);
        end

        function showAnalyzer(filePath,msg)
            document=getDocument(filePath);
            externalDataFcn(filePath,'Analyzer',@matlab.system.editor.internal.Analyzer.show,document,msg);
        end
    end


    methods(Static,Hidden)
        function abortedAnalyzerLaunch(filePath,e)
            externalDataFcn(filePath,'Analyzer',@matlab.system.editor.internal.Analyzer.cleanup);

            showError(filePath,e,message('MATLAB:system:Editor:AnalyzerErrorTitle').getString());
        end
    end

    methods(Static,Access=protected)
        function synchronizeDocument(filePath)

            synchronizeDocumentImpl(filePath);
        end

        function cleanupClosedDocuments
            dataMap=matlab.system.editor.internal.DocumentAction.Map;
            keys=dataMap.keys;
            for k=1:numel(keys)
                key=keys{k};
                data=dataMap(key);
                try
                    document=data.DocumentHandle;
                    if isempty(document)||~document.Opened
                        cleanup(key);
                    end
                catch cleanupErr %#ok<NASGU>
                end
            end
        end

        function forceMtreeRecompute(filePath)
            if isPresent(filePath)
                putDataField(filePath,'ParseTreeNeedsRecompute',true);
            end
        end
    end
end





function varargout=guardedFcn(filePath,fcn,varargin)
    try
        [varargout{1:nargout}]=fcn(varargin{:});
    catch e
        showError(filePath,e);
        [varargout{1:nargout}]=deal([]);
    end
end

function varargout=customTitleGuardedFcn(filePath,titleID,fcn,varargin)
    try
        [varargout{1:nargout}]=fcn(varargin{:});
    catch e
        showError(filePath,e,message(titleID).getString());
        [varargout{1:nargout}]=deal([]);
    end
end

function varargout=synchronizedFcn(filePath,fcn,varargin)
    synchronizeDocumentImpl(filePath);
    [varargout{1:nargout}]=fcn(varargin{:});
end



function mtreeAction(filePath,fcn,varargin)
    mt=getParseTree(filePath);

    cmds=fcn(mt,varargin{:});

    matlab.system.editor.internal.DocumentAction.processCmds(filePath,cmds);
end

function varargout=mtreeActionFcnIgnoredDocument(~,varargin)
    [varargout{1:nargout}]=mtreeAction(varargin{:});
end

function documentOpenFcn(filePath,fcn,varargin)
    document=getDocument(filePath);

    if~isempty(document)&&document.Opened
        fcn(document,varargin{:});
    end
end


function flag=isPresent(filePath)
    dataMap=matlab.system.editor.internal.DocumentAction.Map;
    flag=dataMap.isKey(filePath);
end



function varargout=externalDataFcn(filePath,fieldName,fcn,varargin)
    dataMap=matlab.system.editor.internal.DocumentAction.Map;

    data=dataMap(filePath);

    [data.(fieldName),varargout{1:nargout}]=fcn(data.(fieldName),varargin{:});

    dataMap(filePath)=data;%#ok<NASGU>
end


function result=getDataField(filePath,fieldName)
    dataMap=matlab.system.editor.internal.DocumentAction.Map;
    data=dataMap(filePath);
    result=data.(fieldName);
end

function putDataField(filePath,fieldName,value)
    dataMap=matlab.system.editor.internal.DocumentAction.Map;
    data=dataMap(filePath);
    data.(fieldName)=value;
    dataMap(filePath)=data;%#ok<NASGU>
end

function data=getData(filePath)
    dataMap=matlab.system.editor.internal.DocumentAction.Map;
    data=dataMap(filePath);
end

function putData(filePath,data)
    dataMap=matlab.system.editor.internal.DocumentAction.Map;
    dataMap(filePath)=data;%#ok<NASGU>
end






function mtreeActionWithCode(filePath,fcn)
    document=getDocument(filePath);
    mtreeAction(filePath,fcn,document.Text);
end

function mtreeActionWithPropName(filePath,fcn,varargin)
    propName=getNextPropertyName(filePath);
    mtreeAction(filePath,fcn,propName,varargin{:});
end

function mtreeActionWithStateName(filePath,fcn)
    propName=getNextStateName(filePath);
    mtreeAction(filePath,fcn,propName);
end





function varargout=guardedSynchronizedFcn(filePath,fcn,varargin)
    [varargout{1:nargout}]=guardedFcn(filePath,@synchronizedFcn,filePath,fcn,varargin{:});
end

function guardedSynchronizedMtreeAction(filePath,fcn,varargin)
    guardedSynchronizedFcn(filePath,@mtreeAction,filePath,fcn,varargin{:});
end

function guardedSynchronizedMtreeActionWithCode(filePath,fcn)
    guardedSynchronizedFcn(filePath,@mtreeActionWithCode,filePath,fcn);
end

function guardedSynchronizedMtreeActionWithPropName(filePath,fcn,varargin)
    guardedSynchronizedFcn(filePath,@mtreeActionWithPropName,filePath,fcn,varargin{:});
end

function guardedSynchronizedMtreeActionWithStateName(filePath,fcn)
    guardedSynchronizedFcn(filePath,@mtreeActionWithStateName,filePath,fcn);
end

function guardedDocumentOpenFcn(filePath,fcn,varargin)
    guardedFcn(filePath,@documentOpenFcn,filePath,fcn,varargin{:});
end


function guardedDocumentOpenMtreeAction(filePath,fcn,varargin)
    guardedDocumentOpenFcn(filePath,@mtreeActionFcnIgnoredDocument,filePath,fcn,varargin{:});
end

function guardedSynchronizedExternalDataFcn(filePath,fieldName,fcn,varargin)
    guardedSynchronizedFcn(filePath,@externalDataFcn,filePath,fieldName,fcn,varargin{:})
end

function varargout=documentExternalDataFcn(filePath,fieldName,fcn,varargin)
    document=getDocument(filePath);
    [varargout{1:nargout}]=externalDataFcn(filePath,fieldName,fcn,document,varargin{:});
end

function varargout=synchronizedDocumentExternalDataFcn(filePath,fieldName,fcn,varargin)
    [varargout{1:nargout}]=synchronizedFcn(filePath,@documentExternalDataFcn,...
    filePath,fieldName,fcn,varargin{:});
end

function varargout=customTitleGuardedSynchronizedDocumentExternalDataFcn(filePath,titleID,fieldName,fcn,varargin)
    [varargout{1:nargout}]=customTitleGuardedFcn(filePath,titleID,...
    @synchronizedDocumentExternalDataFcn,filePath,fieldName,fcn,varargin{:});
end








function insertImageIcon(filePath,imageFile)
    guardedDocumentOpenMtreeAction(filePath,...
    @matlab.system.editor.internal.IconAction.insertImageIcon,imageFile);
end

function moveCursorAndFocus(document,pos)
    document.goToPositionInLine(pos(1),pos(2));
    document.makeActive();
end

function analyzer=refreshAnalyzer(analyzer,filePath,mt,methodsInfo)

    analyzer=matlab.system.editor.internal.Analyzer.refresh(analyzer,filePath,mt,...
    methodsInfo.ImplementedSystemObjectMethodsInfo,methodsInfo.ImplementedCustomMethodsInfo);
end

function analyzer=analyzerFilePathChange(analyzer,newFilePath,data)
    methodsInfo=data.MethodsInfo;
    mt=data.ParseTree;
    analyzer=matlab.system.editor.internal.Analyzer.onFilePathChanged(analyzer,newFilePath,mt,...
    methodsInfo.ImplementedSystemObjectMethodsInfo,methodsInfo.ImplementedCustomMethodsInfo);
end

function analyzer=analyzerUpdate(analyzer,filePath,mt,methodsInfo,isLaunch)
    matlab.system.editor.internal.Analyzer.update(filePath,analyzer,...
    mt,methodsInfo.ImplementedSystemObjectMethodsInfo,methodsInfo.ImplementedCustomMethodsInfo,...
    isLaunch);
end

function analyzer=analyzerUpdateStatus(analyzer)
    matlab.system.editor.internal.Analyzer.updateStatus(analyzer);
end

function analyzer=analyzerError(analyzer)
    analyzer=matlab.system.editor.internal.Analyzer.analyzerError(analyzer);
end

function v=getFirstKeyOf(dataMap,fcn)
    keys=dataMap.keys;
    for k=1:numel(keys)
        key=keys{k};
        testV=dataMap(key);
        if fcn(testV)
            v=key;
            return;
        end
    end
    v=[];
end

function propertyName=getNextPropertyName(filePath)


    dataMap=matlab.system.editor.internal.DocumentAction.Map;
    data=dataMap(filePath);
    newPropertyNum=data.PropertyCount+1;
    if newPropertyNum==1
        propertyName='Property';
    else
        propertyName=sprintf('Property%u',newPropertyNum);
    end
    data.PropertyCount=newPropertyNum;
    dataMap(filePath)=data;%#ok<NASGU>
end

function stateName=getNextStateName(filePath)


    dataMap=matlab.system.editor.internal.DocumentAction.Map;
    data=dataMap(filePath);
    newStateNum=data.StateCount+1;
    if newStateNum==1
        stateName='State';
    else
        stateName=sprintf('State%u',newStateNum);
    end
    data.StateCount=newStateNum;
    dataMap(filePath)=data;%#ok<NASGU>
end

function isValidDialog=isValidShowErrorDialogHandle(showErrorDialog)

    isValidDialog=~isempty(showErrorDialog)&&isvalid(showErrorDialog);
end

function initializeSynchronized(filePath)



    document=matlab.desktop.editor.findOpenDocument(filePath);
    mt=matlab.system.editor.internal.ParseTreeUtils.getTree(document.Text);
    matlab.system.editor.internal.DocumentAction.initialize(filePath,mt);
    synchronizeDocumentImpl(filePath);
end

function synchronizeDocumentImpl(filePath)
    dataMap=matlab.system.editor.internal.DocumentAction.Map;

    if dataMap.isKey(filePath)
        data=dataMap(filePath);
        document=data.DocumentHandle;

        if isempty(document)

            document=matlab.desktop.editor.findOpenDocument(filePath);
            data.DocumentHandle=document;


            assert(document.Opened);

            editor=document.Editor;
            if isprop(editor,'RtcId')
                data.RtcId=editor.RtcId;
            end

            dataMap(filePath)=data;%#ok<NASGU>

        elseif~document.Opened


            cleanup(filePath);
            initializeSynchronized(filePath);
        end
    else


        initializeSynchronized(filePath);
    end
end

function cleanup(filePath)
    dataMap=matlab.system.editor.internal.DocumentAction.Map;
    if dataMap.isKey(filePath)
        data=dataMap(filePath);
        try
            matlab.system.editor.internal.DialogPreview.cleanup(data.PreviewDialog);
        catch
        end

        try
            matlab.system.editor.internal.Analyzer.cleanup(data.Analyzer);
        catch
        end

        try
            matlab.system.editor.internal.IconAction.cleanup(data.ImageFileChooser);
        catch
        end

        try
            if isValidShowErrorDialogHandle(data.ShowErrorDialog)
                delete(data.ShowErrorDialog);
            end
        catch
        end


        dataMap.remove(filePath);
    end
end

function document=getDocument(filePath)
    dataMap=matlab.system.editor.internal.DocumentAction.Map;
    if dataMap.isKey(filePath)
        data=dataMap(filePath);
        document=data.DocumentHandle;
    else
        document=[];
    end
end

function mt=getParseTree(filePath)
    dataMap=matlab.system.editor.internal.DocumentAction.Map;
    data=dataMap(filePath);
    if data.ParseTreeNeedsRecompute
        document=data.DocumentHandle;
        mt=matlab.system.editor.internal.ParseTreeUtils.getTree(document.Text);
        data.ParseTree=mt;
        data.ParseTreeNeedsRecompute=false;
        if~matlab.system.editor.internal.ParseTreeUtils.isTreeError(mt)
            data.MethodsInfo=getMethodsInfo(mt);
        end
        dataMap(filePath)=data;%#ok<NASGU>
    else
        mt=data.ParseTree;
    end


    if matlab.system.editor.internal.ParseTreeUtils.isTreeError(mt)
        error(matlab.system.editor.internal.ParseTreeUtils.getTreeErrorMessage(mt))
    end
end




function methodsInfo=getMethodsInfo(mt)



    allMethodNames=matlab.system.editor.internal.CodeTemplate.AllVisibleSystemObjectMethodNames;


    [sysobjMethodInfo,customMethodInfo]=matlab.system.editor.internal.MethodAction.getAnalysisInfo(mt);
    implementedMethodNames={sysobjMethodInfo.Name};
    isImplemented=ismember(allMethodNames,implementedMethodNames);


    iconImplementationMode=0;
    if ismember('getIconImpl',implementedMethodNames)
        try %#ok<TRYNC>
            iconCode=matlab.system.editor.internal.IconAction.getIconExpression(mt);



            icon=eval(iconCode);
            if isa(icon,'matlab.system.display.Icon')
                iconImplementationMode=2;
            elseif isstring(icon)||ischar(icon)||iscellstr(icon)
                iconImplementationMode=1;
            end
        end
    end


    methodsInfo=struct(...
    'ImplementedSystemObjectMethodsInfo',sysobjMethodInfo,...
    'ImplementedCustomMethodsInfo',customMethodInfo,...
    'IsImplemented',isImplemented,...
    'IconImplementation',iconImplementationMode);
end

function isLocked=lockClass


    mlock;
    isLocked=true;
end

function showError(filePath,e,dlgTitle)





    document=getDocument(filePath);
    if isempty(document)||~document.Opened
        return;
    end


    dataMap=matlab.system.editor.internal.DocumentAction.Map;
    if dataMap.isKey(filePath)
        data=dataMap(filePath);
        if isValidShowErrorDialogHandle(data.ShowErrorDialog)
            delete(data.ShowErrorDialog);
        end
    end

    if nargin<3
        dlgTitle=message('MATLAB:system:Editor:CodeErrorTitle').getString;
    end
    synErrIDs={'MATLAB:system:Editor:CodeSyntaxError','MATLAB:system:Editor:CodeSyntaxErrorLine'};
    if any(strcmp(e.identifier,synErrIDs))

        dlg=errordlg(stripLinkFromMessage(e.message),dlgTitle);
    else
        [~,isNonSystemObject]=matlab.system.editor.internal.isSystemObjectFile(filePath,document.Text);
        if isNonSystemObject

            dlg=errordlg(message('MATLAB:system:Editor:CodeNotSystemObject').getString,dlgTitle);
        elseif matlab.system.editor.internal.DialogPreview.isDialogPreviewError(e.identifier)



            dlg=errordlg(stripLinkFromMessage(e.message),dlgTitle);
        else
            dlg=errordlg(message('MATLAB:system:Editor:CodeUnableToComplete',...
            stripLinkFromMessage(e.message)).getString,dlgTitle);
        end
    end

    data.ShowErrorDialog=dlg;
    dataMap(filePath)=data;%#ok<NASGU>
end

function errMsg=stripLinkFromMessage(errMsg)
    errMsg=regexprep(errMsg,'<a href.*?">(.*?)</a>','$1');
end

function C=disableDestructorWarnings
    w(1)=warning('off','MATLAB:class:DestructorError');
    w(2)=warning('off','MATLAB:class:CannotUpdateDelete');
    C=onCleanup(@()warning(w));
end

