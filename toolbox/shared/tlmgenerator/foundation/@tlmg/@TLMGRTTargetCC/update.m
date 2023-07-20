function update(hObj,event)




    if nargin>1
        event=convertStringsToChars(event);
    end

    cs=hObj.getConfigSet;
    if strcmp(event,'attach')


        registerPropList(hObj,'NoDuplicate','All',[]);
    end


    if ismethod(hObj,'getExtensionUpdate')
        hObj.getExtensionUpdate(event);
    end

end