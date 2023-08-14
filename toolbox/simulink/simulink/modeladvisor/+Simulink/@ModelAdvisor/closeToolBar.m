function closeToolBar(varargin)




    mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;

    if strcmp(varargin{1},'MA')
        me=mdladvObj.MAExplorer;
    elseif strcmp(varargin{1},'MACE')
        me=mdladvObj.ConfigUIWindow;
    else
        me=mdladvObj.CheckLibraryBrowser;
    end
    me.UserData.toolbar.visible=0;
