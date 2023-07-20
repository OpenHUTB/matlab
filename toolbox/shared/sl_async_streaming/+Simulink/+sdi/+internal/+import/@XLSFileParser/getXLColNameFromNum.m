function colLabel=getXLColNameFromNum(~,colNum)
    base=26;
    if iscell(colNum)
        colLabel=cellfun(@xlscol,colNum,'UniformOutput',false);
    elseif ischar(colNum)
        if~contains(colNum,':')
            colLabel=cellfun(@xlscol,regexp(colNum,':','split'));
        else
            colLabel=colNum(isletter(colNum));
            if isempty(colLabel)
                colLabel={[]};
            else
                colLabel=double(upper(colLabel))-64;
                n=length(colLabel);
                colLabel=colLabel*base.^((n-1):-1:0)';
            end
        end
    elseif isnumeric(colNum)&&numel(colNum)~=1
        colLabel=arrayfun(@xlscol,colNum,'UniformOutput',false);
    else
        n=ceil(log(colNum)/log(base));
        d=cumsum(base.^(0:n+1));
        n=find(colNum>=d,1,'last');
        d=d(n:-1:1);
        r=mod(floor((colNum-d)./base.^(n-1:-1:0)),base)+1;
        colLabel=char(r+64);
    end
    if iscell(colLabel)&&(iscell([colLabel{:}])||isnumeric([colLabel{:}]))
        colLabel=[colLabel{:}];
    end
