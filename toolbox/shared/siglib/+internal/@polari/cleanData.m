function cleanData(p,datasetIndex)








    if nargin<2||isempty(datasetIndex)
        datasetIndex=p.pCurrentDataSetIndex;
    end

    data1=getDataset(p,datasetIndex);
    if~isDataClean(p,datasetIndex)
        return;
    end
    flag=p.AntennaMetrics;
    proceed=hideLobesAndMarkers(p);
    if proceed
        sel=(data1.mag==-inf)|isnan(data1.mag);
        data1.mag(sel)=[];
        data1.ang(sel)=[];

        if iscell(p.MagnitudeData)
            setdata=numel(p.MagnitudeData);
            data=getDataset(p,1:setdata);
            for i=1:setdata
                if i==1
                    if datasetIndex==1
                        replace(p,data1.ang,data1.mag);
                    else
                        replace(p,data(1).ang,data(1).mag);
                    end
                    continue;
                end
                if datasetIndex==i
                    add(p,data1.ang,data1.mag);
                else
                    add(p,data(i).ang,data(i).mag);
                end
            end
        else
            replace(p,data1.ang,data1.mag);
        end
        if flag
            showLobes(p);
        end
    end