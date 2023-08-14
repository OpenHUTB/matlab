classdef SpectralMaskSpecification<handle&matlab.mixin.SetGet&...
    matlab.mixin.CustomDisplay





















































    properties(Dependent)




EnabledMasks











UpperMask











LowerMask










ReferenceLevel







CustomReferenceLevel






SelectedChannel





MaskFrequencyOffset
    end

    events





MaskTestFailed
    end

    events(NotifyAccess='private',Hidden)
MaskUpdated
    end

    properties(Transient,Hidden)

        Application;

        hVisual;
    end

    properties(Access=protected)


pMaskSpecificationObject
    end

    properties(Constant,Hidden)

        EnabledMasksSet={'None','Upper','Lower','Upper and lower'};
        ReferenceLevelSet={'Spectrum peak','Custom'};
    end





    methods
        function obj=SpectralMaskSpecification(hApp)

            if nargin>0
                obj.Application=hApp;
                obj.hVisual=obj.Application.Visual;
            else
                obj.pMaskSpecificationObject=struct('EnabledMasks','None',...
                'UpperMask',Inf,...
                'LowerMask',-Inf,...
                'ReferenceLevel','Custom',...
                'CustomReferenceLevel',0,...
                'SelectedChannel',1,...
                'MaskFrequencyOffset',0);
            end
        end

        function set.EnabledMasks(obj,val)

            val=convertStringsToChars(val);
            val=validateEnum(obj,val,'EnabledMasks',obj.EnabledMasksSet);
            validateSelectedChannel(obj,obj.SelectedChannel);
            setVisualProperty(obj,'EnabledMasks',val,false);
            validateMaskFrequencyOffset(obj,obj.MaskFrequencyOffset);
            notify(obj,'MaskUpdated');
        end

        function val=get.EnabledMasks(obj)
            val=getVisualProperty(obj,'EnabledMasks',false);
        end

        function set.UpperMask(obj,val)


            validateMaskData(obj,val,'UpperMask');
            validateUpperMaskFrequencyLimits(obj,val);
            setVisualProperty(obj,'UpperMask',val,true);
            notify(obj,'MaskUpdated');
        end

        function val=get.UpperMask(obj)
            val=getVisualProperty(obj,'UpperMask',true);
        end

        function set.LowerMask(obj,val)


            validateMaskData(obj,val,'LowerMask');
            validateLowerMaskFrequencyLimits(obj,val);
            setVisualProperty(obj,'LowerMask',val,true);
            notify(obj,'MaskUpdated');
        end

        function val=get.LowerMask(obj)
            val=getVisualProperty(obj,'LowerMask',true);
        end

        function set.ReferenceLevel(obj,val)

            val=convertStringsToChars(val);
            val=validateEnum(obj,val,'ReferenceLevel',obj.ReferenceLevelSet);
            setVisualProperty(obj,'ReferenceLevel',val,false);
            notify(obj,'MaskUpdated');
        end

        function val=get.ReferenceLevel(obj)
            val=getVisualProperty(obj,'ReferenceLevel',false);
        end

        function set.CustomReferenceLevel(obj,val)

            validateattributes(val,{'numeric'},...
            {'scalar','real','nonnan'},'','CustomReferenceLevel');
            setVisualProperty(obj,'CustomReferenceLevel',val,true);
            notify(obj,'MaskUpdated');
        end

        function val=get.CustomReferenceLevel(obj)
            val=getVisualProperty(obj,'CustomReferenceLevel',true);
        end

        function set.SelectedChannel(obj,val)

            validateattributes(val,{'numeric'},...
            {'scalar','positive','integer'},'','SelectedChannel');
            validateSelectedChannel(obj,val);
            setVisualProperty(obj,'SelectedChannel',val,true);
            notify(obj,'MaskUpdated');
        end

        function val=get.SelectedChannel(obj)
            val=getVisualProperty(obj,'SelectedChannel',true);
        end

        function set.MaskFrequencyOffset(obj,val)

            validateattributes(val,{'numeric'},...
            {'scalar','real','finite'},'','MaskFrequencyOffset');
            validateMaskFrequencyOffset(obj,val);
            setVisualProperty(obj,'MaskFrequencyOffset',val,true);
            notify(obj,'MaskUpdated');
        end

        function val=get.MaskFrequencyOffset(obj)
            val=getVisualProperty(obj,'MaskFrequencyOffset',true);
        end

        function varargout=set(obj,varargin)


            if nargin==2&&ischar(varargin{1})
                switch varargin{1}
                case{'EnabledMasks','ReferenceLevel'}
                    varargout{1}=obj.([varargin{1},'Set']);
                otherwise
                    varargout{1}=[];
                end
            else
                if nargout
                    varargout{1}=set@matlab.mixin.SetGet(obj,varargin{:});
                else
                    set@matlab.mixin.SetGet(obj,varargin{:});
                end
            end
        end
    end

    methods(Hidden)
        function propList=getValidPropertyList(obj)
            propList=getPropertyGroups(obj);
        end

        function[flag,props,vals]=getMeasurementsChangedProps(obj)
            defaultMeasureSpec=getDefaultMeasurementsSpec(obj);
            flag=false;
            props={};
            vals={};
            ctr=1;
            validProps=getValidPropertyList(obj);
            validProps=validProps.PropertyList;

            for idx=1:numel(validProps)

                if isnumeric(defaultMeasureSpec.(validProps{idx}))

                    if defaultMeasureSpec.(validProps{idx})~=obj.(validProps{idx})
                        flag=true;
                        props{ctr}=validProps{idx};%#ok<AGROW>
                        vals{ctr}=mat2str(obj.(validProps{idx}));%#ok<AGROW>
                        ctr=ctr+1;
                    end
                else

                    if~strcmpi(defaultMeasureSpec.(validProps{idx}),obj.(validProps{idx}))
                        flag=true;
                        props{ctr}=validProps{idx};%#ok<AGROW>
                        vals{ctr}=strcat('''',obj.(validProps{idx}),'''');%#ok<AGROW>
                        ctr=ctr+1;
                    end
                end
            end
        end

        function name=getMeasurementName(~)
            name='Spectral Mask';
        end

        function name=getMeasurementObjectName(~)
            name='SpectralMask';
        end
    end

    methods(Access=protected)
        function delete(~)


        end

        function groups=getPropertyGroups(this)


            if~isscalar(this)
                groups=getPropertyGroups@matlab.mixin.CustomDisplay(this);
            else
                propList={'EnabledMasks','UpperMask','LowerMask','ReferenceLevel'};
                if strcmp(this.ReferenceLevel,'Spectrum peak')
                    propList=[propList,{'SelectedChannel'}];
                elseif strcmp(this.ReferenceLevel,'Custom')
                    propList=[propList,{'CustomReferenceLevel'}];
                end
                propList=[propList,{'MaskFrequencyOffset'}];
                groups=matlab.mixin.util.PropertyGroup(propList);
            end
        end

        function footer=getFooter(this)


            if~isscalar(this)
                footer=getFooter@matlab.mixin.CustomDisplay(this);
            else
                eventsTitle=getString(message('MATLAB:ClassUstring:EVENTS_FUNCTION_LABEL',class(this)));
                eventsStr=events(this);
                footer=sprintf('  %s %s\n',eventsTitle,eventsStr{1});
            end
        end

        function value=validateEnum(~,value,propName,validValues)
            validateattributes(value,{'char'},{},'',propName);
            ind=find(ismember(lower(validValues),lower(value))==1,1);
            if isempty(ind)
                error(message('dspshared:SpectrumAnalyzer:invalidEnumValue',value,propName));
            end
            value=validValues{ind};
        end

        function validateMaskData(~,value,propName)
            validateattributes(value,{'numeric'},{'nonempty','real'},'',propName);
            if~(isscalar(value)||(ismatrix(value)&&size(value,1)>1&&size(value,2)==2))
                error(message('dspshared:SpectrumAnalyzer:invalidMaskData',propName));
            end
            if~isscalar(value)&&(any(isnan(value(:,1)))||~all(diff(value(:,1))>=0))
                error(message('dspshared:SpectrumAnalyzer:invalidMaskFrequencyData',propName));
            end
        end

        function validateSelectedChannel(obj,value)

            if~isempty(obj.Application)&&~isempty(obj.Application.Visual)...
                &&strcmp(obj.ReferenceLevel,'Spectrum peak')&&...
                obj.Application.Visual.isSourceRunning
                if isnumeric(value)&&value>obj.Application.Visual.DataBuffer.NumChannels
                    throwAsCaller(MException(message('dspshared:SpectrumAnalyzer:invalidMaskChannelNumber')));
                end
            end
        end

        function validateMaskFrequencyOffset(obj,offsetValue)

            if~isempty(obj.Application)&&~isempty(obj.Application.Visual)...
                &&obj.Application.Visual.isSourceRunning
                [Fstart,Fstop]=getCurrentFreqLimits(obj.Application.Visual);
                if~isscalar(obj.UpperMask)&&any(strcmp(obj.EnabledMasks,{'Upper','Upper and lower'}))
                    freqUpper=obj.UpperMask(:,1)+offsetValue;
                    if(max(freqUpper)<Fstart)||(min(freqUpper)>Fstop)
                        warning(message('dspshared:SpectrumAnalyzer:maskFallsOutsideFrequencyRange','upper'));
                    end
                end
                if~isscalar(obj.LowerMask)&&any(strcmp(obj.EnabledMasks,{'Lower','Upper and lower'}))
                    freqLower=obj.LowerMask(:,1)+offsetValue;
                    if(max(freqLower)<Fstart)||(min(freqLower)>Fstop)
                        warning(message('dspshared:SpectrumAnalyzer:maskFallsOutsideFrequencyRange','lower'));
                    end
                end
            end
        end

        function validateUpperMaskFrequencyLimits(obj,upperMaskValue)

            if~isscalar(upperMaskValue)&&~isempty(obj.Application)&&~isempty(obj.Application.Visual)...
                &&any(strcmp(obj.EnabledMasks,{'Upper','Upper and lower'}))...
                &&obj.Application.Visual.isSourceRunning
                [Fstart,Fstop]=getCurrentFreqLimits(obj.Application.Visual);
                freqUpper=upperMaskValue(:,1)+obj.MaskFrequencyOffset;
                if(max(freqUpper)<max(Fstart))||(min(freqUpper)>min(Fstop))
                    warning(message('dspshared:SpectrumAnalyzer:maskFallsOutsideFrequencyRange','upper'));
                end
            end
        end

        function validateLowerMaskFrequencyLimits(obj,lowerMaskValue)

            if~isscalar(lowerMaskValue)&&~isempty(obj.Application)&&~isempty(obj.Application.Visual)...
                &&any(strcmp(obj.EnabledMasks,{'Lower','Upper and lower'}))...
                &&obj.Application.Visual.isSourceRunning
                [Fstart,Fstop]=getCurrentFreqLimits(obj.Application.Visual);
                freqLower=lowerMaskValue(:,1)+obj.MaskFrequencyOffset;
                if(max(freqLower)<max(Fstart))||(min(freqLower)>min(Fstop))
                    warning(message('dspshared:SpectrumAnalyzer:maskFallsOutsideFrequencyRange','lower'));
                end
            end
        end

        function setVisualProperty(obj,name,value,evalFlag)
            if~isempty(obj.hVisual)
                if evalFlag


                    value=mat2str(value);
                end
                setPropertyValue(obj.hVisual,name,value);
            else
                obj.pMaskSpecificationObject.(name)=value;
            end
        end

        function value=getVisualProperty(obj,name,evalFlag)
            if~isempty(obj.hVisual)
                value=getPropertyValue(obj.hVisual,name);
                if evalFlag
                    value=uiservices.evaluate(value);
                end
            else
                value=obj.pMaskSpecificationObject.(name);
            end
        end

        function spec=getDefaultMeasurementsSpec(~)
            spec=dsp.scopes.SpectralMaskSpecification;
        end
    end
end
