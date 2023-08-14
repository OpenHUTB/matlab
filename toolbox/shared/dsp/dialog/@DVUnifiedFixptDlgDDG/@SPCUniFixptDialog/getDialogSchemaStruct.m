function dtAttrsPanel=getDialogSchemaStruct(this,fixptBlurb)











    dtAttrsPanel=udtGetContainerWidgetBase('panel','','dtAttrsPanel');
    dtAttrsPanel.RowSpan=[1,1];
    dtAttrsPanel.ColSpan=[1,1];
    dtAttrsPanel.Tag='dtAttrsPanel';
    dtAttrsPanel.Source=this;





    roundingMode=udtGetLeafWidgetBaseID('combobox','dspshared:FixptDialog:roundingMode',...
    'roundingMode',this.controller,...
    'roundingMode');


    if this.HasRoundingMode
        roundingMode.Entries=this.Block.getPropAllowedValues('roundingMode',true);
        roundingMode.RowSpan=[1,1];
        roundingMode.ColSpan=[1,1];
        roundingMode.Source=this;
    end

    if this.HasOverflowMode
        overflowMode=udtGetLeafWidgetBaseID('checkbox','dspshared:FixptDialog:saturateOnIntegerOverflow',...
        'overflowMode',this.controller,...
        'overflowMode');
        overflowMode.RowSpan=[1,1];
        overflowMode.ColSpan=[2,2];
        overflowMode.Source=this;
    end

    fixptOperationalGroupBox=...
    udtGetContainerWidgetBase('group',...
    DAStudio.message('dspshared:FixptDialog:fixptOpParams'),...
    'fixptOperationalGroupBox');
    fixptOperationalGroupBox.Tag='fixptOperationalGroupBox';
    fixptOperationalGroupBox.Items={};
    if this.HasRoundingMode
        fixptOperationalGroupBox.Items{end+1}=roundingMode;
    end
    if this.HasOverflowMode
        fixptOperationalGroupBox.Items{end+1}=overflowMode;
    end
    fixptOperationalGroupBox.LayoutGrid=[1,2];
    fixptOperationalGroupBox.RowSpan=[1,1];
    fixptOperationalGroupBox.ColSpan=[1,1];

    if isempty(this.DataTypeRows)
        items={fixptOperationalGroupBox};
    else



        if nargin<2
            fixptBlurb=1;
        end
        discStr=udtGetSPCUDTFltPtTrumpsDisclaimerStr(fixptBlurb);
        discText=udtGetLeafWidgetBase('text',discStr,'discText',0);
        discText.WordWrap=1;
        discPanel=udtGetContainerWidgetBase('panel','','discPanel');
        discPanel.Items={discText};
        discPanel.RowSpan=[2,2];
        discPanel.ColSpan=[1,5];




        emptyPanel=udtGetContainerWidgetBase('panel','','emptyPanel');
        emptyPanel.RowSpan=[3,3];
        emptyPanel.ColSpan=[1,1];




        [allPrompts,allComboxes,allShowBtns,allHideBtns,allDesMin,allDesMax,allDTAGUIs]=...
        this.DataTypeRows.getDialogSchemaCellArray;
        dataTypeTablePanel=createDataTypeTable(allPrompts,...
        allComboxes,...
        allShowBtns,...
        allHideBtns,...
        allDesMin,...
        allDesMax,...
        allDTAGUIs);




        LockScale=udtGetLeafWidgetBaseID('checkbox',...
        'dspshared:FixptDialog:lockAgnstChanges',...
        'LockScale',this.controller,'LockScale');

        NumUDTComboxesAndDTAGUIs=2*this.DataTypeRows(end).Row;
        LockScaleRowIdx=NumUDTComboxesAndDTAGUIs+1;
        LockScale.RowSpan=[LockScaleRowIdx,LockScaleRowIdx];
        LockScale.ColSpan=[1,5];

        dataTypeTablePanel.Items=...
        cat(2,dataTypeTablePanel.Items,{LockScale});
        dataTypeTablePanel.LayoutGrid=[LockScaleRowIdx,5];
        dataTypeTablePanel.RowSpan=[4,4];
        dataTypeTablePanel.ColSpan=[1,5];




        finalEmpRow=udtGetContainerWidgetBase('panel','','finalEmpRow');
        finalEmpRow.RowSpan=[5,5];
        finalEmpRow.ColSpan=[1,5];
        blockHandle=get(this.Block,'Handle');
        fixptOperationalGroupBox.Visible=...
        (this.HasRoundingMode&&isParameterVisible(blockHandle,'roundingMode'))||...
        (this.HasOverflowMode&&isParameterVisible(blockHandle,'overflowMode'));


        items={fixptOperationalGroupBox,...
        discPanel,...
        emptyPanel,...
        dataTypeTablePanel,...
        finalEmpRow};

    end

    dtAttrsPanel.Items=items;
    numDTAttrsPanelItems=length(items);
    dtAttrsPanel.LayoutGrid=[numDTAttrsPanelItems,1];
    dtAttrsPanel.RowStretch=[zeros(1,numDTAttrsPanelItems-1),1];


    function dataTypeTablePanel=createDataTypeTable(allPrompts,allComboxes,allShowBtns,allHideBtns,allDesMin,allDesMax,allDTAGUIs)





        udtTitle=udtGetLeafWidgetBaseID('text','dspshared:FixptDialog:dataType','udtTitle',0);
        udtTitle.RowSpan=[1,1];
        udtTitle.ColSpan=[2,2];
        udtTitle.Alignment=1;
        udtTitle.Visible=1;


        dtaTitle=udtGetLeafWidgetBaseID('text','dspshared:FixptDialog:assistant','dtaTitle',0);
        dtaTitle.RowSpan=[1,1];
        dtaTitle.ColSpan=[3,3];
        dtaTitle.Alignment=1;
        dtaTitle.Visible=1;


        minTitle=udtGetLeafWidgetBaseID('text','dspshared:FixptDialog:minimum','minTitle',0);
        minTitle.RowSpan=[1,1];
        minTitle.ColSpan=[4,4];
        minTitle.Alignment=1;
        minTitle.Visible=0;
        for ind=1:length(allDesMin)
            if~isempty(allDesMin{ind})
                minTitle.Visible=1;
                break;
            end
        end


        maxTitle=udtGetLeafWidgetBaseID('text','dspshared:FixptDialog:maximum','maxTitle',0);
        maxTitle.RowSpan=[1,1];
        maxTitle.ColSpan=[5,5];
        maxTitle.Alignment=1;
        maxTitle.Visible=0;
        for ind=1:length(allDesMax)
            if~isempty(allDesMax{ind})
                maxTitle.Visible=1;
                break;
            end
        end



        dataTypeTablePanel=...
        udtGetContainerWidgetBase('panel','','dataTypeTablePanel');
        dataTypeTablePanel.Tag='dataTypeTablePanel';
        dataTypeTablePanel.Items={udtTitle,dtaTitle,minTitle,maxTitle};



        dataTypeTablePanel.Items=cat(2,dataTypeTablePanel.Items,allPrompts);
        dataTypeTablePanel.Items=cat(2,dataTypeTablePanel.Items,allComboxes);
        dataTypeTablePanel.Items=cat(2,dataTypeTablePanel.Items,allShowBtns);
        dataTypeTablePanel.Items=cat(2,dataTypeTablePanel.Items,allHideBtns);



        for ind=1:length(allPrompts)
            desMinObj=allDesMin{ind};
            if~isempty(desMinObj)
                dataTypeTablePanel.Items=...
                cat(2,dataTypeTablePanel.Items,{desMinObj});
            end
            desMaxObj=allDesMax{ind};
            if~isempty(desMaxObj)
                dataTypeTablePanel.Items=...
                cat(2,dataTypeTablePanel.Items,{desMaxObj});
            end
        end



        dataTypeTablePanel.Items=cat(2,dataTypeTablePanel.Items,allDTAGUIs);

        function isVisible=isParameterVisible(blockHandle,paramName)
            maskObject=Simulink.Mask.get(blockHandle);




            if~isempty(maskObject.BaseMask)
                maskObject=maskObject.BaseMask;
            end

            param=maskObject.getParameter(paramName);
            isVisible=~isempty(param)&&strcmp(param.Visible,'on');


