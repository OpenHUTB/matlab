

classdef ScriptGeneration<CosimWizardPkg.StepBase
    properties
        CallbackTableData=cell(0,1);
    end
    methods
        function obj=ScriptGeneration(WizardData)
            obj=obj@CosimWizardPkg.StepBase(WizardData);
        end

        function WidgetGroup=getDialogSchema(this)

            LaunchHdl.Name='Launch HDL simulator after exiting this dialog.';
            LaunchHdl.Tag='edaLaunchHdl';
            LaunchHdl.Type='checkbox';
            LaunchHdl.Value=true;
            LaunchHdl.RowSpan=[1,1];
            LaunchHdl.ColSpan=[1,1];

            Spacer.Type='panel';
            Spacer.RowSpan=[2,6];
            Spacer.ColSpan=[1,7];

            WidgetGroup.LayoutGrid=[6,7];
            WidgetGroup.RowStretch=[0,0,0,0,0,0];
            WidgetGroup.Items={LaunchHdl,Spacer};


            this.Wizard.UserData.CurrentStep=6;

        end

        function Description=getDescription(~)

            Description=sprintf([...
'When you click Finish, the Cosimulation Wizard performs the following actions: \n'...
            ,'- Creates and opens a MATLAB script configured to launch the HDL simulator. \n'...
            ,'- Generates template(s) for the MATLAB callback function(s). \n'...
            ,'- (If you check the box below) Launches the HDL simulator. \n'...
            ,'\n'...
            ,'After launching the HDL simulator, you might want observe the execution of the callback '...
            ,'functions by starting the simulation in the HDL simulator, for example, entering command '...
            ,'''run 1000 ns''. Then you can modify the templates to implement the desired '...
            ,'algorithms in MATLAB.']);
        end
        function onBack(this,~)

            this.Wizard.NextStepID=10;
        end
        function EnterStep(~)
            return;
        end
        function onNext(this,dlg)

            onCleanupObj=CosimWizardPkg.disableButtonSet(this.Wizard,dlg);

            FuncNames=cell(1,numel(this.Wizard.UserData.MatlabCb));
            for m=1:numel(this.Wizard.UserData.MatlabCb)
                FuncNames{m}=this.Wizard.UserData.MatlabCb{m}.MfuncName;
            end
            FuncNames=unique(FuncNames);

            for indx=1:numel(FuncNames)
                targetFileName=FuncNames{indx};

                functionName=regexprep(targetFileName,'.m$','');



                HdlCompNames='';
                for n=1:numel(this.Wizard.UserData.MatlabCb)
                    if(strcmp(this.Wizard.UserData.MatlabCb{n}.MfuncName,targetFileName))
                        HdlCompNames=[this.Wizard.UserData.MatlabCb{n}.HdlComp,';',HdlCompNames];%#ok<AGROW>
                    end
                end

                templateFileName=fullfile(matlabroot,'toolbox','edalink',...
                'foundation','hdllink','template_matlabcb.m');
                templateContent=fileread(templateFileName);
                templateContent=regexprep(templateContent,'template_matlabcb',functionName,'once');
                templateContent=regexprep(templateContent,'REPLACE_WITH_HDL_COMPONENTS',HdlCompNames,'once');
                templateContent=regexprep(templateContent,'REPLACE_WITH_FILENAME',targetFileName,'once');
                templateContent=regexprep(templateContent,'REPLACE_WITH_DATESTR',datestr(now),'once');



                if(exist(fullfile(pwd,targetFileName),'file')==2)
                    Question=['File ',targetFileName,' exists in current directory. '...
                    ,'Do you want to overwrite it?'];

                    Answer=questdlg(Question,'Overwrite Existing File','Yes','No','No');
                    switch(Answer)
                    case 'No'
                        continue;
                    otherwise

                    end
                end

                [fid,msg]=fopen(targetFileName,'w');
                assert(fid~=-1,...
                message('HDLLink:CosimWizard:OpenFileFailure',msg));
                fprintf(fid,'%s',templateContent);
                fclose(fid);

                if(exist(targetFileName,'file')~=2)
                    pause(1);
                end
                edit(targetFileName);
            end
            delete(onCleanupObj);



            if(isobject(this.Wizard.StepHandles{4}.shutdownHdlObj))
                delete(this.Wizard.StepHandles{4}.shutdownHdlObj);
            end


            genCompileScript(this.Wizard.UserData);

            isLaunchHdlChecked=getWidgetValue(dlg,'edaLaunchHdl');
            launchScriptName=genMlLaunchScript(this.Wizard.UserData,isLaunchHdlChecked);
            edit([launchScriptName,'.m']);
            delete(dlg);
        end
    end
end


