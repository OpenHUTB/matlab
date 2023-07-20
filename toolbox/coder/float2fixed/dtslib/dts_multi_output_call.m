%#codegen


function[varargout]=dts_multi_output_call(fcn,varargin)
    coder.inline('always');
    coder.internal.allowHalfInputs;
    coder.allowpcode('plain');
    coder.internal.prefer_const(fcn,varargin);
    coder.internal.allowUndefinedCellInputs;
    eml_invariant(isa(fcn,'function_handle'),...
    'Coder:MATLAB:structfun_functionHandle');

    out=cell(1,nargout);
    [out{1:nargout}]=fcn(varargin{:});
    for ii=coder.unroll(1:nargout)
        varargout{ii}=dts_cast(out{ii});
    end
end
