function boolVal=isInterfaceViewActive(cbInfo)




    boolVal=false;
    slStudioApp=cbInfo.studio.App;
    currentEditor=slStudioApp.getActiveEditor;
    if(~isempty(currentEditor))
        boolVal=isa(currentEditor.getDiagram,'InterfaceEditor.Diagram');
    end
end
