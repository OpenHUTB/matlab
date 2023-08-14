function registerCustomCommands(app,editor,syntax)
    editor.commandFactory.customCreationData=app;
    editor.commandFactory.registerCreateFunction(...
    diagram.editor.command.DeleteCommand.StaticMetaClass,...
    @(cmd)customDelete(cmd,syntax,app));
end

function c=customDelete(cmd,syntax,app)
    c=classdiagram.app.core.commands.ClassDiagramDeleteCommand(cmd,syntax,app);
end
