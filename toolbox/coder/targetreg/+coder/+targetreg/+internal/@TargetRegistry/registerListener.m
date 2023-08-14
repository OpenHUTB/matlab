function registerListener(hThis,hListener)



    validateattributes(hListener,'RTW.TargetListener',{})

    if hListener.ListenerID==0
        hListener.ListenerID=length(hThis.Listeners)+1;
        hThis.Listeners{end+1}=hListener;
    end
end
