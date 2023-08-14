function pathItems=getPathItems(h,blkObj)%#ok





    try
        offsetVals=evalin('base',blkObj.translation);
        bothPos=(length(offsetVals)==2)&&(offsetVals(1)>=0)&&(offsetVals(2)>=0);
    catch %#ok
        bothPos=false;
    end

    if(strcmp(blkObj.interpMethod,'Nearest neighbor')&&bothPos)
        pathItems={'Output'};
    else
        pathItems={'Product output',...
        'Accumulator',...
        'Output'};
    end
    if strcmp(blkObj.src_trans,'Specify via dialog')
        pathItems{end+1}='Offset values';
    end


