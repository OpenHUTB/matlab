function editorId=getOrCreateSequenceDiagramEditorId(modelName,sequenceDiagramName)
    editorId=callShippedFcn(modelName,sequenceDiagramName);
    ei=sequencediagram.quasiannotation.internal.EditorInterface.getInstance();
    ei.fireEventWhenEditorIsLoaded(modelName,sequenceDiagramName);
end

function editorId=callShippedFcn(modelName,sequenceDiagramName)

    here=pwd;
    cdBack=onCleanup(@()cd(here));

    shippedPath=[matlabroot,'/toolbox/sequencediagram/sl/m'];
    cd(shippedPath);

    editorId=sequencediagram.internal.getOrCreateSequenceDiagramEditorId(modelName,sequenceDiagramName);

end


