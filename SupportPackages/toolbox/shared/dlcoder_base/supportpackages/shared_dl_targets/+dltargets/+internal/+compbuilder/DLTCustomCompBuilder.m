classdef DLTCustomCompBuilder<dltargets.internal.compbuilder.CustomCompBuilder




    properties(Constant,Access=private)

        compKind='DLTCustomLayer';


        createMethodName='createCustomLayer';
    end

    methods(Static,Access=public)

        function compKey=getCompKey(layer)
            compKey=dltargets.internal.getCustomLayerCompKey(layer);
        end

        function compKind=getCompKind()
            compKind=dltargets.internal.compbuilder.DLTCustomCompBuilder.compKind;
        end


        function cppClassName=getCppClassName(layer,converter)
            cppClassName=dltargets.internal.getCustomLayerClassName(layer);
            cppClassName=['MW',upper(cppClassName(1)),cppClassName(2:end),'_',converter.netClassName];

            if isKey(converter.customLayerClassMap,cppClassName)
                converter.customLayerClassMap(cppClassName)=converter.customLayerClassMap(cppClassName)+1;
                cppClassName=[cppClassName,num2str(converter.customLayerClassMap(cppClassName))];
            else
                converter.customLayerClassMap(cppClassName)=1;
                cppClassName=[cppClassName,num2str(1)];
            end
        end

        function createMethodName=getCreateMethodName()
            createMethodName=dltargets.internal.compbuilder.DLTCustomCompBuilder.createMethodName;
        end

        function comp=convert(layer,converter,comp)
            comp=dltargets.internal.compbuilder.CustomCompBuilder.setCommonCustomLayerProperties(layer,converter,comp);


            createMethodArgs=converter.getCreateMethodArgs(layer.Name);
            numArgs=size(createMethodArgs,2);
            for iArg=1:numArgs
                comp.addCreateMethodArg(createMethodArgs{iArg}{1});
                comp.addCreateMethodArgName(createMethodArgs{iArg}{2});
            end

            layerInfo=converter.getLayerInfo(layer.Name);
            comp.setHasSequenceOutputs(layerInfo.hasSequenceOutput);

            internalLayer=layer.getInternalLayers(layer);
            learnableNames=internalLayer{1}.ExternalLearnablesNames;
            for iLearnables=1:numel(learnableNames)
                comp.addLearnable(convertStringsToChars(learnableNames{iLearnables}));
            end
        end

        function validate(layer,validator)



            supportedTargets=["cudnn","mkldnn","onednn","tensorrt","arm-compute"];
            if~(any(strcmpi(validator.getTargetLib(),supportedTargets)))
                layerType=class(layer);
                str=dltargets.internal.compbuilder.CodegenCompBuilder.getLayerName(layer,layerType);
                errorMessage=message('dlcoder_spkg:cnncodegen:unsupported_layer',str,validator.getTargetLib());
                validator.handleError(layer,errorMessage);
            end


            layerType=class(layer);
            supportedTargetsWithBufferReuseOff="tensorrt";
            if~validator.dlcfg.OptimizationConfig.BufferReuseFlag&&~any(strcmpi(validator.getTargetLib(),...
                supportedTargetsWithBufferReuseOff))
                str=dltargets.internal.compbuilder.CodegenCompBuilder.getLayerName(layer,layerType);
                errorMessage=message('dlcoder_spkg:cnncodegen:BufferReuseOffNotSupported',str);
                validator.handleError(layer,errorMessage);
            end


            layerInfo=validator.getLayerInfo(layer.Name);
            if any(layerInfo.hasSequenceInput)&&~dlcoderfeature('GenerateCustomLayersInRNN')
                str=dltargets.internal.compbuilder.CodegenCompBuilder.getLayerName(layer,layerType);
                errorMessage=message('dlcoder_spkg:cnncodegen:UnsupportedLayerRNN',str,validator.getTargetLib());
                validator.handleError(layer,errorMessage);
            end


            if validator.isCnnCodegenWorkflow
                errorMessage=message('dlcoder_spkg:cnncodegen:CnnCodegenNotSupportedForCustomLayers');
                validator.handleError(layer,errorMessage);
            end


            dltargets.internal.checkIfSupportedCustomLayer(layer,validator);
        end

        function saveFiles(layer,fileSaver)
            assert(dltargets.internal.checkIfCustomLayer(layer));


            [customClassPropertyNames,customClassPropertyNamesInIR,isLearnableProperty]=...
            dltargets.internal.compbuilder.DLTCustomCompBuilder.getCustomLayerSpecificProperties(layer);


            numProperties=numel(customClassPropertyNames);
            propertiesOnDiskFileNames={};
            createMethodArgs=cell(1,numProperties);

            argCount=1;
            for iProp=1:numProperties
                paramVal=layer.(customClassPropertyNames{iProp});








                if isLearnableProperty(iProp)
                    iSavePropetiesOnDisk();
                else
                    if isnumeric(paramVal)||islogical(paramVal)
                        if isscalar(paramVal)
                            createMethodParamArgVals=paramVal;
                        elseif isa(paramVal,'double')||isa(paramVal,'single')





                            if isa(paramVal,'double')&&numel(paramVal)<=10

                                isRowMajorLayer=any(strcmp(layer.Name,fileSaver.getRowMajorCustomLayerNames));
                                if isRowMajorLayer
                                    createMethodParamArgVals=...
                                    dltargets.internal.permuteHyperParameters(paramVal,...
                                    'ColmajorToRowmajorInterleaved');
                                else
                                    createMethodParamArgVals=paramVal;
                                end
                            else

                                iSavePropetiesOnDisk();
                            end
                        end
                    elseif ischar(paramVal)||(iscell(paramVal)&&all(cellfun(@ischar,paramVal)))

                        createMethodParamArgVals=paramVal;
                    elseif isstring(paramVal)
                        createMethodParamArgVals=convertStringsToChars(paramVal);



                    end
                end

                createMethodArgs{iProp}={createMethodParamArgVals;customClassPropertyNamesInIR{iProp}};
                argCount=argCount+1;
            end

            fileSaver.setParameterFileNamesMap(layer.Name,propertiesOnDiskFileNames);
            fileSaver.setCreateMethodArgsMap(layer.Name,createMethodArgs);

            function iSavePropetiesOnDisk()
                paramsFile=strcat(fileSaver.getFilePrefix,layer.Name,'_p_',num2str(argCount),'.bin');
                propertiesOnDiskFileNames{end+1}=dltargets.internal.utils.LayerToCompUtils.getCompFileName(...
                paramsFile,fileSaver.getParameterDirectory,fileSaver.getCodegenTarget);
                createMethodParamArgVals=propertiesOnDiskFileNames{end};

                isRowMajorLayer=any(strcmp(layer.Name,fileSaver.getRowMajorCustomLayerNames));
                if isRowMajorLayer
                    paramVal=dltargets.internal.permuteHyperParameters(paramVal,'ColmajorToRowmajorInterleaved');
                end
                dltargets.internal.utils.SaveLayerFilesUtils.saveOneFile(...
                fileSaver.getParameterDirectory,fileSaver.getCodegenTarget,class(paramVal),propertiesOnDiskFileNames{end},paramVal);
            end
        end

        function aStruct=toStruct(layer)



            [customClassPropertyNames,~,isLearnableProperty]=...
            dltargets.internal.compbuilder.DLTCustomCompBuilder.getCustomLayerSpecificProperties(layer);

            aStruct=struct('Class',class(layer));
            for iProp=1:numel(customClassPropertyNames)
                if~isLearnableProperty(iProp)
                    aStruct.(customClassPropertyNames{iProp})=layer.(customClassPropertyNames{iProp});
                end
            end
        end
    end

    methods(Static,Access=private)
        function[customClassPropertyNames,customClassPropertyNamesInIR,isLearnableProperty]=getCustomLayerSpecificProperties(layer)














            metaClassData=metaclass(layer);
            metaClassProperties=metaClassData.PropertyList;





            unaccessiblePropertiesIdx=arrayfun(@(x)strcmpi(x.GetAccess,"private")||strcmpi(x.GetAccess,"protected"),metaClassProperties);
            metaClassProperties(unaccessiblePropertiesIdx)=[];



            if any(arrayfun(@(prop)any(strcmpi(prop.Name,{'NumInputs','NumOutputs',...
                'InputNames','OutputNames'})),metaClassProperties))
                additionalBaseClassPropsInIR={'PrivateInputs','PrivateOutputs'};
                additionalBaseClassProps={'InputNames','OutputNames'};
            else
                additionalBaseClassPropsInIR=[];
                additionalBaseClassProps=[];
            end





            constantPropertiesIdx=[metaClassProperties.Constant];
            dependentPropertiesIdx=[metaClassProperties.Dependent];
            emptyPropertiesIdx=arrayfun(@(prop)isempty(layer.(prop.Name)),metaClassProperties);
            metaClassProperties(constantPropertiesIdx|dependentPropertiesIdx|emptyPropertiesIdx')=[];


            isLearnableProperty=arrayfun(@iIsLearnable,metaClassProperties);



            customClassPropertyNames=cell(1,numel(metaClassProperties));
            [customClassPropertyNames{:}]=metaClassProperties.Name;

            customClassPropertyNamesInIR=[customClassPropertyNames,additionalBaseClassPropsInIR];
            customClassPropertyNames=[customClassPropertyNames,additionalBaseClassProps];
            isLearnableProperty=[isLearnableProperty;zeros(numel(additionalBaseClassProps),1)];

        end
    end
end

function tf=iIsLearnable(prop)
    tf=isprop(prop,'Learnable')&&prop.Learnable;
end
