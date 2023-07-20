function[faceVertices,faceStripData,edgeVertices,edgeStripData]=...
    createAreaVertexData(hObj,hDataSpace,baseValue,selected)












    x=hObj.AreaLayoutData.XData;
    y=hObj.AreaLayoutData.YData;
    order=hObj.AreaLayoutData.Order;


    if hObj.BaseArea&&~isempty(y)
        y(:,1)=baseValue;
    end


    if isa(hDataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')
        invalid_x=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(hDataSpace.XScale,hDataSpace.XLim,x);
        invalid_y=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(hDataSpace.YScale,hDataSpace.YLim,y);

        valid=~any([invalid_x,invalid_y],2);
        x=x(valid,:);
        y=y(valid,:);
        order=order(valid,:);
    end


    if nargin>=4


        padding=min(diff(unique(x)))*0.02;


        tf=ismember(order,selected);
        order(~tf,:)=NaN;
    else
        padding=0;
    end


    validData=isfinite(order);



    [x,y,validData]=matlab.graphics.chart.primitive.area.internal.fixSelfIntersectingFaces(x,y,validData);



    validData=validData';
    x=x(validData,:)';
    y=y(validData,:)';

    segmentBoundaries=[true,~validData(1:end-1)];
    segmentBoundaries=find([segmentBoundaries(validData),true]);


    if padding>0
        isSingle=x(segmentBoundaries(1:end-1))-x(segmentBoundaries(2:end)-1)==0;
        if any(isSingle)
            singleInds=segmentBoundaries(isSingle);
            [~,o]=sort([1:numel(x),singleInds]);
            x=[x,x(singleInds)+padding];
            y=[y,y(:,singleInds)];
            x(singleInds)=x(singleInds)-padding;

            x=x(o);
            y=y(:,o);

            segmentBoundaries=segmentBoundaries+[0,cumsum(isSingle)];
        end
    end




    x=x([1,1],:);
    faceVertices=[x(:),y(:)];


    faceStripData=segmentBoundaries*2-1;


    edgeVertices=[x(2,:);y(2,:)]';
    edgeStripData=segmentBoundaries;
