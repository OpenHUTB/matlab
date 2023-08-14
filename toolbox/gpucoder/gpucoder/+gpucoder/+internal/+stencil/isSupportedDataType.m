function y=isSupportedDataType(x)%#codegen




    coder.allowpcode('plain');
    coder.inline('always');

    y=coder.const((isnumeric(x)||islogical(x))&&(~isobject(x)||isa(x,'gpuArray')));
end
