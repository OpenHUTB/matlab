function out=getHandle(url)




    h=Simulink.URL.parseURL(url);
    out=h.getHandle;
