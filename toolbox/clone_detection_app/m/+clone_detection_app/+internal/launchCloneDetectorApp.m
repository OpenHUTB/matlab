function launchCloneDetectorApp(system)



    s=simulinkcoder.internal.util.getSource(bdroot(system));

    if~isempty(s)&&~isempty(s.studio)
        ts=s.studio.getToolStrip();

        actionService=ts.getActionService();
        actionService.executeAction('modelClonesIdentifierAppAction');
    end
end