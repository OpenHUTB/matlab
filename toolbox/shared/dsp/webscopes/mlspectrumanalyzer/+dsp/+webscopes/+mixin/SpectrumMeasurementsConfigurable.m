classdef SpectrumMeasurementsConfigurable<handle





    properties










        ChannelMeasurements;








        DistortionMeasurements;










        SpectralMask;
    end

    properties(Hidden)

        CCDFMeasurements;
    end



    methods

        function set.ChannelMeasurements(this,value)
            import dsp.webscopes.internal.*;
            if isa(value,'ChannelMeasurementsConfiguration')&&isvalid(value)
                if isempty(this.ChannelMeasurements)
                    this.ChannelMeasurements=value;
                else
                    set(this.ChannelMeasurements,get(value));
                end
            else
                BaseWebScope.localError('invalidMeasurementConfigurationObject','ChannelMeasurements','ChannelMeasurementsConfiguration');
            end
        end

        function set.DistortionMeasurements(this,value)
            import dsp.webscopes.internal.*;
            if isa(value,'DistortionMeasurementsConfiguration')&&isvalid(value)
                if isempty(this.DistortionMeasurements)
                    this.DistortionMeasurements=value;
                else
                    set(this.DistortionMeasurements,get(value));
                end
            else
                BaseWebScope.localError('invalidMeasurementConfigurationObject','DistortionMeasurements','DistortionMeasurementsConfiguration');
            end
        end

        function set.SpectralMask(this,value)
            import dsp.webscopes.internal.*;
            if isa(value,'SpectralMaskConfiguration')&&isvalid(value)
                if isempty(this.SpectralMask)
                    this.SpectralMask=value;
                else
                    set(this.SpectralMask,get(value));
                end
            else
                BaseWebScope.localError('invalidMeasurementConfigurationObject','SpectralMask','SpectralMaskConfiguration');
            end
        end


        function set.CCDFMeasurements(~,~)
            import dsp.webscopes.*;
            SpectrumAnalyzerBaseWebScope.localError('ccdfMeasurementsObsolete');
        end
        function value=get.CCDFMeasurements(~)%#ok<STOUT> 
            import dsp.webscopes.*;
            SpectrumAnalyzerBaseWebScope.localError('ccdfMeasurementsObsolete');
        end
    end



    methods(Access=protected)

        function addSpectrumMeasurementsConfiguration(this)
            this.ChannelMeasurements=getSpectrumMeasurementConfiguration(this,'channel');
            this.DistortionMeasurements=getSpectrumMeasurementConfiguration(this,'distortion');
            this.SpectralMask=getSpectrumMeasurementConfiguration(this,'spectralmask');
        end

        function config=getSpectrumMeasurementConfiguration(this,measurer)
            switch(measurer)
            case 'channel'
                if isempty(this.ChannelMeasurements)
                    config=ChannelMeasurementsConfiguration(this.Specification.ChannelMeasurements);
                else
                    config=this.ChannelMeasurements;
                end

                this.Specification.ChannelMeasurements.Configuration=config;
            case 'distortion'
                if isempty(this.DistortionMeasurements)
                    config=DistortionMeasurementsConfiguration(this.Specification.DistortionMeasurements);
                else
                    config=this.DistortionMeasurements;
                end

                this.Specification.DistortionMeasurements.Configuration=config;
            case 'spectralmask'
                if isempty(this.SpectralMask)
                    config=SpectralMaskConfiguration(this.Specification.SpectralMask);
                else
                    config=this.SpectralMask;
                end

                this.Specification.SpectralMask.Configuration=config;
            end
        end
    end
end
