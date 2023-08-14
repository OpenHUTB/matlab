
function convertToAtomicSubsystemCB(cbinfo)
    block=SLStudio.Utils.getSelectedBlocks(cbinfo);

    if~isempty(block)&&block.isvalid
        handle=block.handle;
    else
        handle=SLStudio.Utils.getDiagramHandle(cbinfo);
        if isa(get_param(handle,'Object'),'Simulink.BlockDiagram')
            return;
        end
    end

    if cbinfo.EventData
        set_param(handle,'TreatAsAtomicUnit','on')
    else
        set_param(handle,'TreatAsAtomicUnit','off');
    end
end
