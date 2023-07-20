function covFilterTab=covFilterDlgTab(licensed)


    persistent staticLabels;
    if isempty(staticLabels)
        staticLabels=coverageLabels();
    end

    coverageSettings=rmi.settings_mgr('get','coverageSettings');

    activeLabel.Type='text';
    activeLabel.Name=staticLabels.coverageActiveFilters;
    activeLabel.RowSpan=[1,1];
    activeLabel.ColSpan=[1,4];

    activeFilters.Type='listbox';
    activeFilters.Tag='activeFilters';
    activeFilters.Entries=listActiveFilters();
    activeFilters.RowSpan=[2,8];
    activeFilters.ColSpan=[1,9];
    activeFilters.Graphical=true;
    activeFilters.MatlabMethod='feval';
    activeFilters.MatlabArgs={@selectItem,'%dialog'};
    activeFilters.Mode=true;
    activeFilters.MultiSelect=false;

    palletLabel.Type='text';
    palletLabel.Name=staticLabels.coverageFiltersPallet;
    palletLabel.RowSpan=[1,1];
    palletLabel.ColSpan=[12,15];

    modifyFilter.Type='pushbutton';
    modifyFilter.Tag='modifyFilter';
    modifyFilter.Name=staticLabels.modifyFilter;
    modifyFilter.ToolTip=staticLabels.modifyFilterTip;
    modifyFilter.RowSpan=[1,1];
    modifyFilter.ColSpan=[18,20];
    modifyFilter.MatlabMethod='feval';
    modifyFilter.MatlabArgs={@modifyOne,'%dialog'};
    modifyFilter.Enabled=false;

    filtersPallet.Type='listbox';
    filtersPallet.Tag='filtersPallet';
    filtersPallet.Entries=rmi.history('filters');
    filtersPallet.RowSpan=[2,8];
    filtersPallet.ColSpan=[12,20];
    filtersPallet.Graphical=true;
    filtersPallet.MatlabMethod='feval';
    filtersPallet.MatlabArgs={@selectItem,'%dialog'};
    filtersPallet.Mode=true;
    filtersPallet.MultiSelect=false;

    clearFilters.Type='pushbutton';
    clearFilters.Tag='clearFilters';
    clearFilters.Name=staticLabels.clearFilters;
    clearFilters.ToolTip=staticLabels.clearFiltersTip;
    clearFilters.RowSpan=[9,9];
    clearFilters.ColSpan=[1,3];
    clearFilters.MatlabMethod='feval';
    clearFilters.MatlabArgs={@clearAll,'%dialog'};
    clearFilters.Enabled=~isempty(activeFilters.Entries);

    removeFilter.Type='pushbutton';
    removeFilter.Tag='removeFilter';
    removeFilter.Name=staticLabels.removeFilter;
    removeFilter.ToolTip=staticLabels.removeFilterTip;
    removeFilter.RowSpan=[9,9];
    removeFilter.ColSpan=[7,9];
    removeFilter.MatlabMethod='feval';
    removeFilter.MatlabArgs={@removeOne,'%dialog'};
    removeFilter.Enabled=false;

    addFilter.Type='pushbutton';
    addFilter.Tag='addFilter';
    addFilter.Name=staticLabels.addFilter;
    addFilter.ToolTip=staticLabels.addFilterTip;
    addFilter.RowSpan=[9,9];
    addFilter.ColSpan=[12,14];
    addFilter.MatlabMethod='feval';
    addFilter.MatlabArgs={@addOne,'%dialog'};
    addFilter.Enabled=false;

    forgetFilters.Type='pushbutton';
    forgetFilters.Tag='forgetFilters';
    forgetFilters.Name=staticLabels.forgetFilters;
    forgetFilters.ToolTip=staticLabels.forgetFiltersTip;
    forgetFilters.RowSpan=[9,9];
    forgetFilters.ColSpan=[18,20];
    forgetFilters.MatlabMethod='feval';
    forgetFilters.MatlabArgs={@forgetAll,'%dialog'};
    forgetFilters.Enabled=~isempty(filtersPallet.Entries);

    filtersGroup.Type='group';
    filtersGroup.Tag='filtersGroup';
    filtersGroup.Name=staticLabels.coverageFiltersGroupName;
    filtersGroup.LayoutGrid=[10,20];
    filtersGroup.Items={...
    activeLabel,clearFilters,palletLabel,modifyFilter,...
    activeFilters,filtersPallet,...
    addFilter,removeFilter,forgetFilters};

    covFilterEnableCheck.Type='checkbox';
    covFilterEnableCheck.Name=staticLabels.coverageEnableCheck;
    covFilterEnableCheck.Tag='covFilterEnableCheck';
    covFilterEnableCheck.RowSpan=[1,1];
    covFilterEnableCheck.ColSpan=[1,1];
    covFilterEnableCheck.Value=0+coverageSettings.enabled;
    covFilterEnableCheck.MatlabMethod='feval';
    covFilterEnableCheck.MatlabArgs={@covFilterEnableClicked,'%source','%dialog'};

    covFilterTab.Name=staticLabels.coverageTabName;
    covFilterTab.Tag='coverageTab';
    covFilterTab.LayoutGrid=[2,1];
    covFilterTab.Items={covFilterEnableCheck,filtersGroup};
    covFilterTab.Enabled=0+licensed;

    function out=coverageLabels()
        out.coverageEnableCheck='Enable traceability coverage filter and context menu';
        out.coverageTabName='Traceability Coverage';
        out.coverageFiltersGroupName='Define exceptions for Linking and Traceability Analysis';
        out.coverageActiveFilters='Applied filters';
        out.coverageFiltersPallet='Filters pallet';
        out.modifyFilter='Modify';
        out.modifyFilterTip='Re-configure selected filter';
        out.clearFilters='Clear applied';
        out.clearFiltersTip='Remove all active filters';
        out.addFilter='<<';
        out.addFilterTip='Add filter';
        out.removeFilter='>>';
        out.removeFilterTip='Remove filter';
        out.forgetFilters='Clear pallet';
        out.forgetFiltersTip='Clear filters pallet from user history';
        out.coverageVerification='Treat verification subsystem and SLDV properties as requirements';
    end

    function covFilterEnableClicked(~,dlgH)
        value=dlgH.getWidgetValue('covFilterEnableCheck');
        coverageSettings=rmi.settings_mgr('get','coverageSettings');
        coverageSettings.enabled=value;
        rmi.settings_mgr('set','coverageSettings',coverageSettings);
        dlgH.setEnabled('filtersGroup',value);
    end

    function filtersList=listActiveFilters()
        filtersList={};
        for i=1:length(coverageSettings.maskTypeFilters)
            filtersList{end+1}=sprintf('%s:\t%s','Mask type',coverageSettings.maskTypeFilters{i});%#ok<AGROW>
        end
        for i=1:length(coverageSettings.objTypeFilters)
            filtersList{end+1}=sprintf('%s:\t%s','Object type',coverageSettings.objTypeFilters{i});%#ok<AGROW>
        end
        for i=1:length(coverageSettings.objPathFilters)
            filtersList{end+1}=sprintf('%s:\t%s','Object path',coverageSettings.objPathFilters{i});%#ok<AGROW>
        end
    end

    function clearAll(dialogH)
        appendToHistory(listActiveFilters());
        coverageSettings.maskTypeFilters={};
        coverageSettings.objTypeFilters={};
        coverageSettings.objPathFilters={};
        rmi.settings_mgr('set','coverageSettings',coverageSettings);
        dialogH.refresh();
    end

    function appendToHistory(filters)
        oldFilters=rmi.history('filters');
        rmi.history('filters',unique([oldFilters;filters(:)]));
    end

    function modifyOne(dialogH)
        idx=dialogH.getWidgetValue('filtersPallet');
        filters=rmi.history('filters');
        filter=filters{idx+1};
        filter=adjustFilter(filter);
        if ischar(filter)
            if isempty(filter)
                filters(idx+1)=[];
            else
                filters{idx+1}=filter;
            end
            rmi.history('filters',filters);
            dialogH.refresh();
        end
    end

    function modifiedFilter=adjustFilter(origFilter)
        [type,value]=strtok(origFilter,':');
        result=inputdlg([type,':'],'Modify Filter',1,{value(3:end)},'on');
        if isempty(result)
            modifiedFilter=[];
        elseif isempty(result{1})
            modifiedFilter='';
        else
            modifiedFilter=sprintf('%s:\t%s',type,result{1});
        end
    end

    function forgetAll(dialogH)
        rmi.history('filters',{});
        dialogH.refresh();
    end

    function addOne(dialogH)
        idx=dialogH.getWidgetValue('filtersPallet');
        filters=rmi.history('filters');
        filter=filters{idx+1};
        coverageSettings=insertFilter(coverageSettings,filter);
        rmi.settings_mgr('set','coverageSettings',coverageSettings);
        filters(idx+1)=[];
        rmi.history('filters',filters);
        dialogH.refresh();
    end

    function removeOne(dialogH)
        idx=dialogH.getWidgetValue('activeFilters');
        filters=listActiveFilters();
        filter=filters{idx+1};
        rmi.history('filter',filter);
        coverageSettings=extractFilter(coverageSettings,filter);
        rmi.settings_mgr('set','coverageSettings',coverageSettings);
        dialogH.refresh();
    end

    function filters=insertFilter(filters,oneFilter)
        [type,value]=strtok(oneFilter,':');
        switch type
        case 'Mask type'
            filters.maskTypeFilters=unique([filters.maskTypeFilters;{value(3:end)}]);
        case 'Object type'
            filters.objTypeFilters=unique([filters.objTypeFilters;{value(3:end)}]);
        case 'Object path'
            filters.objPathFilters=unique([filters.objPathFilters;{value(3:end)}]);
        otherwise
            error('Invalud filter: %s',oneFilter);
        end
    end

    function filters=extractFilter(filters,oneFilter)
        [type,value]=strtok(oneFilter,':');
        switch type
        case 'Mask type'
            filters.maskTypeFilters=setdiff(filters.maskTypeFilters,value(3:end));
        case 'Object type'
            filters.objTypeFilters=setdiff(filters.objTypeFilters,value(3:end));
        case 'Object path'
            filters.objPathFilters=setdiff(filters.objPathFilters,value(3:end));
        otherwise
            error('Invalud filter: %s',oneFilter);
        end
    end

    function selectItem(dialogH)
        currentActive=dialogH.getWidgetValue('activeFilters');
        dialogH.setEnabled('removeFilter',~isempty(currentActive));
        currentFromPallet=dialogH.getWidgetValue('filtersPallet');
        dialogH.setEnabled('addFilter',~isempty(currentFromPallet));
        if~isempty(currentFromPallet)
            dialogH.setEnabled('modifyFilter',true);
        end
    end

end
