function fts=removeTrailingSubbar(fts)

    if~isempty(fts)&&isa(fts{end},'ModelAdvisor.FormatTemplate')
        fts{end}.setSubBar(0);
    end
end