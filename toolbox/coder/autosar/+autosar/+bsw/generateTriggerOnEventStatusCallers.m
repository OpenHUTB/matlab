function generateTriggerOnEventStatusCallers(blkH,numEvents)





    blockPath=getfullname(blkH);

    numEventsStr=num2str(numEvents);


    existingCallerBlocks=Simulink.findBlocksOfType(blkH,'FunctionCaller');

    if numel(existingCallerBlocks)==numEvents


        return;
    end

    for ii=1:numel(existingCallerBlocks)
        lines=get_param(existingCallerBlocks(ii),'LineHandles');
        lines=[lines.Inport,lines.Outport];
        for jj=1:numel(lines)
            if lines(jj)==-1
                continue;
            end
            delete_line(lines(jj));
        end
        delete_block(existingCallerBlocks(ii));
    end


    set_param([blockPath,'/Demux_EventId'],'Outputs',numEventsStr);
    set_param([blockPath,'/Demux_EventStatusByteOld'],'Outputs',numEventsStr);
    set_param([blockPath,'/Demux_EventStatusByteNew'],'Outputs',numEventsStr);
    set_param([blockPath,'/Mux_ERR'],'Inputs',numEventsStr);


    callerBlocks=cell(1,numEvents);

    for ii=1:numEvents
        callerBlocks{ii}=add_block('autosarspkglib_internal_utils/Fim_DemTriggerOnEventStatusCaller',[blockPath,'/Caller'],'MakeNameUnique','on');
        callerName=get_param(callerBlocks{ii},'Name');
        set_param(callerBlocks{ii},'Position',[165,-150+(100*ii),510,-100+(100*ii)]);
        add_line(blockPath,['Demux_EventId/',num2str(ii)],[callerName,'/1']);
        add_line(blockPath,['Demux_EventStatusByteOld/',num2str(ii)],[callerName,'/2']);
        add_line(blockPath,['Demux_EventStatusByteNew/',num2str(ii)],[callerName,'/3']);
        add_line(blockPath,[callerName,'/1'],['Mux_ERR/',num2str(ii)]);
    end
end


