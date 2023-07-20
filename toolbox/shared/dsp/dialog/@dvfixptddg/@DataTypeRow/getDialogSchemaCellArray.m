function widgets=getDialogSchemaCellArray(this,cols);







    [NAME,MODE,DTNAME,SIGN,WL,FL,SLOPE,BIAS]=deal(1,2,3,4,5,6,7,8);
    CENTER_ALIGN=5;


    widgets{NAME}=udtGetLeafWidgetBase('text',this.Name,[this.Prefix,'Name'],0);
    widgets{NAME}.ColSpan=[1,1];
    widgets{NAME}.Alignment=CENTER_ALIGN;


    widgets{MODE}=udtGetLeafWidgetBase('combobox','',[this.Prefix,'Mode'],...
    this.controller,'Mode');
    widgets{MODE}.DialogRefresh=1;
    widgets{MODE}.ColSpan=[2,2];
    widgets{MODE}.Entries=this.Entries(:)';
    widgets{MODE}.Values=0:numel(this.Entries(:)')-1;
    widgets{NAME}.Buddy=widgets{MODE}.Tag;


    widgets{DTNAME}=udtGetLeafWidgetBase('edit','',...
    [this.prefix,'DataTypeName'],...
    this.controller);
    widgets{DTNAME}.ColSpan=[3,3];
    widgets{DTNAME}.Alignment=CENTER_ALIGN;


    switch this.SupportsUnsigned,
    case 0,
        signedTextID='dspshared:FixptDialog:yes';
    case 1,
        signedTextID='dspshared:FixptDialog:sameAsInput';
    case 2,
        signedTextID='dspshared:FixptDialog:Inherit';
    case 3,
        signedTextID='dspshared:FixptDialog:No';
    end

    widgets{SIGN}=udtGetLeafWidgetBaseID('text',signedTextID,...
    [this.Prefix,'Signed'],...
    this.controller);
    widgets{SIGN}.ColSpan=[4,4];
    widgets{SIGN}.Alignment=CENTER_ALIGN;


    widgets{WL}=udtGetLeafWidgetBase('edit','',[this.Prefix,'WordLength'],...
    this.controller,'WordLength');
    widgets{WL}.ColSpan=[5,5];



    widgets{FL}=udtGetLeafWidgetBase('edit','',[this.Prefix,'FracLength'],...
    this.controller,'FracLength');
    widgets{FL}.ColSpan=[6,6];



    widgets{SLOPE}=udtGetLeafWidgetBase('edit','',[this.Prefix,'Slope'],0);
    widgets{SLOPE}.Mode=0;
    widgets{SLOPE}.ColSpan=[7,7];
    widgets{SLOPE}.ObjectMethod='updateFracLengthFromSlope';
    widgets{SLOPE}.MethodArgs={'%value'};
    widgets{SLOPE}.ArgDataTypes={'mxArray'};
    widgets{SLOPE}.Value=this.loadSlopeFromFracLength;
    widgets{SLOPE}.SaveState=0;



    widgets{BIAS}=udtGetLeafWidgetBase('text','0',[this.Prefix,'Bias'],0);
    widgets{BIAS}.ColSpan=[8,8];
    widgets{BIAS}.Alignment=CENTER_ALIGN;


    widgets{NAME}.Visible=this.Visible;
    widgets{MODE}.Visible=this.Visible;

    untranslatedEntries=this.Block.getPropAllowedValues([this.Prefix,'Mode']);
    modeString=untranslatedEntries{this.Mode+1};

    if strcmp(modeString,'User-defined')
        modeString='Binary point scaling';
    end

    switch(modeString)
    case 'Binary point scaling'
        widgets{DTNAME}.Visible=0;
        widgets{SIGN}.Visible=this.Visible;
        widgets{WL}.Visible=this.Visible;
        widgets{FL}.Visible=this.Visible;
        widgets{SLOPE}.Visible=0;
        widgets{BIAS}.Visible=0;

    case 'Slope and bias scaling'
        widgets{DTNAME}.Visible=0;
        widgets{SIGN}.Visible=this.Visible;
        widgets{WL}.Visible=this.Visible;
        widgets{FL}.Visible=0;
        widgets{SLOPE}.Visible=this.Visible;
        widgets{BIAS}.Visible=this.Visible;

    otherwise

        widgets{DTNAME}.Visible=0;
        widgets{SIGN}.Visible=0;
        widgets{WL}.Visible=0;
        widgets{FL}.Visible=0;
        widgets{SLOPE}.Visible=0;
        widgets{BIAS}.Visible=0;
    end

    for i=1:length(widgets)
        widgets{i}.Source=this;
        widgets{i}.RowSpan=[this.Row,this.Row];
    end


