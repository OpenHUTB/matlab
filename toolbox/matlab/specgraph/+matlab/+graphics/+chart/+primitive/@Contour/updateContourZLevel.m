function updateContourZLevel(hObj,updateState)




    loc=hObj.ZLocation_I;

    if strcmp(hObj.ContourZLevelMode,'auto')
        auto=strcmp(hObj.ZLocationMode,'auto');
        [rawZLevel,loc]=getContourZLevel(updateState,loc,auto);
        hObj.ZLocation_I=loc;
        hObj.ContourZLevel_I=rawZLevel;
    else
        hObj.ZLocation_I=hObj.ContourZLevel;
    end

end

function[rawZLevel,loc]=getContourZLevel(updateState,loc,auto)


    zLimit=updateState.DataSpace.ZLim;
    if isnumeric(loc)
        if auto

            loc=calculateAutoZLocation(updateState);
        end
        rawZLevel=loc;
    elseif(strcmpi(loc,"zmin"))
        rawZLevel=zLimit(1);
    else
        rawZLevel=zLimit(2);
    end

end

function loc=calculateAutoZLocation(updateState)


    loc=0;

    dataSpace=updateState.DataSpace;
    if isa(dataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')...
        &&strcmp(dataSpace.ZScale,'log')




        tform=updateState.TransformUnderDataSpace;
        iter=matlab.graphics.axis.dataspace.IndexPointsIterator;
        iter.Vertices=[dataSpace.XLim(1),dataSpace.YLim(1)];
        iter.Vertices=TransformPoints(dataSpace,tform,iter)';
        vd=UntransformPoints(dataSpace,tform,iter);
        loc=vd(3);
    end

end
