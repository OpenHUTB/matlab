





classdef AppController<dig.CustomContext

    properties
        components={};
        runLabels={DAStudio.message('Simulink:Profiler:NoData')};
        uiNodeSrc;
        execNodeSrc;
        warnings;
        visibleSpreadSheetsAtHide=[];
        spreadSheetsVisible=true;
        listenerHandle=[];
        simModeCheckerHandle=[];
        spreadSheetFactory;

        DDGDialogGetter;

        fileDialogService;
        openSpreadSheetCount=0;
        emptySource=Simulink.internal.SimulinkProfiler.emptySource;
        lastKnownSimMode='';
        maxSpreadSheets=2;
    end

    properties(SetObservable=true)
        enableAddReportPanel=true;
    end

    properties(Hidden=true)


        dumpRawData=false;
    end



    methods(Access=public)
        function this=AppController(studio,app,spreadSheetFactory,ddgDialogGetter,fileDialogService)

            this@dig.CustomContext(app);

            if nargin<3


                spreadSheetFactory=Simulink.internal.SimulinkProfiler.SpreadSheetFactory;
                ddgDialogGetter=Simulink.internal.SimulinkProfiler.DDGDialogGetter;
                fileDialogService=Simulink.internal.SimulinkProfiler.FileDialogService;
            end

            this.spreadSheetFactory=spreadSheetFactory;
            this.DDGDialogGetter=ddgDialogGetter;
            this.fileDialogService=fileDialogService;
            this.createSpreadSheetComponent(studio);



            this.uiNodeSrc=containers.Map('KeyType','char','ValueType','any');
            this.execNodeSrc=containers.Map('KeyType','char','ValueType','any');
            this.warnings=containers.Map('KeyType','char','ValueType','char');

        end

        function hideSpreadSheet(this)
            this.visibleSpreadSheetsAtHide=[];
            for n=1:numel(this.components)
                if this.components{n}.isVisible
                    this.components{n}.hide();
                    this.visibleSpreadSheetsAtHide(end+1)=n;
                end
            end
            this.spreadSheetsVisible=false;
        end

        function showSpreadSheet(this)
            N=this.visibleSpreadSheetsAtHide;
            if isempty(N)
                N=1:numel(this.components);
            end
            for n=N
                this.components{n}.show();
            end
            this.spreadSheetsVisible=true;
        end

        function addRun(this,runLabel,uiSrc,execSrc,warning)
            if any(strcmp(this.runLabels,runLabel))
                dp=DAStudio.DialogProvider;
                dp.warndlg(DAStudio.message('Simulink:Profiler:RunAlreadyLoaded',runLabel),...
                DAStudio.message('Simulink:Profiler:SimulinkProfiler'),true);
                return;
            end
            if strcmp(this.runLabels{1},DAStudio.message('Simulink:Profiler:NoData'))
                this.runLabels(1)={runLabel};
            else
                this.runLabels(end+1)={runLabel};
            end
            this.uiNodeSrc(runLabel)=uiSrc;
            this.execNodeSrc(runLabel)=execSrc;
            this.warnings(runLabel)=warning;


            for n=1:numel(this.components)
                this.components{n}.DDGDialogSource.refresh();
            end
        end

        function deleteRun(this,runLabelToBeDeleted)
            uiSrcToBeDeleted=this.uiNodeSrc(runLabelToBeDeleted);
            execSrcToBeDeleted=this.execNodeSrc(runLabelToBeDeleted);

            deletedRunIdx=find(strcmp(this.runLabels,runLabelToBeDeleted),1);
            numberOfRunLabelsBeforeDelete=numel(this.runLabels);


            this.runLabels(deletedRunIdx)=[];
            if isempty(this.runLabels)
                this.runLabels={DAStudio.message('Simulink:Profiler:NoData')};
            end

            if numberOfRunLabelsBeforeDelete==1

                this.setSpreadSheetSources(1:numel(this.components),...
                DAStudio.message('Simulink:Profiler:NoData'));
            else






                newRunLabel=this.runLabels{1};
                showingDeletedRun=cellfun(@(component)(component.getSource==uiSrcToBeDeleted)||...
                (component.getSource==execSrcToBeDeleted),this.components);
                this.setSpreadSheetSources(showingDeletedRun,...
                newRunLabel);





                for n=find(~showingDeletedRun)
                    if this.components{n}.DDGDialogSource.value>(deletedRunIdx-1)
                        this.components{n}.DDGDialogSource.value=...
                        this.components{n}.DDGDialogSource.value-1;
                        this.components{n}.DDGDialogSource.refresh();
                    end
                end
            end



            this.uiNodeSrc.remove(runLabelToBeDeleted);
            this.execNodeSrc.remove(runLabelToBeDeleted);
            this.warnings.remove(runLabelToBeDeleted);
            delete(uiSrcToBeDeleted);
            delete(execSrcToBeDeleted);
        end

    end


    methods(Access={?Simulink.internal.SimulinkProfiler.SpreadSheetComponent})
        function incrementOpenSpreadSheetCount(this)
            this.openSpreadSheetCount=this.openSpreadSheetCount+1;
            this.checkNumberOfOpenSpreadSheets();
        end

        function decrementOpenSpreadSheetCount(this)
            this.openSpreadSheetCount=this.openSpreadSheetCount-1;
            this.checkNumberOfOpenSpreadSheets();
        end

    end


    methods(Access=public)

        function comp=createSpreadSheetComponent(this,studio)
            if numel(this.components)==this.maxSpreadSheets
                return;
            end

            nComponents=numel(this.components)+1;
            comp=Simulink.internal.SimulinkProfiler.SpreadSheetComponent(studio,this,nComponents,this.spreadSheetFactory,this.DDGDialogGetter);
            this.components{nComponents}=comp;
        end

        function setSpreadSheetSources(this,reportIdx,runLabel,viewMode)





            if islogical(reportIdx)
                reportIdx=find(reportIdx);
            end

            if nargin<4
                for n=reportIdx
                    this.components{n}.setSource(runLabel);
                end
            else
                for n=reportIdx
                    this.components{n}.setSource(runLabel,viewMode);
                end
            end
        end

        function endOfSimCleanup(this,src,paramState)
            set_param(src.Handle,'Profile',paramState);
            delete(this.listenerHandle);
            this.listenerHandle=[];
        end

        function checkSimMode(this,src,~)
            mode=get_param(src.Handle,'SimulationMode');
            if strcmpi(mode,'accelerator')
                diag=MSLDiagnostic(src.Handle,message('Simulink:Profiler:AccelNotSupported'));
                diag.reportAsWarning();
            elseif strcmpi(mode,'rapid-accelerator')
                diag=MSLDiagnostic(src.Handle,message('Simulink:Profiler:RapidAccelNotSupported'));
                diag.reportAsWarning();
            end
            delete(this.simModeCheckerHandle);
            this.simModeCheckerHandle=[];
        end

        function saveProfilerDataToMatFile(this,uiRow,execRow,runLabel,numberOfFiles,thisFileNumber)

            title=['Saving profiler report ',num2str(thisFileNumber),' of ',num2str(numberOfFiles)];
            [file,path]=this.fileDialogService.putfile(Simulink.internal.SimulinkProfiler.AppController.runLabelToFileName(runLabel),title);
            if file==0

                return;
            end
            wb=Simulink.internal.SimulinkProfiler.AppController.getWaitBar(...
            DAStudio.message('Simulink:Profiler:SavingData',file));%#ok<NASGU>



            rawData=Simulink.internal.SimulinkProfiler.HandleDataWrapper;
            rawData.rootExecNode=execRow;
            rawData.rootUINode=uiRow;
            profilerData=Simulink.internal.SimulinkProfiler.AppController.createUserNodeTree(rawData,runLabel);

            save(fullfile(path,file),'profilerData');
        end

        function runLabels=getOpenRunLabels(this)
            runLabels=cell(1,numel(this.components));
            for n=1:numel(this.components)
                toolbarWidget=this.components{n}.DDGDialogSource.getToolbarWidget();
                runLabels{n}=toolbarWidget.getComboBoxText('simulink_profiler_run_selector');
            end
        end

        function table=getExecutionStackData(this,data,levelStr,table)
            if isempty(data)
                return;
            end

            dim=size(table);
            len=dim(1)+1;
            x=strcat(levelStr,data.locationName,{'  '});
            table{len,1}=x{1};
            table{len,2}=num2str(data.totalTime,'%f');
            table{len,3}=num2str(data.selfTime,'%f');
            table{len,4}=num2str(data.numCalls);

            levelStr=strcat(levelStr,'--');

            if(~isempty(data.children))
                [~,I]=sort(arrayfun(@(x)x.('totalTime'),data.children));
                data.children=data.children(I);
                for i=length(data.children):-1:1
                    table=this.getExecutionStackData(data.children(i),levelStr,table);
                end
            end
        end

        function table=getModelHierarchyData(this,data,levelStr,table)
            if isempty(data)
                return;
            end

            dim=size(table);
            len=dim(1)+1;
            x=strcat(levelStr,data.objectPath,{'  '});
            table{len,1}=x{1};
            table{len,2}=num2str(data.totalTime,'%f');
            table{len,3}=num2str(data.selfTime,'%f');
            table{len,4}=num2str(data.numCalls);

            levelStr=strcat(levelStr,'--');

            if(~isempty(data.children))
                [~,I]=sort(arrayfun(@(x)x.('totalTime'),data.children));
                data.children=data.children(I);
                for i=length(data.children):-1:1
                    table=this.getModelHierarchyData(data.children(i),levelStr,table);
                end
            end
        end


        function table=generateReportHelper(this,data1,data2,runLabel)

            reportName=strrep(runLabel,'@','profilerReport');
            reportName=strrep(reportName,' ','_');
            reportName=strrep(reportName,':','_');
            reportName=strrep(reportName,'/','_');

            report=Simulink.internal.SimulinkProfiler.SimulinkProfilerReport(reportName,'html-file');


            profileReporter1=Simulink.internal.SimulinkProfiler.SimulinkProfilerReporter();


            profileReporter1.ReportTitle=...
            DAStudio.message('Simulink:Profiler:ReportTitleString',data1.objectPath{1});
            table{1,1}=DAStudio.message('Simulink:Profiler:TotalTime');
            table{1,2}=data1.totalTimeStr;
            table{2,1}=DAStudio.message('Simulink:Profiler:CurrentRun');
            table{2,2}=runLabel;
            table{3,1}='';
            table{3,2}='';
            profileReporter1.SummaryData=table;
            profileReporter1.TableTitle=DAStudio.message('Simulink:Profiler:ExecutionStackString');

            table2={};
            profileReporter1.TableData=this.getExecutionStackData(data1,'-',table2);


            profileReporter2=Simulink.internal.SimulinkProfiler.SimulinkProfilerReporter();


            profileReporter2.ReportTitle=...
            DAStudio.message('Simulink:Profiler:ReportTitleString',data1.objectPath{1});
            profileReporter2.SummaryData=table;

            table2={};
            profileReporter2.TableData=this.getModelHierarchyData(data2,'-',table2);
            profileReporter2.TableTitle=DAStudio.message('Simulink:Profiler:ModelHierarchyString');


            moduleTabs=mlreportgen.report.HTMLModuleTabs();
            tab1.Label=DAStudio.message('Simulink:Profiler:ExecutionStackString');
            tab1.Content=profileReporter1;
            tab2.Label=DAStudio.message('Simulink:Profiler:ModelHierarchyString');
            tab2.Content=profileReporter2;

            moduleTabs.TabsData=[tab1,tab2];
            append(report,moduleTabs);

            close(report);
            rptview(report);
        end

        function openPropertyInspector(~,cbinfo)
            studio=cbinfo.studio;
            pi=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');
            if~pi.isVisible
                studio.showComponent(pi);
            end
        end

        function checkNumberOfOpenSpreadSheets(this)
            if this.openSpreadSheetCount>=this.maxSpreadSheets
                this.enableAddReportPanel=false;
            else
                this.enableAddReportPanel=true;
            end
        end

    end







    methods(Static)

        function launchAppFromDebugTab(userdata,cbinfo)


            cbinfo.EventData='';
            Simulink.internal.SimulinkProfiler.AppController.toggleApp(userdata,cbinfo);
        end

        function toggleApp(userdata,cbinfo)




            c=dig.Configuration.get();
            app=c.getApp(userdata);

            if isempty(app)
                return;
            end



            modelHandle=cbinfo.Context.StudioApp.blockDiagramHandle;
            appController=Simulink.internal.SimulinkProfiler.AppControllerContainer.getController(modelHandle,cbinfo.studio,app);

            st=cbinfo.studio;
            sa=st.App;
            acm=sa.getAppContextManager;


            if isempty(cbinfo.EventData)

                acm.activateApp(appController);
                appController.showSpreadSheet();
                appController.openPropertyInspector(cbinfo);
            else

                acm.deactivateApp(app.name);
                appController.hideSpreadSheet();

                modelName=get_param(modelHandle,'Name');
                pi=st.getComponent('GLUE2:PropertyInspector','Property Inspector');
                dlg=DAStudio.ToolRoot.getOpenDialogs();
                for idx=1:numel(dlg)
                    src=dlg(idx).getDialogSource();
                    if~isa(src,'Simulink.internal.SimulinkProfiler.ExecRow')&&~isa(src,'Simulink.internal.SimulinkProfiler.UIrow')
                        continue;
                    end



                    if any(contains(src.objectPath,modelName))
                        obj=get_param(modelHandle,'Object');
                        pi.updateSource('GLUE2:PropertyInspector',obj);
                    end
                end
            end
        end

        function generateReport(cbinfo)
            controller=Simulink.internal.SimulinkProfiler.AppController.getControllerFromCbInfo(cbinfo);
            runLabels=controller.getOpenRunLabels();
            runLabels=unique(runLabels);
            if strcmp(runLabels{end},DAStudio.message('Simulink:Profiler:NoData'))
                return;
            end
            wb=Simulink.internal.SimulinkProfiler.AppController.getWaitBar(...
            DAStudio.message('Simulink:Profiler:PreparingReport'));%#ok<NASGU>            

            for n=1:numel(runLabels)
                execSrc=controller.execNodeSrc(runLabels{n});
                data1=execSrc.mData;
                uiSrc=controller.uiNodeSrc(runLabels{n});
                data2=uiSrc.mData;
                controller.generateReportHelper(data1,data2,runLabels{n});
            end
        end

        function saveData(cbinfo)
            controller=Simulink.internal.SimulinkProfiler.AppController.getControllerFromCbInfo(cbinfo);
            runLabels=controller.getOpenRunLabels();
            runLabels=unique(runLabels);
            if strcmp(runLabels{end},DAStudio.message('Simulink:Profiler:NoData'))
                return;
            end
            for n=1:numel(runLabels)
                uiSrc=controller.uiNodeSrc(runLabels{n});
                execSrc=controller.execNodeSrc(runLabels{n});
                controller.saveProfilerDataToMatFile(uiSrc.getChildren(),execSrc.getChildren(),runLabels{n},numel(runLabels),n);
            end
        end

        function loadData(cbinfo)
            controller=Simulink.internal.SimulinkProfiler.AppController.getControllerFromCbInfo(cbinfo);
            [file,path]=controller.fileDialogService.getfile('*.mat');
            if file==0
                return;
            end
            blocker=Simulink.internal.SimulinkProfiler.AppController.getWaitBar(...
            DAStudio.message('Simulink:Profiler:LoadingData',file));%#ok<NASGU>
            data=load(fullfile(path,file));
            f=fieldnames(data);
            if numel(f)>1

                dp=DAStudio.DialogProvider;
                dp.errordlg(DAStudio.message('Simulink:Profiler:InvalidDataTypeLoaded'),...
                DAStudio.message('Simulink:Profiler:SimulinkProfiler'),true);
                return;
            end
            data=data.(f{1});
            if~isa(data,'Simulink.profiler.Data')
                if isa(data,'Simulink.ProfilerData')
                    diag=MSLDiagnostic('Simulink:Profiler:UseSlprofreport',file);
                    diag.reportAsWarning();
                    slprofreport(data);
                    return;
                else
                    dp=DAStudio.DialogProvider;
                    dp.errordlg(DAStudio.message('Simulink:Profiler:InvalidDataTypeLoaded'),...
                    DAStudio.message('Simulink:Profiler:SimulinkProfiler'),true);
                    return;
                end
            end
            runLabel=char(data.run);
            if any(strcmp(runLabel,controller.runLabels))
                dp=DAStudio.DialogProvider;
                dp.warndlg(DAStudio.message('Simulink:Profiler:RunAlreadyLoaded',runLabel),...
                DAStudio.message('Simulink:Profiler:SimulinkProfiler'),true);
                return;
            end
            realData=data.extractRealData();
            uiData=realData.rootUINode;
            execData=realData.rootExecNode;
            uiSrc=Simulink.internal.SimulinkProfiler.SpreadSheetSource(uiData);
            execSrc=Simulink.internal.SimulinkProfiler.SpreadSheetSource(execData);
            controller.addRun(runLabel,uiSrc,execSrc,'');



            if controller.uiNodeSrc.length==1
                N=numel(controller.components);
            else
                N=1;
            end
            controller.setSpreadSheetSources(1:N,runLabel);

            if N==1


                controller.components{1}.setActive();
            end
        end

        function profile(cbinfo)
            controller=Simulink.internal.SimulinkProfiler.AppController.getControllerFromCbInfo(cbinfo);
            mh=cbinfo.Context.StudioApp.blockDiagramHandle;
            paramState=get_param(mh,'Profile');
            set_param(mh,'Profile','on');
            cosObj=get_param(mh,'InternalObject');
            controller.listenerHandle=addlistener(cosObj,'SLExecEvent::END_OF_SIM_MODEL_EVENT',...
            @(src,~)controller.endOfSimCleanup(src,paramState));
            controller.simModeCheckerHandle=addlistener(cosObj,'SLCompEvent::START_OF_COMPILE_MODEL_EVENT',...
            @controller.checkSimMode);

            SLM3I.SLCommonDomain.simulationStartPauseContinueFromHandleNAR(mh);
        end

        function exportCSV(cbinfo)
            disp("Export CSV");
        end

        function sendToFigure(cbinfo)
            disp("Send to figure");
        end

        function toggleReportVisible(cbinfo)
            controller=Simulink.internal.SimulinkProfiler.AppController.getControllerFromCbInfo(cbinfo);
            if controller.spreadSheetsVisible
                controller.hideSpreadSheet();
                controller.spreadSheetsVisible=false;
            else
                controller.showSpreadSheet();
                controller.spreadSheetsVisible=true;
            end
        end

        function addSpreadsheet(cbinfo)
            controller=Simulink.internal.SimulinkProfiler.AppController.getControllerFromCbInfo(cbinfo);
            for n=1:numel(controller.components)
                if~controller.components{n}.isVisible
                    controller.components{n}.show();
                    return;
                end
            end

            controller.createSpreadSheetComponent(cbinfo.studio);
            controller.setSpreadSheetSources(numel(controller.components),...
            controller.runLabels{end});
        end

        function result=featureOn

            result=slfeature('SimulinkProfilerV2')>=3;
        end

        function result=featureOff

            result=slfeature('SimulinkProfilerV2')<3;
        end

        function modeCheck(cbinfo,action)



            mh=cbinfo.Context.StudioApp.blockDiagramHandle;
            controller=Simulink.internal.SimulinkProfiler.AppControllerContainer.getController(mh,[]);
            if isempty(controller)
                action.enabled=false;
                return;
            end
            action.enabled=true;
            editor=cbinfo.Context.StudioApp.getActiveEditor;
            mh=cbinfo.Context.StudioApp.blockDiagramHandle;
            simMode=get_param(mh,'SimTabSimulationMode');




            modeIsSupported=any(strcmpi(["normal","accelerator"],simMode));
            if~modeIsSupported
                action.enabled=false;
            else
                action.enabled=true;
            end






            if strcmp(simMode,controller.lastKnownSimMode)


                return;
            else
                controller.lastKnownSimMode=simMode;
            end
            if~modeIsSupported
                editor.closeNotificationByMsgID('Simulink:Profiler:AccelNotSupported');
                m=message('Simulink:Profiler:SupportedModes');
                editor.deliverWarnNotification(m.Identifier,m.getString)
            elseif strcmpi(simMode,'accelerator')
                editor.closeNotificationByMsgID('Simulink:Profiler:SupportedModes');
                m=message('Simulink:Profiler:AccelNotSupported');
                editor.deliverWarnNotification(m.Identifier,m.getString);
            else
                editor.closeNotificationByMsgID('Simulink:Profiler:SupportedModes');
                editor.closeNotificationByMsgID('Simulink:Profiler:AccelNotSupported');
            end
        end

    end





    methods(Static)

        function profilerData=addFreshRun(data)
            h=get_param(data.rootUINode.objectPath{1},'handle');
            controller=Simulink.internal.SimulinkProfiler.AppControllerContainer.getController(h,[]);


            uiSrc=Simulink.internal.SimulinkProfiler.SpreadSheetSource(data.rootUINode);
            execSrc=Simulink.internal.SimulinkProfiler.SpreadSheetSource(data.rootExecNode);
            runLabel=[data.rootUINode.objectPath{1},' @ ',...
            char(datetime('now'))];


            if strcmpi(get_param(data.rootUINode.objectPath{1},'SimulationMode'),'accelerator')
                warning=DAStudio.message('Simulink:Profiler:AccelNotSupported');
            else
                warning='';
            end

            if~isempty(controller)
                controller.addRun(runLabel,uiSrc,execSrc,warning);



                for n=1:numel(controller.components)
                    if(n==1||(numel(controller.runLabels)==1))
                        controller.components{n}.setSource(runLabel);
                    end
                end

                controller.components{1}.setActive();

                if controller.dumpRawData
                    assignin('base','profData',data);
                end
            end


            profilerData=Simulink.internal.SimulinkProfiler.AppController.createUserNodeTree(data,runLabel);
        end

    end


    methods(Static,Access=private)

        function controller=getControllerFromCbInfo(cbinfo)
            mh=cbinfo.Context.StudioApp.blockDiagramHandle;
            controller=Simulink.internal.SimulinkProfiler.AppControllerContainer.getController(mh,[]);
            assert(~isempty(controller));
        end

    end


    methods(Static,Hidden)

        function profilerData=createUserNodeTree(rawProfilerData,runLabel)


            profilerData=Simulink.profiler.Data(rawProfilerData,runLabel);
        end

        function fileName=runLabelToFileName(runLabel)
            fileName=runLabel;
            fileName=strrep(fileName,' ','_');
            fileName=strrep(fileName,'@','');
            fileName=strrep(fileName,':','_');
            fileName=[fileName,'.mat'];
        end

        function wb=getWaitBar(labelText,maxVal)
            if nargin<2
                wb=SLM3I.ScopedStudioBlocker(labelText);
            else
                wb=SLM3I.ScopedStudioBlocker(labelText,0,maxVal);
            end
        end

    end

end
