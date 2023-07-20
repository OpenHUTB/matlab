function rgb=getDatasetColor(p,datasetIdx)



    co=p.pColorOrder;
    Ncolors=size(co,1);
    if Ncolors==0
        rgb=[];
    else
        rgb=co(1+mod(datasetIdx-1,Ncolors),:);
    end
