function extents=getColorAlphaDataExtents(hObj)


    extents=[];


    if strcmp(hObj.CLimInclude,'on')
        colorIndex=hObj.CData;
        if isscalar(colorIndex)


            minPos=NaN;
            if(colorIndex>0)
                minPos=colorIndex;
            end

            numPeers=hObj.NumPeers;
            if numPeers==1


                out=[colorIndex,NaN,minPos,colorIndex+1;NaN,NaN,NaN,NaN];
            else
                out=[colorIndex,NaN,minPos,colorIndex;NaN,NaN,NaN,NaN];
            end
            extents=out;
        end
    end
end