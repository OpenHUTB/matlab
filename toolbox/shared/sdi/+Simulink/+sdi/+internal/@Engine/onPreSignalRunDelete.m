function onPreSignalRunDelete(this,type,id)

    notify(this,'preDeleteEvent',Simulink.sdi.internal.SDIEvent('preDeleteEvent',type,id));
end
