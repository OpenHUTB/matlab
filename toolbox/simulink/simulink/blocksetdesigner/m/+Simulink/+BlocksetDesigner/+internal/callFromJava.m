function callFromJava(varargin)
    inputInfo='';
    if isequal(nargin,2)
        inputInfo.command=varargin{1};
        inputInfo.DOC_SCRIPT=varargin{2};
        inputInfo.opCode=1;
    end
    if isequal(nargin,4)
        inputInfo.command=varargin{1};
        inputInfo.opCode=varargin{2};
        inputInfo.id=varargin{3};
        inputInfo.fileType=varargin{4};
    end
    Simulink.BlocksetDesigner.invokeCommand(inputInfo);
end

