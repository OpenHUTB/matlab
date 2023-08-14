function[table,noRules]=getFilterState(this,forCode)




    if nargin<2
        forCode=false;
    end

    table.ColHeader={getString(message('Sldv:Filter:dvFilterPropertyValue')),...
    getString(message('Sldv:Filter:dvFilterPropertyType')),...
    getString(message('Sldv:Filter:dvFilterMode')),...
    getString(message('Sldv:Filter:dvFilterRationale'))};
    table.Data={};
    noRules=false;

    rowIdx=1;
    allProps=getAllProps(this,this.filterState);
    lastAddedRowIdx=[];
    tableIdxMap=cell(1,numel(allProps));

    for idx=1:numel(allProps)
        prop=allProps(idx);
        if isValid(this,prop)
            if(prop.isCode&&~forCode)||(~prop.isCode&&forCode)
                continue
            end
            if isempty(prop.Rationale)
                text=getString(message('Sldv:Filter:dvFilterEditRationaleText'));
            else
                text=prop.Rationale;
            end

            tableIdxMap{rowIdx}=prop;

            combo.Type='combobox';
            combo.Enabled=true;
            if this.isMetricProperty(prop)||this.isRteProperty(prop)||this.isCodeMetricProperty(prop)
                combo.Entries={getString(message('Sldv:KeyWords:Justified'))};
                combo.Values=1;
                combo.Value=1;
            else
                combo.Entries={getString(message('Sldv:KeyWords:Excluded')),getString(message('Sldv:KeyWords:Justified'))};
                combo.Values=[0,1];
                if isfield(prop,'mode')&&prop.mode==1
                    combo.Value=1;
                else
                    combo.Value=0;
                end
                combo.Mode=true;
            end

            table.Data{rowIdx,3}=combo;
            table.Data{rowIdx,4}=text;

            table.Data{rowIdx,2}=this.getPropertyType(prop);
            table.Data{rowIdx,1}=getText(this,prop);



            if(~forCode&&strcmpi(this.getPropertyValueDescription(prop),this.lastKeyAdded))||...
                (forCode&&strcmpi(prop.value,this.clastKeyAdded))
                lastAddedRowIdx=rowIdx;
            end
            rowIdx=rowIdx+1;
        end
    end


    tableIdxMap(cellfun(@isempty,tableIdxMap))=[];

    if isempty(table.Data)
        table.Data{rowIdx,4}=' ';
        table.Data{rowIdx,3}=' ';
        table.Data{rowIdx,2}=' ';
        table.Data{rowIdx,1}=' ';
        lastColoumRW=false;
        table.SelectedRow=0;
        noRules=true;
    else
        [~,I]=sort(table.Data(:,1));
        table.Data=table.Data(I,:);
        tableIdxMap=tableIdxMap(I);
        table.SelectedRow=[];
        if this.forceSelectedRow>0
            table.SelectedRow=this.forceSelectedRow-1;
        elseif~isempty(lastAddedRowIdx)
            SelectedRow=find(I==lastAddedRowIdx);
            if~isempty(SelectedRow)
                table.SelectedRow=SelectedRow-1;
            end
        else
            table.SelectedRow=0;
        end
        lastColoumRW=true;
        c='';
        if forCode
            c='c';
        end
        propName=[c,'tableIdxMap'];
        this.(propName).remove(this.(propName).keys());
        for idx=1:numel(tableIdxMap)
            this.(propName)(idx)=tableIdxMap{idx};
        end
    end

    table.Size=size(table.Data);
    if lastColoumRW
        table.ReadOnlyColumns=0:table.Size(2)-3;
    else
        table.ReadOnlyColumns=0:table.Size(2)-1;
    end
end

function allProps=getAllProps(this,filterState)
    allProps=[];
    keys=filterState.keys;
    for idx=1:numel(keys)
        cp=filterState(keys{idx});
        cp.key=keys{idx};
        if this.isMetricProperty(cp)||this.isRteProperty(cp)
            value=cp.value;
            for iidx=1:numel(value)
                cp.value=value(iidx);
                cp.mode=cp.value.mode;
                cp.Rationale=cp.value.rationale;
                cp.valueDesc=cp.value.valueDesc;

                allProps=[allProps,cp];%#ok<AGROW>
            end
        else
            allProps=[allProps,cp];%#ok<AGROW>
        end
    end
end

function valid=isValid(this,prop)
    valid=true;
    try
        if~this.isSubProperty(prop)

            if isempty(Simulink.ID.checkSyntax(prop.value))
                nc=strfind(prop.value,':');
                if~isempty(nc)
                    Simulink.ID.getHandle(prop.value);
                end
            end
        end
    catch MEx
        valid=false;
        try

            if strcmpi(MEx.identifier,'Simulink:utility:modelNotLoaded')
                nc=strfind(prop.value,':');
                if~isempty(nc)


                    refs=find_mdlrefs(this.modelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);
                    mn=prop.value(1:nc-1);
                    for idx=1:numel(refs)
                        if strcmp(refs{idx},mn)
                            load_system(mn);
                            valid=true;
                        end
                    end
                end
            end
        catch
            valid=false;
        end
    end
end

function text=getText(this,prop)
    text=[' ',this.getPropertyValueDescription(prop),' '];
    if~(isfield(prop,'isCode')&&prop.isCode)
        text=strrep(text,newline,' ');
    end
end


