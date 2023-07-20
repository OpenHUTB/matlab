classdef ClassDiagramDeleteCommand<diagram.editor.Command&...
    classdiagram.app.core.commands.ClassDiagramUndoRedo
    properties(Access={
        ?diagram.editor.Command,...
        ?classdiagram.app.core.commands.ClassDiagramUndoRedo
        })
        App;
    end

    methods
        function cmd=ClassDiagramDeleteCommand(data,syntax,app)
            cmd@diagram.editor.Command(data,syntax);
            cmd.App=app;
        end
    end

    methods(Access=protected)
        function execute(obj)


            errID='diagram_editor_registry:Command:ExecCommandFailed';
            reason='Invalid command data';



            if(isempty(obj.data))
                error(errID,reason);
            end

            function innerExecute(obj)
                factory=obj.App.getClassDiagramFactory;
                if obj.commandSource==diagram.editor.command.CommandSource.Client
                    uuids=obj.data.elements(1:end);
                    [objects,diagramElements]=obj.uuid2obj(uuids);
                else
                    inputArr=obj.data.elements;
                    if isa(inputArr,'classdiagram.app.core.domain.BaseObject')
                        objects=inputArr;
                    elseif isa(inputArr,'string')||isa(inputArr,'char')
                        packageElementNames=string(inputArr);
                        objects=classdiagram.app.core.domain.PackageElement.empty;
                        for i=1:numel(packageElementNames)
                            packageElementName=packageElementNames(i);
                            packageElementID="Class|"+packageElementName;
                            object=factory.getObject(packageElementID);
                            if isempty(object)
                                packageElementID="Enum|"+packageElementName;
                                object=factory.getObject(packageElementID);
                            end
                            if~isempty(object)&&isvalid(object)
                                objects(end+1)=object;%#ok<AGROW>
                            end
                        end
                    else
                        allPackageElements=factory.getDiagramedEntities;
                        names=arrayfun(@(o)o.getName,allPackageElements);
                        idx=ismember(cellstr(names),cellstr(inputArr));
                        objects=allPackageElements(idx);
                    end
                    if isempty(objects)
                        return;



                    end
                    objects(isempty(objects))=[];

                    idx=arrayfun(@(o)~isempty(o.getDiagramElementUUID),objects);
                    objects=objects(idx);
                    if isempty(objects)
                        return;
                    end
                    diagramElements=obj2uuid(obj,objects);
                end
                if isempty(objects)
                    error(errID,reason);
                end
                obj.syntax.modify(@(operations)obj.delete(operations,objects,diagramElements,...
                obj.commandSource==diagram.editor.command.CommandSource.Server));

            end
            fh=@(batchOps)innerExecute(obj);
            obj.App.executeAction(fh,Action="remove");
        end

        function undo(obj)

            obj.undoDefault;
            obj.setUuids;

            obj.App.inspector.refreshInspector();

            if numel(obj.ModifiedPackageElements)>0&&...
                classdiagram.app.core.feature.isOn('notifications')
                obj.App.notifier.processNotification(...
                classdiagram.app.core.notifications.notifications.NClassesAddedInfo(...
                obj.ModifiedPackageElements,{}),...
                lozengeType=classdiagram.app.core.notifications.LozengeType.UndoRedo);
            end
        end

        function redo(obj)
            obj.removeUuids;


            obj.redoDefault;

            obj.App.inspector.refreshInspector();

            if numel(obj.ModifiedPackageElements)>0&&...
                classdiagram.app.core.feature.isOn('notifications')
                obj.App.notifier.processNotification(...
                classdiagram.app.core.notifications.notifications.NClassesRemovedInfo(...
                obj.ModifiedPackageElements),...
                lozengeType=classdiagram.app.core.notifications.LozengeType.UndoRedo);
            end
        end
    end

    methods(Access=private)
        function delete(self,operations,objects,diagramElements,toBeDeletedFromWDF)
            self.ModifiedPackageElements=objects;
            classesToUpdate=classdiagram.app.core.domain.PackageElement.empty;
            rebuildConnections=0;
            factory=self.App.getClassDiagramFactory;
            deletionVisitor=classdiagram.app.core.visitors.DeleteObjectVisitor(factory);
            for iobject=1:numel(objects)
                object=objects(iobject);
                self.UuidToObjectMap(object.getDiagramElementUUID)=object;

                object.accept(deletionVisitor);
                if isa(object,'classdiagram.app.core.domain.PackageElement')
                    classesToUpdate(end+1)=object;%#ok<AGROW> 
                    rebuildConnections=1;
                end
            end
            if toBeDeletedFromWDF
                self.destroyDiagramElements(operations,diagramElements);
            end

            self.executeDefault;


            factory.updateInCanvasStates(objects,false);


            if rebuildConnections
                self.App.connectionHandler.handleConnections(operations);
                self.App.updateObjectInContentView(classesToUpdate);
                self.App.updatePackageInContentView(classesToUpdate);
            end

            self.App.getClassBrowser.refreshView;

            self.App.inspector.refreshInspector();
        end

        function destroyDiagramElements(~,operations,diagramElements)
            for de=diagramElements
                diagramElement=de{:};
                if isempty(diagramElement)||~diagramElement.isValid
                    continue;
                end
                if regexp(diagramElement.type,"Relationship|Connection")
                    destroy=false;
                else
                    destroy=true;
                end
                operations.destroy(diagramElement,destroy);
            end
        end

        function diagramElements=obj2uuid(self,objects)
            prealloc=numel(objects);
            diagramElements=cell(1,prealloc);
            for ii=1:prealloc
                uuid=objects(ii).getDiagramElementUUID;
                if isempty(uuid)
                    continue;
                end
                diagramElement=self.syntax.findElement(uuid);
                diagramElements{ii}=diagramElement;
            end
            diagramElements(isempty(diagramElements))=[];
        end

        function[objects,diagramElements]=uuid2obj(self,uuids)
            factory=self.App.getClassDiagramFactory;
            prealloc=numel(uuids);
            diagramElements=cell(1,prealloc);
            objects=[];
            for ii=1:prealloc
                diagramElement=self.syntax.findElement(uuids{ii});
                diagramElements{ii}=diagramElement;
                objectID=diagramElement.getAttribute('ObjectID').value;
                object=factory.getObject(objectID);
                objects=[objects,object];%#ok<AGROW> 
            end
        end
    end
end
