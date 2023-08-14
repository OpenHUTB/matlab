function coefficientsSharing=areCoefficientsSharing(~,blkObj)





    coefficientsSharing=false;
    if strcmp(blkObj.CoeffDataTypeStr,'Inherit: Same as first input')
        coefficientsSharing=true;
    end
end
