classdef ImportDialog<handle





    methods(Static)

        function ret=getController(varargin)

            persistent ctrlObj;
            mlock;
            if isempty(ctrlObj)||~isvalid(ctrlObj)



                assert(nargin==1&&isa(varargin{1},'Simulink.sdi.internal.controllers.Dispatcher'));
                dispatcherObj=varargin{1};
                ctrlObj=Simulink.sdi.internal.controllers.ImportDialog(dispatcherObj);
            end


            ret=ctrlObj;
        end
    end


    methods(Hidden)

        function this=ImportDialog(dispatcherObj)

            this.Dispatcher=dispatcherObj;
            this.RunIDByIndexMap=Simulink.sdi.Map(int32(0),int32(0));

            import Simulink.sdi.internal.controllers.ImportDialog;
            this.Dispatcher.subscribe(...
            [ImportDialog.ControllerID,'/','get_initSetup'],...
            @(arg)cb_GetInitSetup(this,arg));
            this.Dispatcher.subscribe(...
            [ImportDialog.ControllerID,'/','get_existingRuns'],...
            @(arg)cb_updateRunList(this,arg));
            this.Dispatcher.subscribe(...
            [ImportDialog.ControllerID,'/','get_dataFromModel'],...
            @(arg)cb_getDataFromModel(this,arg));
            this.Dispatcher.subscribe(...
            [ImportDialog.ControllerID,'/','importFrom'],...
            @(arg)cb_importFromRadioButton(this,arg));
            this.Dispatcher.subscribe(...
            [ImportDialog.ControllerID,'/','importTo'],...
            @(arg)cb_importToRadioButton(this,arg));
            this.Dispatcher.subscribe(...
            [this.ControllerID,'/','excel_selectSheet'],...
            @(arg)cb_SelectSheet(this,arg));
            this.Dispatcher.subscribe(...
            [ImportDialog.ControllerID,'/','browseMATFile'],...
            @(arg)cb_browserMATFileButton(this,arg));
            this.Dispatcher.subscribe(...
            [ImportDialog.ControllerID,'/','get_matFileName'],...
            @(arg)cb_getMATFileName(this,arg));
            this.Dispatcher.subscribe(...
            [ImportDialog.ControllerID,'/','matFileName'],...
            @(arg)cb_setMATFileName(this,arg));
            this.Dispatcher.subscribe(...
            [ImportDialog.ControllerID,'/','refresh'],...
            @(arg)cb_RefreshButton(this,arg));
            this.Dispatcher.subscribe(...
            [ImportDialog.ControllerID,'/','ok'],...
            @(arg)cb_OKButton(this,arg));
            this.Dispatcher.subscribe(...
            [this.ControllerID,'/','excel_import_ok'],...
            @(arg)cb_ExcelImport(this,arg));
            this.Dispatcher.subscribe(...
            [ImportDialog.ControllerID,'/','closedialog'],...
            @(arg)cb_CancelButton(this,arg));
            this.Dispatcher.subscribe(...
            [ImportDialog.ControllerID,'/','help'],...
            @(arg)cb_HelpButton(this,arg));
            this.Dispatcher.subscribe(...
            [ImportDialog.ControllerID,'/','readmore'],...
            @(arg)cb_readMore(this,arg));
        end


        function cb_GetInitSetup(this,arg)



            import Simulink.sdi.internal.controllers.ImportDialog;



            parser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
            parser.resetParser();
            this.cb_CancelButton([]);

            this.ClientID=arg.clientID;
            setupData=struct;
            if(length(this.ValidExtensions)==1)
                this.initializeValidExtensions();
            end

            importer=Simulink.sdi.internal.import.FileImporter.getDefault();
            setupData.isVideoOn=(Simulink.sdi.enableSDIVideo()>1);
            setupData.isBagOn=importer.isBagOn&&setupData.isVideoOn;
            setupData.runList=this.getRunList;
            setupData.dataFromModel=this.getDataFromModel(arg);
            setupData.validFileExtensions=this.ValidExtensions;
            this.Dispatcher.publishToClient(arg.clientID,...
            ImportDialog.ControllerID,'set_initSetup',setupData);
        end


        function cb_RefreshButton(this,arg)




            this.transferDataToScreen(arg);
        end


        function cb_OKButton(this,arg)




            this.transferScreenToData(arg);
            parser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
            parser.resetParser();
        end


        function cb_CancelButton(this,~)




            this.Model.baseWSOrMAT=true;
            this.Model.newOrExistRun=true;
            this.Model.matFileName='';
            this.Model.PreferredImporter='';
        end


        function cb_HelpButton(~,~)

            Simulink.sdi.internal.controllers.SDIHelp('importDataHelp');
        end


        function cb_readMore(this,~)

            fileName=this.Model.matFileName;
            [~,~,ext]=fileparts(fileName);
            if strcmpi(erase(ext,'.'),'csv')
                Simulink.sdi.internal.controllers.SDIHelp('importDataFormatCSV');
            else
                Simulink.sdi.internal.controllers.SDIHelp('importDataFormats');
            end
        end


        function cb_browserMATFileButton(this,arg)






            import Simulink.sdi.internal.controllers.ImportDialog;



            isLabeler=false;

            if isstruct(arg.data)
                if isfield(arg.data,'appName')&&strcmp(arg.data.appName,'signallabeler')
                    isLabeler=true;
                end
                arg.data=arg.data.filename;
            end

            if isfield(arg,'data')&&~isempty(arg.data)
                this.Model.matFileName=arg.data;
                this.Model.PreferredImporter='';
                status=true;
            else
                status=this.openMatFile();
            end





            isMldatx=false;
            fileName=this.Model.matFileName;
            if~isempty(fileName)
                [~,~,fExt]=fileparts(fileName);
                if strcmpi(fExt,'.mldatx')
                    isMldatx=true;
                end
            end


            if isfield(arg.data,'appName')&&isSessionMATFile(this,arg.clientID,arg.data.appName)&&~isLabeler
                status=false;
            elseif isSessionMATFile(this,arg.clientID,'sdi')&&~isLabeler
                status=false;
            end


            if status

                this.cb_getMATFileName(arg);
                this.transferDataToScreen(arg);
            else


                if~isMldatx
                    fileName=[];
                end
                this.Dispatcher.publishToClient(arg.clientID,...
                ImportDialog.ControllerID,'set_matFileName',fileName);
            end
        end


        function cb_getMATFileName(this,arg)




            import Simulink.sdi.internal.controllers.ImportDialog;
            matFileName=this.Model.matFileName;
            if isempty(matFileName)
                matFileName=[];
            end

            this.Dispatcher.publishToClient(arg.clientID,...
            ImportDialog.ControllerID,'set_matFileName',matFileName);
        end


        function cb_setMATFileName(this,arg)





            this.Model.matFileName=arg.data.filePath;
            this.Model.PreferredImporter='';

            if isempty(arg.data.filePath)
                return;
            end


            if arg.data.selected_importer>0
                idx=arg.data.selected_importer+1;
                importers=io.reader.getSupportedReadersForFile(arg.data.filePath);
                if idx<=numel(importers)
                    this.Model.PreferredImporter=char(importers(idx));
                end
                Simulink.sdi.internal.controllers.ImportDialog.getHierarchicalData();
            end


            isMATFile=false;
            if exist(arg.data.filePath,'file')
                if Simulink.sdi.internal.Util.isFileExtensionValid(arg.data.filePath,this.ValidExtensions)
                    isMATFile=true;
                end
            end



            if~isSessionMATFile(this,arg.clientID,arg.data.appName)
                this.transferDataToScreen(arg);
            elseif~isMATFile
                this.Dispatcher.publishToClient(arg.clientID,...
                Simulink.sdi.internal.controllers.ImportDialog.ControllerID,'matFilenameError',[]);
                return;
            else
                this.Dispatcher.publishToClient(arg.clientID,...
                Simulink.sdi.internal.controllers.ImportDialog.ControllerID,'set_matFileName',[]);
            end
        end


        function cb_importFromRadioButton(this,arg)




            this.importFromRadio(arg);
        end


        function cb_importToRadioButton(this,arg)




            this.importToRadio(arg);
        end


        function cb_SelectSheet(this,arg)




            this.ExcelModel.useExistingSheet=strcmp(arg.data,'useExistingSheet');
        end


        function cb_updateRunList(this,arg)




            import Simulink.sdi.internal.controllers.ImportDialog;
            runList=this.getRunList;
            this.Dispatcher.publishToClient(arg.clientID,...
            ImportDialog.ControllerID,'set_existingRuns',...
            runList);
        end


        function cb_getDataFromModel(this,arg)
            this.transferDataToScreen(arg);
        end

    end


    methods(Access=private)

        function transferDataToScreen(this,arg)




            import Simulink.sdi.internal.controllers.ImportDialog;
            outData=this.getDataFromModel(arg);
            if~isempty(outData)
                this.Dispatcher.publishToClient(arg.clientID,...
                ImportDialog.ControllerID,'set_dataFromModel',...
                outData);
            end
        end


        function initializeValidExtensions(this)
            importer=Simulink.sdi.internal.import.FileImporter.getDefault();
            this.ValidExtensions=importer.getAllValidFileExtensions();
        end


        function outData=getDataFromModel(this,~)
            import Simulink.sdi.internal.controllers.ImportDialog;

            outData.baseWSOrMAT=this.Model.baseWSOrMAT;
            outData.matFileName=this.Model.matFileName;

            outData.importers={'built-in'};
            outData.selected_importer=0;
            if~isempty(outData.matFileName)
                [outData.importers,outData.selected_importer]=...
                locGetImportersAndSelection(outData.matFileName,this.Model.PreferredImporter);
            end
        end


        function varOutputs=getHierarchicalDataFromParser(this,varParser)




            message.publish('/sdi2/progressUpdate',struct('dataIO','begin','appName','sdi'));
            tmp=onCleanup(@()message.publish('/sdi2/progressUpdate',struct('dataIO','end','appName','sdi')));

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

            if~hasRun&&hasError
                if this.Model.baseWSOrMAT==0

                    this.Dispatcher.publishToClient(this.ClientID,...
                    this.ControllerID,'matFilenameError',...
                    errorMsg.message);
                end
            end

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
                varOutput.Dimensions=int2str(getSampleDims(varParser));
                varOutput.PortIndex=int2str(getPortIndex(varParser));
                extendedSDIProps=getExtendedSDIProperties(varParser);
                if isfield(extendedSDIProps,'OverridePortIndex')&&...
                    extendedSDIProps.OverridePortIndex
                    varOutput.PortIndex='';
                end
                if isempty(strtrim(varOutput.Name))


                    varOutput.Name=this.getUpdatedSignalLabel(varOutput);
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
                                    checkedValues=[checkedValues,isVariableChecked(this.HierarchialDataMap{childRowID}.VarParser)];%#ok<AGROW>
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


        function transferScreenToData(this,arg)




            info=arg.data;
            if isscalar(info.indices)&&(info.indices==0)
                return;
            end

            parser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
            eng=Simulink.sdi.Instance.engine;


            ws=warning('off',...
            'Simulink:Logging:ModelDataLogConvertError_StateflowNotSupported');
            cleanupWarning=onCleanup(@()warning(ws));


            if~info.is_workspace&&info.selected_importer>0
                idx=info.selected_importer+1;
                importers=io.reader.getSupportedReadersForFile(info.filename);
                if idx<=numel(importers)
                    this.Model.PreferredImporter=char(importers(idx));
                end
            end

            if isempty(info.selectedRun)
                try
                    if info.is_workspace

                        runName='Run <run_index>: Imported_Data';
                        mdlName='';
                        appName='sdi';
                        parser.createRun(eng,this.VarParser,runName,mdlName,appName);
                    else

                        importer=Simulink.sdi.internal.import.FileImporter.getDefault();
                        importer.verifyFileAndImport(...
                        sdi.Repository(1),...
                        info.filename,'Run <run_index>: Imported_Data',...
                        false,...
                        int32(0),...
                        'reader',this.Model.PreferredImporter,...
                        'parser',this.VarParser);
                    end
                catch

                    msgStr=getString(message('SDI:sdi:TimeNotIncMonotonicallyErr'));
                    titleStr=getString(message('SDI:sdi:ImportError'));
                    okStr=getString(message('SDI:sdi:OKShortcut'));
                    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
                    ctrl=Simulink.sdi.internal.controllers.ImportDialog.getController();
                    fw.displayMsgBox(...
                    'default',...
                    titleStr,...
                    msgStr,...
                    {okStr},...
                    0,...
                    -1,...
                    [],...
                    'clientID',ctrl.ClientID);
                    return;
                end
                this.cb_updateRunList(arg);
            else
                if this.RunIDByIndexMap.isKey(info.selectedRun)
                    runID=this.RunIDByIndexMap.getDataByKey(info.selectedRun);
                    try
                        if info.is_workspace
                            addToRun(parser,eng,runID,this.VarParser);
                        else
                            runName=Simulink.sdi.getRun(runID).Name;
                            importer=Simulink.sdi.internal.import.FileImporter.getDefault();
                            importer.verifyFileAndImport(...
                            sdi.Repository(1),...
                            info.filename,runName,...
                            false,...
                            runID,...
                            this.Model.PreferredImporter,...
                            this.VarParser);
                        end
                    catch


                        return;
                    end
                    Simulink.sdi.loadSDIEvent();
                end
            end
        end


        function cb_ExcelImport(this,arg)





            parser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
            eng=Simulink.sdi.Instance.engine;
            try
                if this.ExcelModel.useExistingSheet

                    runName='Run <run_index>: Imported_Data';
                    mdlName='';
                    appName='sdi';
                    runID=parser.createRun(eng,this.VarParser,runName,mdlName,appName);
                else

                    importer=Simulink.sdi.internal.import.FileImporter.getDefault();
                    runID=importer.verifyFileAndImport(...
                    sdi.Repository(1),...
                    this.Model.matFileName,...
                    'Run <run_index>: Imported_Data',...
                    false,...
                    int32(0),...
                    this.Model.PreferredImporter,...
                    this.VarParser);
                end
            catch




                return;
            end


            run=Simulink.sdi.getRun(runID);
            signals=cell(1,run.signalCount);

            for idx=1:run.signalCount
                signal=run.getSignalByIndex(idx);
                signals{idx}=struct('Name',signal.Name);
                signals{idx}.TimeSeries.Time=signal.Values.Time;
                signals{idx}.TimeSeries.Data=signal.Values.Data;
                metaData.Type=strcat('Type: ',signal.DataType);
                metaData.Units=strcat('Units: ',mat2str(signal.Units));
                metaData.InterpMethod=strcat('InterpMethod: ',signal.InterpMethod);
                metaData.BlockPath=strcat('BlockPath: ',mat2str(signal.BlockPath));
                metaData.PortIndex=strcat('PortIndex: ',num2str(signal.PortIndex));

                signals{idx}.metaData=metaData;
            end

            this.Dispatcher.publishToClient(arg.clientID,...
            this.ControllerID,'excel_import_data',jsonencode(signals));

            Simulink.sdi.deleteRun(runID);
        end


        function status=openMatFile(this)

            SD=Simulink.sdi.internal.StringDict;

            if(length(this.ValidExtensions)==1)
                this.initializeValidExtensions();
            end
            dlgFilter=Simulink.sdi.internal.Util.uigetfileFilter(this.Model.matFileName,'import',this.ValidExtensions);
            [LoadFileName,LoadPathName]=...
            uigetfile(dlgFilter,SD.MATLoadTitle);
            status=~isequal(LoadFileName,0);
            if status
                this.Model.matFileName=fullfile(LoadPathName,LoadFileName);
                this.Model.PreferredImporter='';
            end
        end


        function ret=isSessionMATFile(this,clientID,appName)
            fname=this.Model.matFileName;
            try
                fver=Simulink.sdi.internal.Util.getSDIMatFileVersion(fname,this.ValidExtensions);
            catch me %#ok<NASGU>
                ret=false;
                return
            end
            ret=fver>0;
            if ret
                msgStr=message('SDI:sdi:ImportSessionFile').getString();
                titleStr=message('SDI:sdi:ImportSessionFileTitle').getString();
                yesStr=message('SDI:sdi:ImportSessionFileOkButtonShortcut').getString();
                noStr=message('SDI:sdi:CancelShortcut').getString();

                Simulink.sdi.internal.controllers.SessionSaveLoad.displayMsgBox(...
                appName,...
                titleStr,...
                msgStr,...
                {yesStr,noStr},...
                0,...
                1,...
                @(x)this.openMATfileDuringImport(fname,clientID,appName,x));
                this.Model.matFileName='';
            end
        end


        function openMATfileDuringImport(this,fname,clientID,appName,choice)
            if choice==0
                ctrlObj=Simulink.sdi.internal.controllers.SessionSaveLoad.getController(appName);
                loadSession(ctrlObj,fname);
                this.Dispatcher.publishToClient(clientID,...
                Simulink.sdi.internal.controllers.ImportDialog.ControllerID,'hideGUI',...
                []);
            end
        end


        function importFromRadio(this,arg)





            this.Model.baseWSOrMAT=strcmp(arg.data,'imBaseWorkspace');
            this.transferDataToScreen(arg);
        end


        function importToRadio(this,arg)




            this.Model.newOrExistRun=strcmp(arg.data,'imNewRun');
        end


        function runList=getRunList(this)
            this.RunIDByIndexMap=Simulink.sdi.Map(int32(0),int32(0));


            repo=sdi.Repository(1);
            allRunIDs=Simulink.sdi.getAllRunIDs();
            runCount=length(allRunIDs);
            runList=cell(1,runCount);
            if runCount>0
                for idx=1:runCount
                    runID=allRunIDs(idx);
                    runName=repo.getRunDisplayName(runID);
                    runList{idx}=runName;
                    this.RunIDByIndexMap.insert(idx,runID);
                end
            else
                runList={Simulink.sdi.internal.StringDict.SelectRun};
            end
        end
    end

    methods
        function value=get.Model(this)
            if isempty(this.Model)
                eng=Simulink.sdi.Instance.engine;
                this.Model=Simulink.sdi.internal.models.ImportDialog(eng);
            end
            value=this.Model;
        end

        function value=get.ExcelModel(this)
            if isempty(this.ExcelModel)
                eng=Simulink.sdi.Instance.engine;
                this.ExcelModel=Simulink.sdi.internal.models.ExcelImportDialog(eng);
            end
            value=this.ExcelModel;
        end
    end


    methods(Static,Hidden)

        function varOutputs=getHierarchicalData()
            varOutputs=[];


            Simulink.SimulationData.utValidSignalOrCompositeData([],true);
            tmp=onCleanup(@()Simulink.SimulationData.utValidSignalOrCompositeData([],false));

            ctrlObj=Simulink.sdi.internal.controllers.ImportDialog.getController();
            wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
            ctrlObj.VarParser={};
            if ctrlObj.Model.baseWSOrMAT==1

                ctrlObj.VarParser=parseBaseWorkspace(wksParser);
            else
                if~isempty(ctrlObj.Model.matFileName)

                    fileName=ctrlObj.Model.matFileName;
                    [~,~,ext]=fileparts(fileName);


                    importer=Simulink.sdi.internal.import.FileImporter.getDefault();
                    if~isempty(fileName)&&~isempty(ext)&&Simulink.sdi.internal.Util.isFileExtensionValid(fileName,importer.getAllValidFileExtensions())
                        fileParser=importer.getParser(ext,fileName,ctrlObj.Model.PreferredImporter);
                        importer.FileName=fileName;
                    end
                    try
                        ctrlObj.VarParser=fileParser.getVarParser(wksParser,fileName);
                    catch me
                        if~isSessionMATFile(ctrlObj,ctrlObj.ClientID,...
                            'sdi')
                            ctrlObj.Dispatcher.publishToClient(ctrlObj.ClientID,...
                            ctrlObj.ControllerID,'matFilenameError',...
                            me.message);
                        end
                        return;
                    end
                end
            end
            if~isempty(ctrlObj.VarParser)
                varOutputs=ctrlObj.getHierarchicalDataFromParser(ctrlObj.VarParser);
            else


                ctrlObj.Dispatcher.publishToClient(...
                ctrlObj.ClientID,...
                ctrlObj.ControllerID,...
                'hideSpinner',true);
            end
        end


        function updatedRows=updateCheckedState(rowIDs,checkedValue)
            ctrlObj=Simulink.sdi.internal.controllers.ImportDialog.getController();
            updatedRows=ctrlObj.updateCheckedStateInHierarchicalData(rowIDs,checkedValue);
        end
    end


    properties(Hidden)
        ClientID;
        Dispatcher;
        Model;
        ExcelModel;
        RunIDByIndexMap;
        VarParser;
        HierarchialDataMap;
        ValidExtensions={'.mat'};
    end


    properties(Constant)
        ControllerID='importDataDialog';
    end
end

function[importers,sel]=locGetImportersAndSelection(fname,prefImporter)
    sel=0;
    classNames=io.reader.getSupportedReadersForFile(fname);
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

