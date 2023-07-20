function t=block_sources(s)
    if isempty(s)
        r=struct('VariablePath',{},'Description',{},'SID',{});
    else
        r=struct('VariablePath',{s.Path},...
        'Description',{s.Description},...
        'SID',{s.Object});
    end
    t=struct2table(r,'AsArray',true);
end