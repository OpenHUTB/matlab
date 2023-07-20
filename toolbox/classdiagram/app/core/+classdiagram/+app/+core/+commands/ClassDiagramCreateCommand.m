classdef ClassDiagramCreateCommand<diagram.editor.Command&...
    classdiagram.app.core.commands.ClassDiagramUndoRedo
    properties(Access={
        ?diagram.editor.Command,...
        ?classdiagram.app.core.commands.ClassDiagramUndoRedo
        })
        App;
        RootDiagram;
    end

    methods(Static)

        function addPrototypes(operations,protoOps,diagram)
            import classdiagram.app.core.domain.*;
            import classdiagram.app.core.utils.Constants;

            e=operations.createEntity(diagram);
            operations.setTitle(e,'Class');
            operations.setSize(e,Constants.ClassWidth,Constants.ClassTitleHeight);
            operations.setType(e,ClassDiagramTypes.typeMap(...
            Class.ConstantType));
            protoOps.addPrototype('Class','ClassDiagram','Class',e);
        end
    end

    methods
        function cmd=ClassDiagramCreateCommand(data,syntax,app)
            cmd@diagram.editor.Command(data,syntax);
            cmd.App=app;
            cmd.RootDiagram=syntax.root;
        end

    end

    methods(Access=protected)
        function execute(obj)
            import classdiagram.app.core.domain.*;
            import classdiagram.app.core.utils.Constants.*;



            errID='diagram_editor_registry:Command:ExecCommandFailed';
            reason='Invalid command data';


            if(isempty(obj.data))
                error(errID,reason);
            end

            classType=ClassDiagramTypes.typeMap(Class.ConstantType);
            enumType=ClassDiagramTypes.typeMap(Enum.ConstantType);
            packageType=ClassDiagramTypes.typeMap(Package.ConstantType);
            folderType=Folder.ConstantType;
            projectType=Project.ConstantType;


            classes={};
            if obj.commandSource==diagram.editor.command.CommandSource.Server...
                &&isfield(obj.data,'bulkCreate')
                classes=obj.data.classes;
            elseif obj.commandSource==diagram.editor.command.CommandSource.Server...
                &&isfield(obj.data,'packageElements')
                classes=obj.data.packageElements;
            else
                switch obj.data.classType
                case packageType
                    packages={obj.data.title};
                    if~isempty(packages)
                        recurse=true;
                        if isfield(obj.data,'recurse')
                            recurse=obj.data.recurse;
                        end
                        classes=obj.App.addPackageItemsHelper(packages,recurse);
                    end
                case classType
                    classes={obj.data.title};
                case enumType
                    classes={obj.data.title};
                case folderType
                    recurse=true;
                    if isfield(obj.data,'recurse')
                        recurse=obj.data.recurse;
                    end
                    classes=obj.processFolderOrPackageInput(folderType,{obj.data.title},recurse);
                case projectType
                    recurse=true;
                    classes=obj.processFolderOrPackageInput(projectType,{obj.data.title},recurse);
                otherwise
                    self.App.notifier.processNotification(...
                    classdiagram.app.core.notifications.notifications.ErrMNotSupported(...
                    string(obj.data.classType)));
                    return;
                end
            end
            if~isfield(obj.data,'toLayout')
                obj.data.toLayout=false;
            end

            function doIt(operations)
                obj.addClassHelper(operations,classes,obj.data.position,obj.data.toLayout);
            end

            fh=@(batchOps)obj.syntax.modify(@(operations)doIt(operations));
            obj.App.executeAction(fh,Action='add');

            obj.App.inspector.refreshInspector();
        end

        function undo(obj)

            obj.undoDefault;
            obj.removeUuids;

            obj.App.inspector.refreshInspector();
            if numel(obj.ModifiedPackageElements)>0&&...
                classdiagram.app.core.feature.isOn('notifications')
                obj.App.notifier.processNotification(...
                classdiagram.app.core.notifications.notifications.NClassesRemovedInfo(...
                obj.ModifiedPackageElements),...
                lozengeType=classdiagram.app.core.notifications.LozengeType.UndoRedo);
            end
        end

        function redo(obj)

            obj.redoDefault;

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
    end

    methods(Access=private)

        function doLayout(self,operations)
            internal.diagram.layout.treelayout.layoutDiagram(self.syntax,operations);
        end

        function classes=enforceBlockLimit(self,classes)
            if isempty(classes)
                return;
            end
            namesExist=self.App.getAllDiagramEntityNames;
            countExists=numel(namesExist);
            maxAdd=self.App.maxPackageElements-countExists;
            if(maxAdd<1)
                classes=[];
                return;
            end
            namesToAdd=arrayfun(@(c){char(c.getName)},classes);
            uniqueToAdd=unique(setdiff(namesToAdd,namesExist));
            countRequested=numel(uniqueToAdd);
            if(countRequested>maxAdd)


                uniqueToAdd(maxAdd+1:end)=[];
                factory=self.App.getClassDiagramFactory;


                classes=cellfun(@(n){factory.getPackageElement(n)},uniqueToAdd);
                classes=[classes{:}];
            end
        end

        function classentity=addClassHelper(self,operations,data,position,toLayout)

            import classdiagram.app.core.domain.*;

            factory=self.App.getClassDiagramFactory;
            creator=classdiagram.app.core.ElementCreator(self.App,self.UuidToObjectMap);
            len=numel(data);
            classentity=[];
            positions=zeros(len,2);
            if isa(data,'PackageElement')
                idx=arrayfun(@(c)c.getState==ElementState.Normal,data);
                classes=data(idx);
            else
                classes=PackageElement.empty(0,len);
                if~isempty(fieldnames(position))
                    x=[position.x];
                    y=[position.y];
                end
                for ii=1:numel(data)
                    className=data{ii};
                    if~isempty(fieldnames(position))
                        positions(ii,:)=[x(ii),y(ii)];
                    end
                    class=factory.getPackageElement(className);











                    if isempty(class)||class.getState~=ElementState.Normal
                        if~classdiagram.app.core.feature.isOn('notifications')
                            self.App.notifier.processNotification(...
                            'ErrMInvalidMCOSObject',className);
                        else
                            if isempty(class)||isempty(class.getDiagramElementUUID)




                                notifObj=...
                                classdiagram.app.core.notifications.notifications.ErrMInvalidMCOSObject(className);
                            else


                                notifObj=...
                                classdiagram.app.core.notifications.notifications.OutOfSyncClass(class);
                            end
                            self.App.notifier.processNotification(notifObj);
                        end
                        continue;
                    end
                    classes(ii)=class;
                end
            end

            skipConnections=string.empty;
            requestedClasses=PackageElement.empty;
            requestedPositions=zeros(0,2);
            for ii=1:length(classes)
                class=classes(ii);

                if class.isHidden
                    skipConnections(end+1)=class.getName;
                    continue;
                end
                if~self.App.ShowEntity(class)
                    continue;
                end
                requestedClasses(end+1)=class;
                requestedPositions(end+1,:)=positions(ii,:);
            end


            if~isempty(skipConnections)
                if numel(skipConnections)==1
                    self.App.notifier.processNotification('ErrMHiddenMCOSObject',skipConnections);
                else
                    self.App.notifier.processNotification('ErrMHiddenMCOSObjects',skipConnections.join(", "));
                end
            end

            existingClasses=self.App.getAllDiagramEntityNames;
            classes=self.enforceBlockLimit(requestedClasses);

            self.ModifiedPackageElements=PackageElement.empty;
            for ii=1:numel(classes)
                class=classes(ii);
                if isempty(class.getDiagramElementUUID())
                    position=requestedPositions(ii,:);
                    classentity=creator.createDiagramEntityForPackageElement(operations,class,self.RootDiagram);
                    if~isempty(position)

                        operations.setPosition(classentity,position(1),position(2));
                    end

                    self.ModifiedPackageElements(end+1)=class;
                end
                factory.updatePackageInDiagramCache(class,true);
            end

            self.App.connectionHandler.handleConnections(operations);
            if toLayout
                self.App.doLayout(operations);
            end
            self.App.updateObjectInContentView(classes);
            self.App.updatePackageInContentView(classes);


            factory.updateInCanvasStates(classes,true);

            self.App.getClassBrowser.refreshView;

            self.notifyOfResults(numel(classes),requestedClasses,existingClasses);
        end

        function classes=processFolderOrPackageInput(self,type,namesOrPaths,recurse)
            classes=[];
            if isempty(namesOrPaths)
                return;
            end
            factory=self.App.getClassDiagramFactory;
            if strcmp(type,classdiagram.app.core.domain.Folder.ConstantType)
                folders=factory.getFolders(namesOrPaths);
            else
                folders=factory.getProjects(namesOrPaths);
            end
            classes=arrayfun(@(pf)factory.getFolderOrProjectClasses(pf,recurse),...
            folders,'uni',0);
            classes=[classes{:}];
            if isempty(classes)
                self.App.notifier.processNotification(...
                classdiagram.app.core.notifications.notifications.WDFNotification(...
                "classdiagram_editor:messages:CFBClassesNotFound",...
                Target=struct(Diagram="Diagram"),...
                OutputMode=["on","off"],...
                Severity=classdiagram.app.core.notifications.Severity.Info));
            end
        end

        function notifyOfResults(self,classesCnt,requestedClasses,existingClasses)






            if self.commandSource==diagram.editor.command.CommandSource.Client
                self.App.notifier.setMode(...
                classdiagram.app.core.notifications.Mode.UI);
                self.App.notifier.unsetMode(...
                classdiagram.app.core.notifications.Mode.CL);
            elseif~self.App.notifier.isInUIMode
                self.App.notifier.setMode(...
                classdiagram.app.core.notifications.Mode.CL);
            end

            countRequested=length(requestedClasses);
            if classesCnt==countRequested
                if countRequested>0&&...
                    classdiagram.app.core.feature.isOn('notifications')
                    self.App.notifier.processNotification(...
                    classdiagram.app.core.notifications.notifications.NClassesAddedInfo(...
                    requestedClasses,existingClasses));
                end
            else
                maxAdd=self.App.maxPackageElements-numel(existingClasses);
                if maxAdd<1
                    if classdiagram.app.core.feature.isOn('notifications')
                        self.App.notifier.processNotification(...
                        classdiagram.app.core.notifications.notifications.BlockLimitReachedInfo(...
                        self.App.maxPackageElements));
                    else
                        self.App.notifier.processNotification('InfoBlockLimitReached','',...
                        string(self.App.maxPackageElements));
                    end
                else
                    if classdiagram.app.core.feature.isOn('notifications')
                        self.App.notifier.processNotification(...
                        classdiagram.app.core.notifications.notifications.BlockLimitSurpassedWarn(...
                        string(maxAdd),string(countRequested),string(self.App.maxPackageElements)));
                    else
                        self.App.notifier.processNotification('InfoBlockLimitReached1','',...
                        {string(maxAdd),string(countRequested),string(self.App.maxPackageElements)});
                    end
                end
            end

            if self.commandSource==diagram.editor.command.CommandSource.Client

                self.App.notifier.resetMode();
            end
        end
    end
end
