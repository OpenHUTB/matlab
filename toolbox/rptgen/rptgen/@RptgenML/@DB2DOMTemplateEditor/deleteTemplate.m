function deleteTemplate(this)




    reply=questdlg(getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:confirmDeleteTemplateMsg',this.DisplayName)),...
    getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:deleteTemplateDlgTitle')));

    if strcmpi(reply,'Yes')
        category=this.up;
        disconnect(this);


        if~isempty(dir(this.TemplatePath))
            cache=rptgen.db2dom.TemplateCache.getTheCache();
            uncacheTemplate(cache,this.TemplatePath);
            delete(this.TemplatePath);
        end

        if~isempty(category)
            r=RptgenML.Root;
            e=r.Editor;
            if~isempty(e)
                ed=DAStudio.EventDispatcher;
                ed.broadcastEvent('HierarchyChangedEvent',r);
                ime=DAStudio.imExplorer(e);
                ime.selectListViewNode(category);
            end
        end
    else
    end