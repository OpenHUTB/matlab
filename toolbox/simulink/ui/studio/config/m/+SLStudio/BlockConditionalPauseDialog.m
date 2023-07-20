classdef BlockConditionalPauseDialog<handle




    properties(SetObservable=true)
        dlgInstance={};
        modelHandle=[]
        blockHandle=[];
        spreadSheet=[];

        currentDiagSelection=[];
    end
    properties(Constant)

    end

    methods
        function this=BlockConditionalPauseDialog(modelH,blockH)
            this.modelHandle=modelH;
            this.blockHandle=blockH;
            this.currentDiagSelection=zeros(1,SLStudio.StepperBlockDiagnostics.NumAllowedDiagnostics);
            this.spreadSheet=SLStudio.BlockConditionalBreakpointDialogSource(modelH,blockH);
        end

        function deleteDialog(obj)
            if~isempty(obj.dlgInstance)
                delete(obj.dlgInstance);
                obj.dlgInstance=[];
            end
        end
        function closeBlockConditionalPauseDialog(obj,~)
            obj.deleteDialog();
        end
        function refreshDialog(obj)
            if~isempty(obj.dlgInstance)
                obj.dlgInstance.refresh;
            end
        end

        function showBlockConditionalPauseDialog(obj)
            if isempty(obj.dlgInstance)
                obj.dlgInstance=DAStudio.Dialog(obj);
            else
                obj.dlgInstance.refresh;
                obj.dlgInstance.show;
            end
        end


        function[status,msg]=BlockConditionalPauseDlgPostApplyCB(this,dlg)
            status=true;
            msg='';
            bps=dlg.getWidgetValue('block_bplist_tag');

            assert(numel(bps)==SLStudio.StepperBlockDiagnostics.NumAllowedDiagnostics,...
            'The number of allowed diagnostics is not properly set');

            condition.relation=6;
            condition.value='';
            try
                for idx=1:numel(bps)
                    condition.value=SLStudio.StepperBlockDiagnostics.AllowedSet(idx,2);

                    if bps{idx}.getPropValue('Enabled')=='1'
                        switch this.currentDiagSelection(idx)
                        case 0

                            set_param(this.blockHandle,'AddConditionalPause',condition);
                        case{2,3}

                            status.index=idx;
                            status.value=1;
                            set_param(this.blockHandle,'ConditionalPauseStatus',status);
                        otherwise
                        end
                        this.currentDiagSelection(idx)=1;
                    elseif bps{idx}.getPropValue('Enabled')=='0'&&this.currentDiagSelection(idx)==1

                        status.index=idx;
                        status.value=1;
                        set_param(this.blockHandle,'ConditionalPauseStatus',status);
                        this.currentDiagSelection(idx)=0;
                    end



                    conditionalPauseListObj=...
                    SLStudio.GetBlockDiagramConditionalPauseListDialog(...
                    this.modelHandle);

                    conditionalPauseListObj.refreshDialog;
                end
            catch E
                status=false;
                msg=E.message;
            end
        end
        function dlgstruct=getDialogSchema(this)
            ssWidget.Type='spreadsheet';
            ssWidget.Columns={'Enabled','Condition','Hits'};
            ssWidget.Source=this.spreadSheet;
            ssWidget.Tag='block_bplist_tag';

            messageField.Type='text';
            messageField.Tag='desciption';
            messageField.Name='Select diagnostic events on which to pause';
            messageField.RowSpan=[1,1];
            messageField.ColSpan=[1,1];

            dlgstruct.DialogTitle=['Conditional Pause for ',get_param(this.blockHandle,'Name')];
            dlgstruct.StandaloneButtonSet=...
            {'Ok','Cancel','Help'};
            dlgstruct.SmartApply=0;
            dlgstruct.PostApplyCallback=...
            'BlockConditionalPauseDlgPostApplyCB';
            dlgstruct.PostApplyArgs={'%source','%dialog'};

            dlgstruct.HelpMethod='helpview';
            dlgstruct.HelpArgs={fullfile(docroot,'simulink',...
            'helptargets.map'),'SimStepper_cond'};
            dlgstruct.LayoutGrid=[1,1];
            dlgstruct.Items=...
            {ssWidget};
            dlgstruct.CloseMethod='closeBlockConditionalPauseDialog';
            dlgstruct.CloseMethodArgs={'%closeaction'};
            dlgstruct.CloseMethodArgsDT={'string'};
        end
    end
end
