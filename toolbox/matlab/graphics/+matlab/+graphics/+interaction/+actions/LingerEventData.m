classdef LingerEventData<matlab.graphics.interaction.uiaxes.MouseEventData



    properties(SetAccess=?matlab.graphics.interaction.actions.Linger)
        NearestPoint double=NaN
        PreviousObject matlab.graphics.Graphics=gobjects(0)
        PreviousPoint double=NaN
    end

    methods
        function data=LingerEventData(o,e)
            data=data@matlab.graphics.interaction.uiaxes.MouseEventData(o,e);
            if(isstruct(e)&&isfield(e,'NearestPoint'))||(isobject(e)&&isprop(e,'NearestPoint'))
                data.NearestPoint=e.NearestPoint;
            end
            if(isstruct(e)&&isfield(e,'PreviousObject'))||(isobject(e)&&isprop(e,'PreviousObject'))
                data.PreviousObject=e.PreviousObject;
            end
            if(isstruct(e)&&isfield(e,'PreviousPoint'))||(isobject(e)&&isprop(e,'PreviousPoint'))
                data.PreviousPoint=e.PreviousPoint;
            end
        end
    end
end
