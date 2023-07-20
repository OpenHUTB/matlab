classdef Refresher
    properties(Access=private)
        App;
    end

    properties(Access=private,Hidden)
        forceRedrawCounter=0;
    end

    methods
        function obj=Refresher(app)
            obj.App=app;
        end

        function refresh(obj,varargin)
            function innerRefresh(obj,varargin)
                cp=obj.App.editor.commandProcessor;
                cmd=cp.createCustomCommand(...
                'classdiagram.app.core.commands.ClassDiagramRefreshCommand',...
                'Refresh',[]);
                cp.execute(cmd);


                obj.App.getClassDiagramFactory.resetInDiagramCache()


                obj.App.getClassBrowser.refreshHierarchy(varargin{:});


                obj.App.inspector.refreshInspector;
            end
            fh=@(batchOps)innerRefresh(obj,varargin{:});
            obj.App.executeAction(fh,Action='resetDiagram');
        end

        function markStale(obj,uuids)
            action.type="markStaleElements";
            action.elements=uuids;
            obj.App.publishData(action);
        end

        function notifyStale(obj,staleElements)
            import classdiagram.app.core.notifications.notifications.*;

            if isempty(staleElements)
                return;
            end
            for ii=1:length(staleElements)
                obj.App.notifier.processNotification(...
                OutOfSyncClass(staleElements(ii)));
            end
        end

        function markOutOfDateElementsStale(obj)
            factory=obj.App.getClassDiagramFactory();
            report=factory.getOutOfDateElements();
            if classdiagram.app.core.feature.isOn('notifications')
                obj.notifyStale(report.outOfDate);
                return;
            end
            staleUUIDs=arrayfun(@(el)string(el.getDiagramElementUUID),report.outOfDate);
            obj.markStale(staleUUIDs);
        end
    end

    methods(Access={?classdiagram.app.core.ClassDiagramApp,...

        })
        function refreshForMixins(obj)
            factory=obj.App.getClassDiagramFactory;
            packageElements=factory.getDiagramedEntities;
            toRedraw=struct('uuid','','InheritanceFlags',0);
            toRemove=classdiagram.app.core.domain.PackageElement.empty;
            showDetails=obj.App.getGlobalSetting('ShowDetails');
            for ipe=1:numel(packageElements)
                pe=packageElements(ipe);
                peName=pe.getName;
                inherits=classdiagram.app.core.InheritanceFlags.fromMixins(...
                pe.getInheritanceFlags);
                if classdiagram.app.core.InheritanceFlags.isMixin(peName)...
                    &&~showDetails
                    toRemove(end+1)=pe;%#ok<AGROW>
                    continue;
                end
                if(inherits&&~showDetails)
                    classdiagram.app.core.InheritanceFlags.setFlags(...
                    factory,{peName},...
                    classdiagram.app.core.InheritanceFlags.DISABLEIMMEDIATE,...
                    classdiagram.app.core.InheritanceFlags.DISABLEALL...
                    );
                elseif(inherits&&showDetails)
                    classdiagram.app.core.InheritanceFlags.resetFlags(...
                    factory,{peName},...
                    classdiagram.app.core.InheritanceFlags.DISABLEIMMEDIATE,...
                    classdiagram.app.core.InheritanceFlags.DISABLEALL...
                    );
                end
                toRedraw(end+1)=struct('uuid',pe.getDiagramElementUUID,...
                'InheritanceFlags',pe.getInheritanceFlags);%#ok<AGROW>
            end
            toRedraw(1)=[];
            obj.App.syntax.modify(@(operations)obj.redrawForMixins(operations,...
            toRedraw,"InheritanceFlags"));
            obj.App.removeClass(toRemove);
            cb=obj.App.getClassBrowser;
            cb.refreshHierarchy;
            obj.refreshConnections();
            obj.App.publishData(struct('key','ShowDetails','val',showDetails));
        end
    end

    methods(Access=private)
        function refreshConnections(obj)
            factory=obj.App.getClassDiagramFactory;
            allkeys=keys(factory.idToObjectMap);
            allvalues=values(factory.idToObjectMap);
            indirectInheritanceRels=allvalues(~cellfun(@isempty,...
            (regexp(allkeys,'Relationship\|.*INDIRECTINHERITANCE$'))));
            toRedraw=struct('uuid','','InheritanceHierarchyMixinsOnly',0);
            showDetails=obj.App.getGlobalSetting('ShowDetails');
            for iir=1:numel(indirectInheritanceRels)
                rel=indirectInheritanceRels{iir};
                uuid=rel.getDiagramElementUUID;
                if isempty(uuid)
                    continue;
                end
                mixinsOnly=0;
                if~showDetails
                    mixinsOnly=rel.getInheritanceHierarchy.mixinsOnly;
                end
                toRedraw(end+1)=struct('uuid',uuid,...
                'InheritanceHierarchyMixinsOnly',mixinsOnly);%#ok<AGROW>
            end
            toRedraw(1)=[];
            obj.App.syntax.modify(@(operations)obj.redrawForMixins(operations,...
            toRedraw,'InheritanceHierarchyMixinsOnly'));
        end

        function redrawForMixins(obj,operations,toRedraw,attrName)
            for ii=1:numel(toRedraw)
                uuid=toRedraw(ii).uuid;
                attrValue=toRedraw(ii).(attrName);
                diagramElement=obj.App.syntax.findElement(uuid);
                if isempty(diagramElement)||~diagramElement.isValid
                    continue;
                end
                obj.forceRedrawCounter=obj.forceRedrawCounter+1;
                operations.setAttributeValue(diagramElement,"redraw",obj.forceRedrawCounter);
                operations.setAttributeValue(diagramElement,attrName,attrValue);
            end
        end
    end
end