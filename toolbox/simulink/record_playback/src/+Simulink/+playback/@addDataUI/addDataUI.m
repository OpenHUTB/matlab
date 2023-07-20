

classdef addDataUI<handle


    methods




        function this=addDataUI(varargin)

            if~nargin

                return;
            end
            this.Config=varargin{1};
            this.Dispatcher=this.Config.Dispatcher;
            this.Engine=Simulink.sdi.Instance.engine;
            this.Dispatcher.subscribe(...
            [this.Config.BlockId,'/','get_initSetup'],...
            @(arg)cb_GetInitSetup(this,arg));
            this.Dispatcher.subscribe(...
            [this.Config.BlockId,'/','browseMATFile'],...
            @(arg)cb_browserMATFileButton(this,arg));
            this.Dispatcher.subscribe(...
            [this.Config.BlockId,'/','requestCustomReaders'],...
            @(arg)cb_setCustomReaders(this,arg));
            this.Dispatcher.subscribe(...
            [this.Config.BlockId,'/','getfileinfo'],...
            @(arg)cb_publishFileInfo(this,arg));
        end


        function delete(this)
            close(this);
        end


        function close(this,varargin)
            if~isempty(this.Dialog)
                delete(this.Dialog);
            end
        end


        function openGUI(this,varargin)
            import Simulink.playback.addDataUI;
            if~isempty(this.Dialog)&&isvalid(this.Dialog)&&this.Dialog.isOpen

                return;
            end
            url=this.getURL();
            isDebug=addDataUI.debugMode();
            useExternalBrowser=addDataUI.useExternalBrowser();
            if isDebug&&useExternalBrowser


                blockName=get_param(this.Config.BlockHandle,'name');
                url=[url,'&blockName=',blockName];
                web(url,'-browser');
            else

                bUseCEF=~useExternalBrowser;
                bHide=true;
                pos=Simulink.playback.addDataUI.getDefaultPosition();
                blockName=get_param(this.Config.BlockHandle,'name');
                title=append(getString(message('record_playback:playbackui:AddDataTitle')),": ",blockName);
                this.Dialog=Simulink.HMI.BrowserDlg(...
                url,char(title),pos,...
                [],...
                bUseCEF,...
                isDebug,...
                @()onBrowserClose(this),...
                bHide);
            end
        end


        function bringToFront(this)
            import Simulink.playback.addDataUI;
            isDebug=addDataUI.debugMode();
            useExternalBrowser=addDataUI.useExternalBrowser();
            if~useExternalBrowser
                if isempty(this.Dialog)
                    this.openGUI();
                else
                    this.Dialog.bringToFront();
                end
            else
                if isDebug
                    appName='addsignal-debug';
                else
                    appName='addsignal';
                end
                if~Simulink.sdi.WebClient.appIsConnected(appName)
                    this.openGUI();
                end
            end
        end


        function setSize(this,w,h)
            if~isempty(this.Dialog)
                pos=this.Dialog.CEFWindow.Position;
                this.Config.Position=[pos(1:2),w,h];
                this.Dialog.CEFWindow.Position=this.Config.Position;
            end
        end


        function url=getURL(this)
            import Simulink.playback.addDataUI;
            apiObj=Simulink.sdi.internal.ConnectorAPI.getAPI();
            isDebug=addDataUI.debugMode();
            if isDebug
                url=getURL(apiObj,this.DEBUG_URL);
            else
                url=getURL(apiObj,this.REL_URL);
            end
            url=[url,'&blockId=',this.Config.BlockId];
        end

        function value=get.ExcelModel(this)
            if isempty(this.ExcelModel)
                eng=Simulink.sdi.Instance.engine;
                this.ExcelModel=Simulink.sdi.internal.models.ExcelImportDialog(eng);
            end
            value=this.ExcelModel;
        end


        function updatedRows=updateCheckedStateInHierarchicalData(this,rowIDs,checkedValue)




            updatedRows=[];
            numRowsIDs=length(rowIDs);
            for n=1:numRowsIDs
                rowID=rowIDs(n);
                if length(this.HierarchialDataMap)>=rowID
                    setVariableChecked(this.HierarchialDataMap{rowID}.VarParser,checkedValue);
                    updateRowCheckedState(rowID,checkedValue);
                    updateChildrenCheckedState(rowID,checkedValue);
                    updateParentCheckedState(rowID,checkedValue);
                end
            end

            function updateRowCheckedState(rowID,checkedValue)


                row=struct;
                row.RowID=rowID;
                row.CheckedState=checkedValue;
                updatedRows=[updatedRows,row];
            end

            function updateChildrenCheckedState(rowID,checkedValue)


                if isfield(this.HierarchialDataMap{rowID},'Children')&&...
                    ~isempty(this.HierarchialDataMap{rowID}.Children)
                    children=this.HierarchialDataMap{rowID}.Children;
                    numChildren=length(children);
                    for c=1:numChildren
                        childRowID=children(c);
                        if length(this.HierarchialDataMap)>=childRowID
                            setVariableChecked(this.HierarchialDataMap{childRowID}.VarParser,checkedValue);
                            updateRowCheckedState(childRowID,checkedValue);
                            updateChildrenCheckedState(childRowID,checkedValue);
                        end
                    end
                end
            end

            function updateParentCheckedState(rowID,checkedValue)



                if isfield(this.HierarchialDataMap{rowID},'ParentID')&&...
                    this.HierarchialDataMap{rowID}.ParentID~=0
                    parentRowID=this.HierarchialDataMap{rowID}.ParentID;
                    if checkedValue==2
                        if~isVariableChecked(this.HierarchialDataMap{parentRowID}.VarParser)
                            setVariableChecked(this.HierarchialDataMap{parentRowID}.VarParser,1);
                        end
                        updateRowCheckedState(parentRowID,checkedValue);
                        updateParentCheckedState(parentRowID,checkedValue);
                    else
                        if length(this.HierarchialDataMap)>=parentRowID&&...
                            isfield(this.HierarchialDataMap{parentRowID},'Children')&&...
                            ~isempty(this.HierarchialDataMap{parentRowID}.Children)
                            children=this.HierarchialDataMap{parentRowID}.Children;
                            numChildren=length(children);
                            checkedValues=[];
                            for c=1:numChildren
                                childRowID=children(c);
                                if length(this.HierarchialDataMap)>=childRowID
                                    checkedValues=[checkedValues,isVariableChecked(this.HierarchialDataMap{childRowID}.VarParser)];
                                end
                            end
                            if all(checkedValues==1)
                                setVariableChecked(this.HierarchialDataMap{parentRowID}.VarParser,1);
                                newCheckedValue=1;
                            else
                                if all(checkedValues==0)
                                    setVariableChecked(this.HierarchialDataMap{parentRowID}.VarParser,0);
                                    newCheckedValue=0;
                                else
                                    if~isVariableChecked(this.HierarchialDataMap{parentRowID}.VarParser)
                                        setVariableChecked(this.HierarchialDataMap{parentRowID}.VarParser,1);
                                    end
                                    newCheckedValue=2;
                                end
                            end
                            updateRowCheckedState(parentRowID,newCheckedValue);
                            updateParentCheckedState(parentRowID,newCheckedValue);
                        end
                    end
                end
            end
        end


        function varOutputs=getParsedDataFromFile(this,filePath,customParser)
            varOutputs=[];
            [~,~,ext]=fileparts(filePath);
            importer=Simulink.sdi.internal.import.FileImporter.getDefault();
            if~Simulink.sdi.internal.Util.isFileExtensionValid(filePath,importer.getAllValidFileExtensions())
                ME=MException('Playback:AddDataError','Invalid file extension');
                throw(ME);
            end
            fileParser=importer.getParser(ext,filePath,customParser);
            importer.FileName=filePath;
            wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
            this.VarParser=fileParser.getVarParser(wksParser,filePath);
            varOutputs=getHierarchicalDataFromParser(this,this.VarParser);
        end

        function varOuputs=getParsedDataFromVarParser(this,varParser)
            varOuputs=[];
            this.VarParser=varParser;
            varOuputs=getHierarchicalDataFromParser(this,this.VarParser);
        end
    end


    methods(Hidden,Static)

        function isDebug=debugMode(mode)

            mlock;
            persistent pbIsDebug;
            if nargin>0
                pbIsDebug=mode;
            elseif isempty(pbIsDebug)
                pbIsDebug=false;
            end
            isDebug=pbIsDebug;
        end


        function useExternal=useExternalBrowser(mode)

            mlock;
            persistent pbUseExternalBrowser;
            if nargin>0
                pbUseExternalBrowser=mode;
            elseif isempty(pbUseExternalBrowser)
                pbUseExternalBrowser=false;
            end
            useExternal=pbUseExternalBrowser;
        end


        function ret=getDefaultPosition()
            import Simulink.playback.addDataUI;

            width=addDataUI.DEFAULT_WIDTH;
            height=addDataUI.DEFAULT_HEIGHT;

            r=groot;
            screenWidth=r.ScreenSize(3);
            screenHeight=r.ScreenSize(4);
            maxWidth=addDataUI.MAX_SIZE_SCALE_FACTOR*screenWidth;
            maxHeight=addDataUI.MAX_SIZE_SCALE_FACTOR*screenHeight;
            if maxWidth>0&&width>maxWidth
                width=maxWidth;
            end
            if maxHeight>0&&height>maxHeight
                height=maxHeight;
            end

            xOffset=(screenWidth-width)/2;
            yOffset=(screenHeight-height)/2;

            ret=[xOffset,yOffset,width,height];
        end


        function outData=openMatFile(this)

            SD=Simulink.sdi.internal.StringDict;

            if(length(this.ValidExtensions)==1)
                this.initializeValidExtensions();
            end



            dlgFilter=Simulink.sdi.internal.Util.uigetfileFilter('','import',this.ValidExtensions);
            [LoadFileName,LoadPathName]=...
            uigetfile(dlgFilter,SD.MATLoadTitle);
            status=~isequal(LoadFileName,0);
            outData=[];
            outData.status=status;
            if status
                outData.matFileName=fullfile(LoadPathName,LoadFileName);
            end
        end

    end


    methods(Access=private)

        function varOutputs=getHierarchicalDataFromParser(this,varParser)




            ws=warning('off',...
            'Simulink:Logging:ModelDataLogConvertError_StateflowNotSupported');
            cleanupWarning=onCleanup(@()warning(ws));
            this.HierarchialDataMap={};
            varOutputs=[];
            id=0;
            hasRun=false;
            hasError=false;
            errorMsg='';
            traverseHierarchy(varParser);

            function traverseHierarchy(varParser,varargin)

                numVars=length(varParser);
                for i=1:numVars
                    parentID=0;
                    if~isempty(varargin)&&nargin>0
                        parentID=varargin{1};
                    end
                    vParser=varParser{i};
                    setVariableChecked(vParser,1);
                    try
                        children=getChildren(vParser);
                        if vParser.getRepresentsRun()
                            hasRun=true;
                        end
                    catch me
                        hasError=true;
                        errorMsg=me;
                        continue;
                    end
                    if allowSelectiveChildImport(vParser)&&~isempty(children)
                        if~isVirtualNode(vParser)||...
                            alwaysShowInImportUI(vParser)
                            id=id+1;
                            varOutputs=[varOutputs,populateData(vParser,id,parentID,1)];
                            parentID=id;
                        end
                        traverseHierarchy(children,parentID);
                    elseif~isVirtualNode(vParser)
                        id=id+1;
                        varOutputs=[varOutputs,populateData(vParser,id,parentID,0)];
                    else
                        traverseHierarchy(children,parentID);
                    end
                end
            end

            function varOutput=populateData(varParser,varargin)

                varOutput=struct;
                id=0;
                parentID=0;
                hasChildren=0;
                if~isempty(varargin)
                    if nargin>0
                        id=varargin{1};
                    end
                    if nargin>1
                        parentID=varargin{2};
                    end
                    if nargin>2
                        hasChildren=varargin{3};
                    end
                end
                varOutput.RowID=id;
                varOutput.ParentID=parentID;
                varOutput.HasChildren=hasChildren;
                varOutput.Name=getSignalLabel(varParser);
                varOutput.BlockPath=getBlockSource(varParser);
                varOutput.Model=getModelSource(varParser);
                varOutput.Dimensions=num2str(getSampleDims(varParser));
                varOutput.PortIndex=num2str(getPortIndex(varParser));
                extendedSDIProps=getExtendedSDIProperties(varParser);
                if isfield(extendedSDIProps,'OverridePortIndex')&&...
                    extendedSDIProps.OverridePortIndex
                    varOutput.PortIndex='';
                end
                if isempty(strtrim(varOutput.Name))


                    varOutput.Name=this.getUpdatedSignalLabel(varOutput);
                end
                varOutput.RootSource=getRootSource(varParser);
                index=strfind(varOutput.RootSource,'.');
                if~isempty(index)
                    varOutput.RootSource=char(extractBetween(varOutput.RootSource,...
                    1,index(1)-1));
                end
                if isempty(varOutput.RootSource)
                    varOutput.RootSource=varOutput.Name;
                end


                this.HierarchialDataMap{id}=struct;
                this.HierarchialDataMap{id}.ParentID=parentID;
                this.HierarchialDataMap{id}.VarParser=varParser;
                if parentID==0
                    this.HierarchialDataMap{id}.Children=[];
                else
                    if~isfield(this.HierarchialDataMap{parentID},'Children')
                        this.HierarchialDataMap{parentID}.Children=id;
                    else
                        this.HierarchialDataMap{parentID}.Children=[this.HierarchialDataMap{parentID}.Children,id];
                    end
                end
            end
        end


        function updatedLabel=getUpdatedSignalLabel(~,dataRow)


            if isempty(strtrim(dataRow.Name))&&...
                ~isempty(dataRow.BlockPath)&&...
                ~isempty(dataRow.PortIndex)...

                index=strfind(dataRow.BlockPath,dataRow.Model);
                if index==1
                    blockSourceToUse=dataRow.BlockPath(length(dataRow.Model)+2:end);
                else
                    blockSourceToUse=dataRow.BlockPath;
                end
                updatedLabel=[blockSourceToUse,':',num2str(dataRow.PortIndex)];
            else
                updatedLabel=dataRow.Name;
            end
        end


        function initializeValidExtensions(this)
            importer=Simulink.sdi.internal.import.FileImporter.getDefault();
            this.ValidExtensions=importer.getAllValidFileExtensions();
        end
    end


    methods(Hidden)

        function cb_GetInitSetup(this,arg)






            this.Engine.WksParser.resetParser();
            this.ClientID=arg.clientID;
            mainApp=Simulink.playback.mainApp.getController(this.Config);
            mainApp.AddDataUi.ClientID=arg.clientID;
            setupData=struct;
            if(length(this.ValidExtensions)==1)
                this.initializeValidExtensions();
            end
            setupData.validFileExtensions=this.ValidExtensions;
            setupData.BlockPath=this.Config.BlockPath;
            setupData.BlockId=this.Config.BlockId;
            setupData.BlockHandle=getSimulinkBlockHandle(this.Config.BlockPath);
            this.Dispatcher.publishToClient(arg.clientID,...
            this.ControllerID,'set_initSetup',setupData);
        end


        function onBrowserClose(obj)
            obj.close();
        end


        function cb_browserMATFileButton(this,arg)




            if isstruct(arg.data)
                arg.data=arg.data.filename;
            end

            fileData=[];
            if isfield(arg,'data')&&~isempty(arg.data)
                fileData.matFileName=arg.data;
                fileData.status=true;
            else
                fileData=this.openMatFile(this);
            end


            if fileData.status

                if isempty(fileData.matFileName)
                    fileData.matFileName=[];
                end
                fileInfo=Simulink.playback.internal.getFileInfo(fileData.matFileName);
                this.Dispatcher.publishToClient(arg.clientID,...
                this.ControllerID,'set_matFileName',fileInfo);
            else

                this.Dispatcher.publishToClient(arg.clientID,...
                this.ControllerID,'set_matFileName',[]);
            end
        end


        function cb_publishFileInfo(this,arg)




            fileInfo=Simulink.playback.internal.getFileInfo(arg.data.filePath);
            this.Dispatcher.publishToClient(arg.clientID,...
            this.ControllerID,'updateFileName',fileInfo);
        end


        function cb_setCustomReaders(this,arg)





            matFileName=arg.data.filePath;
            PreferredImporter='';
            outData=[];
            outData.importers={'built-in'};
            outData.selected_importer=0;
            outData.customReaderClassNames={''};
            if~isempty(matFileName)
                [outData.importers,outData.selected_importer,outData.customReaderClassNames]=...
                locGetImportersAndSelection(matFileName,PreferredImporter);
            end
            this.Dispatcher.publishToClient(arg.clientID,...
            this.ControllerID,'set_customReaders',...
            outData);
        end
    end


    methods(Static,Hidden)

        function varOutputs=getBaseWorkSpaceHierarchicalData(blockID)
            varOutputs=[];
            config=[];
            config.BlockId=blockID;
            mainApp=Simulink.playback.mainApp.getController(config);
            ctrlObj=mainApp.AddDataUi;
            wksParser=ctrlObj.Engine.WksParser;
            ctrlObj.VarParser={};


            SLBlkPath=Simulink.BlockPath(ctrlObj.Config.BlockPath);
            cellPaths=SLBlkPath.convertToCell();
            modelName=extractBefore(cellPaths{1},'/');

            modelWksVars=Simulink.playback.addDataUI.getModelWorkspaceVariables(modelName);
            baseWksVars=Simulink.playback.addDataUI.getBaseWorkspaceVariables();
            maskWksVars=Simulink.playback.addDataUI.getMaskVariables(ctrlObj.Config.BlockPath);

            vars=horzcat(modelWksVars,baseWksVars,maskWksVars);

            vars=unique(vars);


            if~isempty(vars)
                numVars=length(vars);
                wksVars(numVars)=struct('VarName','','VarValue',[]);
                for varIdx=1:numVars
                    try
                        wksVars(varIdx).VarValue=slResolve(char(vars(varIdx)),ctrlObj.Config.BlockPath);
                        wksVars(varIdx).VarName=char(vars(varIdx));
                    catch

                    end
                end

                ctrlObj.VarParser=wksParser.parseVariables(wksVars);
                if~isempty(ctrlObj.VarParser)
                    varOutputs=ctrlObj.getHierarchicalDataFromParser(ctrlObj.VarParser);
                end
            end
        end


        function vars=getModelWorkspaceVariables(modelName)

            vars={};
            mdlWks=get_param(modelName,'ModelWorkspace');
            if~isempty(mdlWks)
                varInfo=evalin(mdlWks,'whos');
                if~isempty(varInfo)
                    numVars=length(varInfo);
                    for idx=1:numVars
                        vars{end+1}=varInfo(idx).name;%#ok <AGROW>
                    end
                end
            end
        end


        function vars=getBaseWorkspaceVariables

            varInfo=evalin('base','whos');
            vars={};
            if~isempty(varInfo)
                numVars=length(varInfo);
                for idx=1:numVars
                    vars{end+1}=varInfo(idx).name;%#ok <AGROW>
                end
            end
        end


        function vars=getMaskVariables(blkPath)


            vars={};
            parent=get_param(blkPath,'Parent');
            while~isempty(parent)
                try
                    maskWksVars=get_param(parent,'MaskWSVariables');
                    if~isempty(maskWksVars)
                        for idx=1:numel(maskWksVars)
                            vars{end+1}=maskWksVars(idx).Name;%#ok <AGROW>
                        end
                    end
                    parent=get_param(parent,'Parent');
                catch
                    parent=get_param(parent,'Parent');


                end
            end
        end


        function varOutputs=getFileHierarchicalData(blockID,fileName,preferredImporter)
            varOutputs=[];
            config=[];
            config.BlockId=blockID;
            mainApp=Simulink.playback.mainApp.getController(config);
            ctrlObj=mainApp.AddDataUi;
            wksParser=ctrlObj.Engine.WksParser;
            ctrlObj.VarParser={};
            if~isempty(fileName)
                [~,~,ext]=fileparts(fileName);


                importer=Simulink.sdi.internal.import.FileImporter.getDefault();
                if~isempty(fileName)&&~isempty(ext)&&Simulink.sdi.internal.Util.isFileExtensionValid(fileName,importer.getAllValidFileExtensions())
                    fileParser=importer.getParser(ext,fileName,preferredImporter);
                    importer.FileName=fileName;
                end
                try
                    ctrlObj.VarParser=fileParser.getVarParser(wksParser,fileName);
                catch me
                    ctrlObj.Dispatcher.publishToClient(ctrlObj.ClientID,...
                    ctrlObj.ControllerID,'matFilenameError',...
                    me.message);
                    return;
                end
            end
            if~isempty(ctrlObj.VarParser)
                varOutputs=ctrlObj.getHierarchicalDataFromParser(ctrlObj.VarParser);
            end
        end
    end


    properties
        ClientID;
        Config;
        Engine;
    end

    properties(Hidden)
        Dialog;
        ExcelModel;
        Dispatcher;
        VarParser;
        HierarchialDataMap;
        ValidExtensions={'.mat'};
    end


    properties(Hidden,Constant)
        MAX_SIZE_SCALE_FACTOR=0.8;
        DEFAULT_WIDTH=450;
        DEFAULT_HEIGHT=550;
        REL_URL='toolbox/simulink/record_playback/src/web/playback/addsignalview.html';
        DEBUG_URL='toolbox/simulink/record_playback/src/web/playback/addsignalview-debug.html';
    end


    properties(Constant)
        ControllerID='addDataUI';
    end
end

function[importers,sel,classNamesCell]=locGetImportersAndSelection(fname,prefImporter)
    sel=0;
    classNames=io.reader.getSupportedReadersForFile(fname);
    classNamesCell=cellstr(classNames);
    importers=cell(size(classNames));
    for idx=1:numel(classNames)
        try
            obj=eval(classNames(idx));
            dscStr=obj.getDescription();
            cStr=char(classNames(idx));
            if isempty(dscStr)
                importers{idx}=cStr;
            else
                importers{idx}=sprintf('%s (%s)',dscStr,cStr);
            end
        catch me %#ok<NASGU>
            cStr=char(classNames(idx));
            importers{idx}=cStr;
        end
        if strcmpi(cStr,prefImporter)
            sel=idx-1;
        end
    end
end

