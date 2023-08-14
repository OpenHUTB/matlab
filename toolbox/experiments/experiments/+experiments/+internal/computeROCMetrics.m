function[xArray,yArray,tArray,aucArray]=computeROCMetrics(labels,scores,truePredictedLabels,showROCCurve)




    xArray=[];
    yArray=[];
    tArray=[];
    aucArray=[];





    if showROCCurve
        nElements=numel(truePredictedLabels);
        xArray=cell(1,nElements);
        yArray=cell(1,nElements);
        tArray=cell(1,nElements);
        aucArray=zeros(1,nElements);
        for i=1:nElements
            [xArray{i},yArray{i},tArray{i},aucArray(i)]=perfcurve(labels,scores(:,i),truePredictedLabels(i));
        end
    end
end
