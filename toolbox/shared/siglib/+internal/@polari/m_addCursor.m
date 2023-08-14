function m_addCursor(p,datasetIndex)



    if nargin<2
        datasetIndex=[];
    end
    i_addCursor(p,p.hAxes.CurrentPoint,datasetIndex);
