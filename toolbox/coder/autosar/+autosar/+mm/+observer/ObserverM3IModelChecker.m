classdef ObserverM3IModelChecker<autosar.mm.observer.Observer




    properties(SetAccess=immutable,GetAccess=private)
        M3IModel;
    end

    methods

        function this=ObserverM3IModelChecker(m3iModel)
            this.M3IModel=m3iModel;
        end

        function observeChanges(this,changesReport)
            this.observeAdded(changesReport);
        end
    end

    methods(Access=private)

        function observeAdded(this,changesReport)


            added=changesReport.getAdded();



            if Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels(this.M3IModel)
                for ii=1:added.size
                    m3iObj=added.at(ii);
                    if m3iObj.isvalid()&&...
                        isa(m3iObj,'Simulink.metamodel.foundation.PackageableElement')&&...
                        ~isa(m3iObj,'Simulink.metamodel.arplatform.component.Component')&&...
                        (m3iObj.rootModel==this.M3IModel)
                        assert(false,'Element %s should have been added to the shared m3iModel instead of Simulink model m3iModel.',...
                        autosar.api.Utils.getQualifiedName(m3iObj));
                    end
                end
            end
        end
    end
end


