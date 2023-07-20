function toggle=isDataClean(p,datasetIndex)


    toggle=false;
    if nargin==1
        if iscell(p.MagnitudeData)
            for i=1:size(p.MagnitudeData,2)
                if(any(find(isinf(-cell2mat(p.MagnitudeData(i)))))...
                    ||any(find(isnan(cell2mat(p.MagnitudeData(i))))))
                    toggle=true;
                    return;
                end
            end
        else
            if(any(find(isinf(-p.MagnitudeData)))...
                ||any(find(isnan(p.MagnitudeData))))
                toggle=true;
            end
        end
    else
        data1=getDataset(p,datasetIndex);
        if(any(find(isinf(-data1.mag)))...
            ||any(find(isnan(data1.mag))))
            toggle=true;
        end
    end
