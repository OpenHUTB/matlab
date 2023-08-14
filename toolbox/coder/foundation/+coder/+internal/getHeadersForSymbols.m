function headers=getHeadersForSymbols(ci,symbols)





    headers=[];
    for i=1:numel(symbols)
        node=ci.getGlobalSymbolNodeByName(symbols{i});
        if~isempty(node)
            headers=[headers,node.HeaderFiles.toArray];%#ok<AGROW>
        end
    end

    headers=string(unique(headers,'stable'));
    needQuotesIdx=ismissing(regexp(headers,'^(<|")','once','match'));
    headers(needQuotesIdx)='"'+headers(needQuotesIdx)+'"';
