function reRegisterListener=unregisterListenerCBTemporarily(m3iModel)






    reRegisterListener=onCleanup.empty();

    needToReRegisterListener=autosarcore.unregisterListenerCB(m3iModel);
    if(needToReRegisterListener)
        if(autosarinstalled)


            reRegisterListener=onCleanup(@()autosar.ui.utils.registerListenerCB(m3iModel));
        end
    end
