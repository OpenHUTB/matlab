classdef(ConstructOnLoad)ToolbarDropdown<...
    matlab.graphics.controls.AxesToolbarButton&...
    matlab.graphics.mixin.SceneNodeGroup



    properties(Hidden,Transient,NonCopyable,GetAccess=?matlab.graphics.controls.AxesToolbarButton,SetAccess=protected)
        ButtonGroup;
    end

    properties(Access=protected,Transient,NonCopyable)
FadeGroup
PixelGroup
Background


        ChildClickedListener;
    end

    properties(Access=private,Transient)
        Opacity_I=1;
    end

    properties(Access={?matlab.graphics.controls.ToolbarController,?TestAxesToolbar},Dependent)
        Opacity(1,1){...
        mustBeGreaterThanOrEqual(Opacity,0),...
        mustBeLessThanOrEqual(Opacity,1)}
    end

    properties(Access={?tToolbarDropdown},Transient,NonCopyable)

        Expanded=false;
    end

    events(NotifyAccess={?matlab.graphics.controls.AxesToolbarButton})

        ChildClicked;
    end

    methods
        function obj=ToolbarDropdown(varargin)
            obj@matlab.graphics.controls.AxesToolbarButton(varargin{:});

            imageContent=matlab.graphics.shape.internal.ButtonImage(...
            'Alpha',0.75);
            imageContent.ImageSource=matlab.graphics.shape.internal.image.IconDropdownView;
            imageContent.ImageSource.BorderWidth=obj.BorderWidth;
            imageContent.ImageSource.IconSize=obj.IconWidth;
            obj.Button.Content=imageContent;

            obj.FadeGroup=matlab.graphics.controls.internal.FadeGroup(...
            'Alpha',obj.Opacity_I,...
            'Internal',true);
            obj.addNode(obj.FadeGroup);

            obj.PixelGroup=matlab.graphics.controls.internal.ControlsGroup(...
            'Parent',obj.FadeGroup,...
            'Visible','off',...
            'Internal',true);

            obj.Background=matlab.graphics.controls.internal.Backdrop(...
            'Parent',obj.PixelGroup,...
            'Color',uint8([240,240,240]));
            obj.Background.Layer='back';
            obj.Background.setPickableParts('visible');

            obj.ButtonGroup=matlab.graphics.primitive.Group(...
            'Parent',obj.PixelGroup,...
            'Internal',true);

            obj.ChildClickedListener=event.listener(obj,'ChildClicked',...
            @processActionEvent);
        end
    end

    methods
        function set.Opacity(obj,newValue)
            obj.Opacity_I=newValue;

            obj.FadeGroup.Alpha=newValue;

            if newValue==0
                obj.PixelGroup.Visible='off';
            else
                obj.PixelGroup.Visible='on';
            end
        end

        function val=get.Opacity(obj)
            val=obj.Opacity_I;
        end
    end

    methods(Access=protected)
        function processActionEvent(obj,~,~)
            obj.toggleOpen();
        end

        function doSetBackgroundColor(obj,value)
            obj.doSetBackgroundColor@matlab.graphics.controls.AxesToolbarButton(value);

            if~isequal(obj.Background.Color,value)
                obj.Background.Color=value;
            end
        end

        function varargout=getPropertyGroups(~)
            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'Tag','Icon','Children'});
        end


        function label=getDescriptiveLabelForDisplay(obj)




            label=matlab.graphics.internal.convertStringToCharArgs(obj.Tag);
        end
    end

    methods(Hidden)
        function doUpdate(obj,~)

            if isempty(obj.ButtonGroup.NodeChildren)
                return;
            end

            buttonWidth=obj.ButtonGroup.NodeChildren(end).IconWidth+...
            2*obj.ButtonGroup.NodeChildren(end).BorderWidth;

            buttonHeight=buttonWidth;

            itemBuffer=2;

            ddHeight=0;
            bStart=obj.Position(2)-buttonHeight;


            pos=[0,0,0,0];

            if obj.Expanded
                vis='on';
            else
                vis='off';
            end

            for i=1:numel(obj.ButtonGroup.NodeChildren)
                element=obj.ButtonGroup.NodeChildren(i);



                if~isempty(obj.Parent)&&isvalid(obj.Parent)&&...
                    ~obj.Parent.isEnabledForAxes(obj.Parent.Parent,element)
                    element.Visible_I='off';
                else
                    element.Visible_I=vis;

                    ddHeight=ddHeight+(buttonHeight+itemBuffer);


                    if obj.Expanded
                        element.Position=[obj.Position(1),bStart,...
                        buttonWidth,buttonHeight];

                        element.BackgroundColor=double(obj.Background.Color(1:3));

                        bStart=bStart-(buttonHeight+itemBuffer);


                        pos(1)=obj.Position(1);
                        pos(2)=bStart+buttonHeight;
                        pos(3)=buttonWidth;
                        pos(4)=ddHeight;
                    elseif isa(element,'matlab.graphics.controls.internal.ToolTipMixin')


                        element.hideToolTip();
                    end
                end
            end

            obj.PixelGroup.Visible_I=vis;
            obj.Background.Visible_I=vis;
            obj.Background.Position=pos;
        end

        function toggleOpen(obj)
            obj.Expanded=~obj.Expanded;



            obj.Opacity=obj.Opacity;


            obj.MarkDirty('all');
        end

        function doOpen(obj)

            if obj.Expanded
                return;
            else
                obj.toggleOpen();
            end
        end

        function doClose(obj)

            if~obj.Expanded
                return;
            else
                obj.toggleOpen();
            end
        end



        function ignore=mcodeIgnoreHandle(~,~)
            ignore=true;
        end

        function hover(obj)
            obj.hover@matlab.graphics.controls.AxesToolbarButton();
            obj.doOpen();
        end
    end

    methods(Access='public',Hidden=true)

        function actualValue=setParentImpl(obj,proposedValue)
            if~isempty(proposedValue)
                if isa(proposedValue,'matlab.graphics.controls.AxesToolbar')
                    obj.Parent=proposedValue.ButtonGroup;
                elseif~isa(proposedValue,'matlab.graphics.primitive.Group')
                    error(message('MATLAB:graphics:axestoolbar:InvalidAxesToolbar'));
                end
            end


            actualValue=proposedValue;
        end

        function firstChild=doGetChildren(hObj)

            hPar=hObj.ButtonGroup;
            firstChild=matlab.graphics.primitive.world.Group.empty;
            if isempty(hPar)||~isvalid(hPar)
                return;
            else
                allChil=hgGetTrueChildren(hPar);
                if~isempty(allChil)
                    firstChild=allChil(1);
                end
            end
        end

        function trueParent=addChild(hObj,newChild)
            trueParent=hObj;



            if isa(newChild,'matlab.ui.controls.ToolbarPushButton')
                newChild.Parent=hObj;
                trueParent=hObj.ButtonGroup;
            elseif isa(newChild,'matlab.ui.controls.AxesToolbarButton')

                error(message('MATLAB:graphics:axestoolbar:ToolbarDropdownChildError'));
            end
        end
    end

end
