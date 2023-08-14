

classdef CallbackFunc<CosimWizardPkg.StepBase
    properties
        CallbackTableData=cell(0,1);
    end
    methods
        function obj=CallbackFunc(WizardData)
            obj=obj@CosimWizardPkg.StepBase(WizardData);
        end
        function onAddCb(this,dlg)
            CbCmd=getComboBoxText(dlg,'edaSelectCbType');

            HdlComp=getWidgetValue(dlg,'edaCbHdlComponent');
            cbFcnName=getWidgetValue(dlg,'edaCbFcnName');

            Period=getWidgetValue(dlg,'edaCbSampleTime');
            TriggerSignal=getWidgetValue(dlg,'edaTriggerSignal');

            newMatlabCbCmd=CosimWizardPkg.CosimWizardMatlabCb(...
            CbCmd,HdlComp,this.Wizard.TriggerMode,Period,TriggerSignal,cbFcnName);


            foundDup=false;
            for indx=1:numel(this.Wizard.UserData.MatlabCb)
                if(strcmp(this.Wizard.UserData.MatlabCb{indx}.HdlComp,HdlComp))
                    foundDup=true;
                    break;
                end
            end

            if(foundDup)

                this.CallbackTableData{indx}=newMatlabCbCmd.FullCmd;
                this.Wizard.UserData.MatlabCb{indx}=newMatlabCbCmd;

                this.Wizard.Status='Warning: The HDL component already has a scheduled callback function, which is replaced by this new one.';
            else

                this.CallbackTableData=[this.CallbackTableData;{newMatlabCbCmd.FullCmd}];
                this.Wizard.UserData.MatlabCb=[this.Wizard.UserData.MatlabCb;{newMatlabCbCmd}];
                this.Wizard.Status='';
            end
        end

        function onRemoveCb(this,dlg)
            row=dlg.getSelectedTableRow('edaCbList');
            if(row>=0)
                this.CallbackTableData(row+1,:)=[];
                this.Wizard.UserData.MatlabCb(row+1)=[];
                [newRow,~]=size(this.CallbackTableData);
                if(newRow)
                    if(row>newRow-1)
                        row=row-1;
                    end
                    dlg.selectTableRow('edaCbList',row);
                end
            end
        end

        function onRetrieveCb(this,dlg)
            row=dlg.getSelectedTableRow('edaCbList');
            [tbRow,~]=size(this.CallbackTableData);

            if(row<0||row>=tbRow)
                return;
            end

            indx=row+1;
            switch(this.Wizard.UserData.MatlabCb{indx}.CbCmd)
            case 'matlabcp'
                tmp=0;
            otherwise
                tmp=1;
            end
            setWidgetValue(dlg,'edaSelectCbType',tmp);
            setWidgetValue(dlg,'edaCbHdlComponent',this.Wizard.UserData.MatlabCb{indx}.HdlComp);
            this.Wizard.TriggerMode=this.Wizard.UserData.MatlabCb{indx}.TriggerMode;
            setWidgetValue(dlg,'edaCbSampleTime',this.Wizard.UserData.MatlabCb{indx}.Period);
            setWidgetValue(dlg,'edaTriggerSignal',this.Wizard.UserData.MatlabCb{indx}.TriggerSignal);
            setWidgetValue(dlg,'edaCbFcnName',this.Wizard.UserData.MatlabCb{indx}.MfuncName);
            dlg.apply;
        end

        function WidgetGroup=getDialogSchema(this)





            NameCbSelect.Name='Callback type:  ';
            NameCbSelect.Type='text';
            NameCbSelect.Tag='edaTextSelectCbType';
            NameCbSelect.RowSpan=[1,1];
            NameCbSelect.ColSpan=[1,1];

            CbSelect.Name='Callback type:  ';
            CbSelect.Type='combobox';
            CbSelect.Tag='edaSelectCbType';
            CbSelect.Entries={'matlabcp','matlabtb'};
            CbSelect.RowSpan=[1,1];
            CbSelect.ColSpan=[2,3];
            CbSelect.HideName=true;


            CbFcnName.Name='Callback function name:';
            CbFcnName.Type='edit';
            CbFcnName.Tag='edaCbFcnName';
            CbFcnName.RowSpan=[1,1];
            CbFcnName.ColSpan=[4,8];
            CbFcnName.ObjectProperty='CallBackFcnName';


            NameHdlComp.Name='HDL component:';
            NameHdlComp.Type='text';
            NameHdlComp.Tag='edaNameHdlComponent';
            NameHdlComp.RowSpan=[2,2];
            NameHdlComp.ColSpan=[1,1];
            NameHdlComp.HideName=true;

            HdlComp.Name='HDL component:';
            HdlComp.Type='edit';
            HdlComp.Tag='edaCbHdlComponent';
            HdlComp.RowSpan=[2,2];
            HdlComp.ColSpan=[2,7];
            HdlComp.HideName=true;


            BrowseComp=l_CreateButtonWidget('BrowseComp','onBrowseComp');
            BrowseComp.Tag='edaBrowseHdlComp';
            BrowseComp.Name='Browse';
            BrowseComp.RowSpan=[2,2];
            BrowseComp.ColSpan=[8,8];
            BrowseComp.ObjectMethod='onBrowseComp';


            NameTriggerMode.Name='Trigger mode:';
            NameTriggerMode.Type='text';
            NameTriggerMode.Tag='edaNameTriggerMode';
            NameTriggerMode.RowSpan=[3,3];
            NameTriggerMode.ColSpan=[1,1];

            TriggerMode.Name='Trigger mode:';
            TriggerMode.Type='combobox';
            TriggerMode.Tag='edaTriggerMode';
            TriggerMode.Entries={'Repeat','Rising Edge','Falling Edge','Sensitivity'};
            TriggerMode.RowSpan=[3,3];
            TriggerMode.ColSpan=[2,2];
            TriggerMode.ObjectProperty='TriggerMode';
            TriggerMode.DialogRefresh=true;
            TriggerMode.Mode=1;
            TriggerMode.HideName=true;


            SampleTime.Name='Sample time (ns):';
            SampleTime.Type='edit';
            SampleTime.Tag='edaCbSampleTime';
            SampleTime.RowSpan=[3,3];
            SampleTime.ColSpan=[3,7];
            SampleTime.Visible=(this.Wizard.TriggerMode==0);



            TriggerSignal.Name='Trigger Signal:';
            TriggerSignal.Type='edit';
            TriggerSignal.Tag='edaTriggerSignal';
            TriggerSignal.RowSpan=[3,3];
            TriggerSignal.ColSpan=[3,7];
            TriggerSignal.Visible=(this.Wizard.TriggerMode~=0);


            BrowseTrigger=l_CreateButtonWidget('BrowseTrigger','onBrowseTrigger');
            BrowseTrigger.Tag='edaBrowseTriggerSignal';
            BrowseTrigger.Name='Browse';
            BrowseTrigger.RowSpan=[3,3];
            BrowseTrigger.ColSpan=[8,8];
            BrowseTrigger.ObjectMethod='onBrowseTrigger';
            BrowseTrigger.Visible=(this.Wizard.TriggerMode~=0);
            BrowseTrigger.Enabled=true;

            newCbPanel.Name='';
            newCbPanel.Type='group';
            newCbPanel.Tag='edaNewCbPanel';
            newCbPanel.Items={...
            NameCbSelect,CbSelect,CbFcnName,...
            NameHdlComp,HdlComp,BrowseComp,...
            NameTriggerMode,TriggerMode,...
            SampleTime,TriggerSignal,BrowseTrigger};
            newCbPanel.RowSpan=[1,2];
            newCbPanel.ColSpan=[1,6];
            newCbPanel.LayoutGrid=[3,8];
            newCbPanel.ColStretch=[1,1,1,1,1,1,1,1];
            newCbPanel.RowStretch=[1,1,1];


            BtnAdd=l_CreateButtonWidget('Add','onAddCb');
            BtnAdd.RowSpan=[3,3];
            BtnAdd.ColSpan=[1,1];
            BtnAdd.Tag='edaAddCbBtn';

            BtnRemove=l_CreateButtonWidget('Remove','onRemoveCb');
            BtnRemove.Tag='edaRemoveCbBtn';
            BtnRemove.Name='Remove';
            BtnRemove.RowSpan=[3,3];
            BtnRemove.ColSpan=[2,2];



            CbList.Type='table';
            CbList.Name='MATLAB Callback Functions';
            CbList.Tag='edaCbList';
            CbList.ColHeader={'Callback Schedule Commands'};
            CbList.RowHeader={};
            CbList.HeaderVisibility=[0,0];
            CbList.RowSpan=[4,5];
            CbList.ColSpan=[1,6];
            CbList.ReadOnlyColumns=1;
            CbList.ColumnHeaderHeight=0;
            CbList.FontFamily='Courier';
            CbList.Data=this.CallbackTableData;
            CbList.Size=size(this.CallbackTableData);
            CbList.Editable=false;
            CbList.LastColumnStretchable=true;
            CbList.SelectionBehavior='Row';

            maxCmdLen=0;
            for m=1:numel(this.CallbackTableData)
                maxCmdLen=max(maxCmdLen,length(this.CallbackTableData{m}));
            end
            CbList.ColumnCharacterWidth=max(maxCmdLen+2,60);


            WidgetGroup.LayoutGrid=[5,8];

            WidgetGroup.Items={newCbPanel,...
            BtnAdd,BtnRemove,CbList};


            this.Wizard.UserData.CurrentStep=5;

        end

        function Description=getDescription(~)

            Description=...
            ['Enter the required parameters for scheduling MATLAB callback function. '...
            ,'When finished, use the ''Add'' button to generate matlabtb or matlabcp '...
            ,'commands that associates MATLAB function with an instantiated HDL design. '...
            ,'If necessary, use the ''Remove'' button to remove generated commands.'];
        end
        function onBack(this,~)

            this.Wizard.NextStepID=4;
        end
        function EnterStep(this)
            numCBs=numel(this.Wizard.UserData.MatlabCb);
            this.CallbackTableData=cell(numCBs,1);
            for indx=1:numCBs
                this.CallbackTableData{indx}=this.Wizard.UserData.MatlabCb{indx}.FullCmd;
            end
        end
        function onNext(this,~)
            assert(numel(this.Wizard.UserData.MatlabCb)>=1,'No MATLAB callback function was scheduled. Please add at least one MATLAB callback function.');
            this.Wizard.NextStepID=11;
        end
    end
end

function btnWidget=l_CreateButtonWidget(btnName,methodName)
    btnWidget.Type='pushbutton';
    btnWidget.Name=btnName;
    btnWidget.Enabled=true;
    btnWidget.Mode=1;
    btnWidget.ObjectMethod=methodName;
    btnWidget.MethodArgs={'%dialog'};
    btnWidget.ArgDataTypes={'handle'};
end


