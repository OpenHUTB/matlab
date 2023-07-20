classdef ConcatenationCompBuilder<dltargets.internal.compbuilder.CustomCompBuilder




    properties(Constant,Access=private)

        compKey='gpucoder.concatenation_layer_comp';


        compKind='customlayer';


        cppClassName='MWConcatenationLayer';


        createMethodName='createConcatenationLayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.ConcatenationCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.ConcatenationCompBuilder.compKind;
        end

        function cppClassName=getCppClassName(varargin)
            cppClassName=dltargets.internal.compbuilder.ConcatenationCompBuilder.cppClassName;
        end

        function createMethodName=getCreateMethodName()
            createMethodName=dltargets.internal.compbuilder.ConcatenationCompBuilder.createMethodName;
        end

        function comp=convert(layer,converter,comp)

            comp=dltargets.internal.compbuilder.CustomCompBuilder.setCommonCustomLayerProperties(layer,converter,comp);

            comp.setIsVariadicIns(true);

            layerInfo=converter.getLayerInfo(layer.Name);

            concatenationDimLabel=layerInfo.outputFormats{1}(layer.Dim);



            switch concatenationDimLabel
            case 'S'
                assert((layer.Dim==1)||(layer.Dim==2),...
                'dlcoder_spkg:cnncodegen:DLCoderInternalError');
                dimension=layer.Dim;
            case 'C'
                dimension=3;
            case 'B'
                dimension=4;
            case 'T'
                dimension=5;
            otherwise
                error(message('dlcoder_spkg:cnncodegen:DLCoderInternalError'));
            end

            comp.addCreateMethodArg(int32(dimension));
        end

        function validate(layer,validator)


            unsupportedTargets={'arm-compute-mali','cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'Dim',layer.Dim,...
            'NumInputs',layer.NumInputs);
        end
    end
end
