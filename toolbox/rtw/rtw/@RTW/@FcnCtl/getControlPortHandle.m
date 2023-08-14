function ctrlPortH=getControlPortHandle(hSrc,ctrlPortBlock)%#ok









    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);
    ctrlPortH=-1;

    try %#ok
        obj=get_param(bdroot(ctrlPortBlock),'Object');
        hiddenRootSys=obj.getHiddenRootCondExecSystem;




        if(hiddenRootSys==-1)
            return;
        end

        ph=get_param(hiddenRootSys,'PortHandles');
        blockType=get_param(ctrlPortBlock,'BlockType');

        switch(blockType)
        case 'EnablePort'
            ctrlPortH=ph.Enable;

        case 'TriggerPort'
            ctrlPortH=ph.Trigger;

        otherwise
            assert(false,'Unknown control port type');
        end
    end
    delete(sess);
end


