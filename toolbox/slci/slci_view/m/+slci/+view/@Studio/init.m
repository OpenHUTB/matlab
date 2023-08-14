


function init(obj)

    obj.fModelHandle=obj.fStudio.App.blockDiagramHandle;




    obj.fListeners{end+1}=Simulink.listener(obj.fModelHandle,...
    'CloseEvent',@(es,ed)obj.onStudioClose(es,ed));
