function[rgb]=getColorAsMxArrayFromHexStr(hexString)
    if strcmpi(hexString(1,1),'#')
        hexString(:,1)=[];
    end

    rgb=reshape(sscanf(hexString.','%2x'),3,[]).'/255;
end