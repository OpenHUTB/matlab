function ret=getDeviceNumberForVideoCapture(BlockID)




    import codertarget.peripherals.utils.*

    [~,pData]=getPeripheralInfoFromRefModels(bdroot(gcb));
    assert(isfield(pData,'VideoCapture'),...
    'Cannot find data for Video Capture block in the peripheral info');
    blkData=pData.VideoCapture;
    for i=1:numel(blkData)


        if isequal(strrep(blkData(i).ID,':','_'),BlockID)
            value=char(strtrim(blkData(i).DeviceName));
            if value(1)==char(39)
                value(1)='';
            end
            if value(end)==char(39)
                value(end)='';
            end
            upr=value<=char('9');
            lwr=value>=char('0');
            numIdx=find((upr.*lwr)==0,1,'last');
            if numel(value)==numIdx
                error('Enter a valid video device')
            end
            ret=uint8(real(str2double(value(numIdx+1:end))));
            break
        end
        ret=uint8(0);
    end
end
