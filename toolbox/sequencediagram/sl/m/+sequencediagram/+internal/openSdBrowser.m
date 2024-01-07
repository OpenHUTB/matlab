function openSdBrowser(studio,debugMode)

    narginchk(1,2);
    if nargin==1
        debugMode=false;
    end
    topLevelDiagram=studio.App.topLevelDiagram;
    modelHandle=topLevelDiagram.handle;
    modelName=get_param(modelHandle,'Name');
    browserId=builtin('_get_sequence_diagram_browser_id',modelName);

    connector.ensureServiceOn;
    if debugMode
        url=['/toolbox/sequencediagram/web/web/sdBrowser-debug.html?browserId=',browserId];
        url=connector.getUrl(url);
        web(url,'-browser');
    else
        SDBrowserComp=studio.getComponent('GLUE2:Sequence Diagram Browser Component','SD Browser');
        if isempty(SDBrowserComp)
            SDBrowserComp=GLUE2.SequenceDiagramBrowserComponent(studio,'SD Browser');
            url=['/toolbox/sequencediagram/web/web/sdBrowser.html?browserId=',browserId];
            url=connector.getUrl(url);
            SDBrowserComp.setUrl(url);
            studio.registerComponent(SDBrowserComp);
            studio.moveComponentToDock(SDBrowserComp,'Sequence Diagram Browser','Left','Tabbed');
        end

        if~SDBrowserComp.isVisible()
            studio.showComponent(SDBrowserComp);
        end
        studio.focusComponent(SDBrowserComp);

    end

end

