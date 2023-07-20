function[p,idx]=getAllPolari


    f=findobj('type','figure');
    p=[];
    idx=[];
    for i=1:numel(f)
        [p_i,idx_i]=internal.polari.getAllPlots(f(i));
        p=[p;p_i];%#ok<AGROW>
        idx=[idx;idx_i];%#ok<AGROW>
    end
