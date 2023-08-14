classdef ELUCompBuilder<dltargets.internal.compbuilder.CustomCompBuilder




    properties(Constant,Access=private)

        compKey='MWELULayer';


        compKind='customlayer';


        cppClassName='MWELULayer';


        createMethodName='createELULayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(varargin)
            compKey=dltargets.internal.compbuilder.ELUCompBuilder.compKey;
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.ELUCompBuilder.compKind;
        end

        function cppClassName=getCppClassName(varargin)
            cppClassName=dltargets.internal.compbuilder.ELUCompBuilder.cppClassName;
        end

        function createMethodName=getCreateMethodName()
            createMethodName=dltargets.internal.compbuilder.ELUCompBuilder.createMethodName;
        end

        function validate(layer,validator)


            unsupportedTargets={'arm-compute-mali','cmsis-nn'};
            dltargets.internal.utils.checkLayerSupportForTarget(layer,validator,unsupportedTargets);

        end

        function comp=convert(layer,converter,comp)
            comp=dltargets.internal.compbuilder.CustomCompBuilder.setCommonCustomLayerProperties(layer,converter,comp);
            comp.setInplaceIndex(0,0);

            comp.addCreateMethodArg(double(layer.Alpha));
        end

        function aStruct=toStruct(layer)

            aStruct=struct('Class',class(layer),'Name',layer.Name,'Alpha',layer.Alpha);
        end
    end
end
