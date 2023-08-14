function extents=getColorAlphaDataExtents(hObj)


    extents=[];
    cdata=hObj.CData;
    if(strcmp(hObj.FaceColor_I,'flat')||strcmp(hObj.EdgeColor,'flat'))&&isscalar(cdata)




        minPos=NaN;
        if(cdata>0)
            minPos=cdata;
        end

        if hObj.NumPeers==1


            extents=[cdata,NaN,minPos,cdata+1;NaN,NaN,NaN,NaN];
        else
            extents=[cdata,NaN,minPos,cdata;NaN,NaN,NaN,NaN];
        end
    end
end
