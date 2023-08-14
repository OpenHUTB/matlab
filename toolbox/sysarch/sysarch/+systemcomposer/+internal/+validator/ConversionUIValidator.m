classdef ConversionUIValidator<handle









    properties
        handleOrPath;
    end

    methods
        function this=ConversionUIValidator(handleOrPath)
            this.handleOrPath=handleOrPath;
        end


    end

    methods(Static)
        function[canConvert,componentBlockType]=canAddVariant(handleOrPath)


            componentBlockType=systemcomposer.internal.validator.getComponentBlockType(handleOrPath);
            canConvert=componentBlockType.canAddVariant();
        end

        function[canConvert,componentBlockType]=canCreateSimulinkBehavior(handleOrPath)


            componentBlockType=systemcomposer.internal.validator.getComponentBlockType(handleOrPath);
            canConvert=componentBlockType.canCreateSimulinkBehavior();
        end

        function[canConvert,componentBlockType,allowed]=canCreateStateflowBehavior(handleOrPath)


            componentBlockType=systemcomposer.internal.validator.getComponentBlockType(handleOrPath);
            [canConvert,allowed]=componentBlockType.canCreateStateflowBehavior();
        end

        function[canConvert,componentBlockType]=canLinkToModel(handleOrPath)


            componentBlockType=systemcomposer.internal.validator.getComponentBlockType(handleOrPath);
            canConvert=componentBlockType.canLinkToModel();
        end

        function[canConvert,componentBlockType]=canSaveAsArchitecture(handleOrPath)


            componentBlockType=systemcomposer.internal.validator.getComponentBlockType(handleOrPath);
            canConvert=componentBlockType.canSaveAsArchitecture();
        end

        function[canConvert,componentBlockType]=canSaveAsSoftwareArchitecture(handleOrPath)


            componentBlockType=systemcomposer.internal.validator.getComponentBlockType(handleOrPath);
            canConvert=componentBlockType.canSaveAsSoftwareArchitecture();
        end

        function[canConvert,componentBlockType,isReference,isBehavior]=canInline(handleOrPath)


            [componentBlockType,~,isReference,isBehavior]=...
            systemcomposer.internal.validator.getComponentBlockType(handleOrPath);
            canConvert=componentBlockType.canInline();
        end
    end
end
