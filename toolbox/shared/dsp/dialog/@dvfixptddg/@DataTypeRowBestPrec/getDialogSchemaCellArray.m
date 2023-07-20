function widgets=getDialogSchemaCellArray(this,cols);







    [NAME,MODE,DTNAME,SIGN,WL,FL_TEXT,FL_EDIT]=deal(1,2,3,4,5,6,7);
    [SLOPE_EDIT,SLOPE_TEXT,BIAS,REAL_FL]=deal(8,9,10,11);
    CENTER_ALIGN=5;



    [FRAC_COL_BIT,SLOPE_COL_BIT,BIAS_COL_BIT]=deal(4,5,6);



    if~any(strcmp(this.Controller.Root.SimulationStatus,{'running','paused'}))
        this.updateFracLengthFromWordLength;
    end

    widgets{REAL_FL}=udtGetLeafWidgetBase('edit','',...
    [this.Prefix,'FracLength'],...
    this.controller,'FracLength');
    widgets{REAL_FL}.Visible=0;






    widgets{NAME}=udtGetLeafWidgetBase('text',this.Name,[this.Prefix,'Name'],0);


    widgets{MODE}=udtGetLeafWidgetBase('combobox','',[this.Prefix,'Mode'],...
    this.controller,'Mode');
    widgets{MODE}.Entries=this.Entries(:)';
    widgets{MODE}.Values=0:numel(this.Entries(:)')-1;
    widgets{MODE}.DialogRefresh=1;
    widgets{NAME}.Buddy=widgets{MODE}.Tag;



    widgets{DTNAME}=udtGetLeafWidgetBase('edit','',...
    [this.prefix,'DataTypeName'],0);


    widgets{SIGN}=udtGetLeafWidgetBase('text','Yes',[this.Prefix,'Signed'],0);


    widgets{WL}=udtGetLeafWidgetBase('edit','',[this.Prefix,'WordLength'],...
    this.controller,'WordLength');
    widgets{WL}.DialogRefresh=1;


    widgets{FL_TEXT}=udtGetLeafWidgetBase('text',this.FracLength,...
    [this.Prefix,'FL_TEXT'],...
    this.controller);
    widgets{FL_TEXT}.Alignment=CENTER_ALIGN;


    widgets{FL_EDIT}=udtGetLeafWidgetBase('edit','',[this.Prefix,'FL_EDIT'],...
    this.controller,'FracLengthEdit');
    widgets{FL_EDIT}.ObjectMethod='updateFracLengthFromFracLength';
    widgets{FL_EDIT}.MethodArgs={'%value'};
    widgets{FL_EDIT}.ArgDataTypes={'mxArray'};
    widgets{FL_EDIT}.SaveState=0;


    if strcmp(this.FracLength,this.BestPrecString)
        slopeText=this.BestPrecString;
    else
        slopeText=['2^-(',this.FracLength,')'];
    end
    widgets{SLOPE_TEXT}=udtGetLeafWidgetBase('text',...
    slopeText,...
    [this.Prefix,'SlopeText'],...
    this.controller);
    widgets{SLOPE_TEXT}.Alignment=CENTER_ALIGN;

    widgets{SLOPE_EDIT}=udtGetLeafWidgetBase('edit','',[this.Prefix,'SlopeEdit'],...
    this.controller);

    widgets{SLOPE_EDIT}.ObjectMethod='updateFracLengthsFromSlope';
    widgets{SLOPE_EDIT}.MethodArgs={'%value'};
    widgets{SLOPE_EDIT}.ArgDataTypes={'mxArray'};
    widgets{SLOPE_EDIT}.Value=this.loadSlopeFromFracLength('FracLengthEdit');
    widgets{SLOPE_EDIT}.SaveState=0;


    widgets{BIAS}=udtGetLeafWidgetBase('text','0',[this.Prefix,'Bias'],0);


    widgets{NAME}.Visible=this.Visible;
    widgets{MODE}.Visible=this.Visible;

    untranslatedEntries=this.Block.getPropAllowedValues([this.Prefix,'Mode']);
    modeString=untranslatedEntries{this.Mode+1};

    if strcmp(modeString,'User-defined')
        modeString='Binary point scaling';
    elseif(strcmp(modeString,'Same as input')&&~any(strcmp(this.Entries,getString(message('dspshared:FixptDialog:SameAsInput')))))
        modeString='Same word length as input';
    end

    switch(modeString)
    case 'Same word length as input'


        widgets{DTNAME}.Visible=0;
        widgets{SIGN}.Visible=0;
        widgets{WL}.Visible=0;
        widgets{FL_TEXT}.Visible=0;
        widgets{FL_EDIT}.Visible=0;
        widgets{SLOPE_TEXT}.Visible=0;
        widgets{SLOPE_EDIT}.Visible=0;
        widgets{BIAS}.Visible=0;

    case 'Specify word length'

        widgets{DTNAME}.Visible=0;
        widgets{SIGN}.Visible=this.Visible;
        widgets{WL}.Visible=this.Visible;
        widgets{FL_TEXT}.Visible=bitget(cols,FRAC_COL_BIT)&&this.Visible;
        widgets{FL_EDIT}.Visible=0;
        widgets{SLOPE_TEXT}.Visible=bitget(cols,SLOPE_COL_BIT)&&this.Visible;
        widgets{SLOPE_EDIT}.Visible=0;
        widgets{BIAS}.Visible=bitget(cols,BIAS_COL_BIT)&&this.Visible;

    case 'Binary point scaling'
        if strcmp(this.FracLength,this.BestPrecString)
            widgets{FL_EDIT}.Value='0';
        else
            widgets{FL_EDIT}.Value=this.FracLength;
        end


        widgets{DTNAME}.Visible=0;
        widgets{SIGN}.Visible=this.Visible;
        widgets{WL}.Visible=this.Visible;
        widgets{FL_TEXT}.Visible=0;
        widgets{FL_EDIT}.Visible=this.Visible;
        widgets{SLOPE_TEXT}.Visible=0;
        widgets{SLOPE_EDIT}.Visible=0;
        widgets{BIAS}.Visible=0;

    case 'Slope and bias scaling'

        widgets{DTNAME}.Visible=0;
        widgets{SIGN}.Visible=this.Visible;
        widgets{WL}.Visible=this.Visible;
        widgets{FL_TEXT}.Visible=0;
        widgets{FL_EDIT}.Visible=0;
        widgets{SLOPE_TEXT}.Visible=0;
        widgets{SLOPE_EDIT}.Visible=this.Visible;
        widgets{BIAS}.Visible=this.Visible;

    otherwise

        widgets{DTNAME}.Visible=0;
        widgets{SIGN}.Visible=0;
        widgets{WL}.Visible=0;
        widgets{FL_TEXT}.Visible=0;
        widgets{FL_EDIT}.Visible=0;
        widgets{SLOPE_TEXT}.Visible=0;
        widgets{SLOPE_EDIT}.Visible=0;
        widgets{BIAS}.Visible=0;
    end


    widgets{NAME}.ColSpan=[1,1];
    widgets{MODE}.ColSpan=[2,2];
    widgets{DTNAME}.ColSpan=[3,3];
    widgets{SIGN}.ColSpan=[4,4];
    widgets{WL}.ColSpan=[5,5];
    widgets{FL_TEXT}.ColSpan=[6,6];
    widgets{FL_EDIT}.ColSpan=[6,6];
    widgets{SLOPE_TEXT}.ColSpan=[7,7];
    widgets{SLOPE_EDIT}.ColSpan=[7,7];
    widgets{BIAS}.ColSpan=[8,8];
    widgets{REAL_FL}.ColSpan=[1,1];






    widgets{NAME}.Alignment=CENTER_ALIGN;
    widgets{DTNAME}.Alignment=CENTER_ALIGN;
    widgets{SIGN}.Alignment=CENTER_ALIGN;
    widgets{BIAS}.Alignment=CENTER_ALIGN;

    for i=1:length(widgets)
        widgets{i}.Source=this;
        widgets{i}.RowSpan=[this.Row,this.Row];
    end
