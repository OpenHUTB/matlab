classdef FlattenCStyleCompBuilder<dltargets.internal.compbuilder.CustomCompBuilder




    properties(Constant,Access=private)

        compKey='MWFlattenCStyleLayer';


        compKind='customlayer';


        cppClassName='MWFlattenCStyleLayer';


        createMethodName='createFlattenCStyleLayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.FlattenCStyleCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.FlattenCStyleCompBuilder.compKind;
        end

        function cppClassName=getCppClassName(varargin)
            cppClassName=dltargets.internal.compbuilder.FlattenCStyleCompBuilder.cppClassName;
        end

        function createMethodName=getCreateMethodName()
            createMethodName=dltargets.internal.compbuilder.FlattenCStyleCompBuilder.createMethodName;
        end

        function validate(layer,validator)


            layerInfo=validator.getLayerInfo(layer.Name);
            layerInputFormats=layerInfo.inputFormats;
            if~any(strcmp(layerInputFormats,["SSC","SSCB"]))
                errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_flattencstyle_input',layer.Name,layerInputFormats{1});
                validator.handleError(layer,errorMessage);
            end

            unsupportedTargets={'cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

        end

        function comp=convert(layer,converter,comp)

            comp=dltargets.internal.compbuilder.CustomCompBuilder.setCommonCustomLayerProperties(layer,converter,comp);

            comp.setIsScaleInvariant(true);
        end
    end
end
