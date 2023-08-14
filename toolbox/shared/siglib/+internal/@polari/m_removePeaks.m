function m_removePeaks(p,datasetIndex)





    if nargin<2
        datasetIndex=p.pCurrentDataSetIndex;
    end

    removePeaks(p,datasetIndex);







    changeMouseBehavior(p,'general');
