function showDB2DOMTemplateBrowser(root)





    browser=find(root,'-depth',1,'-isa','RptgenML.DB2DOMTemplateBrowser');%#ok<GTARG>

    if isempty(browser)
        browser=RptgenML.DB2DOMTemplateBrowser;
        if isempty(down(root))
            connect(browser,root,'up');
        else
            connect(browser,down(root),'right');
        end
    end

    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('HierarchyChangedEvent',root);
    e=root.getEditor;
    ime=DAStudio.imExplorer(e);
    ime.expandTreeNode(browser);
    e.view(browser);

