
function pStruct=getStencilParams(varargin)


    p=inputParser;
    p.PartialMatching=false;
    p.StructExpand=false;
    addRequired(p,'fHandle',@(x)isa(x,'function_handle'));
    addRequired(p,'input',@(x)(isnumeric(x)||islogical(x)));
    addRequired(p,'window',@isnumeric);
    addRequired(p,'shape',@(x)any(validatestring(x,{'same','full','valid'})));
    addOptional(p,'parameters',{});
    parse(p,varargin{:});

    pStruct=p.Results;
    processInput(pStruct);
    processWindow(pStruct);
    if~iscell(pStruct.parameters)
        pStruct.parameters={pStruct.parameters};
    end
    validateFunctionHandle(pStruct);

end

function validateFunctionHandle(pStruct)
    if(nargout(pStruct.fHandle)~=1)
        error(message('gpucoder:common:StencilInvalidFunctionHandleOutput'));
    end

    foundArgs=nargin(pStruct.fHandle);
    expectedArgs=numel(pStruct.parameters)+1;
    if(foundArgs~=expectedArgs)
        error(message('gpucoder:common:StencilInvalidFunctionHandleInput',...
        expectedArgs,foundArgs));
    end
end


function processInput(pStruct)
    [row,col]=size(pStruct.input);
    assert((isnumeric(pStruct.input)||islogical(pStruct.input))&&...
    (row>0)&&(col>0),...
    'gpucoder:common:StencilInvalidInput');

end

function processWindow(pStruct)
    assert(isnumeric(pStruct.window)&&...
    numel(pStruct.window)==2,message('gpucoder:common:InvalidStencil'));
    checkWindow(pStruct.window(1));
    checkWindow(pStruct.window(2));
end

function checkWindow(wDim)
    if(wDim<=0)||...
        (fix(wDim)~=wDim)
        error(message('gpucoder:common:InvalidStencil'));
    end
end
