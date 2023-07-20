function[out_cell,varargin]=processargin(h,varargin,token)




    arginidx=find(strcmpi(token,varargin));
    if~isempty(arginidx)&&arginidx(1)<numel(varargin)
        out_cell=varargin(arginidx(1)+1);
        idx=true(1,numel(varargin));
        idx(arginidx(1):arginidx(1)+1)=false;
        varargin=varargin(idx);
    else
        out_cell={[]};
    end