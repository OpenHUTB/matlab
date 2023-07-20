function magIdx=getMagIndexFromPoint(p,pt,datasetIndex)








    pdata=getDataset(p,datasetIndex);
    if isempty(pdata)
        magIdx=[];
    else


        if isscalar(pt)
            magNorm=pt;
        else
            magNorm=norm(pt(1:2));
        end

        magUser=transformNormMagToUserMag(p,magNorm);
        [~,magIdx]=min(abs(bsxfun(@minus,magUser,pdata.mag)));
    end
