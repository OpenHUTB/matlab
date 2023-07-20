function out=constraints(s)
    import simscape.statistics.data.internal.Statistic







    out=Statistic(...
    'Data',lConstraintsTable(s.Children),...
    'Name',s.Name,...
    'Description',s.Description);
    out.Data.Properties.Description=s.Description;
end

function t=lConstraintsTable(s)
    if isempty(s)
        t=struct2table(struct('ID',{},'Name',{},'Value',{},'Sources',{}),'AsArray',true);
        return
    end

    for idx=1:numel(s)
        s(idx).Sources=...
        simscape.statistics.data.internal.block_sources(s(idx).Sources);
    end
    t=orderfields(rmfield(s,{'Children','Description','Timestamp'}),{'ID','Name','Value','Sources'});
    t=struct2table(t,'AsArray',true);
end
