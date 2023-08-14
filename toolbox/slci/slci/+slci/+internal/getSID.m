function sid=getSID(blkHdl)




    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
    try
        hdl=slci.internal.getOrigRootIOPort(blkHdl,'Outport');
        sid=Simulink.ID.getSID(get_param(hdl,'Object'));
        if slcifeature('BEPSupport')==0&&...
            slcifeature('VirtualBusSupport')==1&&...
            ~isvalid(sid)&&isBlockIOType(hdl)


            blk=slInternal('busDiagnostics','getOriginalBlockHandleForRootIOBlock',hdl);
            sid=Simulink.ID.getSID(get_param(blk,'Object'));
        end
    end
end

function flag=isvalid(sid)


    pattern='.*:0';
    matched=regexp(sid,pattern,'match');
    flag=isempty(matched);
end

function out=isBlockIOType(blkHdl)

    blkType=get_param(blkHdl,'BlockType');
    out=strcmp(blkType,'Inport')||strcmp(blkType,'Outport');
end
