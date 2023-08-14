classdef(Abstract)InsideROI<handle




    methods




        function in=inROI(self,x,y)






            [xROI,yROI]=getLineData(self);
            in=images.internal.inpoly(x,y,xROI,yROI);
        end

    end

end