classdef ExponentialLayer<nnet.layer.Layer





    methods
        function layer=ExponentialLayer(varargin)
            p=inputParser;
            addParameter(p,'Name',[]);
            parse(p,varargin{:});
            layer.Name=p.Results.Name;
            layer.Type='Exponential';
        end

        function Z=predict(~,X)


            Z=exp(X);
        end
    end
end