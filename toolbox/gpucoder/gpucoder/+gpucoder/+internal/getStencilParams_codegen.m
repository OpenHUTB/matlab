%#codegen
function getStencilParams_codegen(input,window)

    coder.internal.allowHalfInputs;
    coder.allowpcode('plain');
    coder.inline('always');
    processInput(input);
    processWindow(window);
end

function processInput(input)
    [row,col]=size(input);

    coder.internal.assert((isnumeric(input)||islogical(input))&&...
    (row>0)&&(col>0),...
    'gpucoder:common:StencilInvalidInput');

    coder.internal.assert(ndims(input)<=2,'gpucoder:common:StencilInvalidInput');

end

function processWindow(window)
    coder.internal.assert(isnumeric(window)&&(numel(window)==2),...
    'gpucoder:common:InvalidStencil');
    checkWindow(window(1));
    checkWindow(window(2));
end

function checkWindow(wDim)

    coder.internal.errorIf((wDim<=0)||(fix(wDim)~=wDim),...
    'gpucoder:common:InvalidStencil');

end

