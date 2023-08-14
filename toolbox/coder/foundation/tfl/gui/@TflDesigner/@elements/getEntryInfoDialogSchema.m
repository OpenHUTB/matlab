function entryinfoviewgroup=getEntryInfoDialogSchema(this)






    entryinfoviewgroup.Name=DAStudio.message('RTW:tfldesigner:EntryInformationViewText');
    entryinfoviewgroup.Type='group';

    groupIsVisible=true;
    if isempty(this.object.Key)
        groupIsVisible=false;
    elseif ismember(this.object.Key,{'RTW_OP_ADD','RTW_OP_MINUS'})
        groupIsVisible=true;
    elseif~ismember(this.object.Key,...
        {'sin','cos','sincos','rSqrt','fir2d','ConvCorr1d','lookup',...
        'code_profile_read_timer','atan2','reciprocal'})

        groupIsVisible=false;
    end
    if~groupIsVisible
        entryinfoviewgroup.Items={};
        entryinfoviewgroup.Visible=false;
        return;
    end

    algorithminfoLbl.Name=DAStudio.message('RTW:tfldesigner:AlgorithmText');
    algorithminfoLbl.Type='text';
    algorithminfoLbl.RowSpan=[1,1];
    algorithminfoLbl.ColSpan=[1,1];
    algorithminfoLbl.Visible=false;

    algorithminfo=this.getDialogWidget('Tfldesigner_AlgorithmInfo');
    algorithminfo.RowSpan=[1,1];
    algorithminfo.ColSpan=[2,4];
    algorithminfoLbl.Visible=algorithminfo.Visible;
    algorithminfoLbl.Buddy=algorithminfo.Tag;


    outputmodeLbl.Name=DAStudio.message('RTW:tfldesigner:OutputModeText');
    outputmodeLbl.Type='text';
    outputmodeLbl.RowSpan=[1,1];
    outputmodeLbl.ColSpan=[6,6];
    outputmodeLbl.Visible=false;

    outputmode=this.getDialogWidget('Tfldesigner_FIR2D_OutputMode');
    outputmode.Alignment=5;
    outputmode.RowSpan=[1,1];
    outputmode.ColSpan=[7,9];
    outputmodeLbl.Buddy=outputmode.Tag;
    outputmodeLbl.Visible=outputmode.Visible;

    numinrowsLbl.Name=DAStudio.message('RTW:tfldesigner:NumInRowsText');
    numinrowsLbl.Type='text';
    numinrowsLbl.RowSpan=[2,2];
    numinrowsLbl.ColSpan=[1,1];
    numinrowsLbl.Visible=false;

    numinrows=this.getDialogWidget('Tfldesigner_FIR2D_NumInRows');
    numinrows.RowSpan=[2,2];
    numinrows.ColSpan=[2,4];
    numinrowsLbl.Buddy=numinrows.Tag;
    numinrowsLbl.Visible=numinrows.Visible;

    numincolsLbl.Name=DAStudio.message('RTW:tfldesigner:NumInColsText');
    numincolsLbl.Type='text';
    numincolsLbl.RowSpan=[2,2];
    numincolsLbl.ColSpan=[6,6];
    numincolsLbl.Visible=false;

    numincols=this.getDialogWidget('Tfldesigner_FIR2D_NumInCols');
    numincols.RowSpan=[2,2];
    numincols.ColSpan=[7,9];
    numincolsLbl.Buddy=numincols.Tag;
    numincolsLbl.Visible=numincols.Visible;

    numoutrowsLbl.Name=DAStudio.message('RTW:tfldesigner:NumOutRowsText');
    numoutrowsLbl.Type='text';
    numoutrowsLbl.RowSpan=[3,3];
    numoutrowsLbl.ColSpan=[1,1];
    numoutrowsLbl.Visible=false;

    numoutrows=this.getDialogWidget('Tfldesigner_FIR2D_NumOutRows');
    numoutrows.RowSpan=[3,3];
    numoutrows.ColSpan=[2,4];
    numoutrowsLbl.Buddy=numoutrows.Tag;
    numoutrowsLbl.Visible=numoutrows.Visible;

    numoutcolsLbl.Name=DAStudio.message('RTW:tfldesigner:NumOutColsText');
    numoutcolsLbl.Type='text';
    numoutcolsLbl.RowSpan=[3,3];
    numoutcolsLbl.ColSpan=[6,6];
    numoutcolsLbl.Visible=false;

    numoutcols=this.getDialogWidget('Tfldesigner_FIR2D_NumOutCols');
    numoutcols.RowSpan=[3,3];
    numoutcols.ColSpan=[7,9];
    numoutcolsLbl.Buddy=numoutcols.Tag;
    numoutcolsLbl.Visible=numoutcols.Visible;

    nummaskrowsLbl.Name=DAStudio.message('RTW:tfldesigner:NumMaskRowsText');
    nummaskrowsLbl.Type='text';
    nummaskrowsLbl.RowSpan=[4,4];
    nummaskrowsLbl.ColSpan=[1,1];
    nummaskrowsLbl.Visible=false;

    nummaskrows=this.getDialogWidget('Tfldesigner_FIR2D_NumMaskRows');
    nummaskrows.RowSpan=[4,4];
    nummaskrows.ColSpan=[2,4];
    nummaskrowsLbl.Buddy=nummaskrows.Tag;
    nummaskrowsLbl.Visible=nummaskrows.Visible;

    nummaskcolsLbl.Name=DAStudio.message('RTW:tfldesigner:NumMaskColsText');
    nummaskcolsLbl.Type='text';
    nummaskcolsLbl.RowSpan=[4,4];
    nummaskcolsLbl.ColSpan=[6,6];
    nummaskcolsLbl.Visible=false;

    nummaskcols=this.getDialogWidget('Tfldesigner_FIR2D_NumMaskCols');
    nummaskcols.RowSpan=[4,4];
    nummaskcols.ColSpan=[7,9];
    nummaskcolsLbl.Buddy=nummaskcols.Tag;
    nummaskcolsLbl.Visible=nummaskcols.Visible;



    numin1rowsLbl.Name=DAStudio.message('RTW:tfldesigner:NumIn1RowsText');
    numin1rowsLbl.Type='text';
    numin1rowsLbl.RowSpan=[2,2];
    numin1rowsLbl.ColSpan=[1,1];
    numin1rowsLbl.Visible=false;

    numin1rows=this.getDialogWidget('Tfldesigner_CONVCORR1D_NumIn1Rows');
    numin1rows.RowSpan=[2,2];
    numin1rows.ColSpan=[2,4];
    numin1rowsLbl.Buddy=numin1rows.Tag;
    numin1rowsLbl.Visible=numin1rows.Visible;

    numin2rowsLbl.Name=DAStudio.message('RTW:tfldesigner:NumIn2RowsText');
    numin2rowsLbl.Type='text';
    numin2rowsLbl.RowSpan=[2,2];
    numin2rowsLbl.ColSpan=[6,6];
    numin2rowsLbl.Visible=false;

    numin2rows=this.getDialogWidget('Tfldesigner_CONVCORR1D_NumIn2Rows');
    numin2rows.RowSpan=[2,2];
    numin2rows.ColSpan=[7,9];
    numin2rowsLbl.Buddy=numin2rows.Tag;
    numin2rowsLbl.Visible=numin2rows.Visible;


    lookupsearchmodeLbl.Name=DAStudio.message('RTW:tfldesigner:SearchMethodText');
    lookupsearchmodeLbl.Type='text';
    lookupsearchmodeLbl.RowSpan=[1,1];
    lookupsearchmodeLbl.ColSpan=[1,1];
    lookupsearchmodeLbl.Visible=false;

    lookupsearchmode=this.getDialogWidget('Tfldesigner_LOOKUP_SearchMethod');
    lookupsearchmode.RowSpan=[1,1];
    lookupsearchmode.ColSpan=[2,4];
    lookupsearchmodeLbl.Buddy=lookupsearchmode.Tag;
    lookupsearchmodeLbl.Visible=lookupsearchmode.Visible;

    lookupintrpmodeLbl.Name=DAStudio.message('RTW:tfldesigner:InterpolationText');
    lookupintrpmodeLbl.Type='text';
    lookupintrpmodeLbl.RowSpan=[2,2];
    lookupintrpmodeLbl.ColSpan=[1,1];
    lookupintrpmodeLbl.Visible=false;

    lookupintrpmode=this.getDialogWidget('Tfldesigner_LOOKUP_IntrpMethod');
    lookupintrpmode.RowSpan=[2,2];
    lookupintrpmode.ColSpan=[2,4];
    lookupintrpmodeLbl.Buddy=lookupintrpmode.Tag;
    lookupintrpmodeLbl.Visible=lookupintrpmode.Visible;

    lookupextrpmodeLbl.Name=DAStudio.message('RTW:tfldesigner:ExtrapolationText');
    lookupextrpmodeLbl.Type='text';
    lookupextrpmodeLbl.RowSpan=[3,3];
    lookupextrpmodeLbl.ColSpan=[1,1];
    lookupextrpmodeLbl.Visible=false;

    lookupextrpmode=this.getDialogWidget('Tfldesigner_LOOKUP_ExtrpMethod');
    lookupextrpmode.RowSpan=[3,3];
    lookupextrpmode.ColSpan=[2,4];
    lookupextrpmodeLbl.Buddy=lookupextrpmode.Tag;
    lookupextrpmodeLbl.Visible=lookupextrpmode.Visible;



    countdirLbl.Name=DAStudio.message('RTW:tfldesigner:CountDirection');
    countdirLbl.Type='text';
    countdirLbl.RowSpan=[1,1];
    countdirLbl.ColSpan=[1,1];
    countdirLbl.Visible=false;

    countdir=this.getDialogWidget('Tfldesigner_TIMER_CountDirection');
    countdir.RowSpan=[1,1];
    countdir.ColSpan=[2,4];
    countdirLbl.Buddy=countdir.Tag;
    countdirLbl.Visible=countdir.Visible;

    ticksLbl.Name=DAStudio.message('RTW:tfldesigner:Ticks');
    ticksLbl.Type='text';
    ticksLbl.RowSpan=[2,2];
    ticksLbl.ColSpan=[1,1];
    ticksLbl.Visible=false;

    ticks=this.getDialogWidget('Tfldesigner_TIMER_Ticks');
    ticks.RowSpan=[2,2];
    ticks.ColSpan=[2,4];
    ticksLbl.Buddy=ticks.Tag;
    ticksLbl.Visible=ticks.Visible;



    addMinusAlgorithmLbl.Name=DAStudio.message('RTW:tfldesigner:AlgorithmText');
    addMinusAlgorithmLbl.Type='text';
    addMinusAlgorithmLbl.RowSpan=[1,1];
    addMinusAlgorithmLbl.ColSpan=[1,1];
    addMinusAlgorithmLbl.Visible=false;

    addMinusAlgorithm=this.getDialogWidget('Tfldesigner_AddMinusAlgorithm');
    addMinusAlgorithm.RowSpan=[1,1];
    addMinusAlgorithm.ColSpan=[2,4];
    addMinusAlgorithmLbl.Visible=addMinusAlgorithm.Visible;
    addMinusAlgorithmLbl.Buddy=addMinusAlgorithm.Tag;



    entryinfoviewpanel.Type='panel';
    entryinfoviewpanel.LayoutGrid=[4,13];
    entryinfoviewpanel.RowSpan=[1,4];
    entryinfoviewpanel.ColSpan=[1,13];
    entryinfoviewpanel.RowStretch=ones(1,2);
    entryinfoviewpanel.ColStretch=ones(1,13);
    entryinfoviewpanel.Items={algorithminfoLbl,algorithminfo,outputmodeLbl,...
    outputmode,numinrowsLbl,numinrows,...
    numincolsLbl,numoutrowsLbl,numoutcolsLbl,...
    numincols,numoutrows,numoutcols,...
    nummaskrowsLbl,nummaskcolsLbl,...
    nummaskrows,nummaskcols,numin1rowsLbl,numin1rows,...
    numin2rowsLbl,numin2rows,lookupsearchmodeLbl,lookupintrpmodeLbl,...
    lookupextrpmodeLbl,lookupsearchmode,lookupintrpmode,...
    lookupextrpmode,countdirLbl,countdir,ticksLbl,ticks,...
    addMinusAlgorithmLbl,addMinusAlgorithm};



    entryinfoviewgroup.LayoutGrid=[4,13];
    entryinfoviewgroup.Items={entryinfoviewpanel};
    entryinfoviewgroup.Visible=true;

