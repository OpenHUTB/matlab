function portIndices=getMPSwitchDataPortIndices(blockH)


    portOrder=get_param(blockH,'DataPortOrder');
    numData=evalin('base',get_param(blockH,'Inputs'));

    switch portOrder
    case 'One-based contiguous'
        portIndices=1:numData;
    case 'Zero-based contiguous'
        portIndices=0:numData-1;
    case 'Specify indices'

        indexStr=get_param(blockH,'DataPortIndices');


        indexCells=slResolve(indexStr,blockH);


        if iscell(indexCells)
            portIndices=[indexCells{1:end}];
        else
            portIndices=indexCells(1:end);
        end
    end

end
