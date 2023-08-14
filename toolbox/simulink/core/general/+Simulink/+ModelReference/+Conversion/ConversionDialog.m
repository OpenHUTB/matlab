




classdef ConversionDialog<handle
    properties(SetAccess=public,GetAccess=public,SetObservable=true)
System
Model

        ReferencedModelName='';
        DataFile=''

        AutoFix=true;
        ReplaceSubsystem=true;
        CreateWrapperSubsystem=false;


        BuildTarget=DAStudio.message('Simulink:modelReferenceAdvisor:BuildTargetNone');
        SimulationMode=DAStudio.message('Simulink:modelReferenceAdvisor:NormalMode');

        CheckSimulationResults=false;
        StopTime='10'
        AbsoluteTolerance='1e-3'
        RelativeTolerance='1e-6'
        ExpandVirtualBusPorts=false;
        RightClickBuild=false;
    end

    properties(Transient,SetAccess=public,GetAccess=public)
        SubsystemConversion=[]
    end

    properties(Transient,SetAccess=protected,GetAccess=protected)
SubsystemName
        UseDataDictionary=false;
        ShowBuildTargetOption=false
StringMapForGui
    end

    methods(Static,Access=public)
        function[this,dlg]=show(subsys)
            this=Simulink.ModelReference.Conversion.ConversionDialog(subsys);
            dlg=DAStudio.Dialog(this);
            dlg.show;
        end
    end

    methods(Access=public)
        function varType=getPropDataType(this,varName)%#ok
            switch varName
            case{'ReferencedModelName','DataFile','BuildTarget','StopTime','AbsoluteTolerance',...
                'RelativeTolerance','SimulationMode','TimeOut'}
                varType='string';

            case{'ReplaceSubsystem','AutoFix','CreateWrapperSubsystem','CheckSimulationResults','ExpandVirtualBusPorts','RightClickBuild'}
                varType='bool';

            otherwise
                assert(false,'Unrecognized variable type: %s',varName);
            end
        end


        function dlg=getDialogSchema(this)
            referencedModelNameEditBox=this.createEditBox(DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogNewModelName'),...
            'ReferencedModelName','ReferencedModelNameTag',true);
            dataFileEditBox=this.createEditBox(DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogDataFileName'),...
            'DataFile','DataFileTag',~this.UseDataDictionary);
            replaceSubsystemCheckBox=this.createCheckBox(DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogReplaceSubsystem'),...
            'ReplaceSubsystem','ReplaceSubsystemTag',true);


            if this.ExpandVirtualBusPorts
                this.AutoFix=true;
            end

            autofixCheckBox=this.createCheckBox(DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogAutoFix'),...
            'AutoFix','AutoFixTag',true);
            expandVirtualBusCheckBox=this.createCheckBox(DAStudio.message('Simulink:modelReferenceAdvisor:ExpandPortsWithVirtualBusSignalsDlg'),...
            'ExpandVirtualBusPorts','ExpandVirtualBusPortsTag',true);
            rightClickBuildCheckBox=this.createCheckBox(DAStudio.message('Simulink:modelReferenceAdvisor:RightClickBuildDlg'),...
            'RightClickBuild','RightClickBuildTag',true);

            createWrapperSubsystemCheckBox=this.createCheckBox(...
            DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogCreateWraperSubsystem'),...
            'CreateWrapperSubsystem','CreateWrapperSubsystemTag',false);
            createWrapperSubsystemCheckBox.Visible=false;

            buildTargetComboBox=this.getBuildTargetCombo;
            checkSimulationResultsCheckBox=this.createCheckBox(...
            DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogCheckSimulationResults'),...
            'CheckSimulationResults','CheckSimulationResultsTag',true);
            stopTimeEditBox=this.createEditBox(DAStudio.message('Simulink:modelReferenceAdvisor:StopTime'),...
            'StopTime','StopTimeTag',this.CheckSimulationResults);
            relativeToleranceEditBox=this.createEditBox(DAStudio.message('Simulink:modelReferenceAdvisor:RelativeTolerance'),...
            'RelativeTolerance','RelativeToleranceTag',this.CheckSimulationResults);
            absoluteToleranceEditBox=this.createEditBox(DAStudio.message('Simulink:modelReferenceAdvisor:AbsoluteTolerance'),...
            'AbsoluteTolerance','AbsoluteToleranceTag',this.CheckSimulationResults);
            simulationModeComboBox=this.createComboBox(...
            DAStudio.message('Simulink:modelReferenceAdvisor:SimulationMode'),'SimulationMode','SimulationModeTag',...
            {DAStudio.message('Simulink:modelReferenceAdvisor:NormalMode'),DAStudio.message('Simulink:modelReferenceAdvisor:AccelMode')},true);


            paramsGroup=this.createGroup(DAStudio.message('Simulink:modelReferenceAdvisor:OptionalParameters'),...
            'ConversionParamsGroupTag','ConversionParamsGroupTag');

            paramsGroup.Items={autofixCheckBox,replaceSubsystemCheckBox,createWrapperSubsystemCheckBox,expandVirtualBusCheckBox,...
            rightClickBuildCheckBox,simulationModeComboBox,checkSimulationResultsCheckBox,stopTimeEditBox,...
            relativeToleranceEditBox,absoluteToleranceEditBox};


            mainDlgGroup=this.createGroup('','ConversionParametersGroupTag','ConversionParametersGroupTag');

            mainDlgGroup.Items={referencedModelNameEditBox,dataFileEditBox,paramsGroup,buildTargetComboBox};

            dlg.DialogTitle=this.getDialogTitle;
            dlg.Items={mainDlgGroup};

            dlg.PostApplyCallback='Simulink.ModelReference.Conversion.ConversionDialogCallbacks.dlgPostApplyCallback';
            dlg.PostApplyArgs={'%source','%dialog'};

            dlg.CloseCallback='Simulink.ModelReference.Conversion.ConversionDialogCallbacks.dlgCloseCallback';
            dlg.CloseArgs={'%dialog','%closeaction'};
        end

        function inputArguments=generateInputArguments(this)
            inputArguments={};
            inputArguments{end+1}=this.SubsystemName;
            inputArguments{end+1}=this.ReferencedModelName;

            inputArguments{end+1}='DataFileName';
            inputArguments{end+1}=this.DataFile;

            inputArguments{end+1}='ReplaceSubsystem';
            inputArguments{end+1}=this.ReplaceSubsystem;

            inputArguments{end+1}='AutoFix';
            inputArguments{end+1}=this.AutoFix;

            inputArguments{end+1}='CreateWrapperSubsystem';
            inputArguments{end+1}=this.CreateWrapperSubsystem;

            inputArguments{end+1}='SimulationModes';
            inputArguments{end+1}={this.StringMapForGui.get(this.SimulationMode)};

            inputArguments{end+1}='ExpandVirtualBusPorts';
            inputArguments{end+1}=this.ExpandVirtualBusPorts;

            if this.RightClickBuild
                inputArguments{end+1}='RightClickBuild';
                inputArguments{end+1}=this.RightClickBuild;
            else
                if this.CheckSimulationResults
                    inputArguments{end+1}='CheckSimulationResults';
                    inputArguments{end+1}=this.CheckSimulationResults;
                    inputArguments{end+1}='StopTime';
                    inputArguments{end+1}=str2double(this.StopTime);
                    inputArguments{end+1}='AbsoluteTolerance';
                    inputArguments{end+1}=str2double(this.StopTime);
                    inputArguments{end+1}='RelativeTolerance';
                    inputArguments{end+1}=str2double(this.StopTime);
                end
            end
        end
    end

    methods(Access=protected)
        function this=ConversionDialog(subsys)
            this.System=get_param(subsys,'Handle');
            this.Model=bdroot(this.System);

            this.SubsystemName=getfullname(this.System);


            nameObj=Simulink.ModelReference.Conversion.NameUtils;
            this.ReferencedModelName=nameObj.getValidModelName(subsys);
            this.DataFile=Simulink.ModelReference.Conversion.FileUtils.getUniqueFileName(...
            Simulink.ModelReference.Conversion.ConversionParameters.getDataFileName(this.ReferencedModelName));


            stopTimeExpression=this.StopTime;
            this.StopTime=num2str(Simulink.SDIInterface.calculateStopTime(this.Model,stopTimeExpression));
            this.AbsoluteTolerance=num2str(Simulink.SDIInterface.calculateDefaultAbsoluteTolerance(this.Model));
            this.RelativeTolerance=num2str(Simulink.SDIInterface.calculateDefaultRelativeTolerance(this.Model));


            this.UseDataDictionary=~isempty(get_param(this.Model,'DataDictionary'));
            this.StringMapForGui=Simulink.ModelReference.Conversion.StringMapForGui;
        end

        function item=getBuildTargetCombo(this)
            item=this.createComboBox(...
            DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogBuildTarget'),'BuildTarget','BuildTargetComboBoxTag',...
            {DAStudio.message('Simulink:modelReferenceAdvisor:BuildTargetNone'),...
            DAStudio.message('Simulink:modelReferenceAdvisor:StandaloneRTWTarget')},true);
            item.Visible=this.ShowBuildTargetOption;
        end


        function results=getDialogTitle(this)
            results=DAStudio.message('Simulink:modelReferenceAdvisor:ConversionDialogTitle',this.SubsystemName);
        end
    end


    methods(Static,Access=protected)
        function item=createComboBox(itemName,objProperty,itemTag,entries,isEnabled)
            item=Simulink.ModelReference.Conversion.ConversionDialog.createWidget(itemName,objProperty,itemTag,isEnabled);
            item.Type='combobox';
            item.Entries=entries;
        end

        function item=createEditBox(itemName,objProperty,itemTag,isEnabled)
            item=Simulink.ModelReference.Conversion.ConversionDialog.createWidget(itemName,objProperty,itemTag,isEnabled);
            item.Type='edit';
        end

        function item=createCheckBox(itemName,objProperty,itemTag,isEnabled)
            item=Simulink.ModelReference.Conversion.ConversionDialog.createWidget(itemName,objProperty,itemTag,isEnabled);
            item.Type='checkbox';
        end


        function item=createWidget(itemName,objProperty,itemTag,isEnabled)
            item.Name=itemName;
            item.ObjectProperty=objProperty;
            item.Mode=1;
            item.Tag=itemTag;
            item.Enabled=isEnabled;
            item.DialogRefresh=1;
        end

        function item=createGroup(itemName,itemTag,wigetId)
            item.Type='group';
            item.Name=itemName;
            item.Flat=false;
            item.ToolTip='';
            item.Visible=1;
            item.Tag=itemTag;
            item.WidgetId=wigetId;
        end
    end
end
