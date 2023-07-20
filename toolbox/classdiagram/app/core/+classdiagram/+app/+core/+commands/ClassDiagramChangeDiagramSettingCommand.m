classdef ClassDiagramChangeDiagramSettingCommand<diagram.editor.Command&...
    classdiagram.app.core.commands.ClassDiagramUndoRedo



    properties(Access={
        ?diagram.editor.Command,...
        ?classdiagram.app.core.commands.ClassDiagramUndoRedo
        })
        App;
        RootDiagram;
        SettingName;
    end

    methods
        function cmd=ClassDiagramChangeDiagramSettingCommand(data,syntax,app)
            cmd@diagram.editor.Command(data,syntax);
            cmd.App=app;
            cmd.RootDiagram=syntax.root;
        end
    end

    methods(Access=protected)
        function execute(self)
            data=self.data;
            self.SettingName=data.key;
            self.App.syntax.modify(@(ops)...
            ops.setAttributeValue(self.RootDiagram,self.SettingName,self.data.val));
            self.App.Settings=self.App.Settings.set(self.SettingName,self.data.val);
        end

        function undo(self)
            self.undoDefault;
            self.App.Settings=self.App.Settings.set(self.SettingName,...
            self.RootDiagram.getAttribute(self.SettingName).value);
        end

        function redo(self)
            self.redoDefault;
            self.App.Settings=self.App.Settings.set(self.SettingName,...
            self.RootDiagram.getAttribute(self.SettingName).value);
        end
    end
end

