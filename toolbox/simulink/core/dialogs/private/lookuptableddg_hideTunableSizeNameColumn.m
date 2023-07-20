function cols=lookuptableddg_hideTunableSizeNameColumn(h,isBpFromALUTObj,cols,TunableSizeName)

    if isBpFromALUTObj
        if~h.SupportTunableSize&&~h.AllowMultipleInstancesOfTypeToHaveDifferentTableBreakpointSizes
            cols(strcmp(cols(:),TunableSizeName))=[];
        end
    else
        if~h.SupportTunableSize
            cols(strcmp(cols(:),TunableSizeName))=[];
        end
    end
