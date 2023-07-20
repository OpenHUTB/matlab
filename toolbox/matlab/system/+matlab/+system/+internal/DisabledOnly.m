classdef DisabledOnly<matlab.system.internal.NonChoosablePolicy


%#codegen 



    methods
        function obj=DisabledOnly(aClient,aCPN,varargin)
            coder.allowpcode('plain');

            isControlActive=resolveOptionalInput(varargin{:});

            obj@matlab.system.internal.NonChoosablePolicy(...
            'Disabled',...
            aClient,...
            aCPN,...
            false,...
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
