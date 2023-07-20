classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Hidden,Sealed)Button<...
    matlab.graphics.primitive.world.Group&...
    matlab.graphics.mixin.GraphicsPickable&...
    matlab.graphics.internal.Legacy&...
    matlab.graphics.mixin.AxesParentable&...
    matlab.graphics.controls.internal.Control





    properties(AffectsObject,AbortSet)

        Content matlab.internal.datatype.matlab.graphics.datatype.HandleOrEmpty=[]


        Position matlab.internal.datatype.matlab.graphics.datatype.Position=[0,0,1,1]


        Padding(1,1)double=0



        BorderType string{mustBeMember(BorderType,["none","flat"])}="flat"



        FaceType string{mustBeMember(FaceType,["none","flat"])}="flat"
    end

    properties(Dependent)
        Layer matlab.internal.datatype.matlab.graphics.datatype.OrderLayer;
    end

    properties(AbortSet,Access=private)
        Layer_I matlab.internal.datatype.matlab.graphics.datatype.OrderLayer='front';
    end

    properties(Access=private,Transient,NonCopyable)
ContentContainer
ButtonEdge
HitListener
    end

    properties(Access=?matlab.graphics.controls.AxesToolbarButton)
ButtonFace
    end

    events(NotifyAccess=private)
Action
    end

    methods
        function obj=Button(varargin)





            obj@matlab.graphics.primitive.world.Group(varargin{:});

            obj.ButtonFace=matlab.graphics.primitive.world.Quadrilateral(...
            'PickableParts','visible',...
            'Clipping','off',...
            'Layer',obj.Layer_I,...
            'Internal',true,...
            'Description','Button face');
            obj.addNode(obj.ButtonFace);

            obj.ButtonEdge=matlab.graphics.primitive.world.LineLoop(...
            'Clipping','off',...
            'Layer',obj.Layer_I,...
            'AlignVertexCenters','on',...
            'Internal',true,...
            'Description','Button outline');
            obj.addNode(obj.ButtonEdge);




            obj.ContentContainer=matlab.graphics.primitive.Transform(...
            'Internal',true,...
            'HitTest','off',...
            'Description','Button content');
            obj.addNode(obj.ContentContainer);

            if~isempty(obj.Content)

                obj.ContentContainer.addNode(obj.Content);
            end




            hBehavior=hggetbehavior(obj,'DataCursor');
            hBehavior.Enable=false;




            obj.HitListener=event.listener(obj,'Hit',@obj.sendActionEvent);
            obj.HitListener.Recursive=true;

            obj.addDependencyConsumed('xyzdatalimits');
            obj.addDependencyConsumed('dataspace');

            obj.checkColorSpaceDependency();
        end

        function set.Content(obj,value)

            OldContent=obj.Content;
            if~isempty(OldContent)&&isvalid(OldContent)
                OldContent.Parent=[];
            end

            if~isempty(value)
                if~isempty(obj.ContentContainer)
                    obj.ContentContainer.addNode(value);
                end

                if isprop(value,'Layer')

                    value.Layer=obj.Layer_I;
                end
            end

            obj.Content=value;
        end

        function set.BorderType(obj,value)
            obj.BorderType=value;




            if~isempty(obj.ButtonFace)
                obj.checkColorSpaceDependency();
            end
        end

        function set.FaceType(obj,value)
            obj.FaceType=value;




            if~isempty(obj.ButtonFace)
                obj.checkColorSpaceDependency();
            end
        end

        function set.Layer(obj,newval)
            obj.Layer_I=newval;
            if~isempty(obj.ButtonFace)
                obj.ButtonFace.Layer=newval;
                obj.ButtonEdge.Layer=newval;
                if~isempty(obj.Content)&&isprop(obj.Content,'Layer')
                    obj.Content.Layer=newval;
                end
            end
        end

        function val=get.Layer(obj)
            val=obj.Layer_I;
        end
    end

    methods(Hidden)
        doUpdate(obj,updateState)
    end

    methods(Access=private)
        function checkColorSpaceDependency(obj)




            if(obj.BorderType~="none"||obj.FaceType~="none")
                obj.addDependencyConsumed('colorspace');
            end
        end
    end

    methods(Access=private)
        function sendActionEvent(obj,~,eventData)
            if eventData.Button==1

                obj.notify('Action');
            end
        end
    end
end
