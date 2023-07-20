classdef PropertyOrInput<matlab.system.internal.ChoosablePolicy


%#codegen 



    properties(SetAccess=protected)
        InputLabel=''
        InputOrdinal=1
    end

    methods
        function obj=PropertyOrInput(aClient,aCPN,varargin)


            coder.allowpcode('plain');

            [inputOrdinal,inputLabel,isTargetActive]=resolveOptionalInputs(varargin{:});

            obj@matlab.system.internal.ChoosablePolicy(...
            'PropertyOrInput',...
            aClient,...
            aCPN,...
            isTargetActive);

            obj.InputOrdinal=inputOrdinal;
            obj.InputLabel=char(inputLabel);
        end
    end

    methods(Static)
        function props=matlabCodegenNontunableProperties(~)
            props={'InputLabel','InputOrdinal'};
        end

        function args=getConstructorArgs(obj)
            args={obj.Client,...
            obj.ControlPropertyName,...
            obj.InputOrdinal,...
            obj.InputLabel,...
            obj.IsTargetPropertyActive};
        end
    end
end

function[inputOrdinal,inputLabel,isTargetActive]=resolveOptionalInputs(varargin)
    if nargin>0
        inputOrdinal=varargin{1};
    else
        inputOrdinal=1;
    end

    if nargin>1
        inputLabel=varargin{2};
    else
        inputLabel='';
    end

    if nargin>2
        isTargetActive=varargin{3};
    else
        isTargetActive=false;
    end
end
