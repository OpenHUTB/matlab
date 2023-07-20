classdef MultiplicationLayer<nnet.layer.Layer




%#codegen

    methods
        function layer=MultiplicationLayer(name,numInputs)
            coder.allowpcode('plain');
            layer.Name=name;
            layer.NumInputs=numInputs;
        end

        function ZFin=predict(layer,varargin)
            coder.internal.errorIf(isempty(varargin),'MATLAB:narginchk:notEnoughInputs');


            nd=ndims(varargin{1});
            for idx=2:layer.NumInputs
                nd=max(nd,ndims(varargin{idx}));
            end


            outputSize=size(varargin{1},1:nd);
            for idx=2:layer.NumInputs
                sz=size(varargin{idx},1:nd);
                outputSize=max(sz,outputSize);
            end


            I=single(ones(outputSize));

            if coder.const(isdlarray(varargin{1}))


                Z=bsxfun(@times,single(extractdata(varargin{1})),I);

                for idx=2:layer.NumInputs
                    Z=bsxfun(@times,Z,single(extractdata(varargin{idx})));
                end

                ZFin=dlarray(Z);
            else
                ZFin=bsxfun(@times,single(varargin{1}),I);

                for idx=2:layer.NumInputs
                    ZFin=bsxfun(@times,ZFin,single(varargin{idx}));
                end
            end


        end
    end

    methods(Static=true)
        function cgObj=matlabCodegenToRedirected(mlObj)
            cgObj=nnet.internal.cnn.coder.MultiplicationLayer(mlObj.Name,mlObj.NumInputs);
        end
    end

    methods(Static=true)
        function mlObj=matlabCodegenFromRedirected(cgObj)
            mlObj=nnet.cnn.layer.MultiplicationLayer(cgObj.Name,cgObj.NumInputs);
        end
    end
end
