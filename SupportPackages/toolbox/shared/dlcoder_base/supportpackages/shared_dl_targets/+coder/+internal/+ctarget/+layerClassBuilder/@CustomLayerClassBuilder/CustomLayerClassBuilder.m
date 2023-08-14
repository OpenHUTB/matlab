classdef CustomLayerClassBuilder




    properties(Constant,Access=public)






        LayerToBuilderMap=coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.populateLayerToBuilderMap();


        LayerCompToBuilderMap=...
        coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.populateLayerCompToBuilderMap();


        PrototypedLayerToBuilderMap=...
        coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.populatePrototypedLayerToBuilderMap();
    end

    methods(Static,Access=public)

        function doValidate(layer,validator)

            [builderName,builderFound]=...
            coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.getCustomLayerClassBuilderName(layer,validator);

            if builderFound
                assert(exist(builderName,'class'));
                validateMethodName='validate';
                if(coder.internal.hasPublicStaticMethod(builderName,validateMethodName))
                    validateMethodQualifiedName=[builderName,'.',validateMethodName];
                    validateMethod=str2func(validateMethodQualifiedName);
                    validateMethod(layer,validator);
                end
            else

                layerType=class(layer);
                str=coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.getLayerName(layer,layerType);
                errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_layer',str,validator.getTargetLib());
                validator.handleError(layer,errorMessage);
            end
        end



        function customLayer=doConvert(layerComp,converter)



            [builderName,builderFound]=...
            coder.internal.ctarget.layerClassBuilder.CustomLayerClassBuilder.getCustomLayerCompClassBuilderName(...
            layerComp,converter);
            assert(builderFound);
            assert(exist(builderName,'class'));
            convertMethodName='convert';
            assert(coder.internal.hasPublicStaticMethod(builderName,convertMethodName));
            convertMethodQualifiedName=[builderName,'.',convertMethodName];
            customLayer=feval(convertMethodQualifiedName,layerComp,converter);
        end

    end

    methods(Static,Access=protected)
        layerName=getLayerName(layer,layerType)



        [builderName,builderFound]=getCustomLayerClassBuilderName(layer,routineObject)



        [builderName,builderFound]=getCustomLayerCompClassBuilderName(layerComp,layer,routineObject)
    end

    methods(Static,Sealed,Access=private)
        [builder,builderFound]=getCustomLayerClassBuilder(layer,routineObject)
        [builder,builderFound]=getCustomLayerCompClassBuilder(layerComp,layer,routineObject)
    end

    methods(Static,Sealed)


        layerToBuilderMap=populateLayerToBuilderMap()



        layerToBuilderMap=populateLayerCompToBuilderMap()



        layerToBuilderMap=populatePrototypedLayerToBuilderMap()
    end
end
