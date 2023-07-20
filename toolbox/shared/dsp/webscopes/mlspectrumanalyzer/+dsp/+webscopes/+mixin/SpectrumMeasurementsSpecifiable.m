classdef SpectrumMeasurementsSpecifiable<handle







    properties

        ChannelMeasurements;

        DistortionMeasurements;

        SpectralMask;
    end



    methods(Access=protected)

        function addSpectrumMeasurementsSpecification(this)
            this.ChannelMeasurements=getSpectrumMeasurementSpecification(this,'channel');
            this.DistortionMeasurements=getSpectrumMeasurementSpecification(this,'distortion');
            this.SpectralMask=getSpectrumMeasurementSpecification(this,'spectralmask');
        end

        function spec=getSpectrumMeasurementSpecification(this,measurer)
            switch(measurer)
            case 'channel'
                spec=dsp.webscopes.measurements.ChannelMeasurementsSpecification(this);
            case 'distortion'
                spec=dsp.webscopes.measurements.DistortionMeasurementsSpecification(this);
            case 'spectralmask'
                spec=dsp.webscopes.measurements.SpectralMaskSpecification(this);
            end
        end
    end
end

