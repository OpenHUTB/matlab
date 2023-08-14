
function[out,dscr]=modelCoverageEntries(~,name)

    dscr=[name,'''s enum option is determined by ModelCoverageObjectives'];


    vals={'None','Decision','ConditionDecision','MCDC'};
    keys={'Sldv:dialog:sldvTestGenNone',...
    'Sldv:dialog:sldvTestGenDecision',...
    'Sldv:dialog:sldvTestGenCondDeci',...
    'Sldv:dialog:sldvTestGenMCDC'};

    if slavteng('feature','PathBasedTestgen')~=0
        vals{end+1}='EnhancedMCDC';
        keys{end+1}='Sldv:dialog:sldvTestGenEnhancedMCDC';
    end

    avail_vals=cell(1,length(vals));
    for i=1:length(vals)
        avail_vals{i}.str=vals{i};
        avail_vals{i}.key=keys{i};
    end

    out=cell2mat(avail_vals);
