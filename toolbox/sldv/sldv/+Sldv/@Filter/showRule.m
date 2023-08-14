function rowIdx=showRule(this,prop,varargin)




    dlg=this.m_dlg;
    widgetId=this.widgetTag;
    fromExplorer=false;
    if~isempty(varargin)
        dlg=varargin{1};
        widgetId=varargin{2};
        fromExplorer=true;
    end

    if~isfield(prop,'isCode')
        prop.isCode=false;
    end

    tableFieldName='tableIdxMap';
    if prop.isCode
        tableFieldName=['c',tableFieldName];
    end

    keys=this.(tableFieldName).keys();
    propKey=this.getPropKey(prop);
    rowIdx=[];
    for idx=1:numel(keys)
        ckey=keys{idx};
        tp=this.(tableFieldName)(ckey);
        if strcmpi(this.getPropKey(tp),propKey)
            if~tp.isCode&&(this.isMetricProperty(tp)||this.isRteProperty(tp))
                for k=1:numel(tp.value)
                    cv=tp.value(k);
                    if isequal(cv.name,prop.value.name)&&...
                        isequal(cv.idx,prop.value.idx)&&...
                        isequal(cv.outcomeIdx,prop.value.outcomeIdx)
                        rowIdx=ckey;
                        break;
                    end
                end
            else
                rowIdx=ckey;
            end
        end

        if~isempty(rowIdx)
            break;
        end
    end

    if~isempty(rowIdx)&&~isempty(dlg)
        if fromExplorer
            Sldv.Filter.updateFilterNameWidget(dlg,prop.isCode);
        end

        widgetName='filterState';
        if prop.isCode
            widgetName=['c',widgetName];
        end

        widgetTag=[widgetId,widgetName];
        dlg.setFocus(widgetTag);
        dlg.selectTableRow(widgetTag,rowIdx-1);
        this.forceSelectedRow=rowIdx;
        dlg.refresh();
        this.forceSelectedRow=0;
        dlg.ensureTableRowVisible(widgetTag,rowIdx-1);
    end
