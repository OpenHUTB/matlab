classdef ClassDiagramRefreshCommand<diagram.editor.Command&...
    classdiagram.app.core.commands.ClassDiagramUndoRedo
    properties(Access={
        ?diagram.editor.Command,...
        ?classdiagram.app.core.commands.ClassDiagramUndoRedo
        })
        App;
        RootDiagram;
    end

    methods
        function cmd=ClassDiagramRefreshCommand(data,syntax,app)
            cmd@diagram.editor.Command(data,syntax);
            cmd.App=app;
            cmd.RootDiagram=syntax.root;
        end

    end

    methods(Static,Access=?classdiagram.app.mcos.MCOSPackageProvider)
        function updateStateForChildren(factory,valid)
            if isempty(valid)
                return;
            end
            state=valid.getState;

            children=factory.retrieveNonCachedChildren(valid);
            packages=children{1};
            children=[children{2},children{3}];
            arrayfun(@(ch)ch.setState(state),children);
            if~isempty(packages)
                arrayfun(@(ch)ch.setState(state),packages);
                arrayfun(@(ch)classdiagram.app.core.commands.ClassDiagramRefreshCommand.updateStateForChildren...
                (factory,ch),packages);
            end
        end
    end

    methods(Access=protected)
        function doModify(self,operations,~)








            factory=self.App.getClassDiagramFactory();
            report=factory.getOutOfDateElements();
            factory.updateTypes(report.changedType);
            valids=report.upToDate;
            creator=classdiagram.app.core.ElementCreator(self.App,self.UuidToObjectMap);
            if~isempty(valids)&&isa(self.App.notifier,'classdiagram.app.core.notifications.WDFNotifier')
                self.App.notifier.clearNotification(...
                categories='classdiagram.app.core.notifications.notifications.OutOfSyncClass');
            end
            for ivalid=1:numel(valids)
                valid=valids(ivalid);
                valid.clearCaches();
                creator.updateDiagramEntity(operations,valid.getName);

                if isa(self.App.notifier,'classdiagram.app.core.notifications.WDFNotifier')
                    self.App.notifier.clearNotification(keys=valid.getDiagramElementUUID);
                else
                    self.App.notifier.clearNotification(valid.getName);
                end
            end

            function uuid=processOutOfDateElement(el)

                el.setMetadataByKey('nosource','nosource');
                creator.updateDiagramEntityMetadata(operations,el);
                uuid=string(el.getDiagramElementUUID);
            end
            staleUUIDs=arrayfun(@(el)processOutOfDateElement(el),report.outOfDate);
            if isa(self.App.notifier,'classdiagram.app.core.notifications.WDFNotifier')
                if~isempty(staleUUIDs)
                    self.App.refresher.notifyStale(report.outOfDate);
                end
            else


                self.App.refresher.markStale(staleUUIDs);
            end

            if~isempty(valids)
                self.App.connectionHandler.handleConnections(operations);
            end

            if isa(self.App.notifier,'classdiagram.app.core.notifications.Notifier')

                self.App.notifier.doneWaiting();
            end
        end

        function execute(self)
            fh=@(batchOps)self.App.syntax.modify(@(ops)self.doModify(ops,self.data));
            self.App.executeAction(fh,Action='resetDiagram');
        end
    end
end

