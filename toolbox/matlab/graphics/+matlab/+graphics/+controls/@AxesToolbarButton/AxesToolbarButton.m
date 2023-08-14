classdef(ConstructOnLoad)AxesToolbarButton<...
    matlab.graphics.primitive.world.Group&...
    matlab.graphics.internal.Legacy&...
    matlab.graphics.mixin.AxesParentable&...
    matlab.graphics.internal.GraphicsBaseFunctions




    properties(Hidden,Transient)
BackgroundColor
        Hovering=false;
    end

    properties




        Icon;
    end

    properties(Access={?matlab.graphics.controls.AxesToolbar,?tAxesToolbarButton,...
        ?matlab.ui.controls.ToolbarDropdown,?matlab.graphics.controls.internal.ToolTipMixin},Dependent)
        Position matlab.internal.datatype.matlab.graphics.datatype.Position
    end

    properties(Access={?matlab.graphics.controls.AxesToolbar,?tAxesToolbarButton,...
        ?matlab.ui.controls.ToolbarDropdown})




        IconWidth=16;
        BorderWidth=2;
        StartingAlpha=.85;
    end

    properties(Access=private,Transient)



        Icon_I;
    end

    properties(Access=private)
        Position_I=[0,0,1,1];
    end

    properties(Dependent,Hidden)



        Image;
    end

    properties(Access=protected,Transient,NonCopyable)
        Button;
    end

    properties(Access=private,Transient,NonCopyable)
        ButtonListener=[];
    end

    methods(Hidden,Access={?tAxesToolbar,?AxesToolbarFriend})

        function result=getPickableParts(obj)
            result=obj.Button.ButtonFace.PickableParts;
        end
    end

    methods

        function obj=AxesToolbarButton(varargin)
            obj@matlab.graphics.primitive.world.Group(varargin{:});

            obj.Button=matlab.graphics.shape.internal.Button(...
            'FaceType',"none",...
            'BorderType',"none",...
            'Layer','back',...
            'Serializable','off',...
            'HandleVisibility','off',...
            'Position',obj.Position_I);

            obj.Button.ButtonFace.PickableParts='all';
            obj.addNode(obj.Button);

            imageContent=matlab.graphics.shape.internal.ButtonImage(...
            'Alpha',obj.StartingAlpha);
            imageContent.ImageSource=matlab.graphics.shape.internal.image.IconView;
            imageContent.ImageSource.BorderWidth=obj.BorderWidth;
            imageContent.ImageSource.IconSize=obj.IconWidth;
            obj.Button.Content=imageContent;

            obj.ButtonListener=event.listener(obj.Button,'Action',@obj.processActionEvent);

            obj.Icon='none';
        end

        function image=get.Image(obj)
            image=obj.Button.Content.ImageSource.Icon;
        end


        function set.Image(obj,val)
            obj.Button.Content.ImageSource.Icon=val;
            obj.Button.Content.ImageDPIRatios=[];
        end

        function set.Icon(obj,val)
            if(ischar(val)||isstring(val))
                if matlab.graphics.controls.internal.ToolbarValidator.isValidIcon(val)



                    if(isempty(obj.Icon_I)||ischar(obj.Icon_I)||isstring(obj.Icon_I))&&...
                        ~strcmpi(obj.Icon_I,val)
                        obj.Icon_I=val;
                        obj.setStandardIcon(val);
                    end
                else
                    obj.Icon_I='';
                    obj.Image=val;
                end
            elseif isnumeric(val)||islogical(val)
                if ismatrix(val)

                    if isa(val,'logical')||isa(val,'uint8')||isa(val,'uint16')


                        val=val+1;
                    end
                    val=round(val);

                    if any(val(:)<matlab.graphics.shape.internal.image.IconView.MinIndex|...
                        val(:)>matlab.graphics.shape.internal.image.IconView.MaxIndex)
                        error(message('MATLAB:graphics:axestoolbar:InvalidIndexedIcon'));
                    end
                elseif~(ndims(val)==3&&size(val,3)==3)
                    error(message('MATLAB:graphics:axestoolbar:InvalidRGBIcon'));
                end
                obj.Icon_I='';
                obj.Image=val;
            else
                error(message('MATLAB:graphics:axestoolbar:InvalidIcon'));
            end
        end

        function val=get.Icon(obj)
            if~isempty(obj.Icon_I)

                val=obj.Icon_I;
            else
                val=obj.Image;
            end
        end

        function set.BackgroundColor(obj,value)
            obj.doSetBackgroundColor(value);
        end

        function value=get.BackgroundColor(obj)
            value=obj.Button.Content.ImageSource.BackgroundColor;
        end

        function set.Position(obj,value)
            obj.Position_I=value;
            if~isempty(obj.Button)&&isvalid(obj.Button)
                obj.Button.Position=value;
            end
        end

        function value=get.Position(obj)
            value=obj.Position_I;
        end
    end

    methods(Hidden)

        function hover(obj)
            if~obj.Hovering

                obj.doHover(true);
                obj.Hovering=true;
            end
        end

        function unhover(obj)
            if obj.Hovering

                obj.doHover(false);
                obj.Hovering=false;
            end
        end
    end

    methods(Access='public',Hidden=true)
        function hParent=getParentImpl(~,hParentIn)
            hParent=hParentIn;
            if~isempty(hParentIn)

                parent=hParentIn.Parent;
                if~isempty(parent)
                    hParent=parent;
                end
            end
        end

        function actualValue=setParentImpl(obj,proposedValue)
            if~isempty(proposedValue)
                if isa(proposedValue,'matlab.graphics.controls.AxesToolbar')||...
                    (isa(proposedValue,'matlab.ui.controls.ToolbarDropdown')&&...
                    isa(obj,'matlab.ui.controls.ToolbarPushButton'))
                    obj.Parent=proposedValue.ButtonGroup;
                elseif~isa(proposedValue,'matlab.graphics.primitive.Group')
                    error(message('MATLAB:graphics:axestoolbar:InvalidAxesToolbar'));
                end
            end


            actualValue=proposedValue;
        end
    end

    methods(Access=protected)
        function doSetBackgroundColor(obj,value)
            if~isequal(obj.Button.Content.ImageSource.BackgroundColor,value)
                obj.Button.Content.ImageSource.BackgroundColor=value;
            end
        end

        function setStandardIcon(obj,name)

            factory=matlab.graphics.controls.internal.ToolbarButtonRegistry.getInstance();
            [val,ratios]=factory.getButtonIcon(name);

            obj.Button.Content.ImageSource.Icon=val;
            obj.Button.Content.ImageDPIRatios=ratios;
        end
    end

    methods(Access=protected)
        function processActionEvent(obj,~,~)


            if isa(obj.Parent,'matlab.ui.controls.ToolbarDropdown')
                evtData=matlab.graphics.controls.eventdata.ChildClickedEventData(obj);
                notify(obj.Parent,'ChildClicked',evtData);
            end

            try

                tag=obj.Tag;

                if~isempty(tag)
                    [~,buttonTypesEnum]=enumeration('matlab.graphics.controls.internal.ToolbarValidator');



                    if~any(ismember(tag,buttonTypesEnum))
                        tag='custom';
                    end



                    builtin('_logddux','toolbar','toolbarButton',tag);
                end
            catch


            end
        end
    end

    methods(Access=private)
        function doHover(obj,isHover)
            alpha=obj.StartingAlpha;
            if isHover
                alpha=1;
            end
            obj.Button.Content.Alpha=alpha;
        end
    end

    methods(Access={?matlab.graphics.controls.AxesToolbar,...
        ?matlab.graphics.controls.internal.FigureBasedModeStrategy})



        function setOverflowIcon(obj,name)
            if strcmpi(name,'expanded')||strcmpi(name,'collapsed')
                obj.setStandardIcon(name);
            end
        end



        function togglePickable(obj,val)
            obj.Button.ButtonFace.PickableParts=val;
        end

    end
end