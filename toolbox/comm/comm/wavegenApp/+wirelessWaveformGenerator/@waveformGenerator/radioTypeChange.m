function radioTypeChange(obj,newValueTag,newValueType)





    if obj.useAppContainer
        freezeApp(obj);
    else
        obj.ToolGroup.setWaiting(true);
    end


    if nargin==2
        newValueType=newValueTag;
    end


    for item=obj.pRadioGalleryItems
        item=item{:};
        newValueTextNoNewLine=replace(newValueTag,newline,' ');
        if strcmpi(item.Tag,newValueTextNoNewLine)
            item.Value=true;
        else
            item.Value=false;
        end
    end

    obj.pCurrentHWType=replace(newValueType,newline,' ');
    obj.pCurrentHWTag=replace(newValueTag,newline,' ');

    success=checkTransmitterProduct(obj);
    if success


        pause(0.5);
drawnow

        setRadioDialog(obj,obj.pCurrentHWType);


        pause(0.2);
drawnow
        if supportScanning(obj.pParameters.RadioDialog)
            checkProduct=false;
            findRadios(obj,checkProduct);
        else
            if~isempty(obj.pWaveform)
                obj.pTransmitBtn.Enabled=true;
                obj.pExportTxBtn.Enabled=true;
            end
        end
    end


    if obj.useAppContainer
        unfreezeApp(obj);
    else
        obj.ToolGroup.setWaiting(false);
    end