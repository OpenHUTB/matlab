function dlgOrTabStruct=fimath_getDialogSchema(h,name,isTab)








    if nargin==2||isempty(isTab)
        isTab=false;
    end
    rowspan=[0,0];


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
    ProductWordLength_visible_condition=~strcmpi(prodmodeVal,'FullPrecision');
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
    prodBiasVal=h.ProductBias;
    prodSAFVal=h.ProductSlopeAdjustmentFactor;
    ProductFractionLength_visible_condition=strcmpi(prodmodeVal,'SpecifyPrecision')&&prodBiasVal==0&&prodSAFVal==1;
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
    ProductSlope_visible_condition=strcmpi(prodmodeVal,'SpecifyPrecision')&&(prodBiasVal~=0||prodSAFVal~=1);
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
    ProductBias_visible_condition=strcmpi(prodmodeVal,'SpecifyPrecision')&&(prodBiasVal~=0||prodSAFVal~=1);
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
    summodeVal=h.SumMode;






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
    SumWordLength_visible_condition=~strcmpi(h.SumMode,'FullPrecision');
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
    sumBiasVal=h.SumBias;
    sumSAFVal=h.SumSlopeAdjustmentFactor;
    SumFractionLength_visible_condition=strcmpi(h.SumMode,'SpecifyPrecision')&&sumBiasVal==0&&sumSAFVal==1;
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
    SumSlope_visible_condition=strcmpi(h.SumMode,'SpecifyPrecision')&&(sumBiasVal~=0||sumSAFVal~=1);
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
    SumBias_visible_condition=strcmpi(h.SumMode,'SpecifyPrecision')&&(sumBiasVal~=0||sumSAFVal~=1);
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
    CastBeforeSum_visible_condition=~strcmpi(h.SumMode,'FullPrecision');
    CastBeforeSum.Visible=CastBeforeSum_visible_condition;
    CastBeforeSum.Value=h.CastBeforeSum;




    dialogTitleStr=getString(message('fixed:fimath:dialogTitle',name));
    if~isTab
        if isa(h,'embedded.globalfimath')
            dlgOrTabStruct.DialogTitle='Global Fimath';
        else
            dlgOrTabStruct.DialogTitle=dialogTitleStr;
        end
        dlgOrTabStruct.HelpMethod='helpview';
        dlgOrTabStruct.HelpArgs=...
        {fullfile(docroot,'fixedpoint','fixedpoint.map'),'fimath_dialog'};
    else
        dlgOrTabStruct.Name=dialogTitleStr;
    end

    dlgOrTabStruct.Items={RoundingMethodLbl,RoundingMethod,...
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
    CastBeforeSum};

    dlgOrTabStruct.LayoutGrid=[rowspan(1)+1,2];
    dlgOrTabStruct.RowStretch=[zeros(1,rowspan(1)),1];
    dlgOrTabStruct.ColStretch=[0,1];
    if~isempty(name)&&ischar(name)
        dlgOrTabStruct.DialogTag=dialogTitleStr;
    end
