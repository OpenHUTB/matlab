classdef(ConstructOnLoad)ModeButton<matlab.graphics.controls.ToggleButton




    properties
        ModeName;
    end

    methods
        function obj=ModeButton(varargin)
            obj@matlab.graphics.controls.ToggleButton(varargin{:});

            obj.OnCallback=@(e,d)obj.doModeOn();
            obj.OffCallback=@(e,d)obj.doModeOff();
        end

        function setModeState(obj,state)

            modeOn=strcmp(state.Mode,obj.ModeName);



            if modeOn
                obj.Value=true;
            else
                obj.Value=false;
            end
        end

        function doModeOn(obj)
            obj.Value=true;
        end

        function doModeOff(obj)
            obj.Value=false;
        end

    end
end

