classdef PropertyOnly<matlab.system.internal.NonChoosablePolicy


%#codegen   



    methods
        function obj=PropertyOnly(aClient,aCPN,varargin)
            coder.allowpcode('plain');

            isControlActive=resolveOptionalInput(varargin{:});

            obj@matlab.system.internal.NonChoosablePolicy(...
            'Property',...
            aClient,...
            aCPN,...
            true,...
            isControlActive);
        end
    end
end

function isControlActive=resolveOptionalInput(varargin)
    if nargin>0
        isControlActive=varargin{1};
    else
        isControlActive=true;
    end
end
