classdef SSDMergeCompBuilder<dltargets.internal.compbuilder.CustomCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.ssdMergeLayer';


        compKind='customlayer';


        cppClassName='MWSSDMergeLayer';


        createMethodName='createSSDMergeLayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.SSDMergeCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.SSDMergeCompBuilder.compKind;
        end

        function cppClassName=getCppClassName(varargin)
            cppClassName=dltargets.internal.compbuilder.SSDMergeCompBuilder.cppClassName;
        end

        function createMethodName=getCreateMethodName()
            createMethodName=dltargets.internal.compbuilder.SSDMergeCompBuilder.createMethodName;
        end

        function validate(layer,validator)
            unsupportedTargets={'arm-compute-mali','cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);


            coder.internal.layer.ssdMergeUtils.isValidSsdMergeLayer(layer,validator);
        end

        function comp=convert(layer,converter,comp)

            comp=dltargets.internal.compbuilder.CustomCompBuilder.setCommonCustomLayerProperties(layer,converter,comp);

            comp.setIsVariadicIns(true);

            comp.addCreateMethodArg(int32(layer.NumChannels));

            comp.setIsScaleInvariant(true);
        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'NumChannels',layer.NumChannels,...
            'NumInputs',layer.NumInputs);
        end
    end
end
