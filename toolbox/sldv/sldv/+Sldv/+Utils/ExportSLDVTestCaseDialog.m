classdef ExportSLDVTestCaseDialog<handle




    properties(SetObservable=true)
model
sldvDataFile
harnessOwner
testHarnessList
testHarnessInd
testHarnessSrc
testHarnessTestDataFormat
testHarnessSelection
testFileSelection
defaultName
testFileName
newTestFileName
reuseTestFileName
testCaseList
testCaseInfoList
testCaseInd
        modelClosing=false;
readonly
resultDialogH
hModelCloseListener
hModelStatusListener
dialogOwnerModel
reuseHarness
dialog
    end

    methods

        function this=ExportSLDVTestCaseDialog(harnessOwner,sldvDataFile,defaultName,resultDialogH,reuseHarness)
            this.readonly=false;
            this.resultDialogH=resultDialogH;
            this.sldvDataFile=sldvDataFile;
            this.harnessOwner=harnessOwner;
            this.testHarnessInd=0;
            this.testHarnessSelection=0;
            this.testHarnessSrc=0;
            this.testHarnessTestDataFormat=0;
            this.testFileSelection=0;
            hList=Simulink.harness.find(harnessOwner.getFullName);







            this.testHarnessList={hList(cellfun(@(x,y)(y~=2)&&(strcmp(x,'Inport')||strcmp(x,'Signal Builder')||strcmp(x,'Signal Editor')),...
            {hList.origSrc},{hList.synchronizationMode})).name};
            this.model=bdroot(this.harnessOwner.Path);
            this.defaultName=defaultName;

            this.testCaseList={DAStudio.message('Simulink:Harness:ExportTestCaseDialog_NewTestCase')};
            this.testCaseInfoList={[]};
            this.testCaseInd=0;
            this.setDefaultTestFileName();
            this.testFileName=this.newTestFileName;
            this.reuseTestFileName='';

            hList=Simulink.harness.find(this.model,'OpenOnly','on');
            if isempty(hList)
                this.dialogOwnerModel=this.model;
            else
                this.dialogOwnerModel=hList.name;


                if hList.synchronizationMode==2
                    this.testHarnessList={hList.name};
                end
                if reuseHarness
                    this.testHarnessSelection=1;
                    [~,ii]=ismember(hList.name,this.testHarnessList);
                    this.testHarnessInd=ii-1;
                end
            end
            this.reuseHarness=reuseHarness;
            this.dialog=[];
        end

        function setDefaultTestFileName(this)
            if~isempty(this.newTestFileName)
                return;
            end
            s=load(this.sldvDataFile);
            sldvData=s.sldvData;

            opts=sldvData.AnalysisInformation.Options;
            modelH=get_param(this.model,'Handle');
            conflictMode=opts.MakeOutputFilesUnique;
            fullPath=Sldv.utils.settingsFilename(opts.SlTestFileName,...
            conflictMode,'.mldatx',modelH,false,true,opts);

            if strcmp(conflictMode,'off')
                id=1;
                [path,name,ext]=fileparts(fullPath);
                while id>=1
                    if~stm.internal.isTestFileOpen(fullPath)
                        break;
                    end
                    fullPath=fullfile(path,[name,num2str(id),ext]);
                    id=id+1;
                end
            end
            this.newTestFileName=fullPath;
        end




        function varType=getPropDataType(this,varName)%#ok
            switch(varName)
            case{'defaultName',...
                'newTestFileName',...
                'reuseTestFileName',...
                'testFileName'}
                varType='string';
            case{'testHarnessSelection',...
                'testHarnessInd',...
                'testHarnessSrc',...
                'testHarnessTestDataFormat',...
                'testFileSelection',...
                'testCaseInd'}
                varType='int';
            otherwise
                varType='other';
            end
        end

        function setPropValue(obj,varName,varVal)
            DAStudio.Protocol.setPropValue(obj,varName,varVal);
            if strcmp(varName,'testFileName')
                if obj.testFileSelection==0
                    obj.newTestFileName=varVal;
                else
                    obj.reuseTestFileName=varVal;
                end
            end
        end

        function dlgCloseMethod(this)
            if this.modelClosing
                return
            end
            sldvprivate('urlcall','delete_export_progress_bar');
            if~isempty(this.resultDialogH)
                this.resultDialogH.setEnabled('browserarea',true);
                this.resultDialogH.setEnabled('logarea',true);
            end
        end

        function dlgHelpMethod(~)
            try
                mapFile=fullfile(docroot,'sltest','helptargets.map');
                helpview(mapFile,'ExportDVTestCasesToSLTestTag');
            catch ME
                dp=DAStudio.DialogProvider;
                dp.errordlg(ME.message,'Error',true);
            end
        end

        function setReadonly(this,dlg,val)
            this.readonly=val;
            dlg.setEnabled('HarnessList',~val);
        end

        function[status,msg]=dlgPostApplyMethod(this,dlg)
            status=false;
            msg=[];

            try

                if isempty(this.testFileName)
                    msg=DAStudio.message('Simulink:Harness:ExportTestCaseDialog_InvalidTestFileName');
                    return;
                end
                removeOldTestSuites=false;

                this.setReadonly(dlg,true);
                sldvprivate('urlcall','create_export_progress_bar');

                prevFlagVal=Simulink.harness.internal.CreateFromDialogFlag(true);
                cleanUp=onCleanup(@()Simulink.harness.internal.CreateFromDialogFlag(prevFlagVal));
                if this.testCaseInd>0
                    [~,~,tFileName,tcOBJ]=sltest.import.sldvData(this.sldvDataFile,...
                    'TestCase',this.testCaseInfoList{this.testCaseInd+1});
                else
                    if this.testHarnessSelection>0
                        createHarnessFlag=false;
                    else
                        createHarnessFlag=true;
                    end


                    if createHarnessFlag

                        activeHarness=Simulink.harness.find(this.model,'OpenOnly','on');
                        if~isempty(activeHarness)
                            delete(this.hModelCloseListener);
                            delete(this.hModelStatusListener);



                            Simulink.harness.close(activeHarness.ownerFullPath,activeHarness.name);
                        end

                        if this.testHarnessSrc==0
                            src='Inport';
                        elseif this.testHarnessSrc==1
                            src='Signal Editor';
                        else
                            src='Signal Builder';
                        end

                        file=this.testFileName;
                        if exist(file,'file')&&this.testFileSelection==0
                            removeOldTestSuites=true;
                        end

                        if this.testHarnessTestDataFormat==1

                            excelFilePath=fileparts(this.testFileName);
                            [status,excelFileName]=stm.internal.util.createUniqueFile(excelFilePath,...
                            [this.model,'_sldvdata.xlsx']);
                            excelFilePath=fullfile(excelFilePath,excelFileName);
                        else
                            excelFilePath='';
                        end
                        [~,~,tFileName,tcOBJ]=sltest.import.sldvData(this.sldvDataFile,...
                        'CreateHarness',true,...
                        'TestHarnessName',this.defaultName,...
                        'TestHarnessSource',src,...
                        'TestFileName',file,...
                        'ExcelFilePath',excelFilePath);
                    else
                        name=this.testHarnessList{1+this.testHarnessInd};
                        file=this.testFileName;
                        if exist(file,'file')&&this.testFileSelection==0
                            removeOldTestSuites=true;
                        end
                        [~,~,tFileName,tcOBJ]=sltest.import.sldvData(this.sldvDataFile,...
                        'CreateHarness',false,...
                        'TestHarnessName',name,...
                        'TestFileName',file);

                    end
                end

                sltest.testmanager.view;
                testFileObj=tcOBJ.TestFile;
                sltest.testmanager.load(tFileName);
                if removeOldTestSuites==true
                    ts=tcOBJ.Parent;
                    tsList=testFileObj.getTestSuites();
                    for i=1:length(tsList)
                        if~strcmp(ts.Name,tsList(i).Name)
                            tsList(i).remove();
                        end
                    end
                    ts.Name='New Test Suite 1';
                end
                testFileObj.saveToFile;

                sldvprivate('urlcall','update_sltest_result',urlencode(this.sldvDataFile),urlencode('dummy'),tFileName);
                status=true;
            catch ME
                sldvprivate('urlcall','delete_export_progress_bar');

                import Sldv.Utils.ExportSLDVTestCaseDialog;
                ExportSLDVTestCaseDialog.addListener(this,dlg);

                this.setReadonly(dlg,false);


                Simulink.harness.internal.error(ME,true);



                msg=DAStudio.message('Simulink:Harness:SLDVExportAborted');
            end

        end

        function addTestCase(this,ts)
            tc=ts.getTestCases();
            for i=1:length(tc)
                name=this.testHarnessList{1+this.testHarnessInd};
                isRealTime=any(cell2mat(tc(i).RunOnTarget));
                if strcmp(tc(i).getProperty('Model'),this.model)&&...
                    strcmp(tc(i).getProperty('HarnessName'),name)&&...
                    ~isRealTime
                    name=tc(i).Name;
                    x=tc(1);
                    useDot=false;
                    while~isa(x.Parent,'sltest.testmanager.TestFile')
                        if useDot
                            name=['...',' > ',name];
                        else
                            name=[x.Parent.Name,' > ',name];
                            useDot=true;
                        end
                        x=x.Parent;
                    end

                    this.testCaseList{end+1}=name;
                    this.testCaseInfoList{end+1}=tc(i);
                end
            end
            ts1=ts.getTestSuites();
            for i=1:length(ts1)
                this.addTestCase(ts1(i));
            end
        end

        function harnessSrcCBox_cb(this,val)
        end

        function harnessRBtn_cb(this,val)
            this.updateTestCaseList();
        end

        function harnessCBox_cb(this,val)
            this.updateTestCaseList();
        end

        function testCaseCBox_cb(this,val)
        end

        function updateTestCaseList(this)

            this.testCaseList={DAStudio.message('Simulink:Harness:ExportTestCaseDialog_NewTestCase')};
            this.testCaseInfoList={[]};
            this.testCaseInd=0;

            if this.testFileSelection>0&&...
                this.testHarnessSelection&&...
                exist(this.testFileName,'file')==2

                tf=sltest.testmanager.TestFile(this.testFileName);
                ts=tf.getTestSuites();
                for i=1:length(ts)
                    this.addTestCase(ts(i));
                end
            end
        end

        function testFileBrowseBtn_cb(this)
            if this.testFileSelection>0
                [file,path]=uigetfile('*.mldatx',DAStudio.message('Simulink:Harness:ExportTestCaseDialog_SelectTestFile'));
                if~isequal(file,0)&&~isequal(path,0)
                    this.reuseTestFileName=fullfile(path,file);
                    this.testFileName=this.reuseTestFileName;
                    this.updateTestCaseList();
                end
            else
                [file,path]=uiputfile('*.mldatx',DAStudio.message('Simulink:Harness:ExportTestCaseDialog_CreateTestFile'));
                if~isequal(file,0)&&~isequal(path,0)
                    this.newTestFileName=fullfile(path,file);
                    this.testFileName=this.newTestFileName;
                    this.updateTestCaseList();
                end
            end
        end

        function testFileRBtn_cb(this)
            if this.testFileSelection==0

                this.testFileName=this.newTestFileName;
            else
                this.testFileName=this.reuseTestFileName;
            end
            this.updateTestCaseList();
        end









        function[items,newRow]=addTestHarnessOptskUI(this,curRow)


            harnessRBtn.Name='';
            harnessRBtn.Type='radiobutton';
            harnessRBtn.ObjectProperty='testHarnessSelection';
            harnessRBtn.Mode=true;
            harnessRBtn.DialogRefresh=true;
            harnessRBtn.Entries={DAStudio.message('Simulink:Harness:ExportTestCaseDialog_NewTestHarness'),...
            DAStudio.message('Simulink:Harness:ExportTestCaseDialog_ResuseTestHarness')};
            harnessRBtn.Value=this.testHarnessSelection;
            harnessRBtn.Values=[0,1];
            harnessRBtn.MethodArgs={'%value'};
            harnessRBtn.ArgDataTypes={'mxArray'};
            harnessRBtn.ObjectMethod='harnessRBtn_cb';
            harnessRBtn.Tag='ExportDlgHarnessRBtn';


            harnessCBox.Name=DAStudio.message('Simulink:Harness:ExportTestCaseDialog_TestHarness');
            harnessCBox.Type='combobox';
            harnessCBox.Mode=true;
            harnessCBox.DialogRefresh=true;
            harnessCBox.Entries=this.testHarnessList;
            harnessCBox.Values=0:1:length(this.testHarnessList)-1;
            harnessCBox.ObjectProperty='testHarnessInd';
            harnessCBox.MethodArgs={'%value'};
            harnessCBox.ArgDataTypes={'mxArray'};
            harnessCBox.ObjectMethod='harnessCBox_cb';
            harnessCBox.Tag='ExportDlgHarnessCBox';


            harnessEBox.Name=DAStudio.message('Simulink:Harness:ExportTestCaseDialog_TestHarness');
            harnessEBox.Type='edit';
            harnessEBox.Mode=true;
            harnessEBox.DialogRefresh=true;
            harnessEBox.ObjectProperty='defaultName';
            harnessEBox.Tag='ExportDlgHarnessEBox';

            if isempty(this.testHarnessList)
                harnessRBtn.Enabled=false;
                harnessRBtn.Visible=false;
                harnessCBox.Visible=false;
                harnessEBox.Visible=true;
            else
                harnessRBtn.Enabled=true;
                if this.testHarnessSelection>0
                    harnessEBox.Visible=false;
                    harnessCBox.Visible=true;
                else
                    harnessEBox.Visible=true;
                    harnessCBox.Visible=false;
                end
            end


            harnessSrcCBox.Name=DAStudio.message('Simulink:Harness:ExportTestCaseDialog_TestHarnessSrc');
            harnessSrcCBox.Type='combobox';
            harnessSrcCBox.Mode=true;
            harnessSrcCBox.DialogRefresh=true;
            harnessSrcCBox.Entries={'Inport','Signal Editor','Signal Builder'};
            harnessSrcCBox.Values=[0,1,2];
            harnessSrcCBox.ObjectProperty='testHarnessSrc';
            harnessSrcCBox.ArgDataTypes={'mxArray'};
            harnessSrcCBox.MethodArgs={'%value'};
            harnessSrcCBox.ObjectMethod='harnessSrcCBox_cb';
            harnessSrcCBox.Tag='ExportDlgHarnessSrcCBox';


            harnessTestDataFormatCBox.Name=DAStudio.message('Simulink:Harness:ExportTestCaseDialog_TestDataFormat');
            harnessTestDataFormatCBox.Type='combobox';
            harnessTestDataFormatCBox.Mode=true;
            harnessTestDataFormatCBox.DialogRefresh=true;
            harnessTestDataFormatCBox.Entries={'MAT','Excel'};
            harnessTestDataFormatCBox.Values=[0,1];
            harnessTestDataFormatCBox.ObjectProperty='testHarnessTestDataFormat';
            harnessTestDataFormatCBox.ArgDataTypes={'mxArray'};
            harnessTestDataFormatCBox.MethodArgs={'%value'};
            harnessTestDataFormatCBox.ObjectMethod='';
            harnessTestDataFormatCBox.Tag='ExportDlgHarnessTestDataFormatCBox';

            if this.testHarnessSelection>0
                hName=this.testHarnessList{1+this.testHarnessInd};
                harnessInfo=Simulink.harness.find(this.harnessOwner.getFullName(),'Name',hName);
                if strcmp(harnessInfo.origSrc,'Signal Builder')
                    harnessSrcCBox.Value=2;
                    this.testHarnessSrc=2;
                elseif strcmp(harnessInfo.origSrc,'Signal Editor')
                    harnessSrcCBox.Value=1;
                    this.testHarnessSrc=1;
                else
                    harnessSrcCBox.Value=0;
                    this.testHarnessSrc=0;
                end
                harnessSrcCBox.Enabled=false;
            else
                harnessSrcCBox.Enabled=true;
            end


            if harnessSrcCBox.Enabled&&this.testHarnessSrc==0
                harnessTestDataFormatCBox.Enabled=true;
            else
                harnessTestDataFormatCBox.Enabled=false;
            end

            group.Items={harnessRBtn,harnessEBox,harnessCBox,harnessSrcCBox,harnessTestDataFormatCBox};

            group.Name=DAStudio.message('Simulink:Harness:ExportTestCaseDialog_TestHarnessOpts');
            group.Type='group';
            group.Tag='ExportDlgHarnessOptsGrp';
            group.Visible=~this.reuseHarness;

            items={group};
            newRow=curRow+1;
        end

        function[items,newRow]=addTestManagerOptskUI(this,currRow)


            testFileRBtn.Name='';
            testFileRBtn.Type='radiobutton';
            testFileRBtn.ObjectProperty='testFileSelection';
            testFileRBtn.Mode=true;
            testFileRBtn.DialogRefresh=true;
            testFileRBtn.Entries={DAStudio.message('Simulink:Harness:ExportTestCaseDialog_NewTestFile'),...
            DAStudio.message('Simulink:Harness:ExportTestCaseDialog_ResuseTestFile');};
            testFileRBtn.Value=0;
            testFileRBtn.Values=[0,1];
            testFileRBtn.RowSpan=[1,1];
            testFileRBtn.ColSpan=[1,6];
            testFileRBtn.ObjectMethod='testFileRBtn_cb';
            testFileRBtn.Tag='ExportDlgTestFileRBtn';



            testFileEBox.Name=DAStudio.message('Simulink:Harness:ExportTestCaseDialog_TestFile');
            testFileEBox.Type='edit';
            testFileEBox.Mode=true;
            testFileEBox.DialogRefresh=true;
            testFileEBox.ObjectProperty='testFileName';
            testFileEBox.RowSpan=[2,2];
            testFileEBox.ColSpan=[1,5];
            testFileEBox.Tag='ExportDlgTestFileEBox';

            testFileBrowse.Type='pushbutton';
            testFileBrowse.Name=DAStudio.message('Simulink:Harness:BrowseBtn');
            testFileBrowse.Enabled=true;
            testFileBrowse.RowSpan=[2,2];
            testFileBrowse.ColSpan=[6,6];
            testFileBrowse.Alignment=7;
            testFileBrowse.Mode=true;
            testFileBrowse.DialogRefresh=true;
            testFileBrowse.ObjectMethod='testFileBrowseBtn_cb';
            testFileBrowse.Tag='ExportDlgTestFileBrowse';

            testCaseCBox.Name=DAStudio.message('Simulink:Harness:ExportTestCaseDialog_TestCase');
            testCaseCBox.Type='combobox';
            testCaseCBox.Mode=true;
            testCaseCBox.DialogRefresh=true;
            testCaseCBox.Entries=this.testCaseList;
            testCaseCBox.Values=0:1:length(this.testCaseList)-1;
            testCaseCBox.ObjectProperty='testCaseInd';
            testCaseCBox.RowSpan=[3,3];
            testCaseCBox.ColSpan=[1,6];
            testCaseCBox.Tag='ExportDlgTestCaseCBox';

            group.Name=DAStudio.message('Simulink:Harness:ExportTestCaseDialog_TestManagerOpts');
            group.Type='group';
            group.Tag='ExportDlgTestMgrOptsGrp';
            group.LayoutGrid=[3,6];
            group.Items={testFileRBtn,testFileEBox,testFileBrowse,testCaseCBox};
            items={group};
            newRow=currRow+1;
        end

        function dlgDescGroup=addDialogDescriptionUI(this)
            lbl.Name=DAStudio.message('Simulink:Harness:ExportTestCaseDialog_Desc');
            lbl.Type='text';
            lbl.Tag='ExportDlgDescLblTag';
            lbl.Alignment=2;
            lbl.WordWrap=true;
            lbl.RowSpan=[1,1];
            lbl.ColSpan=[1,3];

            lblCUT.Name=DAStudio.message('Simulink:Harness:CUT');
            lblCUT.Type='text';
            lblCUT.Tag='ExportDlgCUTLblTag';
            lblCUT.RowSpan=[2,2];
            lblCUT.ColSpan=[1,1];

            lnk.Name=this.harnessOwner.getFullName();
            lnk.Type='hyperlink';
            lnk.Alignment=0;
            lnk.Tag='ExportDlgOwnerLinkTag';

            lnk.RowSpan=[2,2];
            lnk.ColSpan=[2,3];

            dlgDescGroup.Type='group';
            dlgDescGroup.LayoutGrid=[1,3];
            dlgDescGroup.RowSpan=[1,1];
            dlgDescGroup.ColStretch=[1,1,1];
            dlgDescGroup.Items={lbl,lblCUT,lnk};
            dlgDescGroup.Tag='ExportDlgDescGroupTag';
        end

        function schema=getDialogSchema(this)
            schema.DialogTitle=DAStudio.message('Simulink:Harness:ExportTestCaseDialog_Title');
            schema.DialogTag='ExportSLDVTestCaseDialog';

            schema.Items={this.addDialogDescriptionUI()};
            curRow=1;
            [items,curRow]=this.addTestHarnessOptskUI(curRow);
            schema.Items={schema.Items{:},items{:}};%#ok
            [items,~]=this.addTestManagerOptskUI(curRow);
            schema.Items={schema.Items{:},items{:}};%#ok

            schema.PostApplyMethod='dlgPostApplyMethod';
            schema.PostApplyArgs={'%dialog'};
            schema.PostApplyArgsDT={'handle'};

            schema.CloseMethod='dlgCloseMethod';
            schema.HelpMethod='dlgHelpMethod';

            schema.ExplicitShow=true;
            schema.StandaloneButtonSet={'OK','Cancel','Help'};

        end







        function result=isHierarchyReadonly(this)

            if this.readonly
                result=true;
                return;
            end

            bd=this.dialogOwnerModel;
            restartStatus=get_param(bd,'InteractiveSimInterfaceExecutionStatus');
            blkDiagObject=get_param(bd,'Object');
            if restartStatus~=2
                result=blkDiagObject.isHierarchyReadonly||...
                blkDiagObject.isHierarchySimulating||...
                blkDiagObject.isHierarchyBuilding;
            else
                result=false;
            end
        end

        function show(obj,dlg)
            obj.dialog=dlg;

            if ispc
                width=max(550,dlg.position(3));
            else
                width=max(500,dlg.position(3));
            end
            height=dlg.position(4)+30;
            dlg.position=Simulink.harness.internal.calcDialogGeometry(width,height,'ModelCenter');
            dlg.show();
        end

        function deleteResultDialogH(this)
            this.resultDialogH=[];
        end
    end









    methods(Static)
        function addListener(src,dlg)
            blkDiagram=get_param(src.dialogOwnerModel,'Object');



            src.hModelCloseListener=Simulink.listener(blkDiagram,'CloseEvent',@(s,e)Sldv.Utils.ExportSLDVTestCaseDialog.onModelClose(s,e,src,dlg));
            src.hModelStatusListener=handle.listener(DAStudio.EventDispatcher,'SimStatusChangedEvent',{@Sldv.Utils.ExportSLDVTestCaseDialog.onStatusChanged,src});
        end

        function dlg=create(harnessOwner,sldvDataFile,defaultName,resultDialogH,reuseHarness)

            dlg=Simulink.harness.dialogs.findDialog('ExportSLDVTestCaseDialog',harnessOwner);
            if~isempty(dlg)
                imd=DAStudio.imDialog.getIMWidgets(dlg);
                imd.clickCancel(dlg);
            end


            import Sldv.Utils.ExportSLDVTestCaseDialog;
            src=ExportSLDVTestCaseDialog(harnessOwner,sldvDataFile,defaultName,resultDialogH,reuseHarness);
            dlg=DAStudio.Dialog(src);
            src.show(dlg);
            ExportSLDVTestCaseDialog.addListener(src,dlg);
        end

        function onModelClose(~,~,src,dlg)

            src.modelClosing=true;
            if~strcmp(src.dialogOwnerModel,src.model)
                src.dialogOwnerModel=src.model;
                blkDiagram=get_param(src.dialogOwnerModel,'Object');
                src.hModelCloseListener=Simulink.listener(blkDiagram,'CloseEvent',@(s,e)Sldv.Utils.ExportSLDVTestCaseDialog.onModelClose(s,e,src,dlg));
                src.hModelStatusListener=handle.listener(DAStudio.EventDispatcher,'SimStatusChangedEvent',{@Sldv.Utils.ExportSLDVTestCaseDialog.onStatusChanged,src});
            end
            if ishandle(dlg)
                delete(dlg);
            end
        end

        function onStatusChanged(~,~,src)


            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('ReadonlyChangedEvent',src,'');
        end
    end
end







