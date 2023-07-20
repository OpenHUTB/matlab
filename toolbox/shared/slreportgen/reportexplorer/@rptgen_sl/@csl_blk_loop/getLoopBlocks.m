function hList=getLoopBlocks(c,varargin)






    if c.isFilterList
        searchTerms=[c.FilterTerms(:)',varargin(:)'];
    else
        searchTerms=varargin(:)';
    end
    if~isempty(searchTerms)
        searchTerms=LocWashSearchTerms(searchTerms);
    end

    if strcmp(c.LoopType,'list')
        bList=rptgen_sl.rgFindBlocks(parseList(c),0,searchTerms);
    else
        bList=findContextBlocks(rptgen_sl.appdata_sl,searchTerms{:});
    end

    hList=c.sortBlocks(bList);


    function t=LocWashSearchTerms(t);

        numTerms=length(t);
        if rem(numTerms,2)>0

            t{end+1}='';
            numTerms=numTerms+1;
        end

        emptyCells=find(cellfun('isempty',t));
        emptyNames=emptyCells(1:2:end-1);
        emptyNames=emptyNames(:);

        removeCells=[emptyNames;emptyNames+1];
        okCells=setdiff([1:numTerms],removeCells);

        t=t(okCells);

