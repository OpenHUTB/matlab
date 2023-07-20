function openVariable(name,obj)




    sw=warning('off','all');
    tmp=onCleanup(@()warning(sw));
    Simulink.sdi.plot(obj,name);
end
