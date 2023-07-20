function m_toggleUpdatePeaks(p,datasetIndex)









    if isempty(datasetIndex)

        datasetIndex=p.pCurrentDataSetIndex;
    end


    Np=numel(p.pPeaks);
    if Np<datasetIndex

        val=0;
    else
        val=p.pPeaks(datasetIndex);
    end
    if val==0



        p.pPeaks(datasetIndex)=p.DefaultNewPeaks;
    else

        p.pPeaks(datasetIndex)=0;
    end
    updatePeaks(p);
