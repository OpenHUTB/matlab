classdef(Hidden)BaseWebScope<dsp.webscopes.mixin.Specifiable&...
    dsp.webscopes.mixin.StyleConfigurable&...
    dsp.webscopes.mixin.MeasurementsConfigurable&...
    dsp.webscopes.mixin.LongDisplayCollapsable&...
    dsp.webscopes.mixin.PropertyValueValidator&...
    matlabshared.scopes.WebWindow&...
    matlabshared.scopes.WebStreamingSource&...
    matlab.mixin.internal.indexing.Paren




    properties(Dependent)



        Name(:,:)char;




        NumInputPorts{mustBeInteger,mustBeNumeric,mustBeFinite,mustBePositive,mustBeLessThanOrEqual(NumInputPorts,96)};







        Position;





        AxesScalingNumUpdates;



        MeasurementChannel;
    end

    properties(Hidden)

        Parent;

        ScopeView;
    end

    properties(Hidden,Access=protected)

        HideCalled=false;

        ScopeLocked=false;

        SetupCalled=false;

        ReleaseCalled=false;

        ResetCalled=false;

        CachedInputInfo=[];

        InputsChangedComplexity=[];

        UIHTMLContainer;
    end

    properties(Access=protected,Dependent)

        DataDomain;
    end

    properties(Hidden,Dependent)

        Product;




        Annotation;

        ExpandToolstrip;

        DefaultLegendLabel;

        HasToolstrip;

        HasStatusbar;

        HasDockControls;

        CounterMode;

        NumInputPortsSource;

        MaxNumChannels;


        Tag;



        RenderInMATLAB;


        WarnOnInactivePropertySet;

        ReduceUpdates;
    end

    properties(Dependent,Hidden,SetAccess=private)

        Visible;
    end

    properties(Constant,Hidden)
        CounterModeSet={'samples','frames','none'};
        NumInputPortsSourceSet={'auto','property'};
    end




    methods


        function this=BaseWebScope(varargin)
            this@matlabshared.scopes.WebStreamingSource(varargin{:});
            spec=this.Specification;
            msg=this.MessageHandler;
            this.Specification.MessageHandler=msg;
            this.MessageHandler.Specification=spec;
            this.setProperties(varargin{:});

            this.addStyleConfiguration();

            this.addMeasurementsConfiguration();
        end


        function set.NumInputPorts(this,value)
            this.validatePropertiesOnSet('NumInputPorts');
            this.NumInputs=value;
            setPropertyValue(this,'NumInputPorts',value);
            setPropertyValue(this,'NumInputPortsSource','property');
        end
        function value=get.NumInputPorts(this)
            value=getPropertyValue(this,'NumInputPorts');
        end


        function set.NumInputPortsSource(this,value)
            value=validateEnum(this,'NumInputPortsSource',value);
            setPropertyValue(this,'NumInputPortsSource',value);
        end
        function value=get.NumInputPortsSource(this)
            value=getPropertyValue(this,'NumInputPortsSource');
        end


        function set.Name(this,value)
            value=convertStringsToChars(value);
            setScopeName(this,value);
            setPropertyValue(this,'Name',value);
        end
        function value=get.Name(this)
            value=getPropertyValue(this,'Name');
        end


        function set.Position(this,value)
            import dsp.webscopes.internal.*;
            if~isnumeric(value)||~all(isfinite(value))||~isequal(size(value),[1,4])
                BaseWebScope.localError('invalidPosition');
            end
            setWindowPosition(this,value);
            setPropertyValue(this,'Position',value);
        end
        function value=get.Position(this)
            value=getWindowPosition(this);
        end


        function set.ExpandToolstrip(this,value)
            setPropertyValue(this,'ExpandToolstrip',value)
        end
        function value=get.ExpandToolstrip(this)
            value=getPropertyValue(this,'ExpandToolstrip');
        end


        function set.AxesScalingNumUpdates(this,value)
            validateattributes(value,...
            {'numeric'},{'positive','finite','scalar'},'','AxesScalingNumUpdates');
            setPropertyValue(this,'AxesScalingNumUpdates',value)
        end
        function value=get.AxesScalingNumUpdates(this)
            value=getPropertyValue(this,'AxesScalingNumUpdates');
        end


        function set.MeasurementChannel(this,value)
            import dsp.webscopes.internal.*;
            validateattributes(value,{'numeric'},...
            {'real','scalar','integer','finite','nonnan','>',0,'<=',this.MaxNumChannels},'','MeasurementChannel');
            if this.isLocked()
                numChannels=this.getNumChannels();
                if value>numChannels
                    BaseWebScope.localError('invalidMeasurementChannelNumber',numChannels);
                end
            end
            setPropertyValue(this,'MeasurementChannel',value)
        end
        function value=get.MeasurementChannel(this)
            value=getPropertyValue(this,'MeasurementChannel');
        end


        function set.DefaultLegendLabel(this,value)
            setPropertyValue(this,'DefaultLegendLabel',value)
        end
        function value=get.DefaultLegendLabel(this)
            value=getPropertyValue(this,'DefaultLegendLabel');
        end


        function set.ReduceUpdates(~,value)
            import dsp.webscopes.internal.*;
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ReduceUpdates');
            BaseWebScope.localWarning('reduceUpdatesObsolete');
        end
        function value=get.ReduceUpdates(this)
            value=getPropertyValue(this,'ReduceUpdates');
        end


        function set.Product(this,value)
            setPropertyValue(this,'Product',value)
        end
        function value=get.Product(this)
            value=getPropertyValue(this,'Product');
        end


        function set.HasToolstrip(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','HasToolstrip');
            setPropertyValue(this,'HasToolstrip',logical(value));
        end
        function value=get.HasToolstrip(this)
            value=getPropertyValue(this,'HasToolstrip');
        end


        function set.HasStatusbar(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','ReduceUpdates');
            setPropertyValue(this,'HasStatusbar',logical(value));
        end
        function value=get.HasStatusbar(this)
            value=getPropertyValue(this,'HasStatusbar');
        end


        function set.HasDockControls(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','HasDockControls');
            setPropertyValue(this,'HasToolstrip',logical(value));
        end
        function value=get.HasDockControls(this)
            value=getPropertyValue(this,'HasDockControls');
        end


        function set.Annotation(this,value)
            setPropertyValueAndNotify(this,'Annotation',value);
        end
        function value=get.Annotation(this)
            value=getPropertyValue(this,'Annotation');
        end


        function set.CounterMode(this,value)
            value=validateEnum(this,'CounterMode',value);
            setPropertyValueAndNotify(this,'CounterMode',value);
        end
        function value=get.CounterMode(this)
            value=getPropertyValue(this,'CounterMode');
        end


        function set.Tag(this,value)
            setPropertyValue(this,'Tag',value)
        end
        function value=get.Tag(this)
            value=getPropertyValue(this,'Tag');
        end


        function set.RenderInMATLAB(this,value)
            setPropertyValue(this,'RenderInMATLAB',value)
        end
        function value=get.RenderInMATLAB(this)
            value=getPropertyValue(this,'RenderInMATLAB');
        end


        function set.Parent(this,value)
            this.Parent=value;
            setScopeParent(this);
        end


        function value=get.DataDomain(this)
            value=getPropertyValue(this,'DataDomain');
        end


        function set.MaxNumChannels(this,value)
            validateattributes(value,...
            {'numeric'},{'real','finite','scalar','positive'},'','MaxNumChannels');
            setPropertyValueAndNotify(this,'MaxNumChannels',value);
        end
        function value=get.MaxNumChannels(this)
            value=getPropertyValue(this,'MaxNumChannels');
        end


        function set.WarnOnInactivePropertySet(this,value)
            validateattributes(value,{'logical','numeric'},{'real','scalar','finite','nonnan'},'','WarnOnInactivePropertySet');
            setPropertyValue(this,'WarnOnInactivePropertySet',value)
        end
        function value=get.WarnOnInactivePropertySet(this)
            value=getPropertyValue(this,'WarnOnInactivePropertySet');
        end


        function value=get.Visible(this)
            value=getPropertyValue(this,'Visible');
        end
    end



    methods

        function varargout=generateScript(this)


            if nargout>0
                varargout{1}=this.Specification.generateScript();
            else
                this.Specification.generateScript();
            end
        end

        function step(this,varargin)



            if~this.ScopeLocked


                setup(this,varargin);
            else


                cachedInputInfo=this.CachedInputInfo;
                currentInputInfo=this.getCurrentInputInfo(varargin);



                if(size(cachedInputInfo,2)~=numel(varargin)...
                    ||any(cachedInputInfo~=currentInputInfo,'all'))

                    this.validateInputs(varargin);





                    if any(this.InputsChangedComplexity)
                        inputs=nnz(this.InputsChangedComplexity);
                        varargin(inputs)=cellfun(@(x)fixInputComplexity(this,x),varargin(inputs),'UniformOutput',false);
                    end
                end
            end

            if(isempty(varargin{1}))
                return;
            end

            write(this,varargin{:});
        end

        function release(this)





            this.Specification.release();
            this.CachedInputInfo=[];
            this.StreamingSourceImpl.release();
            this.FrameSize=int32(-Inf);

            this.NumChannels=int32(-1);

            this.IsInputComplex=false;

            this.NumInputPortsSource='auto';
            this.WebScopeCOSI.SimStatusString='simStopped';



            if~this.isWebWindowValid()
                this.MessageHandler.notOpen();
            end
            releaseStreamingSource(this);
            if this.ScopeLocked&&this.Specification.Visible
                matlabshared.application.waitfor(this.MessageHandler,'StopComplete',true,'Timeout',10);
                this.ScopeLocked=false;
                this.SetupCalled=false;
                this.ReleaseCalled=true;
            end
        end

        function reset(this)





            if(this.ScopeLocked)
                this.MessageHandler.reset();
                this.SetupCalled=false;
                this.Specification.release();
                this.StreamingSourceImpl.release();
                releaseStreamingSource(this);
                matlabshared.application.waitfor(this.MessageHandler,'StopComplete',true,'Timeout',10);
                this.MessageHandler.ready();
                this.ResetCalled=true;
            end
        end

        function newObject=clone(originalObject)









            newObject=originalObject.loadobj(saveobj(originalObject));
        end

        function show(this)



            this.Specification.Visible=true;
            this.HideCalled=false;
            if~isempty(this.Parent)

                showInsideParent(this);
            elseif isempty(this.Parent)&&this.RenderInMATLAB

                showInsideAppContainer(this)
            else


                show@matlabshared.scopes.WebWindow(this);

                this.WebScopeCOSI.WebWindow=this.WebWindowObject;

                shouldWait=true;
                if this.Docked
                    container=matlabshared.scopes.container.Container.getInstance(this.ContainerKey);
                    if~container.Visible
                        shouldWait=false;
                    end
                else



                    if this.getDebugLevel()>1
                        this.WebWindowObject.Tag=this.Tag;
                    end
                end

                if shouldWait
                    t=tic;
                    while toc(t)<10&&~this.MessageHandler.OpenComplete
                        drawnow;
                    end
                end
            end
        end

        function hide(this)



            this.Specification.Visible=false;
            this.HideCalled=true;
            if~this.Docked&&this.RenderInMATLAB
                hide(this.ScopeView);
            else
                hide@matlabshared.scopes.WebWindow(this);
            end
        end

        function b=isVisible(this)



            b=isVisible@matlabshared.scopes.WebWindow(this);
        end

        function flag=isLocked(this)





            flag=this.ScopeLocked;
        end

        function infoStruct=info(~)



            infoStruct=struct([]);
        end

        function delete(this)
            if~this.Docked&&this.RenderInMATLAB
                delete(this.ScopeView);
            else
                close(this);
            end
            delete(this.Specification);
        end
    end



    methods(Access=public,Hidden)

        function name=getName(this)
            name=this.Name;
        end

        function valid=isWebWindowValid(this)
            valid=true;

            if~isempty(this.WebWindowObject)
                valid=this.WebWindowObject.isWindowValid;
            end
        end

        function setup(this,data)
            if~iscell(data)
                data={data};
            end

            validateInputs(this,data);

            validatePropertiesOnSetup(this);

            if~isScopeLaunched(this)&&any(this.MessageHandler.DebugLevel>=3)&&~this.HideCalled
                show(this);
            end


            updateSampleTimeAndOffset(this);

            setupStreamingSource(this,data{:});

            this.Specification.NumChannels=this.NumChannels;

            this.Specification.IsInputComplex=this.IsInputComplex;

            this.SetupCalled=true;

            this.ScopeLocked=true;

            this.Specification.ScopeLocked=true;

            this.ReleaseCalled=false;

            this.ResetCalled=false;
        end

        function setupRaw(this,data)

            setup(this,data);
        end

        function str=getQueryString(this,varargin)



            str=getQueryString@matlabshared.scopes.WebStreamingSource(this,...
            'Toolstrip',utils.logicalToOnOff(isJavaScriptToolstripEnabled(this)),...
            'Statusbar',utils.logicalToOnOff(this.HasStatusbar),...
            'HasDockControls',utils.logicalToOnOff(this.HasDockControls),...
            'Product',this.Product,...
            'Deployed',utils.logicalToOnOff(isdeployed),varargin{:});
        end

        function varargout=setDebugLevel(this,varargin)
            [varargout{1:nargout}]=setDebugLevel@matlabshared.scopes.WebStreamingSource(this,varargin{:});
        end

        function level=getDebugLevel(this)
            level=getDebugLevel@matlabshared.scopes.WebStreamingSource(this);
        end

        function val=getNumInputs(this)
            val=this.NumInputPorts;
        end

        function val=getNumOutputs(~)
            val=0;
        end

        function p=getValueOnlyProperties(~)
            p={'NumInputPorts'};
        end

        function o=nargin(~)
            o=1;
        end

        function n=getNumChannels(this)
            if~isempty(this.CachedInputInfo)&&~isLocked(this)


                n=sum(this.CachedInputInfo(2,:));
            else


                n=this.Specification.getNumChannels();
            end
        end

        function flag=needsTimedBuffer(this)
            flag=this.NeedsTimedBuffer;
        end

        function close(this)

            if isvalid(this.Specification)
                this.Specification.Visible=false;
            end
            close@matlabshared.scopes.WebWindow(this);
        end

        function flag=isInactiveProperty(this,propName)
            flag=isInactiveProperty(this.Specification,propName);
        end

        function validProps=getValidDisplayProperties(this,props)
            validProps=getValidDisplayProperties(this.Specification,props);
        end
    end



    methods(Hidden=true,Sealed=true)
        function parenReference(obj,varargin)


            step(obj,varargin{:});
        end
    end



    methods(Access=protected)

        function S=saveobj(this)
            S.class=class(this);
            S.MessageHandler=this.MessageHandler.toStruct();
            S.Specification=this.Specification.toStruct();
            S.Style=this.Specification.Style.toStruct();
            S.HideCalled=this.HideCalled;
            S.Visible=this.Specification.Visible;
            S.ScopeLocked=this.ScopeLocked;
            S.CachedInputInfo=this.CachedInputInfo;
            S.NumChannels=this.NumChannels;
            S.IsInputComplex=this.IsInputComplex;
        end

        function validateInputs(this,data)
            import dsp.webscopes.internal.*;
            nInputs=numel(data);



            if(nInputs~=this.NumInputPorts&&strcmpi(this.NumInputPortsSource,'auto'))




                this.validatePropertiesOnSet('NumInputPorts')
                this.setPropertyValue('NumInputPorts',nInputs);

                this.NumInputs=nInputs;
            end

            if nInputs<this.NumInputPorts
                BaseWebScope.localError('insufficientInputSignals',this.NumInputPorts,nInputs);
            end
            if nInputs>this.NumInputPorts
                BaseWebScope.localError('extraInputSignals',this.NumInputPorts,nInputs);
            end

            validateClientInputs(this,data);

            cachedInputInfo=this.CachedInputInfo;
            inputInfo=zeros(3,nInputs);
            currPortComplexity=zeros(1,nInputs);
            for indx=1:nInputs

                sz=size(data{indx});
                currPortFrameLength=sz(1);
                currPortNumChans=sz(2);
                currPortComplexity(1,indx)=~isreal(data{indx});

                if currPortNumChans==0
                    BaseWebScope.localError('zeroChannels');
                end
                if~isempty(cachedInputInfo)
                    if(size(cachedInputInfo,2)>=indx)



                        if(cachedInputInfo(2,indx)~=currPortNumChans)
                            BaseWebScope.localError('varSizeChannelsNotSupported',indx);
                        end
                    end


                    if currPortComplexity(1,indx)&&~cachedInputInfo(3,indx)
                        BaseWebScope.localError('changingComplexityNotSupported',indx);
                    end



                    inputInfo(1,indx)=currPortFrameLength;
                    inputInfo(2,indx)=currPortNumChans;
                    inputInfo(3,indx)=cachedInputInfo(3,indx);
                else

                    inputInfo(:,indx)=[currPortFrameLength;currPortNumChans;~isreal(data{indx})];
                end
            end


            this.InputsChangedComplexity=inputInfo(3,:)-currPortComplexity(1,:);


            if sum(inputInfo(2,:))>this.MaxNumChannels
                BaseWebScope.localError('numChannelsGreaterThanSupported',this.MaxNumChannels);
            end

            this.CachedInputInfo=inputInfo;
            if(any(inputInfo(3,:)))
                this.setIsAnySignalComplex(true);
            end
            if(isempty(data{1}))
                return;
            end


            if(this.SetupCalled)

                optionList=[];
                actionName='onInputSizeChange';
                frameSize=int32(inputInfo(1,:));
                numChannels=int32(inputInfo(2,:));
                isComplex=int32(inputInfo(3,:));
                optionList.numSignals=nInputs;
                optionList.clientID=this.MessageHandler.ClientId;
                optionList.numChannels=(isComplex.*numChannels)+numChannels;
                optionList.frameSize=frameSize;
                optionList.isComplex=isComplex;

                this.MessageHandler.onInputSizeChange(frameSize);
                if this.needsTimedBuffer
                    this.StreamingSourceImpl.setupWebScopeTimedBuffer(data);
                end
                this.StreamingSourceImpl.updateFilterAndDeviceProperties(optionList,actionName);
            end
        end

        function validateClientInputs(~,~)


        end

        function setProperties(this,varargin)
            if(~isempty(varargin))
                pIdx=1;
                vIdx=1;
                valueProps=this.getValueOnlyProperties();
                while pIdx<=numel(varargin)
                    if(isnumeric(varargin{pIdx}))
                        this.(valueProps{vIdx})=varargin{pIdx};
                        pIdx=pIdx+1;
                        vIdx=vIdx+1;
                    else
                        if pIdx+1>numel(varargin)
                            dsp.webscopes.internal.BaseWebScope.localError('invalidPVPairs')
                        end
                        set(this,varargin{pIdx},varargin{pIdx+1});
                        pIdx=pIdx+2;
                    end
                end
            end
        end


        function validatePropertiesOnSet(this,propName)
            switch propName
            case 'NumInputPorts'
                if(this.isLocked)
                    dsp.webscopes.internal.BaseWebScope.localError('propertySetWhenLocked',propName);
                end
            end
        end


        function validatePropertiesOnSetup(this)
            import dsp.webscopes.internal.*;

            if this.MeasurementChannel>this.getNumChannels()
                BaseWebScope.localError('invalidMeasurementChannelNumber',this.getNumChannels());
            end
        end

        function inputInfo=getCurrentInputInfo(~,data)
            inputInfo=zeros(3,numel(data));
            for indx=1:numel(data)
                sz=size(data{indx});
                frameSize=sz(1);
                numChannels=prod(sz(2:end));
                inputInfo(:,indx)=[frameSize;numChannels;~isreal(data{indx})];
            end
        end

        function flag=isScopeLaunched(this)
            flag=isWindowLaunched(this);
        end

        function setScopeName(this,name)
            if~this.Docked&&this.RenderInMATLAB
                if~isempty(this.ScopeView)
                    setName(this.ScopeView,name);
                end
            else
                setName(this,name);
            end
        end

        function style=getStyleConfiguration(this)
            style=dsp.webscopes.style.StyleConfiguration(this.Specification.Style);
        end

        function filters=getFilterImpls(this)


            [keys,filters]=this.Specification.getSupportedFiltersImpls();
            if~strcmp(this.StreamingEngine,'AsyncIO')


                filterIdx=strcmpi(keys,'postsimstorage');
                filters(filterIdx)=[];
            end
        end

        function setScopeParent(this)
            import dsp.webscopes.internal.*;
            if(this.isVisible||this.Docked)
                BaseWebScope.localError('invalidToBeParented');
            end
            if isempty(this.UIHTMLContainer)
                pos=utils.getDefaultWebWindowPosition([800,500]);
                this.UIHTMLContainer=uihtml(this.Parent,...
                'Position',[1,1,pos(3),pos(4)],...
                'HTMLSource',this.getFullUrl());
                matlabshared.application.waitfor(this.MessageHandler,'OpenComplete',true,'Timeout',10)
            else
                this.UIHTMLContainer.Parent=this.Parent;
            end
        end

        function data=fixInputComplexity(~,data)
            data=complex(data);
        end

        function flag=isJavaScriptToolstripEnabled(this)




            flag=this.HasToolstrip&&~this.Docked&&~this.RenderInMATLAB;
        end

        function createScopeView(~)

        end

        function showInsideParent(this)


            connector.ensureServiceOn;
            this.RenderInMATLAB=true;
            matlabshared.application.waitfor(this.MessageHandler,'OpenComplete',true,'Timeout',10);
        end

        function showInsideAppContainer(this)
            if isempty(this.ScopeView)
                createScopeView(this);
                matlabshared.application.waitfor(this.MessageHandler,'OpenComplete',true,'Timeout',10)
            else
                show(this.ScopeView);
            end
        end
    end



    methods(Abstract,Access=protected)

        updateSampleTimeAndOffset(this)
    end



    methods(Static,Hidden)

        function this=loadobj(S)
            if(isstruct(S))
                this=eval(S.class);
                this.MessageHandler.fromStruct(S.MessageHandler);
                this.Specification.fromStruct(S.Specification);
                if(isfield(S,'NumChannels'))
                    this.NumChannels=S.NumChannels;
                    this.Specification.NumChannels=S.NumChannels;
                end
                if(isfield(S,'IsInputComplex'))
                    this.IsInputComplex=S.IsInputComplex;
                    this.Specification.IsInputComplex=S.IsInputComplex;
                end
                if(isfield(S,'Style'))
                    this.Specification.Style.fromStruct(S.Style);
                end
                if(isfield(S,'CachedInputInfo'))
                    this.CachedInputInfo=S.CachedInputInfo;
                end
            end
        end

        function flag=isCharOrString(value)
            flag=ischar(value)||isstring(value);
        end

        function localError(ID,varargin)
            id=['shared_dspwebscopes:dspwebscopes:',ID];
            ME=MException(message(id,varargin{:}));
            throwAsCaller(ME);
        end

        function localWarning(ID,varargin)
            id=['shared_dspwebscopes:dspwebscopes:',ID];
            warning(message(id,varargin{:}));
        end

        function webWindow=getWebWindowFromClientID(clientID)
            scopeObj=matlabshared.scopes.WebScope.getInstance(clientID);
            webWindow=scopeObj.WebWindow;
        end

        function fig=prepareWebWindowForSharing(clientID,action,encodedImage)

            import dsp.webscopes.internal.*;
            import matlab.internal.lang.capability.Capability;
            decoded=matlab.net.base64decode(encodedImage);
            screenshot=matlab.graphics.internal.convertImageBytesToCData(decoded);

            whiteIndices=all(squeeze(screenshot(:,1,:))==[255,255,255],2);
            topOfAxes=find(whiteIndices,1,'first');
            botOfAxes=find(whiteIndices,1,'last');
            if~isempty(topOfAxes)&&~isempty(botOfAxes)
                screenshot([1:topOfAxes-1,botOfAxes+1:end],:,:)=[];
            end
            webWindow=BaseWebScope.getWebWindowFromClientID(clientID);
            scopePos=webWindow.Position;
            copyAction=strcmpi(action,'copy');
            fig=figure(...
            'HandleVisibility',utils.logicalToOnOff(copyAction||~Capability.isSupported(Capability.LocalClient)),...
            'Visible','off',...
            'Units','pixels',...
            'PaperOrientation','landscape');
            printPos=fig.Position;
            printPos(2)=printPos(2)-(scopePos(4)-printPos(4))/2;
            figCentre=[printPos(1)+printPos(3)/2,printPos(2)+printPos(4)/2];
            printPos(1)=figCentre(1)-scopePos(3)/2;
            printPos(2)=figCentre(2)-scopePos(3)/2;
            pf=utils.getPixelFactor;
            if copyAction
                fig.Position=[printPos(1),printPos(2),scopePos(3),scopePos(4)];
            else
                fig.Position=[printPos(1),printPos(2),800*pf,500*pf];
            end

            w=size(screenshot,2);
            h=size(screenshot,1);

            a=axes(fig,...
            'YDir','reverse',...
            'XLim',[0.5,w+0.5],...
            'YLim',[0.5,h+0.5],...
            'DataAspectRatio',[1,1,1],...
            'PlotBoxAspectRatioMode','auto',...
            'Visible','off');

            image(a,...
            'XData',[1,w],...
            'YData',[1,h],...
            'CData',screenshot);

            matlab.ui.internal.PositionUtils.setDevicePixelPosition(fig,[20,20,w+40,h+40]);
            matlab.ui.internal.PositionUtils.setDevicePixelPosition(a,[20,20,w,h]);
        end

        function copyDisplay(clientID,scopeTag,encodedImage)

            import dsp.webscopes.internal.*;
            import matlab.internal.lang.capability.Capability;
            fig=BaseWebScope.prepareWebWindowForSharing(clientID,'copy',encodedImage);
            if Capability.isSupported(Capability.LocalClient)


                if(ispc)
                    print('-clipboard','-dmeta');
                else
                    print('-clipboard','-dbitmap');
                end
            else


                uniqueName=BaseWebScope.getUniqueFileName(scopeTag);
                print(uniqueName,'-dpdf');
            end
            delete(fig);
        end

        function printDisplay(clientID,scopeTag,encodedImage)

            import dsp.webscopes.internal.*;
            import matlab.internal.lang.capability.Capability;
            fig=BaseWebScope.prepareWebWindowForSharing(clientID,'print',encodedImage);
            if Capability.isSupported(Capability.LocalClient)

                printdlg(fig);
            else

                uniqueName=BaseWebScope.getUniqueFileName(scopeTag);
                print(uniqueName,'-dpdf');
            end
            delete(fig);
        end

        function uniqueName=getUniqueFileName(desiredName)


            dirPDFFiles=dir('./*.pdf');
            existingPDFNames={''};
            if~isempty(dirPDFFiles)
                existingPDFNames={dirPDFFiles.name};

                existingPDFNames=regexprep(existingPDFNames,'.pdf','');
            end
            uniqueName=matlab.lang.makeUniqueStrings(desiredName,existingPDFNames);
        end

        function flag=isSavedAsUnifiedScope(S)


            if isfield(S,'ClassNameForLoadTimeEval')
                flag=true;
            else
                flag=false;
            end
        end

        function cfg=getUnifiedScopeConfiguration(S)

            S=S.ChildClassData;
            if(isfield(S,'ScopeConfiguration'))

                cfg.ScopeConfig=S.ScopeConfiguration.CurrentConfiguration.findChild('Type','Visuals').PropertySet;
                if cfg.ScopeConfig.isValidProperty('SerializedDisplays')
                    cfg.DispConfig=cfg.ScopeConfig.getValue('SerializedDisplays');
                else
                    cfg.DispConfig=cfg.ScopeConfig.getValue('AxesProperties');
                end
                cfg.Name=S.Name;
                cfg.Visible=S.Visible;
                cfg.NumInputPorts=S.NumInputPorts;
            else
                cfg.ScopeConfig=[];
                cfg.DispConfig=[];
                cfg.Name='';
                cfg.Visible=false;
                cfg.NumInputPorts=1;
            end
        end

        function className=getUnifiedScopeClassName(S)

            className=S.ClassNameForLoadTimeEval;
        end

        function publishMessage(clientID,action,value)


            channel=['/webscope',clientID];
            msg.action=[action,clientID];
            msg.params=value;
            message.publish(channel,msg);
        end

        function fevalHandler(action,clientID,varargin)%#ok<INUSD>
            import dsp.webscopes.internal.*;
            switch action
            case 'closeRequested'


            case 'logMessage'

                fprintf('%s\n',varargin{1});
            case 'dock'
            end
        end
    end
end
