

function ret=mergeRange(varargin)

    ranges=cell2mat(varargin');
    sorted=sortrows(ranges);

    ret=[];
    acc=sorted(1,:);
    for idx=2:size(ranges,1)
        range=sorted(idx,:);

        if acc(2)>=range(1)
            acc=[acc(1),max(range(2),acc(2))];
        else
            ret=[ret;acc];%#ok<AGROW>
            acc=range;
        end
    end
    ret=[ret;acc];
end