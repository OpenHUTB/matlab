function update(hObj,event)








    if nargin>1
        event=convertStringsToChars(event);
    end

    switch event
    case 'attach'

        registerPropList(hObj,'NoDuplicate','All',[]);





        hObj.attachDefaultRTWCPPFcnClass;
    case 'activate'




        hObj.attachDefaultRTWCPPFcnClass;
    end


