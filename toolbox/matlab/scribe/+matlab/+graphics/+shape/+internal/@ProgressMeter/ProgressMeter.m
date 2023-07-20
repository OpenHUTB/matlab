classdef(ConstructOnLoad,UseClassDefaultsOnLoad,Hidden,Sealed)ProgressMeter<...
    matlab.graphics.primitive.world.Group






    properties











        Progress(1,1)double=NaN






        ButtonType(1,1)string{mustBeMember(ButtonType,["play","pause"])}="play"






        BarColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0.6,1.0];
    end


    properties(Access=private,Transient,NonCopyable)

ControlsContainer
ProgressBar
ActionButton


ActionButtonListener
    end

    events(NotifyAccess=private)

Action
    end

    methods
        function obj=ProgressMeter(varargin)






            obj.ControlsContainer=matlab.graphics.controls.internal.ControlsGroup(...
            'Internal',true);
            obj.addNode(obj.ControlsContainer);


            obj.ProgressBar=matlab.graphics.controls.internal.ProgressBar(...
            'Description','ProgressMeter bar',...
            'Parent',obj.ControlsContainer,...
            'Color',obj.BarColor,...
            'Progress',obj.Progress);


            obj.ActionButton=localMakeButton('ProgressMeter action button');
            setButtonContent(obj.ActionButton,'play');
            obj.ActionButton.Parent=obj.ControlsContainer;





            obj.ActionButtonListener=event.listener(obj.ActionButton,...
            'Action',@obj.playPauseCallback);
            obj.ActionButtonListener.Recursive=true;


            obj.addDependencyConsumed('ref_frame');
            obj.addDependencyConsumed('view');
            obj.addDependencyConsumed('dataspace');
            obj.addDependencyConsumed('xyzdatalimits');
            obj.addDependencyConsumed('hgtransform_under_dataspace');

            if nargin
                set(obj,varargin{:});
            end
        end



        function set.Progress(obj,newValue)
            obj.Progress=newValue;

            if~isempty(obj.ProgressBar)&&isvalid(obj.ProgressBar)
                obj.ProgressBar.Progress=newValue;
            end
        end


        function set.BarColor(obj,newValue)
            obj.BarColor=newValue;

            if~isempty(obj.ProgressBar)&&isvalid(obj.ProgressBar)
                obj.ProgressBar.Color=newValue;
            end
        end


        function set.ButtonType(obj,newValue)
            obj.ButtonType=newValue;

            setButtonContent(obj.ActionButton,newValue);
        end
    end


    methods(Access={?qeTallShared.specgraph.ScatterTests,...
        ?qeTallShared.graph2d.PlotTests,...
        ?qeTallShared.specgraph.BinscatterTests})
        function playPauseCallback(obj,~,~)
            obj.fireActionEvent();
        end

        function fireActionEvent(obj)
            obj.notify('Action');
        end
    end

    methods(Hidden)
        doUpdate(obj,updateState);
    end
end


function setButtonContent(hButton,type)
    im=getButtonData(type);
    set(hButton.Content,'ImageFile',im);
end


function h=localMakeButton(desc)
    hContent=matlab.graphics.shape.internal.ButtonImage();
    h=matlab.graphics.shape.internal.Button(...
    'Content',hContent,...
    'Description',desc);
end
