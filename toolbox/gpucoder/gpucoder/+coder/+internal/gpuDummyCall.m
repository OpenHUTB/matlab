function varargout=gpuDummyCall(func,varargin)%#codegen








    coder.allowpcode('plain');

    coder.internal.assert(coder.const(~coder.target('MATLAB')),...
    'Coder:builtins:Explicit',...
    'gpuDummyCall can only be used for codegen');


    coder.internal.cfunctionname('#__gpuDummyCall__');
    coder.inline('never');



    coder.ceval("#__this_should_not_compile__");

    [varargout{:}]=func(varargin{:});
end
