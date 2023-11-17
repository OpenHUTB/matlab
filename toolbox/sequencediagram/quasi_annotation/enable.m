addToPath();
setupBlockDiagramListeners();
setupSimulinkRequirements();

function addToPath()
    qaPath=getQAPath();
    addpath(qaPath);
end

function qaPath=getQAPath()
    thisScript=mfilename('fullpath');
    thisDir=fileparts(thisScript);
    qaPath=fullfile(thisDir,'m');
end

function setupBlockDiagramListeners()
    app=sequencediagram.quasiannotation.App.getInstance();
    app.addBlockDiagramCreatedCallback()
end

function setupSimulinkRequirements()
    rmi('register','linktype_rmi_sequenceDiagramQuasiAnnotation');
    sequencediagram.quasiannotation.internal.RequirementsAdapter.register();
end


