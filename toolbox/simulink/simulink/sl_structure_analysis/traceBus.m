




function traceBus(direction,dialog)
    title=dialog.getTitle;
    titleSet=strsplit(title,' - ');
    model=titleSet{end};
    signals=dialog.getWidgetValue('sigselector_signalsTree');
    if~isempty(signals)
        if length(signals)>1
            ME=sltrace.utils.createMException('Simulink:HiliteTool:MultiSelectBusElement');
            warning(ME.message);
        end
        signal=signals{1};
        busPath=busParser(signal);
        seg=getSelectedSeg(model);
        if isempty(seg)
            ME=sltrace.utils.createMException('Simulink:HiliteTool:NoLineSelected');
            warning(ME.message);
            return;
        end
        if strcmp(direction,'source')
            Simulink.Structure.HiliteTool.AppManager.HighlightSignalToAllSources(seg,busPath);
        else
            Simulink.Structure.HiliteTool.AppManager.HighlightSignalToAllDestinations(seg,busPath);
        end
    end
end












function busPath=busParser(signal)
    busPath='';

    bdInfo=strsplit(signal,'//');


    sigInfo=strsplit(signal,'/');

    sigSet=sigInfo(length(bdInfo)+1:end);
    sigSetLength=length(sigSet);

    if sigSetLength<1
        return;
    else
        busPath=sigSet{1};
    end

    for i=2:sigSetLength
        busPath=append(busPath,'/',sigSet{i});
    end
end



function seg=getSelectedSeg(model)









    seg=find_system(gcs,'findAll','on',...
    'FollowLinks','on',...
    'LookUnderMasks','on',...
    'SearchDepth',1,...
    'type','line',...
    'selected','on');

    if isempty(seg)
        seg=find_system(model,'findAll','on',...
        'FollowLinks','on',...
        'LookUnderMasks','on',...
        'SearchDepth',1,...
        'type','line',...
        'selected','on');
    end

    if length(seg)>1
        curport=get(seg,'SrcPortHandle');
        if iscell(curport)
            curport=unique(cell2mat(curport));
        end

        curport=curport(ishandle(curport));

        curport(strcmp(get(curport,'PortType'),'connection'))=[];

        seg=get_param(curport,'line');
    end
end
