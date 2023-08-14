function binIndex=localBarFaceIndexToBinIndex(hObj,faceIndex,isxz,isyz)





    nxz=sum(isxz);
    nyz=sum(isyz);
    if faceIndex<=nxz
        [facerow,facecol]=ind2sub(hObj.NumBins,faceIndex);
        if facecol==1
            bincol=facecol;
        elseif facecol<=hObj.NumBins(2)
            if hObj.Values(facerow,facecol-1)>=hObj.Values(facerow,facecol)
                bincol=facecol-1;
            else
                bincol=facecol;
            end
        else
            facerow=hObj.NumBins(1)-facerow+1;
            bincol=facecol-1;
        end
        binIndex=sub2ind(hObj.NumBins,facerow,bincol);
    elseif faceIndex<=nxz+nyz
        faceIndex=faceIndex-nxz;
        [facecol,facerow]=ind2sub(flip(hObj.NumBins),faceIndex);
        if facerow==1
            facecol=hObj.NumBins(2)-facecol+1;
            binrow=facerow;
        elseif facerow<=hObj.NumBins(1)
            facecol=hObj.NumBins(2)-facecol+1;
            if hObj.Values(facerow-1,facecol)>=hObj.Values(facerow,facecol)
                binrow=facerow-1;
            else
                binrow=facerow;
            end
        else
            binrow=facerow-1;
        end
        binIndex=sub2ind(hObj.NumBins,binrow,facecol);
    else
        nbins=prod(hObj.NumBins);
        binIndex=rem(faceIndex-nxz-nyz-1,nbins)+1;
    end