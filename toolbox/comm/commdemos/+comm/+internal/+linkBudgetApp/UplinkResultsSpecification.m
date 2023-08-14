classdef UplinkResultsSpecification<comm.internal.linkBudgetApp.Specification




    properties
        Distance=0;
        Elevation=0;
        TxAntennaGain=0;
        TxEIRP=0;
        FreeSpaceLoss=0;
        RainAttenuation=0;
        FogCloudAttenuation=0;
        AtmGasAttenuation=0;
        PolarizationLoss=0;
        TotalPropagationLosses=0;
        RxIsotropicPower=0;
        RxAntennaGain=0;
        RxSignalPower=0;
        FigureOfMerit=0;
        CbyN=0;
        CbyN0=0;
        RxEbbyN0=0;
        Margin=0;
    end

    methods
        function ids=getPropertyNames(~)
            ids={'Distance','Elevation','TxAntennaGain','TxEIRP','FreeSpaceLoss',...
            'RainAttenuation',...
            'FogCloudAttenuation','AtmGasAttenuation','PolarizationLoss','TotalPropagationLosses',...
            'RxIsotropicPower','RxAntennaGain','RxSignalPower',...
            'FigureOfMerit','CbyN','CbyN0','RxEbbyN0','Margin'};
        end

        function type=getType(~)
            type='UplinkResults';
        end
    end
end


