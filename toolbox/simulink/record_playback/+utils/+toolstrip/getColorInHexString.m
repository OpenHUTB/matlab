function[hex]=getColorInHexString(rgb)
    rgb=round(rgb*255);
    hex(:,2:7)=reshape(sprintf('%02x',rgb.'),6,[]).';
    hex(:,1)='#';
end