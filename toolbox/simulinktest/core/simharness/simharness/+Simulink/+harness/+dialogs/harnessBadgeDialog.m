classdef harnessBadgeDialog<handle




    properties(SetObservable=true)
        harness=[]
        testCaseInfo={}
hModelCloseListener
    end

    methods
        function this=harnessBadgeDialog(harness)
            this.harness=harness;
        end

        function getTestCaseInfo(this)


            if exist([matlabroot,'/toolbox/stm'],'dir')
                this.testCaseInfo=stm.internal.getTestCasesUsingModelAndHarness(this.harness.model,[this.harness.name,'%%%',this.harness.ownerFullPath]);
            end
        end

        function navigateUI=addNavigateToTestcaseUI(this)
            this.getTestCaseInfo();

            testCaseLink={};
            for i=1:length(this.testCaseInfo)


                if(exist(this.testCaseInfo(i).FilePath,'file')~=2)
                    continue;
                end

                harnessName=[this.testCaseInfo(i).Hierarchy{end},...
                ' : ',this.testCaseInfo(i).Hierarchy{1}];


                hierarchyLengh=length(this.testCaseInfo(i).Hierarchy);
                tooltipName=this.testCaseInfo(i).Hierarchy{hierarchyLengh};
                for j=hierarchyLengh-1:-1:1
                    tooltipName=[tooltipName,'>>',...
                    this.testCaseInfo(i).Hierarchy{j}];
                end

                testCaseLink{i}.Name=harnessName;
                testCaseLink{i}.Type='hyperlink';
                testCaseLink{i}.Alignment=0;
                testCaseLink{i}.Tag=['NavigateLink',int2str(i),'Tag'];
                testCaseLink{i}.ToolTip=tooltipName;
                testCaseLink{i}.ObjectMethod='navigateTestcase_cb';
                testCaseLink{i}.MethodArgs={this.testCaseInfo(i).FilePath,this.testCaseInfo(i).UUID};
                testCaseLink{i}.ArgDataTypes={'string','string'};
                testCaseLink{i}.RowSpan=[i,i];
                testCaseLink{i}.ColSpan=[1,1];
            end

            if~isempty(testCaseLink)
                navigationItems=testCaseLink;
                navigationItemsLength=length(testCaseLink);
            else
                lbl.Name=DAStudio.message('Simulink:Harness:NoOpenTestCasesFound');
                lbl.Type='text';
                lbl.Alignment=0;
                lbl.Tag='NoOpenTestcasesLblTag';
                lbl.RowSpan=[1,1];
                lbl.ColSpan=[1,1];

                createLink.Name=DAStudio.message('Simulink:Harness:CreateNewTestcase');
                createLink.Type='hyperlink';
                createLink.ObjectMethod='createTestcase_cb';
                createLink.MethodArgs={this.harness.model,this.harness.name};
                createLink.ArgDataTypes={'string','string'};
                createLink.Alignment=0;
                createLink.Tag='CreateLinkTag';
                createLink.RowSpan=[2,2];
                createLink.ColSpan=[1,1];

                navigationItems={lbl,createLink};
                navigationItemsLength=2;
            end

            if stm.internal.areAnyMATLABBasedTestsOpened()
                navigationItemsLength=navigationItemsLength+1;
                lbl.Name=DAStudio.message('Simulink:Harness:OpenMATLABBasedTests');
                lbl.Type='text';
                lbl.Alignment=0;
                lbl.Tag='OpenMATLABBasedTest';
                lbl.RowSpan=[navigationItemsLength,navigationItemsLength];
                lbl.ColSpan=[1,1];

                navigationItems=[navigationItems,{lbl}];

            end

            navigateUI.Type='group';
            navigateUI.LayoutGrid=[navigationItemsLength,1];
            navigateUI.ShowGrid=false;

            navigateUI.RowSpan=[navigationItemsLength+1,navigationItemsLength+1];
            navigateUI.ColSpan=[1,3];
            navigateUI.Items=navigationItems;
            navigateUI.Tag='NavigateToTestCaseUITag';
            navigateUI.Name=DAStudio.message('Simulink:Harness:OpenTestcases');

        end

        function navigateTestcase_cb(this,filePath,uuid)%#ok<INUSL>
            if exist([matlabroot,'/toolbox/stm'],'dir')
                stm.internal.openTestCase(filePath,uuid);
            else
                MSLDiagnostic('Simulink:Harness:TestManagerNotFound').reportAsWarning;
            end
        end

        function createTestcase_cb(this,modelName,harnessName)%#ok<INUSD>
            if exist([matlabroot,'/toolbox/stm'],'dir')
                sltest.testmanager.view;
            else
                MSLDiagnostic('Simulink:Harness:TestManagerNotFound').reportAsWarning;
            end
        end

        function propertiesButton=addPropertiesButton(this)%#ok<MANU>
            propertiesButton.Type='pushbutton';
            propertiesButton.Enabled=true;
            propertiesButton.RowSpan=[1,1];
            propertiesButton.ColSpan=[1,1];
            propertiesButton.Tag='HarnessPropertiesButtonTag';
            propertiesButton.Mode=true;
            propertiesButton.Name=DAStudio.message('Simulink:Harness:TestHarnessProperties');
            propertiesButton.ObjectMethod='properties_cb';
            propertiesButton.MethodArgs={'%dialog'};
            propertiesButton.ArgDataTypes={'handle'};
        end

        function properties_cb(this,dlg)
            try
                Simulink.harness.dialogs.updateDialog.create(this.harness);


                delete(dlg);

            catch ME
                disp(ME.message);
                rethrow(ME);
            end
        end

        function schema=getDialogSchema(this)
            schema.DialogTitle=DAStudio.message('Simulink:Harness:HarnessBadgeDialogTitle');
            schema.DialogTag='HarnessBadgeDlgTag';

            schema.Items={};
            navigationUI=this.addNavigateToTestcaseUI();
            propertiesButton=this.addPropertiesButton();
            schema.Items={propertiesButton,navigationUI};

            schema.LayoutGrid=[2,3];
            schema.RowStretch=[1,0];
            schema.ShowGrid=false;
            schema.ExplicitShow=true;


            schema.Transient=true;
            schema.DialogStyle='frameless';
            schema.StandaloneButtonSet={''};
        end

        function show(this,dlg)%#ok<INUSL>
            width=max(400,dlg.position(3));
            height=min(dlg.position(4),300);
            dlg.position=Simulink.harness.internal.calcDialogGeometry(width,height,'Model');
            dlg.position(2)=dlg.position(2)-dlg.position(4)-18;
            dlg.show();
        end
    end

    methods(Static)
        function create(harness)
            import Simulink.harness.dialogs.harnessBadgeDialog;
            src=harnessBadgeDialog(harness);
            dlg=DAStudio.Dialog(src);
            src.show(dlg);
            blkDiagram=get_param(harness.model,'Object');




            src.hModelCloseListener=Simulink.listener(blkDiagram,'CloseEvent',@(src,evt)harnessBadgeDialog.onModelClose(src,evt,dlg));
        end

        function onModelClose(~,~,dlg)

            if ishandle(dlg)
                delete(dlg);
            end
        end
    end
end

