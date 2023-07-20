function p=dnn_pir(varargin)
















    dnn_pir_udd(varargin{:});
    if nargin==0

        p=gpucoder.dnnpir;
    else

        p=gpucoder.dnnctx(varargin{:});
    end

