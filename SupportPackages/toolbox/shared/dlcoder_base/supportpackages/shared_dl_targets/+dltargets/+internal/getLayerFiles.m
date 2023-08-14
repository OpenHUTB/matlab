function[csrcs,headers]=getLayerFiles(hN)







    csrcs={fullfile(dltargets.internal.SupportedLayers.rootDir,'MWCNNLayer.cpp'),...
    fullfile(dltargets.internal.SupportedLayers.rootDir,'MWTensorBase.cpp')...
    };



    headers={fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWCNNLayer.hpp'),...
    fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWTensorBase.hpp'),...
    fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWTensor.hpp')...
    ,fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWCNNLayerImplBase.hpp')...
    ,fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWTargetNetworkImplBase.hpp')...
    ,fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWLayerImplFactory.hpp')...
    ,fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWTargetTypes.hpp')...
    ,fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWActivationFunctionType.hpp')...
    ,fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'MWRNNParameterTypes.hpp')...
    ,fullfile(dltargets.internal.SupportedLayers.rootHeaderDir,'shared_layers_export_macros.hpp')...
    };

    layerSources=dltargets.internal.SupportedLayers.m_sourceFiles;

    layerComps=hN.Components;
    layerCompKeys=arrayfun(@(x)getCompKey(x),layerComps,'UniformOutput',false);
    layerHeaders=dltargets.internal.SupportedLayers.m_headerFiles;

    for k=1:numel(layerCompKeys)
        layerCompKey=layerCompKeys{k};


        if isKey(layerSources,layerCompKey)
            sourceFile=layerSources(layerCompKey);
            csrcs{end+1}=sourceFile;%#ok
        end



        if isKey(layerHeaders,layerCompKey)
            headerFile=layerHeaders(layerCompKey);
            headers{end+1}=headerFile;%#ok
        elseif~contains(layerCompKey,'gpucoder.custom_')

            assert(false,message('dlcoder_spkg:cnncodegen:unsupported_comp',layerCompKey));
        end
    end

    csrcs=unique(csrcs);
    headers=unique(headers);
end



