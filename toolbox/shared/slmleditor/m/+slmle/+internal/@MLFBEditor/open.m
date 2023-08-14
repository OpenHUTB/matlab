function open(obj)




    try

        ed=obj.ed;
        url=obj.getUrl;
        SLStudio.StudioAdapter.attachWebContentToEditor(ed,url);

        if~obj.ready

            obj.createToolStripContext();
        end


        SLM3I.SLCommonDomain.focusEditorCEF(ed);

        switch(get_param(bdroot(ed.getStudio().App.blockDiagramHandle),'SimulationStatus'))
        case{"initializing","terminating"}

            editorWidget=ed.getWidget();
            explorerBarWidget=editorWidget.findChildWithTag('GLUE2:ExplorerBar',true);
            drawnow;
            editorWidget.enabled=true;
            explorerBarWidget.enabled=false;
        otherwise

        end





        if isa(sf('IdToHandle',obj.chartId),'Stateflow.EMChart')||...
            isa(sf('IdToHandle',obj.objectId),'Stateflow.EMFunction')
            obj.registerFocusListener();
        end
        obj.prevActiveEditor=obj.studio.App.getActiveEditor();
    catch

    end






