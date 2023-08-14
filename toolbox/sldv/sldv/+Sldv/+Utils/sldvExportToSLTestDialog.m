



classdef sldvExportToSLTestDialog<handle

    properties(SetObservable=true)

sldvDataFile
harnessNames
harnessOwner
        modelClosing=false;
readonly
hModelCloseListener
hModelStatusListener
defaultName
activeHarness
model
noteVisible
resultDialogH
    end

    methods

        function this=sldvExportToSLTestDialog(harnessOwner,sldvDataFile,harnessNames,defaultName,activeHarness,model,resultDialogH)
            this.sldvDataFile=sldvDataFile;
            this.harnessNames=harnessNames;
            this.harnessOwner=harnessOwner;
            this.readonly=false;
            this.defaultName=defaultName;
            this.activeHarness=activeHarness;
            this.model=model;
            this.resultDialogH=resultDialogH;
            this.noteVisible=0;
        end




        function varType=getPropDataType(this,varName)%#ok
            switch(varName)
            case 'noteVisible'
                varType='double';
            otherwise
                varType='other';
            end
        end

        function setPropValue(obj,varName,varVal)
            DAStudio.Protocol.setPropValue(obj,varName,varVal);
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

        function setReadonly(this,dlg,val)
            this.readonly=val;
            dlg.setEnabled('HarnessList',~val);
        end

        function[status,msg]=dlgPostApplyMethod(this,dlg)
            status=false;
            msg=[];

            try

                this.setReadonly(dlg,true);

                createFlag=true;
                name=this.defaultName;

                index=dlg.getWidgetValue('HarnessList');
                n=length(this.harnessNames);
                if n~=index
                    createFlag=false;
                    name=this.harnessNames{index+1};
                end

                continueExport=true;
                closeHarness=false;
                if createFlag==true&&~isempty(this.activeHarness)
                    closeHarness=true;
                end
                if continueExport

                    sldvprivate('urlcall','create_export_progress_bar');
                    if closeHarness

                        delete(this.hModelCloseListener);
                        delete(this.hModelStatusListener);



                        Simulink.harness.close(this.activeHarness.ownerFullPath,this.activeHarness.name);
                    end

                    [~,~,testFileName]=sltest.import.sldvData(this.sldvDataFile,...
                    'CreateHarness',createFlag,...
                    'TestHarnessName',name);

                    sltest.testmanager.view;
                    sltest.testmanager.load(testFileName);
                    sldvprivate('urlcall','update_sltest_result',urlencode(this.sldvDataFile),urlencode('dummy'),testFileName);
                end

                status=true;
            catch ME
                sldvprivate('urlcall','delete_export_progress_bar');

                import Sldv.Utils.sldvExportToSLTestDialog;
                sldvExportToSLTestDialog.addListener(this,dlg);

                this.setReadonly(dlg,false);


                Simulink.harness.internal.error(ME,true);



                msg=DAStudio.message('Simulink:Harness:SLDVExportAborted');
            end
        end

        function reset_size_cb(this)
            dlg=Simulink.harness.dialogs.findDialog('sldvExportToSLTestDialog',this.harnessOwner);
            if~isempty(dlg)
                dlg.resetSize();
            end
        end

        function list_cb(this,dlg)
            index=dlg.getWidgetValue('HarnessList');
            n=length(this.harnessNames);
            if n~=index
                this.noteVisible=0;
            else
                this.noteVisible=1;
            end
        end








        function schema=getDialogSchema(this)
            schema.DialogTitle=DAStudio.message('Simulink:Harness:SLDVExportDialogTitle');
            schema.DialogTag='sldvExportToSLTestDialog';

            lbl.Name=DAStudio.message('Simulink:Harness:SLDVExportDialogInfo');
            lbl.Type='text';
            lbl.Alignment=2;
            lbl.WordWrap=true;
            lbl.RowSpan=[1,1];
            lbl.ColSpan=[1,4];

            hList.Name='';
            hList.Type='combobox';
            hList.Mode=true;
            hList.DialogRefresh=true;
            names=this.harnessNames;
            names{end+1}='New Harness';
            hList.Entries=names;
            n=length(this.harnessNames)+1;
            hList.Values=1:1:n;
            hList.RowSpan=[2,2];
            hList.ColSpan=[1,4];
            hList.Enabled=1;
            hList.Visible=1;
            hList.Tag='HarnessList';
            hList.ObjectMethod='list_cb';
            hList.MethodArgs={'%dialog'};
            hList.ArgDataTypes={'handle'};

            note.Name=DAStudio.message('Simulink:Harness:SLDVExportDialogNote1',this.defaultName);
            if~isempty(this.activeHarness)
                note.Name=[note.Name,' ',DAStudio.message('Simulink:Harness:SLDVExportDialogNote2',this.activeHarness.name)];
            end
            note.Type='text';
            note.Alignment=2;
            note.WordWrap=true;
            note.RowSpan=[3,3];
            note.ColSpan=[1,4];
            note.Tag='NewHarnessNote';
            note.Visible=this.noteVisible;

            schema.Items={lbl,hList,note};
            schema.ExplicitShow=true;
            schema.LayoutGrid=[3,4];
            schema.ColStretch=[0,0,0,1];
            schema.RowStretch=[0,0,1];

            schema.CloseMethod='dlgCloseMethod';

            schema.PostApplyMethod='dlgPostApplyMethod';
            schema.PostApplyArgs={'%dialog'};
            schema.PostApplyArgsDT={'handle'};

            schema.CloseMethod='dlgCloseMethod';
            schema.HelpMethod='dlgHelpMethod';

            schema.IsScrollable=true;
            schema.DisableDialog=this.isHierarchyReadonly();

            schema.StandaloneButtonSet={'OK','Cancel','Help'};
        end









        function result=isHierarchyReadonly(this)

            if this.readonly
                result=true;
                return;
            end

            bd=this.model;
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

        function show(~,dlg)
            dlg.show();
        end

        function deleteResultDialogH(this)
            this.resultDialogH=[];
        end
    end








    methods(Static)
        function addListener(src,dlg)
            blkDiagram=get_param(src.model,'Object');



            src.hModelCloseListener=Simulink.listener(blkDiagram,'CloseEvent',{@Sldv.Utils.sldvExportToSLTestDialog.onModelClose,src,dlg});
            src.hModelStatusListener=handle.listener(DAStudio.EventDispatcher,'SimStatusChangedEvent',{@Sldv.Utils.sldvExportToSLTestDialog.onStatusChanged,src});
        end

        function dlg=create(harnessOwner,sldvDataFile,harnessNames,defaultName,activeHarness,model,resultDialogH)

            dlg=Simulink.harness.dialogs.findDialog('sldvExportToSLTestDialog',harnessOwner);
            if~isempty(dlg)
                imd=DAStudio.imDialog.getIMWidgets(dlg);
                imd.clickCancel(dlg);
            end


            import Sldv.Utils.sldvExportToSLTestDialog;
            src=sldvExportToSLTestDialog(harnessOwner,sldvDataFile,harnessNames,defaultName,activeHarness,model,resultDialogH);
            dlg=DAStudio.Dialog(src);
            src.show(dlg);
            sldvExportToSLTestDialog.addListener(src,dlg);
        end

        function onModelClose(~,~,src,dlg)

            src.modelClosing=true;
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
