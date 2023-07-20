
classdef SoftwarePlatformDlg<handle
    properties(SetObservable=true)
        ModelName;
        DialogH;
        CloseListener;
        cbinfo;
    end

    methods(Access=public)
        function obj=SoftwarePlatformDlg(cbinfoArg)
            obj.cbinfo=cbinfoArg;
            obj.ModelName=get_param(obj.cbinfo.model.handle,'Name');


            obj.CloseListener=Simulink.listener(obj.cbinfo.model.handle,'CloseEvent',...
            @CloseCB);


        end


        function[isValid,errorMsg]=hApplyCB(obj,dlg)
            isValid=true;
            errorMsg='';


            mapping=Simulink.CodeMapping.getCurrentMapping(obj.ModelName);
            dtWidgetValue=dlg.getWidgetValue('SoftwareDeploymentTypeComboBox');
            switch dtWidgetValue
            case 0
                mapping.DeploymentType='Unset';
            case 1
                mapping.DeploymentType='SoftwareApplication';
            case 2
                mapping.DeploymentType='SoftwareComponent';
            case 3
                mapping.DeploymentType='SoftwareSubAssembly';
            case 4
                mapping.DeploymentType='SoftwareLibrary';
            otherwise
                disp('Unknown value');
            end
        end

        function setDialog(obj,dlg)
            obj.DialogH=dlg;
        end

        function refresh(obj)
            obj.DialogH.refresh;
        end


        function dlg=getDialogSchema(obj)

            rowOffset=1;
            columnCount=20;
            mapping=Simulink.CodeMapping.getCurrentMapping(obj.ModelName);




            DescriptionText.Type='text';
            DescriptionText.Name=DAStudio.message('SimulinkCoderApp:ui:SoftwarePlatformDialogDescription');
            DescriptionText.WordWrap=true;
            DescriptionContainer.Type='group';
            DescriptionContainer.Name=DAStudio.message('SimulinkCoderApp:ui:SoftwarePlatformDescription');
            DescriptionContainer.Items={DescriptionText};





            SoftwarePlatformList.Type='combobox';
            SoftwarePlatformList.Entries={'Simulink Built-in','DDS','qT'};
            SoftwarePlatformList.Name=DAStudio.message('SimulinkCoderApp:ui:SoftwarePlatformComboBoxLabel');



            SoftwareDeploymentList.Type='combobox';
            SoftwareDeploymentList.Tag='SoftwareDeploymentTypeComboBox';
            SoftwareDeploymentList.Entries={'Unset','SoftwareApplication','SoftwareComponent','SoftwareSubAssembly','SoftwareLibrary'};
            SoftwareDeploymentList.Name=DAStudio.message('SimulinkCoderApp:ui:SoftwareDeploymentTypeComboBoxLabel');
            SoftwareDeploymentList.Value=mapping.DeploymentType;




            dlg.DialogTitle=DAStudio.message('SimulinkCoderApp:ui:SoftwarePlatformDialogTitle',obj.ModelName);
            dlg.LayoutGrid=[rowOffset,columnCount];

            dlg.Items={DescriptionContainer,SoftwarePlatformList,SoftwareDeploymentList};
            dlg.Sticky=true;
            dlg.StandaloneButtonSet={'Cancel','OK'};
            dlg.PreApplyCallback='hApplyCB';
            dlg.PreApplyArgs={obj,'%dialog'};
            dlg.Source=obj;
            dlg.DialogTag='SoftwarePlatformDlg';


        end
    end
end


function CloseCB(eventSrc,~)
    root=DAStudio.ToolRoot;
    swPlatformDialog=root.find('-isa','DAStudio.Dialog','dialogTag','SoftwarePlatformDlg');
    for i=1:length(swPlatformDialog)
        dlgSrc=swPlatformDialog.getDialogSource();
        modelH=get_param(dlgSrc.ModelName,'Handle');
        if modelH==eventSrc.Handle
            dlgSrc.delete;
            break;
        end
    end
end



