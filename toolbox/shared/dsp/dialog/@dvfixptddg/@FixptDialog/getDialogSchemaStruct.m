function fpaPane=getDialogSchemaStruct(this,fixptBlurb)











    if nargin<2
        fixptBlurb=1;
    end

    discStr=udtGetSPCUDTFltPtTrumpsDisclaimerStr(fixptBlurb);
    discText=udtGetLeafWidgetBase('text',...
    discStr,...
    'discText',...
    0);
    discText.WordWrap=1;


    discPane=udtGetContainerWidgetBase('panel',...
    '',...
    'discPane');
    discPane.Items={discText};
    discPane.RowSpan=[1,1];
    discPane.ColSpan=[1,1];

    emptyPanel=udtGetContainerWidgetBase('panel',...
    '',...
    'emptyPanel');

    emptyPanel.RowSpan=[2,2];
    emptyPanel.ColSpan=[1,1];







    fpaOperationalPane=udtGetContainerWidgetBase('group',...
    DAStudio.message('dspshared:FixptDialog:fixptOpParams'),...
    'fpaOperationalPane');
    fpaOperationalPane.Items={};
    ExtraRows=[];
    for ind=1:length(this.extraOp)
        if strcmp(this.extraOp(ind).UserData,'FixptOP')
            item=this.extraOp(ind).getDialogSchemaCellArray;
            fpaOperationalPane.Items=cat(2,fpaOperationalPane.Items,item);
            ExtraRows=cat(2,ExtraRows,item{1}.RowSpan(1):item{1}.RowSpan(2));
        end
    end

    ExtraRows=unique(ExtraRows);


    indices=1:length(ExtraRows);
    MissingRow=min(indices(~(ExtraRows(:)==indices(:))));
    if isempty(MissingRow)
        roundOverFlowRowSpan=[length(ExtraRows)+1,length(ExtraRows)+1];
    else
        roundOverFlowRowSpan=[MissingRow,MissingRow];
    end

    roundingMode=udtGetLeafWidgetBaseID('combobox','dspshared:FixptDialog:roundingMode',...
    'roundingMode',this.controller,...
    'roundingMode');
    roundingMode.Entries=this.Block.getPropAllowedValues('roundingMode',true);
    roundingMode.RowSpan=roundOverFlowRowSpan;
    roundingMode.ColSpan=[1,1];
    roundingMode.Source=this;

    overflowMode=udtGetLeafWidgetBaseID('combobox','dspshared:FixptDialog:overflowMode',...
    'overflowMode',this.controller,...
    'overflowMode');
    overflowModeEntries={getString(message('dspshared:FixptDialog:Wrap_CB')),getString(message('dspshared:FixptDialog:Saturate_CB'))};
    overflowMode.Entries=overflowModeEntries;
    overflowMode.RowSpan=roundOverFlowRowSpan;
    overflowMode.ColSpan=[2,2];
    overflowMode.Source=this;

    fpaOperationalPane.Items=cat(2,fpaOperationalPane.Items,...
    {roundingMode,overflowMode});

    fpaOperationalPane.LayoutGrid=[this.TotalOPRows,2];
    fpaOperationalPane.Tag='fpaOperationalPane';
    fpaOperationalPane.RowSpan=[3,3];
    fpaOperationalPane.ColSpan=[1,1];





    if~isempty(this.DataTypeRows)


        fpaDataTypePane=udtGetContainerWidgetBase('group',...
        DAStudio.message('dspshared:FixptDialog:fixptDataTypes'),...
        'fpaDataTypePane');
        fpaDataTypePane.Items={};
        ExtraRows=[];
        for ind=1:length(this.extraOp)
            if strcmp(this.extraOp(ind).UserData,'FixptDType')
                item=this.extraOp(ind).getDialogSchemaCellArray;
                fpaDataTypePane.Items=cat(2,fpaDataTypePane.Items,item);
                ExtraRows=cat(2,ExtraRows,item{1}.RowSpan(1):item{1}.RowSpan(2));
            end
        end

        ExtraRows=unique(ExtraRows);


        indices=1:length(ExtraRows);
        MissingRow=min(indices(~(ExtraRows(:)==indices(:))));
        if isempty(MissingRow)
            TitleRowSpan=[length(ExtraRows)+1,length(ExtraRows)+1];
        else
            TitleRowSpan=[MissingRow,MissingRow];
        end


        modeTitle=udtGetLeafWidgetBaseID('text','dspshared:FixptDialog:dataType','modeTitle',0);
        modeTitle.RowSpan=TitleRowSpan;
        modeTitle.ColSpan=[2,2];
        modeTitle.Alignment=5;

        dtNameTitle=udtGetLeafWidgetBaseID('text','dspshared:FixptDialog:dataTypeName',...
        'dtNameTitle',0);
        dtNameTitle.RowSpan=TitleRowSpan;
        dtNameTitle.ColSpan=[3,3];
        dtNameTitle.Alignment=5;

        signedTitle=udtGetLeafWidgetBaseID('text','dspshared:FixptDialog:signed','signedTitle',0);
        signedTitle.RowSpan=TitleRowSpan;
        signedTitle.ColSpan=[4,4];
        signedTitle.Alignment=5;

        wlTitle=udtGetLeafWidgetBaseID('text','dspshared:FixptDialog:wordLength','wlTitle',0);
        wlTitle.RowSpan=TitleRowSpan;
        wlTitle.ColSpan=[5,5];
        wlTitle.Alignment=5;

        flTitle=udtGetLeafWidgetBaseID('text','dspshared:FixptDialog:fractionLength','flTitle',0);
        flTitle.RowSpan=TitleRowSpan;
        flTitle.ColSpan=[6,6];
        flTitle.Alignment=5;

        slopeTitle=udtGetLeafWidgetBaseID('text','dspshared:FixptDialog:slope','slopeTitle',0);
        slopeTitle.RowSpan=TitleRowSpan;
        slopeTitle.ColSpan=[7,7];
        slopeTitle.Alignment=5;

        biasTitle=udtGetLeafWidgetBaseID('text','dspshared:FixptDialog:bias','biasTitle',0);
        biasTitle.RowSpan=TitleRowSpan;
        biasTitle.ColSpan=[8,8];
        biasTitle.Alignment=5;


        cols=this.DataTypeRows.getAllColumns;
        colStretchInds=[];
        dtNameTitle.Visible=0;

        if bitand(cols,2)
            signedTitle.Visible=1;
        else
            signedTitle.Visible=0;
        end
        if bitand(cols,4)
            wlTitle.Visible=1;
            colStretchInds=cat(2,colStretchInds,5);
        else
            wlTitle.Visible=0;
        end
        if bitand(cols,8)
            flTitle.Visible=1;
            colStretchInds=cat(2,colStretchInds,6);
        else
            flTitle.Visible=0;
        end
        if bitand(cols,16)
            slopeTitle.Visible=1;
            colStretchInds=cat(2,colStretchInds,7);
        else
            slopeTitle.Visible=0;
        end
        if bitand(cols,32)
            biasTitle.Visible=1;
        else
            biasTitle.Visible=0;
        end


        if isempty(colStretchInds)
            colStretchInds=cat(2,colStretchInds,8);
        end

        fpaDataTypePane.Items=cat(2,fpaDataTypePane.Items,...
        {modeTitle,dtNameTitle,signedTitle,...
        wlTitle,flTitle,slopeTitle,biasTitle});
        fpaDataTypePane.Tag='fpaDataTypePane';

        MaxDTypeRow=1;
        for ind=1:length(this.DataTypeRows)
            fpaDataTypePane.Items=cat(2,fpaDataTypePane.Items,...
            this.DataTypeRows(ind).getDialogSchemaCellArray(cols));
            if this.DataTypeRows(ind).Row>MaxDTypeRow
                MaxDTypeRow=this.DataTypeRows(ind).Row;
            end
        end


        if this.hasLockScale
            LockScaleRow=MaxDTypeRow+1;
            while any(LockScaleRow==ExtraRows)
                LockScaleRow=LockScaleRow+1;
            end
            LockScale=udtGetLeafWidgetBaseID('checkbox',...
            'dspshared:FixptDialog:lockAgnstChanges','LockScale',...
            this.controller,'LockScale');
            if~isempty(this.Controller)
                LockScale.Source=this.Controller.Block;
                LockScale.ObjectProperty='LockScale';
            end
            LockScale.RowSpan=[LockScaleRow,LockScaleRow];
            LockScale.ColSpan=[1,8];

            fpaDataTypePane.Items=cat(2,fpaDataTypePane.Items,{LockScale});
        end

        fpaDataTypePane.LayoutGrid=[this.TotalDataTypeRows,8];
        colStretch=zeros(1,8);
        colStretch(colStretchInds)=1;
        fpaDataTypePane.ColStretch=colStretch;

        fpaDataTypePane.RowSpan=[4,4];
        fpaDataTypePane.ColSpan=[1,1];

        items={discPane,emptyPanel,fpaOperationalPane,fpaDataTypePane};

    else
        items={discPane,emptyPanel,fpaOperationalPane};

    end





    fpaPane=udtGetContainerWidgetBase('panel','','fpaPane');
    fpaPane.Items=items;
    fpaPane.LayoutGrid=[length(items)+1,1];
    fpaPane.RowStretch=zeros(1,length(items)+1);
    fpaPane.RowStretch(end)=1;
    fpaPane.RowSpan=[1,1];
    fpaPane.ColSpan=[1,1];
    fpaPane.Tag='fpaPane';
    fpaPane.Source=this;

