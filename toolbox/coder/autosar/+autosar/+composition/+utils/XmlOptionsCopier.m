classdef XmlOptionsCopier<handle





    methods(Static)
        function copyXmlOptionsAndSetToInherit(srcM3IModel,targetM3IModel)

            autosar.updater.copyXmlOptions(srcM3IModel,targetM3IModel);


            targetARRoot=targetM3IModel.RootPackage.front();
            targetARRoot.ArxmlFilePackaging=Simulink.metamodel.arplatform.common.ArxmlFilePackagingKind.Modular;
            autosar.mm.util.XmlOptionsAdapter.set(targetARRoot,'XmlOptionsSource','Inherit');
        end
    end
end


