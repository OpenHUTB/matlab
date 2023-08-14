classdef EnumerationPicker<systemcomposer.internal.mixin.CenterDialog

    properties(Transient)
        Owner;
        OwnerDlg;
        OrigIdx;
        PropName;
        EnumValue;
    end
    properties(Hidden,Transient)
        openNewEnumInEditor=true;
        createdNewFile=false;
        PollingTimer=[];
    end

    methods
        function obj=EnumerationPicker(profileEditor,dlg,origIdx,propName)
            obj.Owner=profileEditor;
            obj.OwnerDlg=dlg;
            obj.OrigIdx=origIdx;
            obj.PropName=propName;
            obj.EnumValue='';
        end

        function schema=getDialogSchema(this)
            enumerationName.Name=DAStudio.message('SystemArchitecture:ProfileDesigner:EnumNameLabel',this.PropName);
            enumerationName.NameLocation=2;
            enumerationName.Type='edit';
            enumerationName.Tag='enumNameEdit';
            enumerationName.Source=this;
            enumerationName.Mode=true;
            enumerationName.ObjectMethod='EnumerationValueChanged';
            enumerationName.MethodArgs={'%value'};
            enumerationName.ArgDataTypes={'string'};
            enumerationName.RowSpan=[1,1];
            enumerationName.ColSpan=[1,1];
            enumerationName.ToolTip=DAStudio.message('SystemArchitecture:ProfileDesigner:EnumNameTooltip');

            enumHelp.Type='text';
            enumHelp.Name=DAStudio.message('SystemArchitecture:ProfileDesigner:EnumPickerHelpText');
            enumHelp.WordWrap=false;
            enumHelp.FontPointSize=8;
            enumHelp.RowSpan=[2,2];
            enumHelp.ColSpan=[1,1];

            group.Type='group';
            group.Items={enumerationName,enumHelp};
            group.LayoutGrid=[2,1];

            schema.DialogTitle=DAStudio.message('SystemArchitecture:ProfileDesigner:EnumPickerTitle');
            schema.Items={group};
            schema.Source=this;
            schema.OpenCallback=@(dlg)this.openCallback(dlg);
            schema.CloseMethodArgs={'%dialog','%closeaction'};
            schema.CloseMethodArgsDT={'handle','string'};
            schema.CloseMethod='dialogclosed';
            schema.Sticky=true;
            schema.StandaloneButtonSet={'OK','Cancel'};

        end

        function openCallback(this,dlg)




            this.positionDialog(dlg,this.OwnerDlg);


            dlg.setFocus('enumNameEdit');
        end

        function dialogclosed(this,dlg,action)
            if strcmp(action,'cancel')||isempty(this.EnumValue)
                dlg.hide;
                this.Owner.handleEnumSelected(this.OwnerDlg,this.OrigIdx,this.PropName,'');
            else
                try

                    c=eval(['?',this.EnumValue]);
                catch ME
                    dp=DAStudio.DialogProvider;
                    cDlg=dp.errordlg(...
                    ME.message,...
                    DAStudio.message('SystemArchitecture:ProfileDesigner:ClassDoesNotDefineEnum',this.EnumValue),...
                    true);
                    this.reject();
                    this.positionDialog(cDlg,this.OwnerDlg);
                end

                if~isempty(c)&&c.Enumeration
                    this.setEnumType();
                else
                    this.reportInvalidEnumeration(c);
                end
            end
            delete(dlg);
        end

        function EnumerationValueChanged(this,value)
            this.EnumValue=value;
        end

        function checkFileExists(this,fname,timer,~)



            if exist(fname,'file')
                this.createdNewFile=true;
                stop(timer);
            end
        end

        function finishWaitingForFile(this,fname,timer,~)



            delete(timer);
            this.PollingTimer=[];

            if this.createdNewFile
                this.setEnumType();
                this.openCreatedFile(fname);
            else
                this.reject();
            end
        end
    end

    methods(Access=private)

        function reportInvalidEnumeration(this,metaClass)

            dp=DAStudio.DialogProvider;
            if isempty(metaClass)

                cDlg=dp.questdlg(...
                DAStudio.message('SystemArchitecture:ProfileDesigner:EnumTypeNotFoundQuestion',this.EnumValue),...
                DAStudio.message('SystemArchitecture:ProfileDesigner:EnumTypeNotFoundTitle'),...
                {DAStudio.message('SystemArchitecture:ProfileDesigner:Create'),...
                DAStudio.message('SystemArchitecture:ProfileDesigner:Cancel')},...
                DAStudio.message('SystemArchitecture:ProfileDesigner:Create'),...
                @(response)handleResponse(response));
            else

                cDlg=dp.errordlg(...
                DAStudio.message('SystemArchitecture:ProfileDesigner:ClassDoesNotDefineEnum',this.EnumValue),...
                DAStudio.message('SystemArchitecture:ProfileDesigner:EnumTypeNotFoundTitle'),...
                true);
                this.reject();
            end
            this.positionDialog(cDlg,this.OwnerDlg);

            function handleResponse(resp)
                if strcmp(resp,DAStudio.message('SystemArchitecture:ProfileDesigner:Create'))

                    this.createAndOpenNewEnumClass();
                else
                    this.reject();
                end
            end
        end

        function reject(this)
            this.Owner.handleEnumSelected(this.OwnerDlg,this.OrigIdx,this.PropName,'');
        end

        function setEnumType(this)
            this.Owner.handleEnumSelected(this.OwnerDlg,this.OrigIdx,this.PropName,this.EnumValue);
        end

        function createAndOpenNewEnumClass(this)


            fname=[this.EnumValue,'.m'];


            dp=DAStudio.DialogProvider;
            if exist(fullfile(pwd,fname),'file')
                eDlg=dp.errordlg(...
                DAStudio.message('SystemArchitecture:ProfileDesigner:FileAlreadyExists',fname),...
                DAStudio.message('SystemArchitecture:ProfileDesigner:FileAlreadyExistsTitle'),...
                true);
                this.positionDialog(eDlg,this.OwnerDlg);
                this.reject();
                return;
            end

            fid=fopen(fname,'w');


            if fid<0
                eDlg=dp.errordlg(...
                DAStudio.message('SystemArchitecture:ProfileDesigner:NoWriteAccess',fname),...
                DAStudio.message('SystemArchitecture:ProfileDesigner:NoWriteAccessTitle'),...
                true);
                this.positionDialog(eDlg,this.OwnerDlg);
                this.reject();
                return;
            end
            fileGuard=onCleanup(@()fclose(fid));

            spec=this.getEnumClassTemplate(this.EnumValue);
            fprintf(fid,spec);
            delete(fileGuard);






            this.waitForFile(fname);
        end

        function template=getEnumClassTemplate(~,className)

            template=sprintf([...
'classdef %s < Simulink.IntEnumType\n'...
            ,'    %%%% %s Enumeration type definition for use with System Composer profile\n'...
            ,'\n'...
            ,'    enumeration\n'...
            ,'        Red(0)\n'...
            ,'        Green(1)\n'...
            ,'        Blue(2)\n'...
            ,'    end\n'...
            ,'\n'...
            ,'end\n'],...
            className,className);
        end

        function waitForFile(this,fname)



            this.PollingTimer=timer(...
            'TimerFcn',@(t,e)this.checkFileExists(fname,t,e),...
            'ExecutionMode','fixedRate',...
            'TasksToExecute',20,...
            'Period',0.5,...
            'ObjectVisibility','off',...
            'StopFcn',@(t,e)this.finishWaitingForFile(fname,t,e));
            start(this.PollingTimer);
        end

        function openCreatedFile(this,fname)


            if this.openNewEnumInEditor
                edit(fname);
            end
        end
    end

end