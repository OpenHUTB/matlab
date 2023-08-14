classdef(Abstract)ComponentContainer<matlab.ui.container.internal.ComponentContainerProxy&...
    matlab.graphics.chartcontainer.mixin.internal.GeneratedCallbackSaveLoadMixin








    methods(Access='protected',Abstract)


        setup(obj)

        update(obj)
    end

    events(Hidden,NotifyAccess='private')
PreUpdate
PostUpdate
    end

    events(Hidden,NotifyAccess='private',ListenAccess={?appdesigner.internal.appalert.AppAlertController})
UpdateError
    end


    methods(Access='protected',Hidden)

        function t=getTypeName(obj)
            m=metaclass(obj);

            t=lower(m.Name);
        end


        function groups=getPropertyGroups(obj)
            mc=metaclass(obj);
            clsprops=findobj(mc.PropertyList,'DefiningClass',mc,...
            '-and','Hidden',false,...
            '-and','GetAccess','public');
            groups(1)=matlab.mixin.util.PropertyGroup(...
            {clsprops.Name,'Position'});
        end
    end



    methods
        function obj=ComponentContainer(varargin)




            obj=obj@matlab.ui.container.internal.ComponentContainerProxy(...
            'Units_I','pixels','Position_I',[100,100,100,100]);




            [parent,parentIndices,parentMode,remainingArgs]=obj.processParent(varargin{:});
            obj.Parent=parent;
            if isempty(obj.Parent)...
                &&isempty(parentIndices)...
                &&strcmp(parentMode,'auto')...
                &&~obj.componentObjectBeingCopied...
                &&~obj.componentObjectBeingLoaded...
                &&~obj.componentObjectBeingLoadedInAppDesigner
                obj.Parent=uifigure;
            end

            if(obj.componentObjectBeingLoadedInAppDesigner)
                matlab.ui.internal.FigureServices.setAppBuildingDefaults(obj);
            end

            obj=doPreSetup(obj);

            obj=doSetupInternal(obj);


            if~isempty(remainingArgs)
                try
                    set(obj,remainingArgs{:});
                catch me
                    newMe=MException(message('MATLAB:ui:componentcontainer:ErrorWhileSettingNameValuePairs'));
                    delete(obj);
                    throwAsCaller(newMe.addCause(me));
                end
            end

            obj=doPostSetup(obj);
        end
    end


    properties(Hidden,Transient,NonCopyable,UsedInUpdate=false)
        SetupComplete(1,1)logical=false;
        InUpdateFlag(1,1)logical=false;
    end


    methods(Hidden,Access='private')
        function[parent,parentIndices,parentMode,remainingCtorInputs]=processParent(obj,varargin)
            parent=[];
            parentIndices=[];
            remainingCtorInputs={};
            parentMode=obj.ParentMode;

            if length(varargin)>0

                if isobject(varargin{1})&&ishghandle(varargin{1})
                    varargin=[{'Parent'},{varargin{1}},varargin(2:end)];
                end


                inputs={};
                count=1;
                numInputArguments=length(varargin);
                while count<=(numInputArguments)
                    if isstruct(varargin{count})
                        inputs=[inputs,namedargs2cell(varargin{count})];

                        count=count+1;
                    else
                        inputs=[inputs,varargin(count:(min(count+1,numInputArguments)))];

                        count=count+2;
                    end
                end

                if mod(numel(inputs),2)~=0
                    me=MException(message('MATLAB:ui:componentcontainer:UnmatchedNameValuePairs'));
                    throwAsCaller(me);
                end


                parentIndices=find(cellfun(@(x)startsWith(["Parent"],x,'IgnoreCase',true),inputs(1:2:end)));
                remainingCtorInputs=inputs;
                if~isempty(parentIndices)
                    parent=inputs{parentIndices(end)*2};
                    remainingCtorInputs([parentIndices*2,parentIndices*2-1])=[];
                end



                pmidx=cellfun(@(x)startsWith(["ParentMode"],x,'IgnoreCase',true),remainingCtorInputs(1:2:end));
                pmIdx=find(pmidx);
                if~isempty(pmIdx)
                    parentMode=remainingCtorInputs{pmidx(end)+1};
                end
            end
        end

        function obj=doPreSetup(obj,varargin)
            obj.Type=obj.getTypeName();
        end

        function obj=doPostSetup(obj)
            obj.SetupComplete=true;
        end

        function obj=doSetupInternal(obj)

            warningstate=warning('off','MATLAB:ui:components:noPositionSetWhenInLayoutContainer');
            try
                obj.setup();
            catch me
                newMe=MException(message('MATLAB:ui:componentcontainer:ErrorWhileExecutingSetup'));
                warning(warningstate);
                throwAsCaller(newMe.addCause(me));
            end
            warning(warningstate);
        end
    end

    methods(Access={?matlab.ui.container.internal.ComponentContainerProxy},Hidden,Sealed)
        function executeUpdate(obj)
            if~isvalid(obj)||~obj.SetupComplete
                return
            end

            obj.InUpdateFlag=true;
            notify(obj,'PreUpdate');

            try
                obj.update();
            catch me
                obj.InUpdateFlag=false;
                newMe=MException(message('MATLAB:ui:componentcontainer:ErrorWhileExecutingUpdate'));
                showReport(newMe.addCause(me));


                notify(obj,'UpdateError',matlab.ui.eventdata.internal.UpdateErrorEventData(me));
            end
            if~isvalid(obj)
                showReport(MException(message('MATLAB:ui:componentcontainer:ObjectDeletedDuringUpdate')));
                return;
            end

            notify(obj,'PostUpdate');
            obj.InUpdateFlag=false;
        end
    end

    methods(Hidden)
        function c=doCollectChildren(obj)



            c=[];
        end
    end

    methods(Access='protected',Hidden,Sealed)
        function validateChildState(this,newChild)



            if(this.SetupComplete)
                objClassName=matlab.ui.control.internal.model.PropertyHandling.getComponentClassName(this);
                childClassName=matlab.ui.control.internal.model.PropertyHandling.getComponentClassName(newChild);

                messageObj=message('MATLAB:ui:components:invalidParentOfComponent',...
                objClassName,childClassName);

                newMe=MException('MATLAB:ui:componentcontainer:invalidParent',getString(messageObj));
                throwAsCaller(newMe);
            end
        end
    end

    methods(Static,Hidden)
        function tf=componentObjectBeingCopied(val)




            persistent value;
            if nargin
                value=val;
            elseif isempty(value)
                value=false;
            end
            tf=value;
        end

        function tf=componentObjectBeingLoaded()




            st=dbstack();


            tf=any(ismember({st.name},{'FigFile.FigFile'}));
        end

        function tf=componentObjectBeingLoadedInAppDesigner(val)




            persistent value;
            if nargin
                value=val;
            elseif isempty(value)
                value=false;
            end
            tf=value;
        end
    end

    methods(Access={?matlab.graphics.mixin.internal.Copyable,?matlab.graphics.internal.CopyContext},Hidden)
        function hCopy=copyElement(hSrc)




            matlab.ui.componentcontainer.ComponentContainer.componentObjectBeingCopied(true);
            c=onCleanup(@()matlab.ui.componentcontainer.ComponentContainer.componentObjectBeingCopied(false));


            hCopy=copyElement@matlab.ui.container.internal.UIContainer(hSrc);
        end
    end
end
