function dlgStruct=getDialogSchema(this,name)





    tag_prefix='rptgen_csl_emlfcn_';

    colStretch=[0,1,1];









    wIncludeFcnProps=this.dlgWidget('includeFcnProps',...
    'Tag',[tag_prefix,'includeFcnProps'],...
    'ToolTip',getString(message('RptgenSL:csl_emlfcn:includeFcnPropsLbl')),...
    'Mode',true,...
    'DialogRefresh',true,...
    'ColSpan',[1,1],...
    'RowSpan',[1,1]);



    ttTitleType=getString(message('RptgenSL:csl_emlfcn:tableTitleDropdownTooltip'));
    wFcnPropsTableTitleType=this.dlgWidget('FcnPropsTableTitleType',...
    'Tag',[tag_prefix,'FcnPropsTableTitleType'],...
    'ToolTip',ttTitleType,...
    'Mode',true,...
    'DialogRefresh',true,...
    'ColSpan',[1,1],...
    'RowSpan',[1,1]);

    wFcnPropsTableTitle=this.dlgWidget('FcnPropsTableTitle',...
    'Tag',[tag_prefix,'FcnPropsTableTitle'],...
    'ToolTip',getString(message('RptgenSL:csl_emlfcn:tableTitleTooltip')),...
    'Enabled',strcmp(this.FcnPropsTableTitleType,'manual'),...
    'ColSpan',[2,3],...
    'RowSpan',[1,1]);


    fcnPropsTableData=cell(2,2);
    fcnPropsTableData{1,1}=sprintf('%g',this.FcnPropsTablePropColWidth);
    fcnPropsTableData{1,2}=this.FcnPropsTablePropColHeader;
    fcnPropsTableData{2,1}=sprintf('%g',this.FcnPropsTableValueColWidth);
    fcnPropsTableData{2,2}=this.FcnPropsTableValueColHeader;

    wFcnPropColTable.Type='table';
    wFcnPropColTable.Tag=[tag_prefix,'FcnPropsColTable'];
    ttColOptions=getString(message('RptgenSL:csl_emlfcn:tableColOptionTooltip'));
    wFcnPropColTable.ToolTip=ttColOptions;
    wFcnPropColTable.Size=size(fcnPropsTableData);
    wFcnPropColTable.Data=fcnPropsTableData;
    wFcnPropColTable.ValueChangedCallback=@onFcnPropsColTableValueChanged;
    wFncPropColTable.Grid=true;
    wFcnPropColTable.HeaderVisibility=[1,1];
    wFcnPropColTable.ColHeader={getString(message('RptgenSL:csl_emlfcn:width')),getString(message('RptgenSL:csl_emlfcn:header'))};
    wFcnPropColTable.RowHeader={getString(message('RptgenSL:csl_emlfcn:propertyColumn')),getString(message('RptgenSL:csl_emlfcn:valueColumn'))};
    wFcnPropColTable.RowHeaderWidth=12;
    wFcnPropColTable.ColumnCharacterWidth=[6,12];
    wFcnPropColTable.Editable=true;
    wFcnPropColTable.ColSpan=[1,2];
    wFcnPropColTable.RowSpan=[2,3];

    ttGridLines=getString(message('RptgenSL:csl_emlfcn:gridLinesTooltip'));
    wHasBorderFcnPropTable=this.dlgWidget('hasBorderFcnPropTable',...
    'Tag',[tag_prefix,'hasBorderFcnPropsTable'],...
    'ToolTip',ttGridLines,...
    'ColSpan',[3,3],...
    'RowSpan',[2,2]);

    ttSpansPage=getString(message('RptgenSL:csl_emlfcn:pageWidthTooltip'));
    wSpansPageFcnPropTable=this.dlgWidget('spansPageFcnPropTable',...
    'Tag',[tag_prefix,'spansPageFcnPropsTable'],...
    'ToolTip',ttSpansPage,...
    'ColSpan',[3,3],...
    'RowSpan',[3,3]);

    wFcnPropTableFormatOptions=this.dlgContainer({
wFcnPropsTableTitleType
wFcnPropsTableTitle
wFcnPropColTable
wHasBorderFcnPropTable
wSpansPageFcnPropTable
    },getString(message('RptgenSL:csl_emlfcn:fnPropTableOptionsTooltip')),...
    'Enabled',this.includeFcnProps,...
    'LayoutGrid',[3,3],...
    'ColStretch',colStretch,...
    'RowSpan',[2,2],...
    'ColSpan',[1,2]);










    wIncludeArgSummary=this.dlgWidget('includeArgSummTable',...
    'Tag',[tag_prefix,'includeArgSummTable'],...
    'ToolTip',getString(message('RptgenSL:csl_emlfcn:includeFnArgSummTooltip')),...
    'Mode',true,...
    'DialogRefresh',true,...
    'ColSpan',[1,2],...
    'RowSpan',[3,3]);


    wArgSummTableTitleType=this.dlgWidget('ArgSummTableTitleType',...
    'Tag',[tag_prefix,'ArgSummTableTitleType'],...
    'ToolTip',ttTitleType,...
    'Mode',true,...
    'DialogRefresh',true,...
    'ColSpan',[1,1],...
    'RowSpan',[1,1]);

    isCustomTitleType=strcmp(this.ArgSummTableTitleType,'manual');

    wArgSummTableTitle=this.dlgWidget('ArgSummTableTitle',...
    'Tag',[tag_prefix,'ArgSummTableTitle'],...
    'ToolTip',getString(message('RptgenSL:csl_emlfcn:customArgTableTitleTooltip')),...
    'Enabled',isCustomTitleType,...
    'ColSpan',[2,3],...
    'RowSpan',[1,1]);



    propCount=length(this.ArgSummTableProps);
    tableData=cell(propCount,3);
    rowHeaders=cell(propCount,1);

    for i=1:propCount
        tableData{i,1}=this.ArgSummTableProps{i};
        tableData{i,3}=this.ArgSummTableColHeaders{i};
        tableData{i,2}=sprintf('%g',this.ArgSummTableColWidths(i));
        rowHeaders{i,1}=sprintf([getString(message('RptgenSL:csl_emlfcn:col')),' %g'],i);
    end

    wPropColTable.Type='table';
    wPropColTable.Tag=[tag_prefix,'ArgSummTableProps'];
    wPropColTable.ToolTip=ttColOptions;
    wPropColTable.Size=size(tableData);
    wPropColTable.Data=tableData;
    wPropColTable.Grid=true;
    wPropColTable.HeaderVisibility=[1,1];
    wPropColTable.ColHeader={getString(message('RptgenSL:csl_emlfcn:property')),getString(message('RptgenSL:csl_emlfcn:width')),getString(message('RptgenSL:csl_emlfcn:header'))};
    wPropColTable.ColumnCharacterWidth=[8,6,12];
    wPropColTable.RowHeader=rowHeaders;
    wPropColTable.RowHeaderWidth=3;
    wPropColTable.Editable=true;
    wPropColTable.ValueChangedCallback=@onArgSummTableValueChanged;
    wPropColTable.CurrentItemChangedCallback=@onArgSummTableCurrentItemChanged;
    wPropColTable.SelectedRow=this.ArgSummTablePropIdx-1;
    wPropColTable.ColSpan=[1,1];
    wPropColTable.RowSpan=[1,6];

    wUpButton.Type='pushbutton';
    wUpButton.Tag=[tag_prefix,'UpButton'];
    wUpButton.Enabled=this.ArgSummTablePropIdx>1;
    wUpButton.FilePath=fullfile(matlabroot,'toolbox/rptgen/resources/move_up.png');
    wUpButton.MatlabMethod='dlgMoveUp';
    wUpButton.MatlabArgs={'%source'};
    wUpButton.ToolTip=getString(message('RptgenSL:csl_emlfcn:moveLeftTooltip'));
    wUpButton.ColSpan=[2,2];
    wUpButton.RowSpan=[2,2];

    wDownButton.Type='pushbutton';
    wDownButton.Tag=[tag_prefix,'DownButton'];
    wDownButton.Enabled=this.ArgSummTablePropIdx<propCount;
    wDownButton.FilePath=fullfile(matlabroot,'toolbox/rptgen/resources/move_down.png');
    wDownButton.MatlabMethod='dlgMoveDown';
    wDownButton.MatlabArgs={'%source'};
    wDownButton.ToolTip=getString(message('RptgenSL:csl_emlfcn:moveRightTooltip'));
    wDownButton.ColSpan=[2,2];
    wDownButton.RowSpan=[3,3];

    wDeleteButton.Type='pushbutton';
    wDeleteButton.Tag=[tag_prefix,'DeleteButton'];
    wDeleteButton.Enabled=propCount>1;
    wDeleteButton.FilePath=fullfile(matlabroot,'toolbox/rptgen/resources/move_right.png');
    wDeleteButton.MatlabMethod='dlgDelete';
    wDeleteButton.MatlabArgs={'%source'};
    wDeleteButton.ToolTip=getString(message('RptgenSL:csl_emlfcn:removePropTooltip'));
    wDeleteButton.ColSpan=[2,2];
    wDeleteButton.RowSpan=[4,4];

    wMoveLeftButton.Type='pushbutton';
    wMoveLeftButton.Tag=[tag_prefix,'MoveLeftButton'];
    wMoveLeftButton.Enabled=~isempty(this.ArgSummTableOmittedProps);
    wMoveLeftButton.FilePath=fullfile(matlabroot,'toolbox/rptgen/resources/move_left.png');
    wMoveLeftButton.MatlabMethod='dlgAdd';
    wMoveLeftButton.MatlabArgs={'%source'};
    wMoveLeftButton.ToolTip=getString(message('RptgenSL:csl_emlfcn:addPropTooltip'));
    wMoveLeftButton.ColSpan=[2,2];
    wMoveLeftButton.RowSpan=[5,5];

    wOmittedPropsList.Type='listbox';
    wOmittedPropsList.Tag=[tag_prefix,'OmittedProps'];
    wOmittedPropsList.ToolTip=getString(message('RptgenSL:csl_emlfcn:omittedPropsTooltip'));
    wOmittedPropsList.MultiSelect=false;
    wOmittedPropsList.Entries=this.ArgSummTableOmittedProps;
    wOmittedPropsList.MatlabMethod='dlgSelectAction';
    wOmittedPropsList.MatlabArgs={'%source','%value'};
    wOmittedPropsList.Value=this.ArgSummTableAddPropIdx-1;
    wOmittedPropsList.ColSpan=[3,3];
    wOmittedPropsList.RowSpan=[1,6];

    wArgSummTableContentOptions=this.dlgContainer({
wPropColTable
wUpButton
wDownButton
wDeleteButton
wMoveLeftButton
wOmittedPropsList
    },getString(message('RptgenSL:csl_emlfcn:summTableColumnsTooltip')),...
    'Enabled',this.includeArgSummTable,...
    'LayoutGrid',[6,3],...
    'ColStretch',[0,0,1],...
    'RowSpan',[2,2],...
    'ColSpan',[1,3]);

    wHasBorderArgSummTable=this.dlgWidget('hasBorderArgSummTable',...
    'ToolTip',ttGridLines,...
    'ColSpan',[1,1],...
    'RowSpan',[3,3]);

    wSpansPageArgSummTable=this.dlgWidget('spansPageArgSummTable',...
    'ToolTip',ttSpansPage,...
    'ColSpan',[2,2],...
    'RowSpan',[3,3]);

    wArgSummTableAlign=this.dlgWidget('ArgSummTableAlign',...
    'ToolTip',getString(message('RptgenSL:csl_emlfcn:alignmentTooltip')),...
    'ColSpan',[3,3],...
    'RowSpan',[3,3]);

    wArgSummaryTableOptions=this.dlgContainer({
wArgSummTableTitleType
wArgSummTableTitle
wArgSummTableContentOptions
wHasBorderArgSummTable
wSpansPageArgSummTable
wArgSummTableAlign
    },getString(message('RptgenSL:csl_emlfcn:argSummaryOptionsTooltip')),...
    'Enabled',this.includeArgSummTable,...
    'LayoutGrid',[3,3],...
    'ColStretch',[1,2,3.5],...
    'RowSpan',[4,4],...
    'ColSpan',[1,2]);










    wIncludeArgDetails=this.dlgWidget('includeArgDetails',...
    'Tag',[tag_prefix,'includeArgDetails'],...
    'ToolTip',getString(message('RptgenSL:csl_emlfcn:includeFuncArgsTooltip')),...
    'Mode',true,...
    'DialogRefresh',true,...
    'ColSpan',[1,2],...
    'RowSpan',[5,5]);



    wArgPropTableTitleType=this.dlgWidget('ArgPropTableTitleType',...
    'Tag',[tag_prefix,'ArgPropTableTitleType'],...
    'ToolTip',ttTitleType,...
    'Mode',true,...
    'DialogRefresh',true,...
    'ColSpan',[1,1],...
    'RowSpan',[1,1]);

    wArgPropTableTitle=this.dlgWidget('ArgPropTableTitle',...
    'Tag',[tag_prefix,'ArgPropTableTitle'],...
    'ToolTip',getString(message('RptgenSL:csl_emlfcn:customArgPropTableTitleTooltip')),...
    'Enabled',strcmp(this.ArgPropTableTitleType,'manual'),...
    'ColSpan',[2,3],...
    'RowSpan',[1,1]);


    argPropsTableData=cell(2,2);
    argPropsTableData{1,1}=sprintf('%g',this.ArgPropTablePropColWidth);
    argPropsTableData{1,2}=this.ArgPropTablePropColHeader;
    argPropsTableData{2,1}=sprintf('%g',this.ArgPropTableValueColWidth);
    argPropsTableData{2,2}=this.ArgPropTableValueColHeader;

    wArgPropColTable.Type='table';
    wArgPropColTable.Tag=[tag_prefix,'ArgPropColTable'];
    wArgPropColTable.ToolTip=ttColOptions;
    wArgPropColTable.Size=size(argPropsTableData);
    wArgPropColTable.Data=argPropsTableData;
    wArgPropColTable.ValueChangedCallback=@onArgPropColTableValueChanged;
    wFncPropColTable.Grid=true;
    wArgPropColTable.HeaderVisibility=[1,1];
    wArgPropColTable.ColHeader={getString(message('RptgenSL:csl_emlfcn:width')),getString(message('RptgenSL:csl_emlfcn:header'))};
    wArgPropColTable.RowHeader={getString(message('RptgenSL:csl_emlfcn:propertyColumn')),getString(message('RptgenSL:csl_emlfcn:valueColumn'))};
    wArgPropColTable.RowHeaderWidth=12;
    wArgPropColTable.ColumnCharacterWidth=[6,12];
    wArgPropColTable.Editable=true;
    wArgPropColTable.ColSpan=[1,2];
    wArgPropColTable.RowSpan=[2,3];

    wHasBorderArgPropTable=this.dlgWidget('hasBorderArgPropTable',...
    'Tag',[tag_prefix,'hasBorderArgPropTable'],...
    'ToolTip',ttGridLines,...
    'ColSpan',[3,3],...
    'RowSpan',[2,2]);

    wSpansPageArgPropTable=this.dlgWidget('spansPageArgPropTable',...
    'Tag',[tag_prefix,'spansPageFcnPropsTable'],...
    'ToolTip',ttSpansPage,...
    'ColSpan',[3,3],...
    'RowSpan',[3,3]);

    wArgPropTableFormatOptions=this.dlgContainer({
wArgPropTableTitleType
wArgPropTableTitle
wArgPropColTable
wHasBorderArgPropTable
wSpansPageArgPropTable
    },getString(message('RptgenSL:csl_emlfcn:argPropTableOptions')),...
    'Enabled',this.includeArgDetails,...
    'LayoutGrid',[3,3],...
    'ColStretch',colStretch,...
    'RowSpan',[6,6],...
    'ColSpan',[1,2]);







    wIncludeScript=this.dlgWidget('includeScript',...
    'Tag',[tag_prefix,'includeScript'],...
    'ToolTip',getString(message('RptgenSL:csl_emlfcn:includeFnScriptTooltip')),...
    'Mode',true,...
    'DialogRefresh',true,...
    'ColSpan',[1,1],...
    'RowSpan',[7,7]);

    wSyntaxHighlightScript=this.dlgWidget('highlightScriptSyntax',...
    'Tag',[tag_prefix,'highlightScriptSyntax'],...
    'ToolTip',getString(message('RptgenSL:csl_emlfcn:highlightScriptTooltip')),...
    'Enabled',this.includeScript,...
    'ColSpan',[2,2],...
    'RowSpan',[7,7]);







    wIncludeDataAttr=this.dlgWidget('includeFcnSymbData',...
    'Tag',[tag_prefix,'includeFcnSymbData'],...
    'ToolTip',getString(message('RptgenSL:csl_emlfcn:includeFnSymDataTooltip')),...
    'Mode',true,...
    'DialogRefresh',true,...
    'ColSpan',[1,1],...
    'RowSpan',[8,8]);







    wIncludeSupportingFunctions=this.dlgWidget('includeSupportingFunctions',...
    'Tag',[tag_prefix,'includeSupportingFunctions'],...
    'ToolTip',getString(message('RptgenSL:csl_emlfcn:includeInvokedFnTooltip')),...
    'Mode',true,...
    'DialogRefresh',true,...
    'ColSpan',[1,1],...
    'RowSpan',[9,9]);



    wSupportFcnsToInclude=this.dlgWidget('supportFunctionsToInclude',...
    'Type','radiobutton',...
    'Tag',[tag_prefix,'supportFunctionsToInclude'],...
    'ToolTip',getString(message('RptgenSL:csl_emlfcn:selectIncludedFnTooltip')),...
    'Entries',{getString(message('RptgenSL:csl_emlfcn:mlAndUserDefinedFnOption'))...
    ,getString(message('RptgenSL:csl_emlfcn:userDefinedFnOption'))},...
    'Values',[1,2],...
    'OrientHorizontal',true,...
    'Enabled',this.includeSupportingFunctions,...
    'ColSpan',[1,1],...
    'RowSpan',[11,11]);



    wSupportFcnTableTitleType=this.dlgWidget('SupportFcnTableTitleType',...
    'Tag',[tag_prefix,'SupportFcnTableTitleType'],...
    'ToolTip',ttTitleType,...
    'Mode',true,...
    'DialogRefresh',true,...
    'ColSpan',[1,1],...
    'RowSpan',[1,1]);

    wSupportFcnTableTitle=this.dlgWidget('SupportFcnTableTitle',...
    'Tag',[tag_prefix,'SupportFcnTableTitle'],...
    'ToolTip',getString(message('RptgenSL:csl_emlfcn:customSuppFnTableTitleTooltip')),...
    'Enabled',strcmp(this.SupportFcnTableTitleType,'manual'),...
    'ColSpan',[2,3],...
    'RowSpan',[1,1]);


    supportFcnsTableData=cell(3,2);
    supportFcnsTableData{1,1}=sprintf('%g',this.SupportFcnTableNameColWidth);
    supportFcnsTableData{1,2}=this.SupportFcnTableNameColHeader;
    supportFcnsTableData{2,1}=sprintf('%g',this.SupportFcnTableDefinedByColWidth);
    supportFcnsTableData{2,2}=this.SupportFcnTableDefinedByColHeader;
    supportFcnsTableData{3,1}=sprintf('%g',this.SupportFcnTablePathColWidth);
    supportFcnsTableData{3,2}=this.SupportFcnTablePathColHeader;


    wSupportFcnColTable.Type='table';
    wSupportFcnColTable.Tag=[tag_prefix,'SupportFcnColTable'];
    wSupportFcnColTable.ToolTip=ttColOptions;
    wSupportFcnColTable.Size=size(supportFcnsTableData);
    wSupportFcnColTable.Data=supportFcnsTableData;
    wSupportFcnColTable.ValueChangedCallback=@onSupportFcnColTableValueChanged;
    wFncPropColTable.Grid=true;
    wSupportFcnColTable.HeaderVisibility=[1,1];
    wSupportFcnColTable.ColHeader={getString(message('RptgenSL:csl_emlfcn:width')),getString(message('RptgenSL:csl_emlfcn:header'))};
    wSupportFcnColTable.RowHeader={getString(message('RptgenSL:csl_emlfcn:nameColumn')),...
    getString(message('RptgenSL:csl_emlfcn:definedByColumn')),...
    getString(message('RptgenSL:csl_emlfcn:pathColumn'))};
    wSupportFcnColTable.RowHeaderWidth=12;
    wSupportFcnColTable.ColumnCharacterWidth=[6,12];
    wSupportFcnColTable.Editable=true;
    wSupportFcnColTable.ColSpan=[1,2];
    wSupportFcnColTable.RowSpan=[2,3];

    wHasBorderSupportFcnTable=this.dlgWidget('hasBorderSupportFcnTable',...
    'Tag',[tag_prefix,'hasBorderSupportFcnTable'],...
    'ToolTip',ttGridLines,...
    'ColSpan',[3,3],...
    'RowSpan',[2,2]);

    wSpansPageSupportFcnTable=this.dlgWidget('spansPageSupportFcnTable',...
    'Tag',[tag_prefix,'spansPageFcnPropsTable'],...
    'ToolTip',ttSpansPage,...
    'ColSpan',[3,3],...
    'RowSpan',[2,3]);

    wSupportFcnTableFormatOptions=this.dlgContainer({
wSupportFcnTableTitleType
wSupportFcnTableTitle
wSupportFcnColTable
wHasBorderSupportFcnTable
wSpansPageSupportFcnTable
    },getString(message('RptgenSL:csl_emlfcn:suppFnOptionsTooltip')),...
    'Enabled',this.includeSupportingFunctions,...
    'LayoutGrid',[3,3],...
    'ColStretch',colStretch,...
    'RowSpan',[12,12],...
    'ColSpan',[1,2]);







    wIncludeSupportingFunctionsCode=this.dlgWidget('includeSupportingFunctionsCode',...
    'Tag',[tag_prefix,'includeSupportingFunctionsCode'],...
    'ToolTip',getString(message('RptgenSL:csl_emlfcn:includeSuppFcnCodeTooltip')),...
    'Mode',true,...
    'DialogRefresh',true,...
    'ColSpan',[1,1],...
    'RowSpan',[10,10]);







    dlgStruct=this.dlgMain(name,{
wIncludeFcnProps
wFcnPropTableFormatOptions
wIncludeArgSummary
wArgSummaryTableOptions
wIncludeArgDetails
wArgPropTableFormatOptions
wIncludeDataAttr
wIncludeScript
wSyntaxHighlightScript
wIncludeSupportingFunctions
wSupportFcnsToInclude
wSupportFcnTableFormatOptions
wIncludeSupportingFunctionsCode
    },...
    'LayoutGrid',[12,2],...
    'RowStretch',[0,0,0,0,0,0,0,0,0,0,0,1]);





    function onArgSummTableValueChanged(d,r,c,val)

        this=d.getWidgetSource('rptgen_csl_emlfcn_ArgSummTableProps');
        r=r+1;

        if c==0
            this.ArgSummTableProps{r}=val;
        elseif c==1
            this.ArgSummTableColWidths(r)=str2double(val);
        else
            this.ArgSummTableColHeaders(r)=val;
        end






        function onArgSummTableCurrentItemChanged(d,r,~)

            this=d.getWidgetSource('rptgen_csl_emlfcn_ArgSummTableProps');
            this.ArgSummTablePropIdx=r+1;
            d.selectTableRow('rptgen_csl_emlfcn_ArgSummTableProps',r);

            d.setEnabled('rptgen_csl_emlfcn_UpButton',this.ArgSummTablePropIdx>1);
            d.setEnabled('rptgen_csl_emlfcn_DownButton',this.ArgSummTablePropIdx<length(this.ArgSummTableProps));




            function onFcnPropsColTableValueChanged(d,r,c,val)

                this=d.getWidgetSource('rptgen_csl_emlfcn_FcnPropsColTable');

                if r==0
                    if c==0
                        this.FcnPropsTablePropColWidth=str2double(val);
                    else
                        this.FcnPropsTablePropColHeader=val;
                    end
                else
                    if c==0
                        this.FcnPropsTableValueColWidth=str2double(val);
                    else
                        this.FcnPropsTableValueColHeader=val;
                    end
                end




                function onArgPropColTableValueChanged(d,r,c,val)

                    this=d.getWidgetSource('rptgen_csl_emlfcn_ArgPropColTable');

                    if r==0
                        if c==0
                            this.ArgPropsTablePropColWidth=str2double(val);
                        else
                            this.ArgPropsTablePropColHeader=val;
                        end
                    else
                        if c==0
                            this.ArgPropsTableValueColWidth=str2double(val);
                        else
                            this.ArgPropsTableValueColHeader=val;
                        end
                    end





                    function onSupportFcnColTableValueChanged(d,r,c,val)

                        this=d.getWidgetSource('rptgen_csl_emlfcn_SupportFcnColTable');

                        switch r
                        case 0
                            if c==0
                                this.SupportFcnTableNameColWidth=str2double(val);
                            else
                                this.SupportFcnTableNameColHeader=val;
                            end
                        case 1
                            if c==0
                                this.SupportFcnTableDefinedByColWidth=str2double(val);
                            else
                                this.SupportFcnTableDefinedByColHeader=val;
                            end
                        case 2
                            if c==0
                                this.SupportFcnTablePathColWidth=str2double(val);
                            else
                                this.SupportFcnTableValueColHeader=val;
                            end

                        end








