function highlight(h,block)




    if nargin>1
        block=convertStringsToChars(block);
    end

    root=slroot;
    if~root.isValidSlObject(h.Model)
        load_system(h.Model);
    end

    if~ischar(block)
        sid=Simulink.ID.getSID(block);
        [blockName,ssid]=Simulink.ID.getFullName(sid);
        blockName=[blockName,ssid];
    elseif isempty(strfind(block,'/'))

        sid=block;
        blockName=Simulink.ID.getFullName(block);
    elseif isempty(strfind(block,':'))

        sid=Simulink.ID.getSID(block);
        blockName=getfullname(block);
    else

        sid=block;
        blockName=block;
    end

    model=strtok(block,':/');
    if~strcmp(model,h.Model)
        DAStudio.error('RTW:traceInfo:blockNotInModel',blockName);
    end

    [uptodate,reason,args]=h.isUpToDate;
    if~uptodate&&~strcmp(h.getLastWarningId,reason)
        h.LastWarning=[reason,args];
        MSLDiagnostic(h.LastWarning{:}).reportAsWarning;
    end

    if h.FeatureSubsysHighlight
        if strcmp(get_param(block,'BlockType'),'SubSystem')
            h.highlightSubsystem(block);
            return
        end
    end

    msgId=[];
    reg=h.getRegistry(block);
    subSysFullName='';
    if~isempty(h.SourceSystem)
        subSysFullName=getfullname(h.SourceSystem);
    end
    if isempty(reg)
        if strcmp(subSysFullName,blockName)
            h.highlightCodeLocations([]);
            return
        end
        reg=h.getRegistryEmlLine(block);
    end
    if isempty(reg)
        if~isempty(subSysFullName)&&...
            ~strncmp(blockName,subSysFullName,length(subSysFullName))
            msgId='RTW:traceInfo:blockOutsideSystem';
        else
            msgId='RTW:traceInfo:notTraceable';
        end
    else
        location=reg.location;
        if isempty(location)
            msgId=h.getReason(h.getBlockReductionReasons,reg);
        end
    end
    if~isempty(msgId)
        if h.DisplayErrorInBrowser
            h.displayMessage(h.getCodeGenRptFullPathName,msgId,sid);
        else
            DAStudio.error(msgId,blockName);
        end
    else
        h.highlightCodeLocations(location);
    end
