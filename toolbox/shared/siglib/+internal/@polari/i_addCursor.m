function m=i_addCursor(p,pt,datasetIndex)














    [didx,datasetIndex]=getDataIndexFromPoint(p,pt,datasetIndex);
    if isempty(didx)
        str='Add data to plot before adding data cursors.';

        showBannerMessage(p,str);
        m=[];
    else
        m=addCursorAllArgs(p,didx,datasetIndex);
    end
