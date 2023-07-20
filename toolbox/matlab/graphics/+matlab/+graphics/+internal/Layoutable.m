classdef(Hidden)Layoutable<handle






    methods(Hidden)
        function pos=getPositionForAutoResizableChildren(obj,prop)
            if strcmpi(obj.Units,'pixels')
                pos=get(obj,prop);
            else

                pos=get(obj,prop);


                viewport=obj.getUnitPositionObject();
                pos=matlab.graphics.internal.convertUnits(viewport,'pixels',obj.Units,pos);
            end
        end

        function setPositionForAutoResizableChildren(obj,prop,value,frameDimensions)
            if strcmpi(obj.Units,'pixels')
                set(obj,prop,value);
            else



                import matlab.graphics.internal.convertUnits
                viewport=obj.getUnitPositionObject();
                frameDimensions=convertUnits(viewport,'devicepixels','pixels',[1,1,frameDimensions(:)']);
                viewport.RefFrame=frameDimensions;


                value=convertUnits(viewport,obj.Units,'pixels',value);


                set(obj,prop,value);
            end
        end
    end

    methods(Abstract,Access=protected)





        unitPos=getUnitPositionObject(obj)
    end
end
