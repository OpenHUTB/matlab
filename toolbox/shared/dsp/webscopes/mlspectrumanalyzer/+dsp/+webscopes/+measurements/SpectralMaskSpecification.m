classdef SpectralMaskSpecification<dsp.webscopes.measurements.BaseMeasurementSpecification






    properties(AbortSet)
        EnabledMasks='none';
        UpperMask=Inf;
        LowerMask=-Inf;
        ReferenceLevel='custom';
        CustomReferenceLevel=0;
        SelectedChannel=1;
        MaskFrequencyOffset=0;
    end



    methods


        function propValue=preprocessPropertyValue(~,propName,value)
            propValue=value;
            if any(strcmpi(propName,{'UpperMask','LowerMask'}))
                propValue=string(value);
            end
        end


        function settings=getSettings(this)
            settings.EnabledMasks=this.EnabledMasks;
            settings.UpperMask=string(this.UpperMask);
            settings.LowerMask=string(this.LowerMask);
            settings.ReferenceLevel=this.ReferenceLevel;
            settings.CustomReferenceLevel=this.CustomReferenceLevel;
            settings.SelectedChannel=this.SelectedChannel;
            settings.MaskFrequencyOffset=this.MaskFrequencyOffset;
        end


        function S=toStruct(this)
            S=getSettings(this);
            S.UpperMask=double(S.UpperMask);
            S.LowerMask=double(S.LowerMask);
            S.SelectedChannel=this.SelectedChannel;
            S.Enabled=this.Enabled;
        end


        function setSettings(this,S)
            propNames=fields(S);
            for idx=1:numel(propNames)
                propName=propNames{idx};
                if isprop(this,propName)
                    propValue=S.(propName);
                    if any(strcmpi(propName,{'UpperMask','LowerMask'}))&&ischar(propValue)
                        propValue=str2num(propValue);%#ok<ST2NM> 
                    end
                    this.(propName)=propValue;
                end
            end
        end

        function flag=isInactiveProperty(this,propName)
            flag=false;
            switch propName
            case 'SelectedChannel'
                flag=strcmpi(this.ReferenceLevel,'custom');
            case 'CustomReferenceLevel'
                flag=strcmpi(this.ReferenceLevel,'spectrum-peak');
            case 'Enabled'
                flag=true;
            end
        end

        function flag=isEnabled(this)
            flag=~strcmpi(this.EnabledMasks,'none');
        end
    end



    methods(Hidden)

        function name=getMeasurementPropertyName(~)
            name='SpectralMask';
        end

        function name=getMeasurementName(~)
            name='Spectral Mask';
        end
    end
end
