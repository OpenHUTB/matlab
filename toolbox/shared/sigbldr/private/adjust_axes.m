function adjust_axes(hgObjs,delta,aspect)









    index=find(strcmpi({'x_coord','y_coord','width','height'},aspect));


    if length(hgObjs)>1
        positionCell=get(hgObjs,'Position');
        positionMatrix=cat(1,positionCell{:});
        positionMatrix(:,index)=positionMatrix(:,index)+delta;
        newPositionCell=num2cell(positionMatrix,2);
        set(hgObjs,{'Position'},newPositionCell);
    else
        oldPos=get(hgObjs,'Position');
        oldPos(index)=oldPos(index)+delta;
        set(hgObjs,'Position',oldPos);
    end