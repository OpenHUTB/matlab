
function out=getSlciAppContext(studio)
    contextManager=studio.App.getAppContextManager;
    userdata="slciApp";
    out=contextManager.getCustomContext(userdata);
end