function idx=peaks(p,varargin)












    if isIntensityData(p)

        idx=peaks3D(p,varargin{:});

    else







        if nargin<2||isempty(varargin{1})
            datasetIndex=p.pCurrentDataSetIndex;
        else
            datasetIndex=varargin{1};
        end
        if nargin<3
            NPeaks=p.pPeaks(datasetIndex);
        else
            NPeaks=varargin{2};
        end
        pdata=getDataset(p,datasetIndex);
        idx=internal.polariCommon.findPolarPeaks(pdata.mag,...
        NPeaks,p.MagnitudeLim,p.PeaksOptions);
    end
