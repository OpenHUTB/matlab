function dlgStruct=getDialogSchema(this,name)




    if~builtin('license','checkout','SIMULINK_Report_Gen')
        dlgStruct=this.buildErrorMessage(name,true);
        return;

    end

    switch lower(getContextType(rptgen_sl.appdata_sl,this,false));
    case 'model'
        ctxtMsg=getString(message('RptgenSL:rsl_csl_blk_count:countInCurrentModelLabel'));
        enableIncludeBlocks=true;
    case 'system'
        ctxtMsg=getString(message('RptgenSL:rsl_csl_blk_count:countInCurrentSystemLabel'));
        enableIncludeBlocks=false;
    case 'block'
        ctxtMsg=getString(message('RptgenSL:rsl_csl_blk_count:cannotCountInsideBlockLoopLabel'));
        enableIncludeBlocks=false;
    case 'signal'
        ctxtMsg=getString(message('RptgenSL:rsl_csl_blk_count:cannotCountInsideSignalLoopLabel'));
        enableIncludeBlocks=false;
    case 'annotation'
        ctxtMsg=getString(message('RptgenSL:rsl_csl_blk_count:cannotCountInsideAnnotationLoopLabel'));
        enableIncludeBlocks=false;
    case 'configset'
        ctxtMsg=getString(message('RptgenSL:rsl_csl_blk_count:cannotCountInsideConfigSetLoopLabel'));
        enableIncludeBlocks=false;
    otherwise
        ctxtMsg=getString(message('RptgenSL:rsl_csl_blk_count:countInOpenModelsLabel'));
        enableIncludeBlocks=false;
    end

    dlgStruct=this.dlgMain(name,{
    this.dlgContainer({
    this.dlgText(ctxtMsg,...
    'RowSpan',[1,1],'ColSpan',[1,1])
    this.dlgWidget('IncludeBlocks',...
    'Enabled',enableIncludeBlocks,...
    'RowSpan',[2,2],'ColSpan',[1,1])
    },getString(message('RptgenSL:rsl_csl_blk_count:countTypesLabel')),...
    'LayoutGrid',[2,1],...
    'RowSpan',[1,1],'ColSpan',[1,1])
    this.dlgContainer({
    this.dlgWidget('TableTitle',...
    'RowSpan',[1,1],'ColSpan',[1,1])
    this.dlgWidget('isBlockName',...
    'RowSpan',[2,2],'ColSpan',[1,1])
    this.dlgWidget('SortOrder',...
    'RowSpan',[3,3],'ColSpan',[1,1])
    this.dlgWidget('IncludeTotal',...
    'RowSpan',[4,4],'ColSpan',[1,1])
    },getString(message('RptgenSL:rsl_csl_blk_count:tableContentLabel')),...
    'LayoutGrid',[4,1],...
    'RowSpan',[2,2],'ColSpan',[1,1])
    },'LayoutGrid',[3,1],'RowStretch',[0,0,1]);
