function rules=findRules(this,blockH)



    sid='';

    if~isempty(blockH)
        sid=Simulink.ID.getSID(blockH);
    end
    allRules=isempty(sid);
    map=this.filter.filterState;
    keys=map.keys;
    rules=[];
    for idx=1:numel(keys)
        props=map(keys{idx});
        for ii=1:numel(props)
            cp=props(ii);
            if isa(cp.selectorType,'slcoverage.BlockSelectorType')
                if cp.selectorType==slcoverage.BlockSelectorType.BlockType
                    name=get_param(blockH,'BlockType');
                elseif cp.selectorType==slcoverage.BlockSelectorType.MaskType
                    name=get_param(blockH,'MaskType');
                else
                    name=sid;
                end
                if allRules||strcmpi(cp.value,name)
                    if cp.selectorType==slcoverage.BlockSelectorType.TemporalEvent
                        cp.value=cp.value.name;
                    end
                    sel=slcoverage.BlockSelector(cp.selectorType,cp.value);
                    sel.setDescription(cp.valueDesc);
                    rules=addRule(rules,slcoverage.FilterRule(sel,cp.Rationale,slcoverage.FilterMode(cp.mode)));
                end
            elseif isa(cp.selectorType,'slcoverage.MetricSelectorType')
                for iii=1:numel(cp.value)
                    pv=cp.value(iii);
                    if allRules||strcmpi(pv.ssid,sid)
                        sel=slcoverage.MetricSelector(pv.selectorType,pv.ssid,pv.idx,pv.outcomeIdx);
                        sel.setDescription(pv.valueDesc);
                        rules=addRule(rules,slcoverage.FilterRule(sel,pv.rationale,slcoverage.FilterMode(pv.mode)));
                    end
                end
            elseif isa(cp.selectorType,'slcoverage.SFcnSelectorType')
                [codeCovInfo,psid]=SlCov.FilterEditor.decodeCodeFilterInfo(keys{idx});

                if allRules||strcmpi(sid,psid)
                    if isequal(cp.selectorType,slcoverage.SFcnSelectorType.SFcnName)
                        psid=keys{idx};
                    end


                    endIdx=min(numel(codeCovInfo),3);
                    args=[{cp.selectorType},{psid},codeCovInfo{1:endIdx}];
                    if numel(codeCovInfo)>=4
                        args=[args,num2cell(codeCovInfo{4})];%#ok<AGROW>
                    end
                    sel=slcoverage.SFcnSelector(args{:});
                    sel.setDescription(cp.valueDesc);
                    rules=addRule(rules,slcoverage.FilterRule(sel,cp.Rationale,slcoverage.FilterMode(cp.mode)));
                end
            elseif isa(cp.selectorType,'slcoverage.CodeSelectorType')
                codeCovInfo=SlCov.FilterEditor.decodeCodeFilterInfo(keys{idx});


                endIdx=min(numel(codeCovInfo),3);
                args=[{cp.selectorType},codeCovInfo{1:endIdx}];
                if numel(codeCovInfo)>=4
                    args=[args,num2cell(codeCovInfo{4})];%#ok<AGROW>
                end
                sel=slcoverage.CodeSelector(args{:});
                sel.setDescription(cp.valueDesc);
                rules=addRule(rules,slcoverage.FilterRule(sel,cp.Rationale,slcoverage.FilterMode(cp.mode)));
            end
        end
    end


    function rules=addRule(rules,rule)
        if isempty(rules)
            rules=rule;
        else
            rules(end+1)=rule;
        end


