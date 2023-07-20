function propValueChangeCallback(hObj,event)







    if(ismethod(hObj,'dirtyHostBD'))
        hObj.dirtyHostBD();
    end













    if(strcmp(get(event.Source).Name,'DisabledProps'))

        return
    elseif(~strcmp(hObj.tlmgTbExeDir,'')&&any(~strcmp(event.NewValue,'tlmgTbExeDir')))



        hObj.tlmgTbExeDir='';



        hCs=hObj.getConfigSet();
        if(~isempty(hCs))
            warning(message('TLMGenerator:TLMTargetCC:TbOutOfDate'));
        end
    end


