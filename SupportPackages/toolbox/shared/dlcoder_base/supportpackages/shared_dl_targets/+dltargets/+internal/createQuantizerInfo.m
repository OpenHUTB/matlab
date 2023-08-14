









function quantizationSpec=createQuantizerInfo(networkInfo,dlcfg)





    int8SupportedTargets=dltargets.internal.getTargetsSupportedForINT8();
    isInt8Supported=any(strcmpi(dlcfg.TargetLibrary,int8SupportedTargets));




    if~isempty(networkInfo.LayerExecutionSpecification)&&...
        ~isInt8Supported

        error(message('dlcoder_spkg:ReducedPrecisionCodegen:InvalidTargetLibrary',dlcfg.TargetLibrary,strjoin(int8SupportedTargets,', ')));
    end




    if(~isempty(networkInfo.LayerExecutionSpecification)&&isInt8Supported)&&...
        (isprop(dlcfg,'CalibrationResultFile')&&~isempty(dlcfg.CalibrationResultFile))

        error(message('dlcoder_spkg:ReducedPrecisionCodegen:InvalidINT8Workflow'));

    end


    if~isempty(networkInfo.LayerExecutionSpecification)


        quantizationSpec=struct('exponentsData',struct([]),'skipLayers',...
        networkInfo.getSkipLayersForQuantization,'quantizedDLNetwork',true);
    elseif isInt8Supported&&(isprop(dlcfg,'DataType')&&strcmpi(dlcfg.DataType,'int8'))&&...
        isprop(dlcfg,'CalibrationResultFile')

        dlquantObj=getdlquantizerObject(dlcfg.CalibrationResultFile,networkInfo);


        dlquantizerContext.instrumentationData=dlquantObj.CalibrationStatistics;


        if isempty(dlquantObj.SkipLayers)
            dlquantizerContext.skipLayers={''};
        else
            dlquantizerContext.skipLayers=dlquantObj.SkipLayers;
        end


        dlquantizerContext.exponentScheme=dlquantObj.ExponentScheme;






        dlquantizerContext.hasGenericCalibrationStatistics=dlquantObj.HasDecoupledCalibrationFusionRecord;

        networkInfo.setDLQuantizerContext(dlquantizerContext)

        specBuilder=dltargets.internal.quantization.getSpecificationBuilder(networkInfo,GenerateExponents=false);
        quantizationSpec=specBuilder.build();

    else
        quantizationSpec=struct('exponentsData',struct([]),'skipLayers',{{''}},'quantizedDLNetwork',false);
    end

end

function dlquantizerObj=getdlquantizerObject(calibrationResultMatFile,networkInfo)






    dlquantizerObj=[];

    calibrationResult=load(calibrationResultMatFile);
    fieldNames=fieldnames(calibrationResult);

    for i=1:numel(fieldNames)
        fieldValue=calibrationResult.(fieldNames{i});
        if isa(fieldValue,'dlquantizer')
            dlquantizerObj=fieldValue;
            break;
        end
    end



    validateNetworkObjects(dlquantizerObj,networkInfo);

end


function validateNetworkObjects(dlquantizerObj,networkInfo)

    if isa(dlquantizerObj.Net,'dlnetwork')&&~dlcoderfeature('EnableINT8ForDLNetwork')
        error(message('dlcoder_spkg:ReducedPrecisionCodegen:DLNetworkIsNotSupportedForINT8Workflow'));
    end



    dlquantNetLayerGraph=dltargets.internal.getSortedLayerGraph(dlquantizerObj.Net);

    for i=1:numel(networkInfo.SortedLayerGraph.Layers)


        if~(strcmp(dlquantNetLayerGraph.Layers(i).Name,networkInfo.SortedLayerGraph.Layers(i).Name))
            error(message('dlcoder_spkg:cnncodegen:IncorrectNetworkObject'));
        end


        expectedlayerProp=properties(dlquantNetLayerGraph.Layers(i));
        actuallayerProp=properties(networkInfo.SortedLayerGraph.Layers(i));

        for k=1:numel(expectedlayerProp)
            expectedPropValue=dlquantNetLayerGraph.Layers(i).(expectedlayerProp{k});
            if isnumeric(expectedPropValue)
                if~isequal(expectedPropValue,networkInfo.SortedLayerGraph.Layers(i).(actuallayerProp{k}))
                    error(message('dlcoder_spkg:cnncodegen:IncorrectNetworkObject'));
                end
            end
        end

    end

end
