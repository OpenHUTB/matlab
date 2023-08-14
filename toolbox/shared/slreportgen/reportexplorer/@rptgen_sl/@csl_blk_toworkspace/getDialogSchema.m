function dlgStruct=getDialogSchema(this,name)





    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage(name,true);
        return;

    end










    dlgStruct=this.dlgMain(name,{
    this.dlgContainerSimplePrint('RowSpan',[1,1],'ColSpan',[1,1])
    this.gr_dlgDisplayOptions(...
    struct('none',getString(message('RptgenSL:rsl_csl_blk_toworkspace:noTitleLabel')),...
    'varname',getString(message('RptgenSL:rsl_csl_blk_toworkspace:useVariableNameLabel')),...
    'blkname','blockname',...
    'manual','-Title'),...
    struct('manual','-Caption',...
    'auto',getString(message('RptgenSL:rsl_csl_blk_toworkspace:fromDescriptionLabel')),...
    'none',getString(message('RptgenSL:rsl_csl_blk_toworkspace:noCaptionLabel'))),...
    'RowSpan',[2,2],...
    'ColSpan',[1,1])
    },'LayoutGrid',[2,1],'RowStretch',[0,1]);



