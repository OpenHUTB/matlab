function[arr_sorted,idxs_out]=sort(arr,varargin)




    [arr_sorted_single,idxs]=sort(single(arr),varargin{:});

    if isvector(arr)
        arr_sorted=arr(idxs);
    else
        arr_sorted=half(arr_sorted_single);
    end

    if nargout>1
        idxs_out=idxs;
    end
