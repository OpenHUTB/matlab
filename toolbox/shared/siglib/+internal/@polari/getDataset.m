function[pdata,datasetIndex]=getDataset(p,datasetIndex)





    if nargin<2||isempty(datasetIndex)
        datasetIndex=p.pCurrentDataSetIndex;
    end
    Nd=getNumDatasets(p);
    if datasetIndex>Nd
        error('Dataset index (%d) exceeds number of datasets (%d).',datasetIndex,Nd);
    end
    pdata=p.pData(datasetIndex);
