function h=customize(h)




    h.Title=DAStudio.message('RTW:tfldesigner:TflDesignerTitle');
    h.Icon=fullfile(matlabroot,'toolbox','shared','dastudio','resources','SimulinkModelIcon.png');
    h.setTreeTitle('');

    h.imme=DAStudio.imExplorer(h);
    h.showDialogView(true);

    h.showContentsOf(false);

    h.setDispatcherEvents({
    'HierarchyChangedEvent',...
    'ListChangedEvent',...
    'PropertyChangedEvent',...
    'DirtyChangedEvent',...
    'ChildAddedEvent',...
'ChildRemovedEvent'
    });

