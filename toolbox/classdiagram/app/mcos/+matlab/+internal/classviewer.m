function app=classviewer(varargin)
    inputParameters=classdiagram.app.mcos.InputParameters;
    if(nargin>0)
        input={};
        for i=1:numel(varargin)
            arg=varargin{i};
            if iscell(arg)
                arg=arg{1};
            end
            input{end+1}=char(arg);%#ok<AGROW>
        end
        unprocessedInputs=matlab.internal.processInputParameter(inputParameters,'IsDebugInput',input{:});
        unprocessedInputs=matlab.internal.processInputParameter(inputParameters,'ShowHiddenInput',unprocessedInputs{:});
        unprocessedInputs=matlab.internal.processInputParameter(inputParameters,'ShowAssociationsInput',unprocessedInputs{:});
        inputParameters.Packages=unprocessedInputs;
    end
    app=classdiagram.app.mcos.MCOSApp(inputParameters);
    app.show(inputParameters.IsDebug);
end
