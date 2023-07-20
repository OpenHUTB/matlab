



classdef Filter<SlCov.FilterEditor
    methods(Hidden=true)
        function this=Filter(modelName,fileName)
            if nargin==0


                modelName='';
                fileName='';
            end

            if isempty(modelName)
                dialogTag='';
                dialogTitle='';
            else
                dialogTag=Sldv.Filter.getDialogTag(get_param(modelName,'Name'));
                dialogTitle=Sldv.Filter.getDialogTitle(get_param(modelName,'Name'));
            end

            this@SlCov.FilterEditor(modelName,...
            fileName,...
            '',...
            dialogTag,...
            dialogTitle);
        end
    end

    methods(Static=true)
        function fName=defaultFileName()
            fName='active_filter';
        end

        function tag=getDialogTag(modelName)
            tag=['Analysis_Filter_',modelName];
        end

        function title=getDialogTitle(modelName)
            title=[getString(message('Sldv:Filter:dvFilterUITitle')),': ',modelName];
        end

        function this=createFilterEditor(modelName,fileName)
            this=Sldv.Filter(modelName,fileName);
            this.reset;
            setEventHandler(this);
            this.load(fileName);
        end

        function this=createFilter(fileName)

            this=Sldv.Filter('','');
            this.reset;
            this.load(fileName);
        end

        function filter=getInstance(modelName,filterFileName)
            if ishandle(modelName)
                modelName=get_param(modelName,'Name');
            end
            if nargin<2
                try
                    filterFileName=get_param(modelName,'DVCovFilterFileName');
                catch
                    filterFileName='';
                end
            end
            dialogTag=Sldv.Filter.getDialogTag(modelName);
            filter=Sldv.Filter.findExistingDlg(modelName,filterFileName,dialogTag);
            if isempty(filter)
                if isempty(filterFileName)
                    filterFileName=Sldv.Filter.defaultFileName();
                end
                filter=Sldv.Filter.createFilterEditor(modelName,filterFileName);
            end
        end

        function updateFilterNameWidget(dlg,widgetTag)
            forCode=contains(widgetTag,'_cfilterState');

            try
                idx=dlg.getSelectedTableRows(widgetTag);
            catch
                return;
            end



            if isempty(idx)&&~forCode
                return;
            end


            name='';
            if forCode
                srcObj=dlg.getSource();
                if~isempty(srcObj)
                    if~isa(srcObj,'Sldv.Filter')
                        return
                    end
                end
                if~isempty(idx)
                    name=genCodeFilterDescription(srcObj,idx);
                end
            else
                if~isempty(idx)
                    name=dlg.getTableItemValue(widgetTag,idx,0);
                end
            end


            dlg.setWidgetValue([widgetTag,'Name'],name);
        end

        function fileName=mergeFilters(filterName1,filterName2)
            if isempty(filterName1)
                fileName=filterName2;
                return;
            elseif isempty(filterName2)
                fileName=filterName1;
                return;
            end

            filter1=Sldv.Filter.createFilter(filterName1);
            filter2=Sldv.Filter.createFilter(filterName2);
            filter1.copyRulesFrom(filter2);

            fileName=tempname;
            filter1.save(fileName);
        end
    end

    methods(Static=true,Hidden=true)
        function mergedFilter=mergeInMemory(filters)
            numFilters=length(filters);

            if numFilters==0
                mergedFilter=[];
                return;
            end

            mergedFilter=filters(1);

            if numFilters==1
                return;
            end



            mergedFilter.filterName='';
            mergedFilter.fileName='';
            mergedFilter.setUUID();

            for i=2:numFilters
                mergedFilter.copyRulesFrom(filters(i));
            end


        end
    end

    methods
        addRteFilter(this,ssid,rteObjType,objectiveIdx,dummyIdx,mode,rationale,descr);
        [res,propInstance]=isFilteredByRte(this,ssid,rteName);
        rowIdx=showRteRule(this,ssid,rteType,idx,varargin);
        rowIdx=showRule(this,prop,varargin);
        dlg=getDialogSchema(this,~);
        groupFilterState=getFilterStateGroup(this,tag,widgetId,varargin);
        [table,noRules]=getFilterState(this,forCode);
        copyRulesFrom(this,anotherFilter);
        saveFilterCallback(this);
        loadFilterCallback(this);
        [status,errstr]=postApplyCallback(this,dlg);
        [status,errstr]=postRevertCallback(this,dlg);
        [status,errStr]=closeCallback(this,dlg);
        addRationaleCallback(this,dlg,ridx,cidx,value,forCode);
        changeFilterModeCallback(this,dlg,ridx,mode,forCode);
        updateResults(this);

        function text=getPropertyValueDescription(~,prop)
            if isequal(prop.valueDesc,'metric')
                text=prop.value(end).valueDesc;
            elseif isequal(prop.valueDesc,'rte')
                text=prop.value(end).valueDesc;
            else
                text=prop.valueDesc;
            end
        end

        function revert(this,~)
            if~isempty(this.lastFilterElement)
                fe=this.lastFilterElement;
                if isfield(fe,'add')
                    if numel(fe.add)>1
                        this.removeFilterByProp(fe.add{1});
                        this.setFilterByProp(fe.add{2},'');
                    else
                        this.removeFilterByProp(fe.add);
                    end
                end
                if isfield(fe,'remove')
                    this.setFilterByProp(fe.remove,'');
                end
                if isfield(fe,'rationale')
                    this.addRationaleCallback([],fe.rationale{1},fe.rationale{2},fe.rationale{3},fe.rationale{4});
                end
                if isfield(fe,'mode')
                    this.changeFilterModeCallback([],fe.mode{1},fe.mode{2},fe.mode{3});
                end
                this.lastFilterElement={};
                this.hasUnappliedChanges=false;
            end
        end
    end
end
