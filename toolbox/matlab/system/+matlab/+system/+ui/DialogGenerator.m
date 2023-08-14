classdef DialogGenerator<handle





    properties
        Platform='Simulink';
        Renderer='DDG';
    end

    methods
        function obj=DialogGenerator(varargin)
            narginchk(0,4);
            if mod(nargin,2)
                error(message('MATLAB:system:numArgsMustBeEven'));
            end
            for ii=1:2:nargin
                obj.(varargin{ii})=varargin{ii+1};
            end
        end


        function hDialogManager=getDialogManager(obj,arg3)





            switch obj.Renderer
            case 'DDG'
                hDialogManager=matlab.system.ui.DynDialogManager(obj.Platform,obj.Renderer,arg3);

            otherwise
                error(message('MATLAB:system:wrongRenderer',obj.Renderer));
            end
        end

        function set.Platform(obj,val)
            if~any(strcmp(val,{'MATLAB','Simulink','SimulinkPreview'}))
                error(message('MATLAB:system:wrongPlatform',val));
            end
            obj.Platform=val;
        end

        function set.Renderer(obj,val)
            if~any(strcmp(val,{'DDG'}))
                error(message('MATLAB:system:wrongRenderer',val));
            end
            obj.Renderer=val;
        end
    end

    methods(Static)



        function dialogManagerClass=getDialogClass(renderer)
            switch renderer
            case 'DDG'
                dialogManagerClass='matlab.system.ui.DynDialogManager';
            otherwise
                error(message('MATLAB:system:wrongRenderer',renderer));
            end
        end
    end

end