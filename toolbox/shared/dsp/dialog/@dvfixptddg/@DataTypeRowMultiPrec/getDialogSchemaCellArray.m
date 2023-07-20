function widgets=getDialogSchemaCellArray(this,cols)







    [NAME,MODE,DTNAME,SIGN,WL,FL,SLOPE,BIAS]=deal(1,2,3,4,5,6,7,8);
    CENTER_ALIGN=5;






    widgets{NAME}=udtGetLeafWidgetBase('text',this.Name,this.Name,...
    this.Controller);


    widgets{MODE}=udtGetLeafWidgetBase('combobox','',[this.Prefix,'Mode'],...
    this.Controller,'Mode');
    widgets{MODE}.Entries=this.Entries(:)';
    widgets{MODE}.Values=0:numel(this.Entries(:)')-1;
    widgets{MODE}.DialogRefresh=1;
    widgets{NAME}.Buddy=widgets{MODE}.Tag;


    widgets{DTNAME}=udtGetLeafWidgetBase('edit','',...
    [this.prefix,'DataTypeName'],...
    this.Controller);


    widgets{SIGN}=udtGetLeafWidgetBase('text','Yes',...
    [this.Prefix,'Signed'],this.Controller);


    widgets{WL}=udtGetLeafWidgetBase('edit','',[this.Prefix,'WordLength'],...
    this.Controller,'WordLength');


    widgets{FL}=udtGetContainerWidgetBase('panel','',...
    [this.Prefix,'FracLengthPanel']);
    widgets{FL}.LayoutGrid=[1,2];


    widgets{SLOPE}=udtGetContainerWidgetBase('panel','',...
    [this.Prefix,'SlopePanel']);
    widgets{SLOPE}.LayoutGrid=[1,2];


    widgets{BIAS}=udtGetLeafWidgetBase('text','0',[this.Prefix,'Bias'],...
    this.Controller);


    widgets{NAME}.Visible=this.Visible;
    widgets{MODE}.Visible=this.Visible;

    untranslatedEntries=this.Block.getPropAllowedValues([this.Prefix,'Mode']);
    modeString=untranslatedEntries{this.Mode+1};

    if strcmp(modeString,'User-defined')
        modeString='Binary point scaling';
    elseif(strcmp(modeString,'Same as input')&&~any(strcmp(this.Entries,getString(message('dspshared:FixptDialog:SameAsInput')))))
        modeString='Same word length as input';
    elseif(strcmp(modeString,'Same as numerator')&&~any(strcmp(this.Entries,getString(message('dspshared:FixptDialog:SameAsNumerator')))))
        modeString='Same word length as numerator';
    end

    switch(modeString)
    case 'Specify word length'
        widgets{DTNAME}.Visible=0;
        widgets{SIGN}.Visible=this.Visible;
        widgets{WL}.Visible=this.Visible;
        widgets{WL}.DialogRefresh=1;
        fracPanelVisibility=0;
        slopePanelVisibility=0;
        widgets{BIAS}.Visible=0;

    case 'Binary point scaling'
        widgets{DTNAME}.Visible=0;
        widgets{SIGN}.Visible=this.Visible;
        widgets{WL}.Visible=this.Visible;
        fracPanelVisibility=this.Visible;
        slopePanelVisibility=0;
        widgets{BIAS}.Visible=0;

    case 'Slope and bias scaling'
        widgets{DTNAME}.Visible=0;
        widgets{SIGN}.Visible=this.Visible;
        widgets{WL}.Visible=this.Visible;
        fracPanelVisibility=0;
        slopePanelVisibility=this.Visible;
        widgets{BIAS}.Visible=this.Visible;

    otherwise


        widgets{DTNAME}.Visible=0;
        widgets{SIGN}.Visible=0;
        widgets{WL}.Visible=0;
        fracPanelVisibility=0;
        slopePanelVisibility=0;
        widgets{BIAS}.Visible=0;

    end

    widgets{FL}.Items=this.createFracLengthPanel(fracPanelVisibility);
    widgets{SLOPE}.Items=this.createSlopePanel(slopePanelVisibility);


    widgets{NAME}.ColSpan=[1,1];
    widgets{MODE}.ColSpan=[2,2];
    widgets{DTNAME}.ColSpan=[3,3];
    widgets{SIGN}.ColSpan=[4,4];
    widgets{WL}.ColSpan=[5,5];
    widgets{FL}.ColSpan=[6,6];
    widgets{SLOPE}.ColSpan=[7,7];
    widgets{BIAS}.ColSpan=[8,8];






    widgets{NAME}.Alignment=CENTER_ALIGN;
    widgets{DTNAME}.Alignment=CENTER_ALIGN;
    widgets{SIGN}.Alignment=CENTER_ALIGN;
    widgets{BIAS}.Alignment=CENTER_ALIGN;

    for i=1:length(widgets)
        widgets{i}.Source=this;
        widgets{i}.RowSpan=[this.Row,this.Row];
    end
