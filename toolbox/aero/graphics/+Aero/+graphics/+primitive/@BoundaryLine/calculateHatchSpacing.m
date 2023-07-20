function calculateHatchSpacing(hObj,vertexData)



    x=vertexData(1,:);
    y=vertexData(2,:);
    z=vertexData(3,:);

    lineLength=hObj.calculateSegmentLength(x,y,z);



    if lineLength==0
        hObj.HatchHandle.Visible="off";
        hObj.MarkerHandle.Visible="off";
        return
    else
        hObj.HatchHandle.Visible="on";
        hObj.MarkerHandle.Visible="on";
    end



    if hObj.HatchSpacingMode=="auto"
        nHatches=strlength(hObj.Hatches);
        if nHatches==0
            return
        end



        hObj.HatchSpacing_I=(lineLength/nHatches./max(floor(lineLength./0.025),1));
    end
end

