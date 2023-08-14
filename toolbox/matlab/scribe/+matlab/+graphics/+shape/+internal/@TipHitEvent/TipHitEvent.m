classdef(ConstructOnLoad,Sealed)TipHitEvent<event.EventData




    properties(GetAccess=public,SetAccess=private)
        Button=0;
        IntersectionPoint=[0,0];
        Primitive=[];
    end

    methods
        function obj=TipHitEvent(button,point,prim)






            if nargin
                obj.Button=button;
                obj.IntersectionPoint=point;
                obj.Primitive=prim;
            end
        end
    end

    methods
        function ret=isContextMenuEvent(obj)





            ret=obj.Button==3;
        end




        function ret=isTipEditEvent(~,hTip)
            hFig=ancestor(hTip,'figure');
            ret=false;
            if~isempty(hFig)
                dcm=datacursormode(hFig);




                targetObject=hTip.DataSource;
                hasCustomUpdate=~isempty(dcm.UpdateFcn)||...
                (~isempty(targetObject)&&...
                ~isempty(hggetbehavior(targetObject.getAnnotationTarget(),'datacursor','-peek')));



                if~hasCustomUpdate&&...
                    (strcmpi(hFig.SelectionType,'open')||...
                    (strcmp(hTip.CurrentTip,'on')&&~isactiveuimode(hFig,'Standard.EditPlot')))
                    ret=true;
                end
            end
        end
    end
end
