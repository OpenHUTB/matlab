classdef AddAssetsAndAnalyses %#codegen




    methods
        function obj=AddAssetsAndAnalyses
            coder.allowpcode('plain');
        end
    end

    methods(Static)
        lnks=link(source,varargin)
        tx=transmitter(asset,varargin)
        rx=receiver(asset,varargin)
    end
end

