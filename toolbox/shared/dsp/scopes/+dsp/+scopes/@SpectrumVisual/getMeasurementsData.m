function data=getMeasurementsData(this,allFlag)





    if nargin<2
        allFlag=false;
    end

    allData=this.pCachedMeasurementsData;
    enabledMeasurements=this.pCachedEnabledMeasurements;

    if this.IsNewMeasurementsDataReady

        allData.SimulationTime={this.SimulationTime};

        enabledMeasurements(1,2)=false;
        if isvalid(this.PeakFinderObject)
            if this.PeakFinderObject.Enable
                allData.PeakFinder=struct('Frequency',this.PeakFinderObject.Results.xData.',...
                'Value',this.PeakFinderObject.Results.yData);
                enabledMeasurements(1,2)=true;
            end
        end

        enabledMeasurements(1,3)=false;
        if isvalid(this.CursorMeasurementsObject)
            if this.CursorMeasurementsObject.Enable
                allData.CursorMeasurements=this.CursorMeasurementsObject.Results;
                enabledMeasurements(1,3)=true;
            end
        end


        enabledMeasurements(1,4)=false;
        if isvalid(this.ChannelMeasurementsObject)
            if this.ChannelMeasurementsObject.Enable
                if strcmpi(this.ChannelMeasurementsObject.Algorithm,'ACPR')
                    allData.ChannelMeasurements=struct(...
                    'ChannelPower',this.ChannelMeasurementsObject.Results.ChannelPower,...
                    'ACPRLower',this.ChannelMeasurementsObject.Results.ACPR(:,1),...
                    'ACPRUpper',this.ChannelMeasurementsObject.Results.ACPR(:,2));
                else
                    allData.ChannelMeasurements=struct(...
                    'ChannelPower',this.ChannelMeasurementsObject.Results.Readout(1),...
                    'OccupiedBW',this.ChannelMeasurementsObject.Results.Readout(2),...
                    'FrequencyError',this.ChannelMeasurementsObject.Results.Readout(3));
                end
                enabledMeasurements(1,4)=true;
            end
        end


        enabledMeasurements(1,5)=false;
        if isvalid(this.DistortionMeasurementsObject)
            if this.DistortionMeasurementsObject.Enable
                if strcmpi(this.DistortionMeasurementsObject.Algorithm,'Harmonic')
                    allData.DistortionMeasurements=struct(...
                    'HarmonicNumber',(1:this.DistortionMeasurementsObject.NumHarmonics).',...
                    'Frequency',this.DistortionMeasurementsObject.Results.Frequency,...
                    'Power',this.DistortionMeasurementsObject.Results.Power,...
                    'THD',this.DistortionMeasurementsObject.Results.Readout(1),...
                    'SNR',this.DistortionMeasurementsObject.Results.Readout(2),...
                    'SINAD',this.DistortionMeasurementsObject.Results.Readout(3),...
                    'SFDR',this.DistortionMeasurementsObject.Results.Readout(4));
                else
                    allData.DistortionMeasurements=struct(...
                    'Frequency',this.DistortionMeasurementsObject.Results.Frequency,...
                    'Power',this.DistortionMeasurementsObject.Results.Power,...
                    'TOI',this.DistortionMeasurementsObject.Results.Readout(1));
                end
                enabledMeasurements(1,5)=true;
            end
        end
        if~this.IsSystemObjectSource

            enabledMeasurements(1,6)=false;
            if isvalid(this.CCDFMeasurementsObject)
                if this.CCDFMeasurementsObject.Enable
                    allData.CCDFMeasurements=struct('Probability',this.CCDFMeasurementsObject.Results.Probability.',...
                    'DBAboveAverage',this.CCDFMeasurementsObject.Results.DBAboveAverage,...
                    'AveragePower',this.CCDFMeasurementsObject.Results.Readout(1),...
                    'MaxPower',this.CCDFMeasurementsObject.Results.Readout(2),...
                    'PAPR',this.CCDFMeasurementsObject.Results.Readout(3),...
                    'SampleCount',this.CCDFMeasurementsObject.Results.Readout(4));
                    enabledMeasurements(1,6)=true;
                end
            end
        end


        this.pCachedEnabledMeasurements=enabledMeasurements;
        this.IsNewMeasurementsDataReady=false;
        this.pCachedMeasurementsData=allData;
    end

    if~allFlag
        idx=enabledMeasurements;
        data=allData(:,idx);
    else
        data=allData;
    end

end