

classdef CompileOption<CosimWizardPkg.StepBase
    methods
        function obj=CompileOption(Wizard)
            obj=obj@CosimWizardPkg.StepBase(Wizard);
        end
        function WidgetGroup=getDialogSchema(this)
            currRow=0;
            currRow=currRow+1;GROW_ROW=currRow;
            CompileCmdEdit.Name='Compilation Commands:';
            CompileCmdEdit.Tag='edaCompileCmdEdit';
            CompileCmdEdit.Type='editarea';
            CompileCmdEdit.RowSpan=[currRow,currRow+3];
            CompileCmdEdit.ColSpan=[1,3];
            CompileCmdEdit.ObjectProperty='CompileCmd';
            CompileCmdEdit.Mode=true;
            CompileCmdEdit.Enabled=true;
            currRow=currRow+3;


            currRow=currRow+1;
            ResetButton.Name='Restore Default Commands';
            ResetButton.Tag='edaResetButton';
            ResetButton.Type='pushbutton';
            ResetButton.RowSpan=[currRow,currRow];
            ResetButton.ColSpan=[1,1];
            ResetButton.ObjectMethod='onResetCompileCmd';
            ResetButton.MethodArgs={'%dialog'};
            ResetButton.ArgDataTypes={'handle'};
            ResetButton.Mode=true;
            ResetButton.Enabled=true;


            WidgetGroup.LayoutGrid=[currRow,3];
            rowstretch=zeros([1,currRow]);
            rowstretch(GROW_ROW)=1;
            WidgetGroup.RowStretch=rowstretch;





            WidgetGroup.Items={ResetButton,CompileCmdEdit};



            this.Wizard.UserData.CurrentStep=3;
        end

        function onBack(this,dlg)
            if(~isequal(this.Wizard.UserData.GeneratedCompileCmd,this.Wizard.CompileCmd))
                Question=['All your changes at this step would be discarded. '...
                ,'Would you like to continue?'];

                dp=DAStudio.DialogProvider;
                dp.questdlg(Question,'Confirm Change',{'Yes','No'},'No',@questdlg_cb);
            else
                this.Wizard.NextStepID=2;
            end

            function questdlg_cb(Answer)
                switch(Answer)
                case 'No'
                    return;
                otherwise
                    this.Wizard.NextStepID=2;
                    dlg.refresh;
                end
            end
        end
        function onNext(this,dlg)
            this.Wizard.UserData.CompileCmd=this.Wizard.CompileCmd;




            statusmsg='Compiling HDL files. Please wait ...';
            displayStatusMessage(this.Wizard,dlg,statusmsg);


            onCleanupObj=CosimWizardPkg.disableButtonSet(this.Wizard,dlg);


            disp('### Compiling HDL design');

            runCompilation(this.Wizard.UserData);

            delete(onCleanupObj);


            this.Wizard.StepHandles{4}.ResetOptions;

            this.Wizard.NextStepID=4;
        end
        function EnterStep(this,~)
            this.Wizard.ElabOptions=this.Wizard.UserData.ElabOptions;
        end
        function Description=getDescription(~)

            Description=['HDL Verifier has automatically generated the following '...
            ,'HDL compilation commands. You can customize these commands with optional '...
            ,'parameters as specified in the HDL simulator documentation but they are '...
            ,'sufficient as shown to compile your HDL code for cosimulation. The HDL files '...
            ,'will be compiled when you click Next.'];
        end
    end
end


