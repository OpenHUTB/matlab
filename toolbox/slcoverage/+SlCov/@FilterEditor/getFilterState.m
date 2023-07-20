function[table,noRules]=getFilterState(this,forCode)




    if nargin<2
        forCode=false;
    end


    table.ColHeader={DAStudio.message('Slvnv:simcoverage:covFilterPropertyValue'),...
    DAStudio.message('Slvnv:simcoverage:covFilterPropertyType'),...
    DAStudio.message('Slvnv:simcoverage:covFilterRationale')};
    if SlCov.CoverageAPI.feature('justification')
        table.ColHeader{4}=table.ColHeader{3};
        table.ColHeader{3}='Mode';
    end

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
                text=DAStudio.message('Slvnv:simcoverage:covFilterEditRationaleText');
            else
                text=prop.Rationale;
            end

            tableIdxMap{rowIdx}=prop;
            if SlCov.CoverageAPI.feature('justification')...

                combo.Enabled=true;
                combo.Type='combobox';
                combo.Value=0;

                if this.isMetricProperty(prop)||this.isCodeMetricProperty(prop)
                    combo.Entries={getString(message('Slvnv:simcoverage:cvhtml:Justified'))};
                    combo.Value=1;
                    combo.Values=[1];
                else
                    combo.Entries={getString(message('Slvnv:simcoverage:cvhtml:Excluded')),getString(message('Slvnv:simcoverage:cvhtml:Justified'))};
                    combo.Mode=true;
                    combo.Values=[0,1];
                    if isfield(prop,'mode')&&prop.mode==1
                        combo.Value=1;
                    end
                end

                table.Data{rowIdx,3}=combo;
                table.Data{rowIdx,4}=text;
            else
                table.Data{rowIdx,3}=text;
            end

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
        if SlCov.CoverageAPI.feature('justification')
            table.Data{rowIdx,4}=' ';
        end

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

    function allProps=getAllProps(this,filterState)

        allProps=[];
        keys=filterState.keys;
        for idx=1:numel(keys)

            cp=filterState(keys{idx});
            cp.key=keys{idx};
            if this.isMetricProperty(cp)
                value=cp.value;
                for iidx=1:numel(value)
                    cp.value=value(iidx);
                    cp.mode=cp.value.mode;
                    cp.Rationale=cp.value.rationale;
                    cp.valueDesc=cp.value.valueDesc;
                    if isempty(allProps)
                        allProps=cp;
                    else
                        allProps(end+1)=cp;%#ok<AGROW>
                    end
                end
            elseif~this.isRteProperty(cp)
                if isempty(allProps)
                    allProps=cp;
                else
                    allProps(end+1)=cp;%#ok<AGROW>
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
                            mn=prop.value(1:nc-1);
                            if~bdIsLoaded(mn)
                                load_system(mn);
                                valid=true;
                            end
                        end
                    end
                catch
                    valid=false;
                end
            end


            function text=getText(this,prop)
                text=[' ',this.getPropertyValueDescription(prop),' '];
                if~(isfield(prop,'isCode')&&prop.isCode)
                    text=strrep(text,newline,' ');
                end


