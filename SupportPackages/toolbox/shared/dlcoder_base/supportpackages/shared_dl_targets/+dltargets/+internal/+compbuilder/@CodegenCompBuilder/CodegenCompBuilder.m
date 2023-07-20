classdef CodegenCompBuilder




    properties(Constant,Access=public)




        layerToBuilderMap=dltargets.internal.compbuilder.CodegenCompBuilder.populateLayerToBuilderMap();
    end

    methods(Abstract)
        compKey=getCompKey(varargin)

        compKind=getCompKind()
    end

    methods(Static,Access=public)

        function doValidate(layer,validator)

            [builderName,builderFound]=dltargets.internal.compbuilder.CodegenCompBuilder.getCompBuilderName(layer,validator);
            if builderFound
                validateMethodName='validate';
                if(coder.internal.hasPublicStaticMethod(builderName,validateMethodName))
                    validateMethodQualifiedName=[builderName,'.',validateMethodName];
                    validateMethod=str2func(validateMethodQualifiedName);
                    validateMethod(layer,validator);
                end
            else

                layerType=class(layer);
                str=dltargets.internal.compbuilder.CodegenCompBuilder.getLayerName(layer,layerType);
                errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_layer',str,validator.getTargetLib());
                validator.handleError(layer,errorMessage);
            end
        end



        function doConvert(layer,converter)


            comp=dltargets.internal.compbuilder.CodegenCompBuilder.createLayerComp(layer,converter);




            [builderName,builderFound]=dltargets.internal.compbuilder.CodegenCompBuilder.getCompBuilderName(layer,converter);
            assert(builderFound);
            assert(exist(builderName,'class'));
            convertMethodName='convert';
            if(coder.internal.hasPublicStaticMethod(builderName,convertMethodName))
                convertMethodQualifiedName=[builderName,'.',convertMethodName];
                comp=feval(convertMethodQualifiedName,layer,converter,comp);
            end






            comp=dltargets.internal.compbuilder.CodegenCompBuilder.setCommonCompProperties(layer,converter,comp);



            dltargets.internal.compbuilder.CodegenCompBuilder.validateCompKey(layer,converter,comp);
            converter.layerToCompMap(layer.Name)=comp;
        end

        function doSaveFiles(layer,fileSaver)
            [builderName,builderFound]=dltargets.internal.compbuilder.CodegenCompBuilder.getCompBuilderName(layer,fileSaver);
            assert(builderFound);
            assert(exist(builderName,'class'));
            saveFilesMethodName='saveFiles';
            if(coder.internal.hasPublicStaticMethod(builderName,saveFilesMethodName))
                saveFileMethodQualifiedName=[builderName,'.',saveFilesMethodName];
                feval(saveFileMethodQualifiedName,layer,fileSaver);
            end
        end

        function aStruct=doSerialize(layer,fileSaver)
            compBuilderName=dltargets.internal.compbuilder.CodegenCompBuilder.getCompBuilderName(layer,fileSaver);
            assert(exist(compBuilderName,'class'));
            toStructMethodName='toStruct';
            if(coder.internal.hasPublicStaticMethod(compBuilderName,toStructMethodName))
                toStructMethodQualifiedName=[compBuilderName,'.',toStructMethodName];
                aStruct=feval(toStructMethodQualifiedName,layer);
            else
                aStruct=struct('Class',class(layer),'Name',layer.Name);
            end
        end

        comp=addComponentToNetwork(pirNetwork,compKind,layerName)

        layerName=getLayerName(layer,layerType)
    end

    methods(Static,Access=protected)
        comp=createLayerComp(layer,converter)



        [builderName,builderFound]=getCompBuilderName(layer,routineObject)
    end

    methods(Static,Sealed,Access=private)


        layerToBuilderMap=populateLayerToBuilderMap()




        [builder,builderFound]=getCompBuilder(layer,routineObject)

        comp=setCommonCompProperties(layer,converter,comp)

        validateCompKey(layer,converter,comp)
    end
end
