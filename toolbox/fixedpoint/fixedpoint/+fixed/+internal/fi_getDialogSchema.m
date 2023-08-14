function dlgStruct=fi_getDialogSchema(h,name,isTab)




    if nargin<3||isempty(isTab)
        isTab=false;
    end

    rowspan=[0,0];

    fimath_is_local=h.fimathislocal;
    is_scaled_type=h.isscaledtype;


















    rowspan=rowspan+1;
    valueLbl.Tag='ValueLbl';
    valueLbl.Type='text';
    valueLbl.Name=getString(message('fixed:fi:dialogValuePrompt'));
    valueLbl.RowSpan=rowspan;
    valueLbl.ColSpan=[1,1];

    value.Name='';
    value.RowSpan=rowspan;
    value.ColSpan=[2,2];
    value.Tag='Value';
    value.Type='edit';
    value.ObjectProperty='Value';
    value.DialogRefresh=0;
    value.Mode=0;

















    rowspan=rowspan+1;
    dataTypeModeLbl.Name=getString(message('fixed:numerictype:dialogDataTypeModePrompt'));
    dataTypeModeLbl.Tag='DataTypeModeLbl';
    dataTypeModeLbl.Type='text';
    dataTypeModeLbl.RowSpan=rowspan;
    dataTypeModeLbl.ColSpan=[1,1];


    dataTypeMode.Name='';
    dataTypeMode.RowSpan=rowspan;
    dataTypeMode.ColSpan=[2,2];
    dataTypeMode.Tag='DataTypeMode';
    dataTypeMode.Type='combobox';
    dataTypeMode.Entries={getString(message('fixed:fi:DataTypeModeBoolean'))
    getString(message('fixed:fi:DataTypeModeSingle'))
    getString(message('fixed:fi:DataTypeModeDouble'))
    getString(message('fixed:fi:DataTypeModeFixedBinaryPoint'))
    getString(message('fixed:fi:DataTypeModeFixedSlopeAndBias'))
    getString(message('fixed:fi:DataTypeModeScaledDoubleBinaryPoint'))
    getString(message('fixed:fi:DataTypeModeScaledDoubleSlopeAndBias'))};
    dataTypeMode.ObjectProperty='DataTypeMode';
    dataTypeMode.Mode=1;
    dataTypeMode.Enabled=false;






    rowspan=rowspan+1;
    signednessLbl.Name=getString(message('fixed:numerictype:dialogSignednessPrompt'));
    signednessLbl.Tag='SignednessLbl';
    signednessLbl.Type='text';
    signednessLbl.RowSpan=rowspan;
    signednessLbl.ColSpan=[1,1];
    signednessLbl.Visible=isscaledtype(h);

    signedness.Name='';
    signedness.RowSpan=rowspan;
    signedness.ColSpan=[2,2];
    signedness.Tag='Signedness';
    signedness.Type='combobox';
    signedness.Entries={getString(message('fixed:fi:SignednessSigned'))
    getString(message('fixed:fi:SignednessUnsigned'))};
    signedness.ObjectProperty='Signedness';
    signedness.Mode=0;
    signedness.Enabled=false;
    signedness.Visible=isscaledtype(h);






    rowspan=rowspan+1;
    WordLengthLbl.Name=getString(message('fixed:numerictype:dialogWordLengthPrompt'));
    WordLengthLbl.Tag='WordLengthLbl';
    WordLengthLbl.Type='text';
    WordLengthLbl.RowSpan=rowspan;
    WordLengthLbl.ColSpan=[1,1];
    WordLengthLbl.Visible=isscaledtype(h);

    WordLength.Name='';
    WordLength.RowSpan=rowspan;
    WordLength.ColSpan=[2,2];
    WordLength.Tag='WordLength';
    WordLength.Type='edit';
    WordLength.ObjectProperty='WordLength';
    WordLength.Mode=0;
    WordLength.DialogRefresh=0;
    WordLength.Enabled=0;
    WordLength.Visible=isscaledtype(h);







    rowspan=rowspan+1;
    FractionLengthLbl.Name=getString(message('fixed:numerictype:dialogFractionLengthPrompt'));
    FractionLengthLbl.Tag='FractionLengthLbl';
    FractionLengthLbl.Type='text';
    FractionLengthLbl.RowSpan=rowspan;
    FractionLengthLbl.ColSpan=[1,1];
    FractionLengthLbl.Visible=isscalingbinarypoint(h);

    FractionLength.Name='';
    FractionLength.RowSpan=rowspan;
    FractionLength.ColSpan=[2,2];
    FractionLength.Tag='FractionLength';
    FractionLength.Type='edit';
    FractionLength.ObjectProperty='FractionLength';
    FractionLength.Mode=0;
    FractionLength.DialogRefresh=0;
    FractionLength.Enabled=0;
    FractionLength.Visible=isscalingbinarypoint(h);






    rowspan=rowspan+1;
    SlopeLbl.Name=getString(message('fixed:numerictype:dialogSlopePrompt'));
    SlopeLbl.Tag='SlopeLbl';
    SlopeLbl.Type='text';
    SlopeLbl.RowSpan=rowspan;
    SlopeLbl.ColSpan=[1,1];
    SlopeLbl.Visible=isscalingslopebias(h);

    Slope.Name='';
    Slope.RowSpan=rowspan;
    Slope.ColSpan=[2,2];
    Slope.Tag='Slope';
    Slope.Type='edit';
    Slope.ObjectProperty='Slope';
    Slope.Mode=0;
    Slope.DialogRefresh=0;
    Slope.Enabled=0;
    Slope.Visible=isscalingslopebias(h);






    rowspan=rowspan+1;
    BiasLbl.Name=getString(message('fixed:numerictype:dialogBiasPrompt'));
    BiasLbl.Tag='BiasLbl';
    BiasLbl.Type='text';
    BiasLbl.RowSpan=rowspan;
    BiasLbl.ColSpan=[1,1];
    BiasLbl.Visible=isscalingslopebias(h);

    Bias.Name='';
    Bias.RowSpan=rowspan;
    Bias.ColSpan=[2,2];
    Bias.Tag='Bias';
    Bias.Type='edit';
    Bias.ObjectProperty='Bias';
    Bias.Mode=0;
    Bias.DialogRefresh=0;
    Bias.Enabled=0;
    Bias.Visible=isscalingslopebias(h);













    rowspan=rowspan+1;
    fimathislocal.Name=getString(message('fixed:fi:dialogLocalFimathPrompt'));
    fimathislocal.RowSpan=rowspan;
    fimathislocal.ColSpan=[1,1];
    fimathislocal.Type='checkbox';
    fimathislocal.Tag='fimathislocal';
    fimathislocal.ObjectProperty='fimathislocal';
    fimathislocal.Mode=1;
    fimathislocal.DialogRefresh=1;
    fimathislocal.Visible=is_scaled_type;
    fimathislocal.Value=fimath_is_local;






    rowspan=rowspan+1;
    RoundingMethodLbl.Name=getString(message('fixed:fimath:dialogRoundingMethodPrompt'));
    RoundingMethodLbl.Type='text';
    RoundingMethodLbl.RowSpan=rowspan;
    RoundingMethodLbl.ColSpan=[1,1];
    RoundingMethodLbl.Tag='RoundingMethodLbl';

    RoundingMethod.Name='';
    RoundingMethod.RowSpan=rowspan;
    RoundingMethod.ColSpan=[2,2];
    RoundingMethod.Tag='RoundingMethod';
    RoundingMethod.Type='combobox';
    RoundingMethod.Entries={getString(message('fixed:fi:RoundingMethodCeiling'))
    getString(message('fixed:fi:RoundingMethodConvergent'))
    getString(message('fixed:fi:RoundingMethodZero'))
    getString(message('fixed:fi:RoundingMethodFloor'))
    getString(message('fixed:fi:RoundingMethodNearest'))
    getString(message('fixed:fi:RoundingMethodRound'))}';
    RoundingMethod.ObjectProperty='DDGRoundingMethod';
    RoundingMethod.Mode=0;
    RoundingMethod.DialogRefresh=0;
    RoundingMethodLbl.Visible=fimath_is_local;
    RoundingMethod.Visible=fimath_is_local;
    RoundingMethod.Enabled=fimath_is_local;






    rowspan=rowspan+1;
    OverflowActionLbl.Name=getString(message('fixed:fimath:dialogOverflowActionPrompt'));
    OverflowActionLbl.Type='text';
    OverflowActionLbl.RowSpan=rowspan;
    OverflowActionLbl.ColSpan=[1,1];
    OverflowActionLbl.Tag='OverflowActionLbl';

    OverflowAction.Name='';
    OverflowAction.RowSpan=rowspan;
    OverflowAction.ColSpan=[2,2];
    OverflowAction.Tag='OverflowAction';
    OverflowAction.Type='combobox';
    OverflowAction.Entries={getString(message('fixed:fi:OverflowActionSaturate'))
    getString(message('fixed:fi:OverflowActionWrap'))}';
    OverflowAction.ObjectProperty='DDGOverflowAction';
    OverflowAction.Mode=0;
    OverflowAction.DialogRefresh=0;
    OverflowActionLbl.Visible=fimath_is_local;
    OverflowAction.Visible=fimath_is_local;
    OverflowAction.Enabled=fimath_is_local;






    rowspan=rowspan+1;
    ProductModeLbl.Name=getString(message('fixed:fimath:dialogProductModePrompt'));
    ProductModeLbl.Type='text';
    ProductModeLbl.RowSpan=rowspan;
    ProductModeLbl.ColSpan=[1,1];
    ProductModeLbl.Tag='ProductModeLbl';

    ProductMode.Name='';
    ProductMode.RowSpan=rowspan;
    ProductMode.ColSpan=[2,2];
    ProductMode.Tag='ProductMode';
    ProductMode.Type='combobox';
    ProductMode.Entries={getString(message('fixed:fi:ProductModeFullPrecision'))
    getString(message('fixed:fi:ProductModeKeepLSB'))
    getString(message('fixed:fi:ProductModeKeepMSB'))
    getString(message('fixed:fi:ProductModeSpecifyPrecision'))}';
    ProductMode.ObjectProperty='DDGProductMode';
    ProductMode.Mode=1;
    ProductMode.DialogRefresh=1;
    prodmodeVal=h.ProductMode;
    ProductModeLbl.Visible=fimath_is_local;
    ProductMode.Visible=fimath_is_local;
    ProductMode.Enabled=fimath_is_local;






    rowspan=rowspan+1;
    ProductWordLengthLbl.Name=getString(message('fixed:fimath:dialogProductWordLengthPrompt'));
    ProductWordLengthLbl.Type='text';
    ProductWordLengthLbl.RowSpan=rowspan;
    ProductWordLengthLbl.ColSpan=[1,1];
    ProductWordLengthLbl.Tag='ProductWordLengthLbl';

    ProductWordLength.Name='';
    ProductWordLength.RowSpan=rowspan;
    ProductWordLength.ColSpan=[2,2];
    ProductWordLength.Tag='ProductWordLength';
    ProductWordLength.Type='edit';
    ProductWordLength.ObjectProperty='DDGProductWordLength';
    ProductWordLength.Mode=0;
    ProductWordLength.DialogRefresh=0;
    ProductWordLength_visible_condition=fimath_is_local&&~strcmpi(prodmodeVal,'FullPrecision');
    ProductWordLengthLbl.Visible=ProductWordLength_visible_condition;
    ProductWordLength.Visible=ProductWordLength_visible_condition;
    ProductWordLength.Enabled=ProductWordLength_visible_condition;






    rowspan=rowspan+1;
    ProductFractionLengthLbl.Name=getString(message('fixed:fimath:dialogProductFractionLengthPrompt'));
    ProductFractionLengthLbl.Type='text';
    ProductFractionLengthLbl.RowSpan=rowspan;
    ProductFractionLengthLbl.ColSpan=[1,1];
    ProductFractionLengthLbl.Tag='ProductFractionLengthLbl';

    ProductFractionLength.Name='';
    ProductFractionLength.RowSpan=rowspan;
    ProductFractionLength.ColSpan=[2,2];
    ProductFractionLength.Tag='ProductFractionLength';
    ProductFractionLength.Type='edit';
    ProductFractionLength.ObjectProperty='DDGProductFractionLength';
    ProductFractionLength.Mode=0;
    ProductFractionLength.DialogRefresh=0;
    ProductFractionLength_visible_condition=fimath_is_local&&strcmpi(prodmodeVal,'SpecifyPrecision')&&isscalingbinarypoint(h);
    ProductFractionLengthLbl.Visible=ProductFractionLength_visible_condition;
    ProductFractionLength.Visible=ProductFractionLength_visible_condition;
    ProductFractionLength.Enabled=ProductFractionLength_visible_condition;






    rowspan=rowspan+1;
    ProductSlopeLbl.Name=getString(message('fixed:fimath:dialogProductSlopePrompt'));
    ProductSlopeLbl.Type='text';
    ProductSlopeLbl.RowSpan=rowspan;
    ProductSlopeLbl.ColSpan=[1,1];
    ProductSlopeLbl.Tag='ProductSlopeLbl';

    ProductSlope.Name='';
    ProductSlope.RowSpan=rowspan;
    ProductSlope.ColSpan=[2,2];
    ProductSlope.Tag='ProductSlope';
    ProductSlope.Type='edit';
    ProductSlope.ObjectProperty='DDGProductSlope';
    ProductSlope.Mode=0;
    ProductSlope.DialogRefresh=0;
    ProductSlope_visible_condition=fimath_is_local&&strcmpi(prodmodeVal,'SpecifyPrecision')&&isscalingslopebias(h);
    ProductSlopeLbl.Visible=ProductSlope_visible_condition;
    ProductSlope.Visible=ProductSlope_visible_condition;
    ProductSlope.Enabled=ProductSlope_visible_condition;






    rowspan=rowspan+1;
    ProductBiasLbl.Name=getString(message('fixed:fimath:dialogProductBiasPrompt'));
    ProductBiasLbl.Type='text';
    ProductBiasLbl.RowSpan=rowspan;
    ProductBiasLbl.ColSpan=[1,1];
    ProductBiasLbl.Tag='ProductBiasLbl';

    ProductBias.Name='';
    ProductBias.RowSpan=rowspan;
    ProductBias.ColSpan=[2,2];
    ProductBias.Tag='ProductBias';
    ProductBias.Type='edit';
    ProductBias.ObjectProperty='DDGProductBias';
    ProductBias.Mode=0;
    ProductBias.DialogRefresh=0;
    ProductBias_visible_condition=fimath_is_local&&strcmpi(prodmodeVal,'SpecifyPrecision')&&isscalingslopebias(h);
    ProductBiasLbl.Visible=ProductBias_visible_condition;
    ProductBias.Visible=ProductBias_visible_condition;
    ProductBias.Enabled=ProductBias_visible_condition;






    rowspan=rowspan+1;
    SumModeLbl.Name=getString(message('fixed:fimath:dialogSumModePrompt'));
    SumModeLbl.Type='text';
    SumModeLbl.RowSpan=rowspan;
    SumModeLbl.ColSpan=[1,1];
    SumModeLbl.Tag='SumModeLbl';

    SumMode.Name='';
    SumMode.RowSpan=rowspan;
    SumMode.ColSpan=[2,2];
    SumMode.Tag='SumMode';
    SumMode.Type='combobox';
    SumMode.Entries={getString(message('fixed:fi:SumModeFullPrecision'))
    getString(message('fixed:fi:SumModeKeepLSB'))
    getString(message('fixed:fi:SumModeKeepMSB'))
    getString(message('fixed:fi:SumModeSpecifyPrecision'))}';
    SumMode.ObjectProperty='DDGSumMode';
    SumMode.Mode=1;
    SumMode.DialogRefresh=1;
    SumModeLbl.Visible=fimath_is_local;
    SumMode.Visible=fimath_is_local;
    SumMode.Enabled=fimath_is_local;






    rowspan=rowspan+1;
    SumWordLengthLbl.Name=getString(message('fixed:fimath:dialogSumWordLengthPrompt'));
    SumWordLengthLbl.Type='text';
    SumWordLengthLbl.RowSpan=rowspan;
    SumWordLengthLbl.ColSpan=[1,1];
    SumWordLengthLbl.Tag='SumWordLengthLbl';

    SumWordLength.Name='';
    SumWordLength.RowSpan=rowspan;
    SumWordLength.ColSpan=[2,2];
    SumWordLength.Tag='SumWordLength';
    SumWordLength.Type='edit';
    SumWordLength.ObjectProperty='DDGSumWordLength';
    SumWordLength.Mode=0;
    SumWordLength.DialogRefresh=0;
    SumWordLength_visible_condition=fimath_is_local&&~strcmpi(h.SumMode,'FullPrecision');
    SumWordLengthLbl.Visible=SumWordLength_visible_condition;
    SumWordLength.Visible=SumWordLength_visible_condition;
    SumWordLength.Enabled=SumWordLength_visible_condition;






    rowspan=rowspan+1;
    SumFractionLengthLbl.Name=getString(message('fixed:fimath:dialogSumFractionLengthPrompt'));
    SumFractionLengthLbl.Type='text';
    SumFractionLengthLbl.RowSpan=rowspan;
    SumFractionLengthLbl.ColSpan=[1,1];
    SumFractionLengthLbl.Tag='SumFractionLengthLbl';

    SumFractionLength.Name='';
    SumFractionLength.RowSpan=rowspan;
    SumFractionLength.ColSpan=[2,2];
    SumFractionLength.Tag='SumFractionLength';
    SumFractionLength.Type='edit';
    SumFractionLength.ObjectProperty='DDGSumFractionLength';
    SumFractionLength.Mode=0;
    SumFractionLength.DialogRefresh=0;
    SumFractionLength_visible_condition=fimath_is_local&&strcmpi(h.SumMode,'SpecifyPrecision')&&isscalingbinarypoint(h);
    SumFractionLengthLbl.Visible=SumFractionLength_visible_condition;
    SumFractionLength.Visible=SumFractionLength_visible_condition;
    SumFractionLength.Enabled=SumFractionLength_visible_condition;







    rowspan=rowspan+1;
    SumSlopeLbl.Name=getString(message('fixed:fimath:dialogSumSlopePrompt'));
    SumSlopeLbl.Type='text';
    SumSlopeLbl.RowSpan=rowspan;
    SumSlopeLbl.ColSpan=[1,1];
    SumSlopeLbl.Tag='SumSlopeLbl';

    SumSlope.Name='';
    SumSlope.RowSpan=rowspan;
    SumSlope.ColSpan=[2,2];
    SumSlope.Tag='SumSlope';
    SumSlope.Type='edit';
    SumSlope.ObjectProperty='DDGSumSlope';
    SumSlope.Mode=0;
    SumSlope.DialogRefresh=0;
    SumSlope_visible_condition=fimath_is_local&&strcmpi(h.SumMode,'SpecifyPrecision')&&isscalingslopebias(h);
    SumSlopeLbl.Visible=SumSlope_visible_condition;
    SumSlope.Visible=SumSlope_visible_condition;
    SumSlope.Enabled=SumSlope_visible_condition;






    rowspan=rowspan+1;
    SumBiasLbl.Name=getString(message('fixed:fimath:dialogSumBiasPrompt'));
    SumBiasLbl.Type='text';
    SumBiasLbl.RowSpan=rowspan;
    SumBiasLbl.ColSpan=[1,1];
    SumBiasLbl.Tag='SumBiasLbl';

    SumBias.Name='';
    SumBias.RowSpan=rowspan;
    SumBias.ColSpan=[2,2];
    SumBias.Tag='SumBias';
    SumBias.Type='edit';
    SumBias.ObjectProperty='DDGSumBias';
    SumBias.Mode=0;
    SumBias.DialogRefresh=0;
    SumBias_visible_condition=fimath_is_local&&strcmpi(h.SumMode,'SpecifyPrecision')&&isscalingslopebias(h);
    SumBiasLbl.Visible=SumBias_visible_condition;
    SumBias.Visible=SumBias_visible_condition;
    SumBias.Enabled=SumBias_visible_condition;





    rowspan=rowspan+1;
    CastBeforeSum.Name=getString(message('fixed:fimath:dialogCastBeforeSumPrompt'));
    CastBeforeSum.RowSpan=rowspan;
    CastBeforeSum.ColSpan=[1,1];
    CastBeforeSum.Type='checkbox';
    CastBeforeSum.Tag='CastBeforeSum';
    CastBeforeSum.ObjectProperty='DDGCastBeforeSum';
    CastBeforeSum.Mode=0;
    CastBeforeSum.DialogRefresh=0;
    CastBeforeSum_visible_condition=fimath_is_local&&~strcmpi(h.SumMode,'FullPrecision');
    CastBeforeSum.Value=h.CastBeforeSum;
    CastBeforeSum.Visible=CastBeforeSum_visible_condition;
    CastBeforeSum.Enabled=CastBeforeSum_visible_condition;








    dialogTitleStr=getString(message('fixed:fi:dialogTitle',name));
    if isTab
        dlgStruct.Name=dialogTitleStr;
    else
        dlgStruct.DialogTitle=dialogTitleStr;
        dlgStruct.HelpMethod='helpview';
        dlgStruct.HelpArgs=...
        {fullfile(docroot,'fixedpoint','fixedpoint.map'),'fi_dialog'};
    end

    if fimath_is_local

        dlgStruct.Items={valueLbl,value,...
        dataTypeModeLbl,dataTypeMode,...
        signednessLbl,signedness,...
        WordLengthLbl,WordLength,...
        FractionLengthLbl,FractionLength,...
        SlopeLbl,Slope,...
        BiasLbl,Bias,...
        fimathislocal,...
        RoundingMethodLbl,RoundingMethod,...
        OverflowActionLbl,OverflowAction,...
        ProductModeLbl,ProductMode,...
        ProductWordLengthLbl,ProductWordLength,...
        ProductFractionLengthLbl,ProductFractionLength,...
        ProductSlopeLbl,ProductSlope,...
        ProductBiasLbl,ProductBias,...
        SumModeLbl,SumMode,...
        SumWordLengthLbl,SumWordLength,...
        SumFractionLengthLbl,SumFractionLength,...
        SumSlopeLbl,SumSlope,...
        SumBiasLbl,SumBias,...
CastBeforeSum
        };
    else
        dlgStruct.Items={valueLbl,value,...
        dataTypeModeLbl,dataTypeMode,...
        signednessLbl,signedness,...
        WordLengthLbl,WordLength,...
        FractionLengthLbl,FractionLength,...
        SlopeLbl,Slope,...
        BiasLbl,Bias,...
fimathislocal
        };
    end

    dlgStruct.LayoutGrid=[rowspan(1)+1,2];
    dlgStruct.RowStretch=[zeros(1,rowspan(1)),1];
    dlgStruct.ColStretch=[0,1];
    if~isempty(name)&&ischar(name)
        dlgStruct.DialogTag=dialogTitleStr;
    end

end







