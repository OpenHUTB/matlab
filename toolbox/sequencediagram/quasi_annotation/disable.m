unregisterSimulinkRequirements();
removeBlockDiagramListeners();
destroySingletons();
removeFromPath();


function removeFromPath()
    qaPath=getQAPath();
    rmpath(qaPath);
end


function qaPath=getQAPath()
    thisScript=mfilename('fullpath');
    thisDir=fileparts(thisScript);
    qaPath=fullfile(thisDir,'m');
end


function removeBlockDiagramListeners()
    app=sequencediagram.quasiannotation.App.getInstance();
    app.removeBlockDiagramCreatedCallback()
end

function unregisterSimulinkRequirements()
    sequencediagram.quasiannotation.internal.RequirementsAdapter.unregister();
    rmi('unregister','linktype_rmi_sequenceDiagramQuasiAnnotation');
end


function destroySingletons()
    delete(sequencediagram.quasiannotation.internal.EditorInterface.getInstance());
    delete(sequencediagram.quasiannotation.App.getInstance());
    munlock sequencediagram.quasiannotation.internal.EditorInterface.getInstance;
    munlock sequencediagram.quasiannotation.App.getInstance;
end


