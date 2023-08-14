classdef ChangeDefaultClassDDG<handle







    properties
        dataObjectWizard={};
        Parameter={};
        Signal={};
        customizationDDG=[];
    end

    properties(Access=public)
        m_eventListener=[];
        m_closeEventListener=[];
    end

    methods
        function schema=getDialogSchema(obj)
            rowIndex=1;
            [paramLabel,paramCmbBox]=addClassList(obj,'Parameter',rowIndex);
            rowIndex=rowIndex+1;
            [signalLabel,signalCmbBox]=addClassList(obj,'Signal',rowIndex);

            schema.StandaloneButtonSet={'Ok','Cancel'};

            schema.DialogTag='ChangeDefaultClassDDG';
            schema.DialogTitle=DAStudio.message('Simulink:dow:ChangeDefaultClassDialogTitle');
            schema.LayoutGrid=[3,2];

            schema.Items={paramLabel,paramCmbBox,signalLabel,signalCmbBox};
            schema.CloseArgs={'%dialog','%closeaction'};
            schema.CloseCallback='Simulink.data.ChangeDefaultClassDDG.buttonCB';
        end


        function obj=ChangeDefaultClassDDG(varargin)
            if~isempty(varargin)
                obj.dataObjectWizard=varargin{1};
            else
                obj.dataObjectWizard={};
            end
        end
    end

    methods(Access=private)
        function[label,cmbBox]=addClassList(obj,clsType,rowIndex)

            label.Name=clsType;
            label.Type='text';
            label.RowSpan=[rowIndex,rowIndex];
            label.ColSpan=[1,1];

            [list,defItemIndex]=Simulink.data.findValidClasses(clsType);
            list=list';
            list{end+1}=DAStudio.message('modelexplorer:DAS:ME_SIMULINK_OBJECT_LIST_CUSTOMIZE_MENU_ITEM');
            obj.(clsType)=list;

            cmbBox.Tag=clsType;
            cmbBox.Type='combobox';
            cmbBox.Entries=obj.(clsType);
            cmbBox.Value=defItemIndex;
            cmbBox.RowSpan=[rowIndex,rowIndex];
            cmbBox.ColSpan=[2,2];

            cmbBox.MatlabMethod='Simulink.data.ChangeDefaultClassDDG.cmbBoxCB';
            cmbBox.MatlabArgs={'%dialog','%tag'};
        end

    end

    methods(Static)
        function buttonCB(dlg,closeaction)
            if strcmpi(closeaction,'ok')
                newDefParamClass=dlg.getWidgetValue('Parameter');
                Simulink.data.findValidClasses('Parameter',newDefParamClass);

                newDefSignalClass=dlg.getWidgetValue('Signal');
                Simulink.data.findValidClasses('Signal',newDefSignalClass);

                obj=dlg.getDialogSource;
                if~isempty(obj.dataObjectWizard)
                    dow_callback('applyClass',obj.dataObjectWizard,...
                    obj.Parameter{newDefParamClass+1},...
                    obj.Signal{newDefSignalClass+1});
                end
            end
        end

        function cmbBoxCB(dlg,tag)
            obj=dlg.getDialogSource;
            itemIndex=dlg.getWidgetValue(tag);

            customizeListItem=DAStudio.message('modelexplorer:DAS:ME_SIMULINK_OBJECT_LIST_CUSTOMIZE_MENU_ITEM');
            if strcmp(obj.(tag){itemIndex+1},customizeListItem)==1
                dlgSrc=Simulink.data.CustomObjectClassDDG(dlg);
                DAStudio.Dialog(dlgSrc,'','DLG_STANDALONE');
            end
        end

        function onCustomDialogClose(dlg)
            [~,defParam]=Simulink.data.findValidClasses('Parameter');
            [~,defSignal]=Simulink.data.findValidClasses('Signal');
            dlg.setWidgetValue('Parameter',defParam);
            dlg.setWidgetValue('Signal',defSignal);
            dlg.refresh;
        end
    end
end
