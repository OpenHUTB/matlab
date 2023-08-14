













function hiliteBusObject(type,source,bus,element)
    switch type
    case 'data dictionary'
        dataSource=Simulink.data.DataDictionary(source);
    case 'base workspace'
        dataSource=Simulink.data.BaseWorkspace();
    otherwise
        dataSource=Simulink.data.BaseWorkspace();
    end
    buseditor('Create',bus,dataSource);
    ed=Simulink.typeeditor.app.Editor.getInstance;
    if isa(dataSource,'Simulink.data.BaseWorkspace')
        root=ed.getBaseRoot;
    else
        [~,fileName,~]=fileparts(source);
        root=ed.getSource.find(fileName);
    end
    if~isempty(element)
        node=Simulink.typeeditor.utils.getNodeFromPath(root,[bus,'.',element]);
        Simulink.typeeditor.app.Editor.setCurrentListNode(node);
    end
end

