classdef DataModel<handle




    properties
UplinkLink
TxEarth
RxSatellite
UplinkPropagation
DownlinkLink
TxSatellite
RxEarth
DownlinkPropagation
UplinkResults
DownlinkResults

    end

    events
SpecificationChanged
ResultsComputed
    end

    methods
        function this=DataModel
            new(this);
        end

        function new(this)
            this.UplinkLink=comm.internal.linkBudgetApp.UplinkLinkSpecification;

            this.TxEarth=comm.internal.linkBudgetApp.TxEarthSpecification(...
            'Latitude',42.37,'Longitude',-71.02,'Altitude',20);

            this.RxSatellite=comm.internal.linkBudgetApp.RxSatelliteSpecification(...
            'Latitude',40.65,'Longitude',-73.78,'Altitude',30);
            this.UplinkPropagation=comm.internal.linkBudgetApp.UplinkPropagationSpecification;
            this.DownlinkLink=comm.internal.linkBudgetApp.DownlinkLinkSpecification;

            this.TxSatellite=comm.internal.linkBudgetApp.TxSatelliteSpecification(...
            'Latitude',40.65,'Longitude',-73.78,'Altitude',30);

            this.RxEarth=comm.internal.linkBudgetApp.RxEarthSpecification(...
            'Latitude',42.37,'Longitude',-71.02,'Altitude',20);
            this.DownlinkPropagation=comm.internal.linkBudgetApp.DownlinkPropagationSpecification;

            this.UplinkResults=comm.internal.linkBudgetApp.UplinkResultsSpecification;
            this.DownlinkResults=comm.internal.linkBudgetApp.DownlinkResultsSpecification;

            notify(this,'SpecificationChanged');
        end

        function str=generateMatlabCode(~)
            str='Generate some code here';
        end

        function setProperty(this,type,prop,value)
            this.(type).(prop)=value;
            notify(this,'SpecificationChanged');
        end

        function value=getProperty(this,type,prop)
            value=this.(type).(prop);
        end

        function analyzeLinkBudget(this)

            upLink=this.UplinkLink;
            txEarth=this.TxEarth;
            rxSat=this.RxSatellite;
            upProp=this.UplinkPropagation;

            downLink=this.DownlinkLink;
            txSat=this.TxSatellite;
            rxEarth=this.RxEarth;
            downProp=this.DownlinkPropagation;

            upResults=this.UplinkResults;
            downResults=this.DownlinkResults;


            [uplinkDistance,uplinkElevation]=computeDistance(...
            txEarth.Latitude,txEarth.Longitude,txEarth.Altitude,rxSat.Latitude,...
            rxSat.Longitude,rxSat.Altitude);
            [downlinkDistance,downlinkElevation]=computeDistance(...
            txSat.Latitude,txSat.Longitude,txSat.Altitude,rxEarth.Latitude,...
            rxEarth.Longitude,rxEarth.Altitude);
            upResults.Distance=uplinkDistance;
            upResults.Elevation=uplinkElevation;
            downResults.Distance=downlinkDistance;
            downResults.Elevation=downlinkElevation;

            uplinkFreq=upLink.Frequency;
            downlinkFreq=downLink.Frequency;


            uplinkLambda=computeWavelength(uplinkFreq);
            setWavelength(upLink,uplinkLambda);
            downlinkLambda=computeWavelength(downlinkFreq);
            setWavelength(downLink,downlinkLambda);


            uplinkTxAntennaGain=computeAntennaGain(uplinkLambda,...
            txEarth.AntennaDiameter,txEarth.AntennaEfficiency);
            uplinkRxAntennaGain=computeAntennaGain(uplinkLambda,...
            rxSat.AntennaDiameter,rxSat.AntennaEfficiency);
            downlinkTxAntennaGain=computeAntennaGain(downlinkLambda,...
            txSat.AntennaDiameter,txSat.AntennaEfficiency);
            downlinkRxAntennaGain=computeAntennaGain(downlinkLambda,...
            rxEarth.AntennaDiameter,rxEarth.AntennaEfficiency);
            upResults.TxAntennaGain=uplinkTxAntennaGain;
            upResults.RxAntennaGain=uplinkRxAntennaGain;
            downResults.TxAntennaGain=downlinkTxAntennaGain;
            downResults.RxAntennaGain=downlinkRxAntennaGain;


            uplinkTxEIRP=computeEIRP(...
            txEarth.AmplifierPower,txEarth.AmplifierBackoffLoss,...
            txEarth.FeederLoss,txEarth.RadomeLoss,...
            txEarth.OtherLosses,uplinkTxAntennaGain);
            downlinkTxEIRP=computeEIRP(...
            txSat.AmplifierPower,txSat.AmplifierBackoffLoss,...
            txSat.FeederLoss,txSat.RadomeLoss,txSat.OtherLosses,...
            downlinkTxAntennaGain);
            upResults.TxEIRP=uplinkTxEIRP;
            downResults.TxEIRP=downlinkTxEIRP;


            uplinkFSPL=computeFSPL(uplinkDistance*1e3,uplinkLambda);
            downlinkFSPL=computeFSPL(downlinkDistance*1e3,downlinkLambda);
            upResults.FreeSpaceLoss=uplinkFSPL;
            downResults.FreeSpaceLoss=downlinkFSPL;




            uplinkClippedDistance=uplinkDistance*1e3;
            if(txEarth.Altitude>1e4)||(rxSat.Altitude>1e4)
                uplinkAtmDistance=(1e4-min(txEarth.Altitude,rxSat.Altitude))/sind(uplinkElevation);
                uplinkClippedDistance=min(uplinkAtmDistance,uplinkClippedDistance);
            end
            downlinkClippedDistance=downlinkDistance*1e3;
            if(txSat.Altitude>1e4)||(rxEarth.Altitude>1e4)
                downlinkAtmDistance=(1e4-min(txSat.Altitude,rxEarth.Altitude))/sind(downlinkElevation);
                downlinkClippedDistance=min(downlinkAtmDistance,downlinkClippedDistance);
            end


            uplinkRainAtt=computeRainAtt(uplinkClippedDistance,...
            uplinkFreq,upProp.RainRate,...
            uplinkElevation,upProp.PolarizationTilt);
            upResults.RainAttenuation=uplinkRainAtt;
            downlinkRainAtt=computeRainAtt(downlinkClippedDistance,...
            downlinkFreq,downProp.RainRate,...
            downlinkElevation,downProp.PolarizationTilt);
            downResults.RainAttenuation=downlinkRainAtt;


            uplinkFogAtt=computeFogAtt(uplinkClippedDistance,uplinkFreq,...
            upProp.FogCloudTemperature,upProp.FogCloudWaterDensity);
            upResults.FogCloudAttenuation=uplinkFogAtt;
            downlinkFogAtt=computeFogAtt(downlinkClippedDistance,downlinkFreq,...
            downProp.FogCloudTemperature,downProp.FogCloudWaterDensity);
            downResults.FogCloudAttenuation=downlinkFogAtt;



            uplinkAtmGasAtt=computeAtmGasAtt(...
            uplinkClippedDistance,uplinkFreq,upProp.Temperature,...
            upProp.AtmPressure,upProp.WaterVaporDensity);
            upResults.AtmGasAttenuation=uplinkAtmGasAtt;
            downlinkAtmGasAtt=computeAtmGasAtt(...
            downlinkClippedDistance,downlinkFreq,downProp.Temperature,...
            downProp.AtmPressure,downProp.WaterVaporDensity);
            downResults.AtmGasAttenuation=downlinkAtmGasAtt;


            uplinkPolLoss=computePolarizationLoss(upLink.Polarization);
            downlinkPolLoss=computePolarizationLoss(downLink.Polarization);
            upResults.PolarizationLoss=uplinkPolLoss;
            downResults.PolarizationLoss=downlinkPolLoss;


            uplinkTotalPropLosses=uplinkFSPL+uplinkRainAtt+uplinkFogAtt+...
            uplinkAtmGasAtt+uplinkPolLoss+upProp.OtherLosses;
            upResults.TotalPropagationLosses=uplinkTotalPropLosses;
            downlinkTotalPropLosses=downlinkFSPL+downlinkRainAtt+downlinkFogAtt+...
            downlinkAtmGasAtt+downlinkPolLoss+downProp.OtherLosses;
            downResults.TotalPropagationLosses=downlinkTotalPropLosses;


            uplinkRxIsoPower=uplinkTxEIRP-uplinkTotalPropLosses-rxSat.RadomeLoss;
            upResults.RxIsotropicPower=uplinkRxIsoPower;
            downlinkRxIsoPower=downlinkTxEIRP-downlinkTotalPropLosses-rxEarth.RadomeLoss;
            downResults.RxIsotropicPower=downlinkRxIsoPower;


            uplinkRxSigPower=uplinkRxIsoPower+uplinkRxAntennaGain-...
            rxSat.FeederLoss-rxSat.OtherLosses;
            upResults.RxSignalPower=uplinkRxSigPower;
            downlinkRxSigPower=downlinkRxIsoPower+downlinkRxAntennaGain-...
            rxEarth.FeederLoss-rxEarth.OtherLosses;
            downResults.RxSignalPower=downlinkRxSigPower;


            uplinkFoM=computeFigureOfMerit(uplinkRxAntennaGain,rxSat.SystemTemperature);
            upResults.FigureOfMerit=uplinkFoM;
            downlinkFoM=computeFigureOfMerit(downlinkRxAntennaGain,rxEarth.SystemTemperature);
            downResults.FigureOfMerit=downlinkFoM;





            uplinkCbyN0=computeCbyN0(uplinkRxSigPower,rxSat.SystemTemperature);
            upResults.CbyN0=uplinkCbyN0;
            downlinkCbyN0=computeCbyN0(downlinkRxSigPower,rxEarth.SystemTemperature);
            downResults.CbyN0=downlinkCbyN0;


            uplinkCbyN=computeCbyN(uplinkCbyN0,upLink.Bandwidth);
            upResults.CbyN=uplinkCbyN;
            downlinkCbyN=computeCbyN(downlinkCbyN0,downLink.Bandwidth);
            downResults.CbyN=downlinkCbyN;


            uplinkRxEbbyN0=computeEbN0(uplinkCbyN0,upLink.BitRate);
            upResults.RxEbbyN0=uplinkRxEbbyN0;
            downlinkRxEbbyN0=computeEbN0(downlinkCbyN0,downLink.BitRate);
            downResults.RxEbbyN0=downlinkRxEbbyN0;


            upResults.Margin=computeMargin(uplinkRxEbbyN0,...
            upLink.RequiredEbN0,upLink.ImplementationLoss);
            downResults.Margin=computeMargin(downlinkRxEbbyN0,...
            downLink.RequiredEbN0,downLink.ImplementationLoss);

            notify(this,'ResultsComputed');

        end

    end
end
