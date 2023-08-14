function dlgStruct=getDialogSchema(this,name)








    wShowWorkspace=this.dlgWidget('ShowWorkspace',...
    'ColSpan',[1,1],...
    'RowSpan',[1,1]);

    wShowWorkspace.ToolTip=this.msg('WdgtTTShowWorkspace');

    wShowUsedBy=this.dlgWidget('ShowUsedBy',...
    'ColSpan',[1,1],...
    'RowSpan',[2,2]);

    wShowUsedBy.ToolTip=this.msg('WdgtTTShowUsedBy');

    optionsLabel=this.msg('WdgtLblOptions');

    wDoCustom=this.dlgWidget('customFilteringEnabled',...
    'RowSpan',[3,3],...
    'ColSpan',[1,2],...
    'DialogRefresh',true);

    wCustomPropertyFilter=this.dlgWidget('customFilteringCode',...
    'Type','editarea',...
    'RowSpan',[4,4],...
    'ColSpan',[1,1],...
    'Visible',this.customFilteringEnabled);

    wPropFilterUI=locBuildPropertyFilterUI(this);
    wPropFilterUI.Visible=~wCustomPropertyFilter.Visible;
    wPropFilterUI.RowSpan=wCustomPropertyFilter.RowSpan;
    wPropFilterUI.ColSpan=wCustomPropertyFilter.ColSpan;

    pOptions=this.dlgContainer({
wShowUsedBy
wShowWorkspace
wDoCustom
wCustomPropertyFilter
wPropFilterUI
    },optionsLabel,...
    'LayoutGrid',[4,1],...
    'RowSpan',[1,1],...
    'ColSpan',[1,1],...
    'ShowGrid',true);



    dlgStruct=this.dlgMain(name,{
pOptions
    },...
    'LayoutGrid',[2,1],...
    'RowStretch',[0,1]);

    function widget=locBuildPropertyFilterUI(this)

        classList=struct();
        classList.Tag='filteredClassNames';
        classList.Editable=true;
        classList.Mode=1;
        classList.Type='combobox';
        classList.Value=this.currFilterClass;
        if(~isempty(this.filteredPropHash))
            classList.Entries=this.filteredPropHash.keys;
        end
        classList.RowSpan=[2,2];
        classList.ColSpan=[1,2];
        classList.DialogRefresh=true;
        classList.MatlabMethod='onFilteredClassListChange';
        classList.MatlabArgs={'%source','%value'};
        classList.MinimumSize=200;
        classList.Alignment=2;
        classListLabel=this.dlgText(this.msg('filteredClassListLabel'),'RowSpan',[1,1],'ColSpan',[1,1]);

        shuttle=this.dlgShuttlebus('acceptedProps','filteredProps',this.msg('availablePropsLabel'),this.msg('FilteredPropsLabel'),'','onShuttleContentChanged');
        shuttle.RowSpan=[3,3];
        shuttle.ColSpan=[1,2];

        shuttle.Visible=(~isempty(this.acceptedProps)||(isempty(this.filteredPropHash)&&isempty(this.currFilterClass)));

        explicitList=struct();
        explicitList.Tag='filteredProperties';
        explicitList.Editable=true;
        explicitList.Mode=1;
        explicitList.Type='edit';
        explicitList.Value=locConvertCellArrayToString(this.filteredProps);
        explicitList.RowSpan=shuttle.RowSpan+1;
        explicitList.ColSpan=shuttle.ColSpan;
        explicitList.MinimumSize=200;
        explicitList.Visible=~shuttle.Visible;
        explicitList.MatlabMethod='onExplicitListContentChanged';
        explicitList.MatlabArgs={'%source','%value'};
        explicitListLabel=this.dlgText(this.msg('explicitListLabel'));
        explicitListLabel.Visible=explicitList.Visible;
        explicitListLabel.RowSpan=shuttle.RowSpan;
        explicitListLabel.ColSpan=shuttle.ColSpan;

        goCustomButton=struct();
        goCustomButton.Type='pushbutton';
        goCustomButton.Name=getString(message('RptgenSL:csl_ws_variable:convertCustomButtonLabel'));
        goCustomButton.RowSpan=[1,1];
        goCustomButton.ColSpan=[2,2];
        goCustomButton.MatlabMethod='convertToCustomFilter';
        goCustomButton.MatlabArgs={'%source'};
        goCustomButton.Source=this;

        widget=this.dlgContainer(...
        {
classListLabel
classList
shuttle
explicitList
explicitListLabel
goCustomButton
        },...
        this.msg('customFilterHeader'),...
        'LayoutGrid',[4,2],'ColStretch',[1,0]);

        function str=locConvertCellArrayToString(cellArray)

            str='';
            if(~isempty(cellArray))

                str=cellArray{1};

                for i=2:length(cellArray)
                    str=[str,', ',cellArray{i}];%#ok<AGROW>
                end
            end
