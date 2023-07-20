classdef PrimaryAsset<matlabshared.satellitescenario.internal.Asset %#codegen




    properties(SetAccess={?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.internal.Asset,...
        ?matlabshared.satellitescenario.internal.ObjectArray,...
        ?matlabshared.satellitescenario.coder.internal.ObjectArrayCG,...
        ?matlabshared.satellitescenario.coder.internal.Access,...
        ?matlabshared.satellitescenario.internal.ScenarioGraphicBase,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses})



Gimbals



ConicalSensors



Transmitters



Receivers


Accesses
    end

    properties(Access={?matlabshared.satellitescenario.internal.PrimaryAsset,...
        ?matlabshared.satellitescenario.internal.PrimaryAssetWrapper,...
        ?matlabshared.satellitescenario.coder.internal.PrimaryAssetWrapper,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses})
        pGimbalsAddedBefore=false
        pConicalSensorsAddedBefore=false
        pTransmittersAddedBefore=false
        pReceiversAddedBefore=false
        pAccessesAddedBefore=false
    end

    methods
        function obj=PrimaryAsset(varargin)
            coder.allowpcode("plain");
        end
    end

    methods(Hidden)
        function addGraphicToClutterMap(asset,viewer)
            if~isfield(viewer.DeclutterMap,asset.getGraphicID)
                viewer.DeclutterMap.(asset.getGraphicID)=struct;
                viewer.DeclutterMap.(asset.getGraphicID).childVisibility=viewer.ShowDetails;
            end
        end
    end
end

