function result=promptForSelection()



    instruction={...
    getString(message('Slvnv:oslc:CurrentSelectionNotKnown')),...
    ' ',...
    getString(message('Slvnv:oslc:PleaseSelectInArtifactsView')),...
    getString(message('Slvnv:oslc:orManuallyEnterNumericID'))};
    title=getString(message('Slvnv:oslc:LinkingWithDngTitle'));
    serverAddress=rmipref('OslcServerAddress');
    if~isempty(serverAddress)
        okBtn=getString(message('Slvnv:oslc:ListProjects'));
    else
        okBtn=getString(message('Slvnv:oslc:OK'));
    end

    response=questdlg(instruction,title,...
    getString(message('Slvnv:oslc:ManualEntry')),...
    okBtn,...
    getString(message('Slvnv:oslc:Cancel')),...
    getString(message('Slvnv:oslc:ManualEntry')));

    if isempty(response)||strcmp(response,getString(message('Slvnv:oslc:Cancel')))
        result=false;

    elseif strcmp(response,getString(message('Slvnv:oslc:ManualEntry')))
        result=true;

    elseif~isempty(serverAddress)
        serviceRoot=rmipref('OslcServerRMRoot');
        entryPage=[serverAddress,'/',serviceRoot,'/web'];
        web(entryPage,'-browser','-display');
        result=false;
    else
        result=false;
    end
end



