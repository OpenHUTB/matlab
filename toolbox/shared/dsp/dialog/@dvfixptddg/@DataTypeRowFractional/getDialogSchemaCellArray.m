function widgets=getDialogSchemaCellArray(this,cols)







    [NAME,MODE,DTNAME,SIGN,WL,FL,SLOPE,BIAS,REAL_FL]=deal(1,2,3,4,5,6,7,8,9);
    CENTER_ALIGN=5;



    [FRAC_COL_BIT,SLOPE_COL_BIT,BIAS_COL_BIT]=deal(4,5,6);



    if~any(strcmp(this.Controller.Root.SimulationStatus,{'running','paused'}))
        this.updateFracLengthFromWordLength;
    end


    widgets{NAME}=udtGetLeafWidgetBase('text',this.Name,[this.Prefix,'Name'],0);
    widgets{NAME}.ColSpan=[1,1];
    widgets{NAME}.Alignment=CENTER_ALIGN;


    widgets{MODE}=udtGetLeafWidgetBase('combobox','',[this.Prefix,'Mode'],...
    this.controller,'Mode');
    widgets{MODE}.DialogRefresh=1;
    widgets{MODE}.ColSpan=[2,2];
    widgets{MODE}.Entries=this.Entries(:)';
    widgets{MODE}.Values=0:numel(this.Entries(:)')-1;


    widgets{DTNAME}=udtGetLeafWidgetBase('edit','',[this.prefix,'DataTypeName'],0);
    widgets{DTNAME}.ColSpan=[3,3];
    widgets{DTNAME}.Alignment=CENTER_ALIGN;


    if this.isSigned
        signedText='Yes';
    else
        signedText='No';
    end
    widgets{SIGN}=udtGetLeafWidgetBase('text',signedText,[this.Prefix,'Signed'],0);
    widgets{SIGN}.ColSpan=[4,4];
    widgets{SIGN}.Alignment=CENTER_ALIGN;


    widgets{WL}=udtGetLeafWidgetBase('edit','',[this.Prefix,'WordLength'],...
    this.controller,'WordLength');
    widgets{WL}.ColSpan=[5,5];
    widgets{WL}.DialogRefresh=1;



    widgets{FL}=udtGetLeafWidgetBase('text',this.FracLength,...
    [this.Prefix,'FracLengthText'],this.controller);
    widgets{FL}.ColSpan=[6,6];
    widgets{FL}.Alignment=CENTER_ALIGN;


    if strcmp(this.FracLength,this.BestPrecString)
        slopeText=this.BestPrecString;
    else
        slopeText=['2^-(',this.FracLength,')'];
    end
    widgets{SLOPE}=udtGetLeafWidgetBase('text',slopeText,...
    [this.Prefix,'Slope'],this.controller);
    widgets{SLOPE}.Mode=0;
    widgets{SLOPE}.ColSpan=[7,7];
    widgets{SLOPE}.Alignment=CENTER_ALIGN;


    widgets{BIAS}=udtGetLeafWidgetBase('text','0',[this.Prefix,'Bias'],0);
    widgets{BIAS}.ColSpan=[8,8];
    widgets{BIAS}.Alignment=CENTER_ALIGN;


    widgets{REAL_FL}=udtGetLeafWidgetBase('edit','',...
    [this.Prefix,'FracLength'],...
    this.controller,'FracLength');
    widgets{REAL_FL}.Visible=0;
    widgets{REAL_FL}.ColSpan=[1,1];


    widgets{NAME}.Visible=this.Visible;
    widgets{MODE}.Visible=this.Visible;

    untranslatedEntries=this.Block.getPropAllowedValues([this.Prefix,'Mode']);
    modeString=untranslatedEntries{this.Mode+1};

    if any(strcmp(modeString,...
        {'User-defined','Binary point scaling','Slope and bias scaling'}))
        modeString='Specify word length';
    elseif(strcmp(modeString,'Same as input')&&~any(strcmp(this.Entries,getString(message('dspshared:FixptDialog:SameAsInput')))))
        modeString='Same word length as input';
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

    case 'User-named data type'

        widgets{DTNAME}.Visible=0;
        widgets{SIGN}.Visible=0;
        widgets{WL}.Visible=0;
        widgets{FL}.Visible=0;
        widgets{SLOPE}.Visible=0;
        widgets{BIAS}.Visible=0;

    case 'Same word length as input'

        widgets{DTNAME}.Visible=0;
        if strcmp(this.SignednessVisible,'always')&&this.Visible
            widgets{SIGN}.Visible=1;
        else
            widgets{SIGN}.Visible=0;
        end
        widgets{WL}.Visible=0;
        widgets{FL}.Visible=0;
        widgets{SLOPE}.Visible=0;
        widgets{BIAS}.Visible=0;

    case 'Specify word length'

        widgets{DTNAME}.Visible=0;
        widgets{SIGN}.Visible=this.Visible;
        widgets{WL}.Visible=this.Visible;
        widgets{FL}.Visible=bitget(cols,FRAC_COL_BIT)&&this.Visible;
        widgets{SLOPE}.Visible=bitget(cols,SLOPE_COL_BIT)&&this.Visible;
        widgets{BIAS}.Visible=bitget(cols,BIAS_COL_BIT)&&this.Visible;

    otherwise
        error(message('dspshared:getDialogSchemaCellArray:unhandledCase'));
    end

    for i=1:length(widgets)
        widgets{i}.Source=this;
        widgets{i}.RowSpan=[this.Row,this.Row];
    end

