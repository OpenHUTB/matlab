function kernelImpl(externalUse,varargin)

%#codegen
    if(~coder.target('MATLAB'))
        coder.allowpcode('plain');
        coder.inline('never');

        coder.internal.prefer_const(externalUse);
        coder.internal.prefer_const(varargin);
        if coder.internal.targetLang('GPU')&&~coder.internal.isConstantFolding


            coder.internal.errorIf(...
            (nargin>1&&~isnumeric(varargin{1}))||...
            (nargin>2&&~isnumeric(varargin{2})),...
            'gpucoder:common:KernelPragmaInvalidDimType');

            validSizes=[1,3];
            coder.internal.errorIf(...
            (nargin>1&&~ismember(numel(varargin{1}),validSizes))||...
            (nargin>2&&~ismember(numel(varargin{2}),validSizes)),...
            'gpucoder:common:KernelPragmaInvalidDimSize');

            if nargin>4&&isstring(varargin{4})
                kernelName=char(varargin{4});
                coder.ceval('-preservearraydims','__gpu_kernel',externalUse,varargin{1:3},kernelName);
            else
                coder.ceval('-preservearraydims','__gpu_kernel',externalUse,varargin{:});
            end
        end
    end
end


