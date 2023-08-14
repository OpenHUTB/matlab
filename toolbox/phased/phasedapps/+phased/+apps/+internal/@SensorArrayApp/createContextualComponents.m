function[tabGroup,documentGroup]=createContextualComponents(obj,toolStrip,plotTag,name,tag)






    import matlab.ui.internal.toolstrip.*
    import matlab.ui.container.internal.appcontainer.*;
    import matlab.ui.container.internal.AppContainer;
    import matlab.ui.internal.*;


    toolStrip.Props=...
    buildPlotPropSection(toolStrip,plotTag);


    tabGroup=TabGroup();
    tabGroup.Tag=[tag,'_tabGroup'];
    tabGroup.Contextual=true;


    contextualTab=Tab(name);
    contextualTab.Tag=tag;
    contextualTab.add(toolStrip.Props);
    tabGroup.add(contextualTab);
    obj.ToolGroup.add(tabGroup);

    groupOptions.Tag=[tag,'_group'];
    groupOptions.Title=['Document_',tag];
    groupOptions.Context=matlab.ui.container.internal.appcontainer.ContextDefinition();
    groupOptions.Context.ToolstripTabGroupTags=[tag,'_tabGroup'];
    documentGroup=FigureDocumentGroup(groupOptions);
    obj.ToolGroup.add(documentGroup);
