classdef MainTab<autosar.ui.bsw.Tab




    properties(Constant)
        tag='tag_';
    end

    methods(Static)
        function text=getTab(h)
            tagPrefix=autosar.ui.bsw.FaultTab.tag;

            maskObj=get_param(h.getBlock().handle,'MaskObject');

            configurationRow=0;


            configurationRow=configurationRow+1;
            widget=[];
            widget.Type='text';
            widget.Name=DAStudio.message('autosarstandard:ui:uiDiagIncStepSizeText');
            widget.Tag=[tagPrefix,'IncrementStepSizeLabel'];

            widget.ColSpan=[1,1];
            widget.RowSpan=[configurationRow,configurationRow];
            IncrementStepSizeLabel=widget;


            widget=[];
            widget.Type='edit';
            widget.Source=h.getBlock();
            widget.ObjectProperty='DemDebounceCounterIncrementStepSize';
            widget.MatlabMethod='handleEditEvent';
            widget.MatlabArgs={h,'%value',find(strcmp({maskObj.Parameters(:).Name},widget.ObjectProperty))-1,'%dialog'};
            widget.Tag=widget.ObjectProperty;

            widget.ColSpan=[2,4];
            widget.RowSpan=[configurationRow,configurationRow];
            IncrementStepSize=widget;


            configurationRow=configurationRow+1;
            widget=[];
            widget.Type='text';
            widget.Name=DAStudio.message('autosarstandard:ui:uiDiagDecStepSizeText');
            widget.Tag=[tagPrefix,'DecrementStepSizeLabel'];

            widget.ColSpan=[1,1];
            widget.RowSpan=[configurationRow,configurationRow];
            DecrementStepSizeLabel=widget;


            widget=[];
            widget.Type='edit';
            widget.Source=h.getBlock();
            widget.ObjectProperty='DemDebounceCounterDecrementStepSize';
            widget.MatlabMethod='handleEditEvent';
            widget.MatlabArgs={h,'%value',find(strcmp({maskObj.Parameters(:).Name},widget.ObjectProperty))-1,'%dialog'};
            widget.Tag=widget.ObjectProperty;

            widget.ColSpan=[2,4];
            widget.RowSpan=[configurationRow,configurationRow];
            DecrementStepSize=widget;


            configurationRow=configurationRow+1;
            widget=[];
            widget.Type='text';
            widget.Name=DAStudio.message('autosarstandard:ui:uiDiagFailedThresholdText');
            widget.Tag=[tagPrefix,'FailedThresholdLabel'];

            widget.ColSpan=[1,1];
            widget.RowSpan=[configurationRow,configurationRow];
            FailedThresholdLabel=widget;


            widget=[];
            widget.Type='edit';
            widget.Source=h.getBlock();
            widget.ObjectProperty='DemDebounceCounterFailedThreshold';
            widget.MatlabMethod='handleEditEvent';
            widget.MatlabArgs={h,'%value',find(strcmp({maskObj.Parameters(:).Name},widget.ObjectProperty))-1,'%dialog'};
            widget.Tag=widget.ObjectProperty;

            widget.ColSpan=[2,4];
            widget.RowSpan=[configurationRow,configurationRow];
            FailedThreshold=widget;


            configurationRow=configurationRow+1;
            widget=[];
            widget.Type='text';
            widget.Name=DAStudio.message('autosarstandard:ui:uiDiagPassedThresholdText');
            widget.Tag=[tagPrefix,'PassedThresholdLabel'];

            widget.ColSpan=[1,1];
            widget.RowSpan=[configurationRow,configurationRow];
            PassedThresholdLabel=widget;


            widget=[];
            widget.Type='edit';
            widget.Source=h.getBlock();
            widget.ObjectProperty='DemDebounceCounterPassedThreshold';
            widget.MatlabMethod='handleEditEvent';
            widget.MatlabArgs={h,'%value',find(strcmp({maskObj.Parameters(:).Name},widget.ObjectProperty))-1,'%dialog'};
            widget.Tag=widget.ObjectProperty;

            widget.ColSpan=[2,4];
            widget.RowSpan=[configurationRow,configurationRow];
            PassedThreshold=widget;

            paramsgroupRow=0;


            paramsgroupRow=paramsgroupRow+1;
            debouncecontainer.Type='group';
            debouncecontainer.Name=DAStudio.message('autosarstandard:ui:uiDiagDebounceDesc');
            debouncecontainer.Tag=[tagPrefix,'debouncecontainer'];

            debouncecontainer.LayoutGrid=[configurationRow+1,2];

            debouncecontainer.RowStretch=[zeros(1,configurationRow),1];

            debouncecontainer.ColSpan=[1,1];
            debouncecontainer.RowSpan=[paramsgroupRow,paramsgroupRow];
            debouncecontainer.Items={
IncrementStepSizeLabel...
            ,IncrementStepSize...
            ,DecrementStepSizeLabel...
            ,DecrementStepSize...
            ,FailedThresholdLabel...
            ,FailedThreshold...
            ,PassedThresholdLabel...
            ,PassedThreshold};

            configurationRow=0;


            configurationRow=configurationRow+1;
            widget=[];
            widget.Type='text';
            widget.Name=DAStudio.message('autosarstandard:ui:uiNVRAMMaxBlockId');
            widget.Tag=[tagPrefix,'MaxBlockIdLabel'];

            widget.ColSpan=[1,1];
            widget.RowSpan=[configurationRow,configurationRow];
            MaxBlockIdLabel=widget;


            widget=[];
            widget.Type='edit';
            widget.Source=h.getBlock();
            widget.ObjectProperty='MaxBlockId';
            widget.MatlabMethod='handleEditEvent';
            widget.MatlabArgs={h,'%value',find(strcmp({maskObj.Parameters(:).Name},widget.ObjectProperty))-1,'%dialog'};
            widget.Tag=widget.ObjectProperty;

            widget.ColSpan=[2,4];
            widget.RowSpan=[configurationRow,configurationRow];
            MaxBlockId=widget;

            paramsgroupRow=0;


            paramsgroupRow=paramsgroupRow+1;
            nvramcontainer.Type='group';
            nvramcontainer.Name=DAStudio.message('autosarstandard:ui:uiNVRAMParamDesc');
            nvramcontainer.Tag=[tagPrefix,'nvramcontainer'];

            nvramcontainer.LayoutGrid=[configurationRow+1,2];

            nvramcontainer.RowStretch=[zeros(1,configurationRow),1];

            nvramcontainer.ColSpan=[1,1];
            nvramcontainer.RowSpan=[paramsgroupRow,paramsgroupRow];
            nvramcontainer.Items={
MaxBlockIdLabel...
            ,MaxBlockId};

            configurationRow=0;


            text=[];

            isDem=autosar.ui.bsw.Tab.isDem(h);
            if isDem
                text.Name=DAStudio.message('autosarstandard:ui:uiDemTab');
            else
                text.Name=DAStudio.message('autosarstandard:ui:uiNvMTab');
            end

            text.Tag=[tagPrefix,'maintab'];
            text.LayoutGrid=[configurationRow,2];
            if isDem
                text.Items={debouncecontainer};
            else
                text.Items={nvramcontainer};
            end

        end
    end
end


