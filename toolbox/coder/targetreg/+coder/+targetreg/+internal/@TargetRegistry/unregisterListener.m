function unregisterListener(hThis,hListener)



    thisID=hListener.ListenerID;
    if thisID~=0
        oldListeners=hThis.Listeners;
        hThis.Listeners=hThis.Listeners(1:thisID-1);
        for idx=thisID+1:length(oldListeners)
            hListener=oldListeners(idx);
            hListener{1}.ListenerID=idx-1;
            hThis.Listeners=[hThis.Listeners,hListener];
        end
    end
