classdef(Abstract,Hidden)BaseOutputPackager









    methods(Abstract,Static)































        [outputType,outputData,lineNumbers]=packageOutput(evalStruct,editorId,requestId,varargin);
    end
end
