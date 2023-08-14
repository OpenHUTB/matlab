function dlgStruct=getDialogSchema(this,name)







    presentationFormatLabel=this.msg('WdgtLblPresentationFormat');

    rpt=rptgen.findRpt(this);
    if isempty(rpt)
        isDOM=false;
    else
        isDOM=~isempty(regexp(rpt.Format,'dom-','ONCE'))...
        ||strcmp(rpt.Format,'db');
    end

    rowNum=2;
    wTableTitleStyleName=locGetStyleMode(this,isDOM,'TableTitleStyleName',rowNum);
    wTableStyleName=locGetStyleMode(this,isDOM,'TableStyleName',rowNum+1);



    if strcmpi(this.TableTitleStyleNameType,'auto')
        tableTitleStyleNameProp=findprop(this.classhandle,'TableTitleStyleName');
        if~isempty(tableTitleStyleNameProp)
            this.TableTitleStyleName=tableTitleStyleNameProp.FactoryValue;
        end
    end

    if strcmpi(this.TableStyleNameType,'auto')
        tableStyleNameProp=findprop(this.classhandle,'TableStyleName');
        if~isempty(tableStyleNameProp)
            this.TableStyleName=tableStyleNameProp.FactoryValue;
        end
    end


    dlgRowNum=1;
    pPresentationFormat=this.dlgContainer({
wTableTitleStyleName
wTableStyleName
    },presentationFormatLabel,...
    'Enabled',isDOM,...
    'LayoutGrid',[dlgRowNum,1],...
    'RowSpan',[dlgRowNum,dlgRowNum],...
    'ColSpan',[1,1],...
    'RowStretch',0,...
    'ShowGrid',true);




    rowNum=1;
    wIncludeChildDictionaries=this.dlgWidget('IncludeChildDictionaries',...
    'ColSpan',[1,1],...
    'RowSpan',[rowNum;rowNum],...
    'DialogRefresh',true);
    wIncludeChildDictionaries.ToolTip=this.msg('WdgtTTIncludeChildDictionaries');
    rowNum=rowNum+1;
    wMakeSeparateTableForChild=this.dlgWidget('MakeSeparateTableForChild',...
    'ColSpan',[1,1],...
    'RowSpan',[rowNum;rowNum],...
    'DialogRefresh',true,...
    'Enabled',this.IncludeChildDictionaries);
    wMakeSeparateTableForChild.ToolTip=this.msg('WdgtTTMakeSeparateTableForChild');
    rowNum=rowNum+1;
    wIncludeChildDictionariesList=this.dlgWidget('IncludeChildDictionariesList',...
    'ColSpan',[1,1],...
    'RowSpan',[rowNum;rowNum],...
    'Enabled',~this.MakeSeparateTableForChild);
    wIncludeChildDictionariesList.ToolTip=this.msg('WdgtTTIncludeChildDictionariesList');
    dlgRowNum=dlgRowNum+rowNum;


    rowNum=1;
    wIncludeDesignDataSection=this.dlgWidget('IncludeDesignDataSection',...
    'ColSpan',[1,1],...
    'RowSpan',[rowNum;rowNum]);
    wIncludeDesignDataSection.ToolTip=this.msg('WdgtTTIncludeDesignDataSection');
    rowNum=rowNum+1;
    wIncludeConfigurationsSection=this.dlgWidget('IncludeConfigurationsSection',...
    'ColSpan',[1,1],...
    'RowSpan',[rowNum;rowNum]);
    wIncludeConfigurationsSection.ToolTip=this.msg('WdgtTTIncludeConfigurationsSection');
    rowNum=rowNum+1;
    wIncludeOtherDataSection=this.dlgWidget('IncludeOtherDataSection',...
    'ColSpan',[1,1],...
    'RowSpan',[rowNum;rowNum]);
    wIncludeOtherDataSection.ToolTip=this.msg('WdgtTTIncludeOtherDataSection');

    sectionsToIncludeListLabel=[this.msg('WdgtLblSectionsToReportOn'),':'];
    rowStretch=zeros(1,rowNum);
    pSections=this.dlgContainer({
wIncludeDesignDataSection
wIncludeConfigurationsSection
wIncludeOtherDataSection
    },sectionsToIncludeListLabel,...
    'LayoutGrid',[rowNum,1],...
    'RowSpan',[dlgRowNum,dlgRowNum],...
    'RowStretch',rowStretch,...
    'ColSpan',[1,1],...
    'ShowGrid',true);
    dlgRowNum=dlgRowNum+1;


    rowNum=1;
    wShowDataType=this.dlgWidget('ShowDataType',...
    'ColSpan',[1,1],...
    'RowSpan',[rowNum;rowNum]);
    wShowDataType.ToolTip=this.msg('WdgtTTShowDataType');
    rowNum=rowNum+1;

    wShowLastModified=this.dlgWidget('ShowLastModified',...
    'ColSpan',[1,1],...
    'RowSpan',[rowNum;rowNum]);
    wShowLastModified.ToolTip=this.msg('WdgtTTShowLastModified');
    rowNum=rowNum+1;

    wShowLastModifiedBy=this.dlgWidget('ShowLastModifiedBy',...
    'ColSpan',[1,1],...
    'RowSpan',[rowNum;rowNum]);
    wShowLastModifiedBy.ToolTip=this.msg('WdgtTTShowLastModifiedBy');
    rowNum=rowNum+1;

    wShowStatus=this.dlgWidget('ShowStatus',...
    'ColSpan',[1,1],...
    'RowSpan',[rowNum;rowNum]);
    wShowStatus.ToolTip=this.msg('WdgtTTShowStatus');
    rowNum=rowNum+1;

    wShowDataSource=this.dlgWidget('ShowDataSource',...
    'ColSpan',[1,1],...
    'RowSpan',[rowNum;rowNum],...
    'Enabled',this.IncludeChildDictionaries&&~this.MakeSeparateTableForChild);
    wShowDataSource.ToolTip=this.msg('WdgtTTShowDataSource');

    fieldsToIncludeListLabel=[this.msg('WdgtLblFieldsToReportOn'),':'];
    rowStretch=zeros(1,rowNum);
    pFields=this.dlgContainer({
wShowDataType
wShowLastModified
wShowLastModifiedBy
wShowStatus
wShowDataSource
    },fieldsToIncludeListLabel,...
    'LayoutGrid',[rowNum,1],...
    'RowSpan',[dlgRowNum,dlgRowNum],...
    'RowStretch',rowStretch,...
    'ColSpan',[1,1],...
    'ShowGrid',true);

    optionsRowsNum=5;
    rowStretch=zeros(1,optionsRowsNum);
    optionsLabel=this.msg('WdgtLblOptions');
    pOptions=this.dlgContainer({
wIncludeChildDictionaries
wMakeSeparateTableForChild
wIncludeChildDictionariesList
pSections
pFields
    },optionsLabel,...
    'LayoutGrid',[optionsRowsNum,1],...
    'RowSpan',[2,2],...
    'RowStretch',rowStretch,...
    'ColSpan',[1,1],...
    'ShowGrid',true);


    dlgCmpnsNum=2;

    layoutGrid=[dlgCmpnsNum+1,1];
    rowStretch=zeros(1,dlgCmpnsNum);
    rowStretch(dlgCmpnsNum+1)=1;
    dlgStruct=this.dlgMain(name,{
pPresentationFormat
pOptions
    },...
    'LayoutGrid',layoutGrid,...
    'RowStretch',rowStretch);

end

function wStyleMode=locGetStyleMode(this,isDOM,schemaStyleEntry,rowNum)
    rowForStyleMode=[rowNum,rowNum];
    [wStyleNameMode,tStyleNameMode]=dlgWidget(this,[schemaStyleEntry,'Type'],...
    'RowSpan',rowForStyleMode,...
    'ColSpan',[2,2],...
    'ToolTip',getString(message('rptgen:r_cfr_text:styleNameToolTip')),...
    'DialogRefresh',true);

    if isDOM
        switch schemaStyleEntry
        case 'TableTitleStyleName'
            isEditable=~strcmpi(this.TableTitleStyleNameType,'Auto');
        case 'TableStyleName'
            isEditable=~strcmpi(this.TableStyleNameType,'Auto');
        otherwise
            isEditable=false;
        end
    else
        isEditable=false;
    end

    wStyleName=dlgWidget(this,schemaStyleEntry,...
    'ToolTip',getString(message('rptgen:r_cfr_text:styleNameToolTip')),...
    'Enabled',isEditable,...
    'RowSpan',rowForStyleMode,...
    'ColSpan',[3,3]);

    styleLabel='';
    wStyleMode=this.dlgContainer(...
    {tStyleNameMode
wStyleNameMode
    wStyleName},...
    styleLabel,...
    'LayoutGrid',[1,3],...
    'RowSpan',rowForStyleMode,...
    'ColSpan',[1,1]...
    );
end
