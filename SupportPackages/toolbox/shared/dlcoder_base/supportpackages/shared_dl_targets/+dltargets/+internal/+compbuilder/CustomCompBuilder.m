classdef CustomCompBuilder<dltargets.internal.compbuilder.CodegenCompBuilder




    methods(Static,Access=protected)

        function comp=setCommonCustomLayerProperties(layer,converter,comp)
            compBuilderName=dltargets.internal.compbuilder.CodegenCompBuilder.getCompBuilderName(layer,converter);

            getCppClassNameMethod=[compBuilderName,'.','getCppClassName'];
            comp.setLayerClassName(feval(getCppClassNameMethod,layer,converter));

            getCreateMethodNameMethod=[compBuilderName,'.','getCreateMethodName'];
            comp.setLayerCreateMethod(feval(getCreateMethodNameMethod));
        end
    end
end
