function propertyCallback_editingMode(this,eventData)






    owner=eventData.AffectedObject;
    event=eventData.Type;

    switch event
    case 'PropertyPostSet'

        dirtyModel=pmsl_private('pmsl_markmodeldirty');
        dirtyModel(owner.getBlockDiagram);




        hModel=owner.getBlockDiagram;
        pmOpenDialogs=this.getOpenDialogs(hModel);
        for idx=1:numel(pmOpenDialogs)
            this.prepareToOpenDialog(pmOpenDialogs(idx).Block);
            pmOpenDialogs(idx).Dialog.refresh();
        end












        if~isempty(hModel)&&~this.isExaminingModel(hModel)
            hBlocks=this.getSelectedBlocks(hModel);
            if~isempty(hBlocks)
                ev=DAStudio.EventDispatcher;
                for idx=1:numel(hBlocks)
                    pmsl_rtmcallback(get_param(hBlocks(idx),'Object'),'BLK_OPENDLG');
                    ev.broadcastEvent('PropertyChange',hBlocks(idx));
                end
            end
        end

    otherwise

        configData=RunTimeModule_config;
        pm_error(configData.Error.UnexpectedCallback_templ_msgid,event,eventData.Source.Name);

    end





