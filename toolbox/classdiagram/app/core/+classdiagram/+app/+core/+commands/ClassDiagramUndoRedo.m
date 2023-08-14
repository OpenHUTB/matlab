classdef ClassDiagramUndoRedo<handle
    properties
        ModifiedPackageElements;
        UuidToObjectMap;
    end

    properties(Constant)
        Constants=classdiagram.app.core.utils.Constants;
    end

    methods
        function obj=ClassDiagramUndoRedo()
            obj.UuidToObjectMap=containers.Map;
        end

        function setUuids(self)
            factory=self.App.getClassDiagramFactory;

            uuids=keys(self.UuidToObjectMap);
            for ii=1:numel(uuids)
                uuid=uuids{ii};
                domainObj=self.UuidToObjectMap(uuid);
                domainObj.setDiagramElementUUID(uuid);

                if isa(domainObj,'classdiagram.app.core.domain.PackageElement')
                    factory.updatePackageInDiagramCache(domainObj,true);
                end
            end

            factory.updateInCanvasStates(self.ModifiedPackageElements,true);

            self.App.updateObjectInContentView(self.ModifiedPackageElements);
            self.App.getClassBrowser.refreshView;
        end

        function removeUuids(self)
            factory=self.App.getClassDiagramFactory;
            deletionVisitor=classdiagram.app.core.visitors.DeleteObjectVisitor(factory);
            for ipe=1:numel(self.ModifiedPackageElements)
                pe=self.ModifiedPackageElements(ipe);


                pe.accept(deletionVisitor);
            end

            factory.updateInCanvasStates(self.ModifiedPackageElements,false);

            self.App.updateObjectInContentView(self.ModifiedPackageElements);
            self.App.getClassBrowser.refreshView;
        end
    end
end
