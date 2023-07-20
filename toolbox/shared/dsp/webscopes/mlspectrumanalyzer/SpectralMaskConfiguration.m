classdef SpectralMaskConfiguration<dsp.webscopes.measurements.BaseMeasurementConfiguration



































    properties(Dependent)




        EnabledMasks;











        UpperMask;











        LowerMask;










        ReferenceLevel;







        CustomReferenceLevel;





        SelectedChannel;





        MaskFrequencyOffset;
    end

    events





MaskTestFailed
    end

    properties(Constant,Hidden)

        EnabledMasksSet={'none','upper','lower','upper-and-lower'};
        EnabledMasksObsoleteSet={'None','Upper','Lower','Upper and lower'};
        ReferenceLevelSet={'spectrum-peak','custom'};
        ReferenceLevelObsoleteSet={'Spectrum peak','Custom'};
    end



    methods

        function this=SpectralMaskConfiguration(hSpec)
            if nargin>0
                this.Specification=hSpec;
            else
                this.Specification=dsp.webscopes.measurements.SpectralMaskSpecification;
            end
        end


        function set.EnabledMasks(this,value)
            validatePropertiesOnSet(this,'SpectralMask');
            value=validateEnum(this,'EnabledMasks',value);
            setPropertyValue(this.Specification,'Enabled',~strcmpi(value,'none'));
            setPropertyValue(this.Specification,'EnabledMasks',value);
        end
        function value=get.EnabledMasks(this)
            value=getPropertyValue(this.Specification,'EnabledMasks');
        end


        function set.UpperMask(this,value)
            validateMaskData(this,value,'UpperMask');
            validateUpperMaskFrequencyLimits(this,value);
            setPropertyValue(this.Specification,'UpperMask',value);
        end
        function value=get.UpperMask(this)
            value=getPropertyValue(this.Specification,'UpperMask');
        end


        function set.LowerMask(this,value)
            validateMaskData(this,value,'LowerMask');
            validateLowerMaskFrequencyLimits(this,value);
            setPropertyValue(this.Specification,'LowerMask',value);
        end
        function value=get.LowerMask(this)
            value=getPropertyValue(this.Specification,'LowerMask');
        end


        function set.ReferenceLevel(this,value)
            value=validateEnum(this,'ReferenceLevel',value);
            setPropertyValue(this.Specification,'ReferenceLevel',value);
        end
        function value=get.ReferenceLevel(this)
            value=getPropertyValue(this.Specification,'ReferenceLevel');
        end


        function set.CustomReferenceLevel(this,value)
            validateattributes(value,{'numeric'},...
            {'scalar','real','nonnan'},'','CustomReferenceLevel');
            setPropertyValue(this.Specification,'CustomReferenceLevel',value);
        end
        function value=get.CustomReferenceLevel(this)
            value=getPropertyValue(this.Specification,'CustomReferenceLevel');
        end


        function set.SelectedChannel(this,value)
            validateattributes(value,{'numeric'},...
            {'scalar','positive','integer'},'','SelectedChannel');
            validateSelectedChannel(this,value);
            setPropertyValue(this.Specification,'SelectedChannel',value);
        end
        function value=get.SelectedChannel(this)
            value=getPropertyValue(this.Specification,'SelectedChannel');
        end


        function set.MaskFrequencyOffset(this,value)
            validateattributes(value,{'numeric'},...
            {'scalar','real','finite'},'','MaskFrequencyOffset');
            validateMaskFrequencyOffset(this,value);
            setPropertyValue(this.Specification,'MaskFrequencyOffset',value);
        end
        function value=get.MaskFrequencyOffset(this)
            value=getPropertyValue(this.Specification,'MaskFrequencyOffset');
        end
    end



    methods(Hidden)

        function validateSpectralMaskFrequencyLimits(this)
            validateLowerMaskFrequencyLimits(this,this.LowerMask);
            validateUpperMaskFrequencyLimits(this,this.UpperMask);
        end
    end



    methods(Access=protected)

        function groups=getPropertyGroups(this)


            propList=getValidDisplayProperties(this.Specification,{...
            'EnabledMasks',...
            'UpperMask',...
            'LowerMask',...
            'ReferenceLevel',...
            'SelectedChannel',...
            'CustomReferenceLevel',...
            'MaskFrequencyOffset'});
            groups=matlab.mixin.util.PropertyGroup(propList);
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
    end



    methods(Access=protected)

        function validatePropertiesOnSet(this,propName)
            import dsp.webscopes.*;
            if~isempty(this.Specification.Specification)
                if isInactiveProperty(this.Specification.Specification,propName)
                    SpectrumAnalyzerBaseWebScope.localWarning('nonRelevantProperty',propName);
                end
            end
        end
    end



    methods(Access=private)

        function[Fstart,Fstop]=getCurrentFrequencyLimits(this)
            [Fstart,Fstop]=this.Specification.Specification.getCurrentFrequencyLimits;
        end

        function validateMaskData(~,value,propName)
            validateattributes(value,{'numeric'},{'nonempty','real'},'',propName);
            if~(isscalar(value)||(ismatrix(value)&&size(value,1)>1&&size(value,2)==2))
                error(message('shared_dspwebscopes:spectrumanalyzer:invalidMaskData',propName));
            end
            if~isscalar(value)&&(any(isnan(value(:,1)))||~all(diff(value(:,1))>=0))
                error(message('shared_dspwebscopes:spectrumanalyzer:invalidMaskFrequencyData',propName));
            end
        end

        function validateSelectedChannel(this,value)

            if strcmpi(this.ReferenceLevel,'spectrum-peak')&&this.isLocked
                numChannels=getNumChannels(this);
                if isnumeric(value)&&value>numChannels
                    throwAsCaller(MException(message('shared_dspwebscopes:spectrumanalyzer:invalidMaskChannelNumber',numChannels)));
                end
            end
        end

        function validateMaskFrequencyOffset(this,offsetValue)

            if this.isLocked()
                [Fstart,Fstop]=this.getCurrentFrequencyLimits;
                if~isscalar(this.UpperMask)&&any(strcmp(this.EnabledMasks,{'upper','upper-and-lower'}))
                    freqUpper=this.UpperMask(:,1)+offsetValue;
                    if(max(freqUpper)<Fstart)||(min(freqUpper)>Fstop)
                        warning(message('shared_dspwebscopes:spectrumanalyzer:maskFallsOutsideFrequencyRange','upper'));
                    end
                end
                if~isscalar(this.LowerMask)&&any(strcmp(this.EnabledMasks,{'lower','upper-and-lower'}))
                    freqLower=this.LowerMask(:,1)+offsetValue;
                    if(max(freqLower)<Fstart)||(min(freqLower)>Fstop)
                        warning(message('shared_dspwebscopes:spectrumanalyzer:maskFallsOutsideFrequencyRange','lower'));
                    end
                end
            end
        end

        function validateUpperMaskFrequencyLimits(this,upperMaskValue)

            if~isscalar(upperMaskValue)&&any(strcmpi(this.EnabledMasks,{'upper','upper-and-lower'}))...
                &&this.isLocked
                [Fstart,Fstop]=this.getCurrentFrequencyLimits;
                freqUpper=upperMaskValue(:,1)+this.MaskFrequencyOffset;
                if(max(freqUpper)<Fstart)||(min(freqUpper)>Fstop)
                    warning(message('shared_dspwebscopes:spectrumanalyzer:maskFallsOutsideFrequencyRange','upper'));
                end
            end
        end

        function validateLowerMaskFrequencyLimits(this,lowerMaskValue)

            if~isscalar(lowerMaskValue)&&any(strcmp(this.EnabledMasks,{'lower','upper-and-lower'}))...
                &&this.isLocked
                [Fstart,Fstop]=this.getCurrentFrequencyLimits;
                freqLower=lowerMaskValue(:,1)+this.MaskFrequencyOffset;
                if(max(freqLower)<Fstart)||(min(freqLower)>Fstop)
                    warning(message('shared_dspwebscopes:spectrumanalyzer:maskFallsOutsideFrequencyRange','lower'));
                end
            end
        end
    end
end