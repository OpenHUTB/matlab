



classdef AddConditionalPauseDialog<handle
    properties(SetObservable=true)
        dlgInstance={};
        modelHandle=[]
        portHandle=[];
        relationalOperator=...
        DAStudio.message('Simulink:studio:Greater');
        relationalOperatorList=...
        {DAStudio.message('Simulink:studio:Greater'),...
        DAStudio.message('Simulink:studio:GreaterEqual'),...
        DAStudio.message('Simulink:studio:Equal'),...
        DAStudio.message('Simulink:studio:NotEqual'),...
        DAStudio.message('Simulink:studio:LessEqual'),...
        DAStudio.message('Simulink:studio:Less'),...
        };
        conditionValue='';
    end

    methods
        function obj=AddConditionalPauseDialog(modelH,portH)
            obj.modelHandle=modelH;
            obj.portHandle=portH;
        end

        function deleteDialog(obj)
            if~isempty(obj.dlgInstance)
                delete(obj.dlgInstance);
                obj.dlgInstance=[];
            end
            obj.conditionValue='';
        end
        function closeAddConditionalPauseDialog(obj,~)
            obj.deleteDialog();

        end
        function refreshDialog(obj)
            if~isempty(obj.dlgInstance)
                obj.dlgInstance.refresh;
            end
        end

        function showAddConditionalPauseDialog(obj)
            if isempty(obj.dlgInstance)
                obj.dlgInstance=DAStudio.Dialog(obj);
            else
                obj.dlgInstance.refresh;
                obj.dlgInstance.show;
            end
        end

        function[status,msg]=addConditionalPauseDlgPreApplyCB(~,dlg)

            status=true;
            msg='';



            value=(dlg.getWidgetValue('condition_value_tag'));
            if isempty(value),value='';end
            name='Simulink:studio:ConditionValue';
            newVal=str2double(value);

            if(isnan(newVal)||~isreal(newVal))
                status=false;
                msg=DAStudio.message(...
                'Simulink:studio:AddConditionalPauseInvalidInput',...
                value,DAStudio.message(name));
                return;
            end
        end

        function[status,msg]=addConditionalPauseDlgPostApplyCB(obj,dlg)
            status=true;
            msg='';
            try
                editor=SLM3I.SLDomain.findLastActiveEditor();

                blkHandle=get_param(obj.portHandle,'Parent');
                blkHandle=get_param(blkHandle,'Handle');
                fullBlockPathToTopModel=Simulink.BlockPath.fromHierarchyIdAndHandle(...
                editor.getHierarchyId,blkHandle);

                condition.relation=...
                dlg.getWidgetValue('relational_operator_tag');
                condition.value=...
                str2double(dlg.getWidgetValue('condition_value_tag'));
                condition.blockPath=fullBlockPathToTopModel;

                set_param(obj.portHandle,'AddConditionalPause',condition);
                conditionalPauseListObj=...
                SLStudio.GetBlockDiagramConditionalPauseListDialog(...
                obj.modelHandle);
                conditionalPauseListObj.refreshDialog;

            catch E
                status=false;
                msg=E.message;
            end
        end

        function dlgstruct=getDialogSchema(obj)

            wDescription.Name=...
            DAStudio.message(...
            'Simulink:studio:AddConditionalPauseDescription');
            wDescription.Type='text';
            wDescription.RowSpan=[1,1];
            wDescription.ColSpan=[1,2];
            wDescription.Alignment=1;
            locPrefix='description_';
            wDescription.Tag=[locPrefix,'tag'];
            wDescription.WidgetId=[locPrefix,'widgetid'];
            wDescription.ToolTip='';

            wRelationalOperator.Name='';
            wRelationalOperator.Type='combobox';
            wRelationalOperator.Entries=obj.relationalOperatorList;
            wRelationalOperator.ObjectProperty='relationalOperator';
            wRelationalOperator.RowSpan=[2,2];
            wRelationalOperator.ColSpan=[1,1];
            wRelationalOperator.Enabled=true;
            wRelationalOperator.Alignment=0;
            locPrefix='relational_operator_';
            wRelationalOperator.Tag=[locPrefix,'tag'];
            wRelationalOperator.WidgetId=[locPrefix,'widgetid'];
            wRelationalOperator.ToolTip='';

            wConditionValue.Name='';
            wConditionValue.Type='edit';
            wConditionValue.ObjectProperty='conditionValue';
            wConditionValue.RowSpan=[2,2];
            wConditionValue.ColSpan=[2,2];
            wConditionValue.Alignment=1;
            locPrefix='condition_value_';
            wConditionValue.Tag=[locPrefix,'tag'];
            wConditionValue.WidgetId=[locPrefix,'widgetid'];
            wConditionValue.ToolTip='';


            dlgstruct.DialogTitle=...
            DAStudio.message('Simulink:studio:AddConditionalPause');
            dlgstruct.StandaloneButtonSet=...
            {'Ok','Cancel','Help'};
            dlgstruct.SmartApply=0;
            dlgstruct.PreApplyCallback=...
            'addConditionalPauseDlgPreApplyCB';
            dlgstruct.PreApplyArgs={'%source','%dialog'};

            dlgstruct.PostApplyCallback=...
            'addConditionalPauseDlgPostApplyCB';
            dlgstruct.PostApplyArgs={'%source','%dialog'};

            dlgstruct.HelpMethod='helpview';
            dlgstruct.HelpArgs={fullfile(docroot,'simulink',...
            'helptargets.map'),'SimStepper_cond'};
            dlgstruct.LayoutGrid=[2,2];
            dlgstruct.Items=...
            {wDescription,wRelationalOperator,wConditionValue};
            dlgstruct.CloseMethod='closeAddConditionalPauseDialog';
            dlgstruct.CloseMethodArgs={'%closeaction'};
            dlgstruct.CloseMethodArgsDT={'string'};
        end



        function dataType=getPropDataType(~,propName)
            dataType='invalid';
            if any(strcmp(propName,{'relationalOperator','conditionValue'}))
                dataType='string';
            end
        end
    end
end


