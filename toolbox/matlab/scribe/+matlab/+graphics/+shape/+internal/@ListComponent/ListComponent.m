classdef ListComponent





    properties
        ObjectHandle;
        Location='east';
        DirtyListener event.listener;
        UpdateLayoutListener event.listener;
        DestroyedListener event.listener;
    end

    methods(Access=public)
        function hObj=ListComponent(obj,location,md_lis,ul_lis,des_lis)
            hObj.ObjectHandle=obj;
            hObj.Location=location;
            hObj.DirtyListener=md_lis;
            hObj.UpdateLayoutListener=ul_lis;
            hObj.DestroyedListener=des_lis;
        end
    end
end
