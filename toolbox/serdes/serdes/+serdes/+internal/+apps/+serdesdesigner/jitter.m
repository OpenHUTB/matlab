classdef jitter<handle

    properties

        isModeClocked=true;
        isModeIdeal=false;

        isTxDCD=false;
        isTxRj=false;
        isTxDj=false;
        isTxSj=false;
        isTxSjFrequency=false;

        isRxDCD=false;
        isRxRj=false;
        isRxDj=false;
        isRxSj=false;

        isRxClockRecoveryMean=false;
        isRxClockRecoveryRj=false;
        isRxClockRecoveryDj=false;
        isRxClockRecoverySj=false;
        isRxClockRecoveryDCD=false;

        isRxReceiverSensitivity=false;
        isRxGaussianNoise=false;
        isRxUniformNoise=false;

        TxDCD=0;
        TxRj=0;
        TxDj=0;
        TxSj=0;
        TxSjFrequency=1e6;

        RxDCD=0;
        RxRj=0;
        RxDj=0;
        RxSj=0;

        RxClockRecoveryMean=0;
        RxClockRecoveryRj=0;
        RxClockRecoveryDj=0;
        RxClockRecoverySj=0;
        RxClockRecoveryDCD=0;

        RxReceiverSensitivity=0;
        RxGaussianNoise=0;
        RxUniformNoise=0;

        unitsTxDCD=2;
        unitsTxRj=2;
        unitsTxDj=2;
        unitsTxSj=2;

        unitsRxDCD=2;
        unitsRxRj=2;
        unitsRxDj=2;
        unitsRxSj=2;

        unitsRxClockRecoveryMean=2;
        unitsRxClockRecoveryRj=2;
        unitsRxClockRecoveryDj=2;
        unitsRxClockRecoverySj=2;
        unitsRxClockRecoveryDCD=2;

    end


    properties(Constant,Hidden)
        isModeClocked_NameInGUI=getString(message('serdes:serdesdesigner:ModeClocked'));
        isModeIdeal_NameInGUI=getString(message('serdes:serdesdesigner:ModeIdeal'));
        TxDCD_NameInGUI=getString(message('serdes:serdesdesigner:ParameterTxDCD'));
        TxRj_NameInGUI=getString(message('serdes:serdesdesigner:ParameterTxRj'));
        TxDj_NameInGUI=getString(message('serdes:serdesdesigner:ParameterTxDj'));
        TxSj_NameInGUI=getString(message('serdes:serdesdesigner:ParameterTxSj'));
        TxSjFrequency_NameInGUI=getString(message('serdes:serdesdesigner:ParameterTxSjFrequency'));
        RxDCD_NameInGUI=getString(message('serdes:serdesdesigner:ParameterRxDCD'));
        RxRj_NameInGUI=getString(message('serdes:serdesdesigner:ParameterRxRj'));
        RxDj_NameInGUI=getString(message('serdes:serdesdesigner:ParameterRxDj'));
        RxSj_NameInGUI=getString(message('serdes:serdesdesigner:ParameterRxSj'));
        RxClockRecoveryMean_NameInGUI=getString(message('serdes:serdesdesigner:ParameterRxClockRecoveryMean'));
        RxClockRecoveryRj_NameInGUI=getString(message('serdes:serdesdesigner:ParameterRxClockRecoveryRj'));
        RxClockRecoveryDj_NameInGUI=getString(message('serdes:serdesdesigner:ParameterRxClockRecoveryDj'));
        RxClockRecoverySj_NameInGUI=getString(message('serdes:serdesdesigner:ParameterRxClockRecoverySj'));
        RxClockRecoveryDCD_NameInGUI=getString(message('serdes:serdesdesigner:ParameterRxClockRecoveryDCD'));
        RxReceiverSensitivity_NameInGUI=getString(message('serdes:serdesdesigner:ParameterRxReceiverSensitivity'));
        RxGaussianNoise_NameInGUI=getString(message('serdes:serdesdesigner:ParameterRxGaussianNoise'));
        RxUniformNoise_NameInGUI=getString(message('serdes:serdesdesigner:ParameterRxUniformNoise'));
        ColumnName_Text=getString(message('serdes:serdesdesigner:ColumnName'));
        ColumnValue_Text=getString(message('serdes:serdesdesigner:ColumnValue'));
        ColumnUnit_Text=getString(message('serdes:serdesdesigner:ColumnUnit'));
        UnitsSeconds_Text=getString(message('serdes:serdesdesigner:UnitsSeconds'));
        UnitsUI_Text=getString(message('serdes:serdesdesigner:UnitsUI'));
        UnitsHz_Text=getString(message('serdes:serdesdesigner:UnitsHz'));
        UnitsVolts_Text=getString(message('serdes:serdesdesigner:UnitsVolts'));
    end


    methods

        function jitter=getJitterObject(obj)

            if obj.isModeIdeal==1
                jitter=JitterAndNoise('RxClockMode','ideal');
            else
                jitter=JitterAndNoise('RxClockMode','clocked');
            end

            if obj.isTxDCD==1
                if obj.unitsTxDCD==1
                    jitter.Tx_DCD=obj.TxDCD;
                else
                    jitter.Tx_DCD=SimpleJitter(...
                    'Value',obj.TxDCD,'Type','UI','Include',true);
                end
            end
            if obj.isTxRj==1
                if obj.unitsTxRj==1
                    jitter.Tx_Rj=obj.TxRj;
                else
                    jitter.Tx_Rj=SimpleJitter(...
                    'Value',obj.TxRj,'Type','UI','Include',true);
                end
            end
            if obj.isTxDj==1
                if obj.unitsTxDj==1
                    jitter.Tx_Dj=obj.TxDj;
                else
                    jitter.Tx_Dj=SimpleJitter(...
                    'Value',obj.TxDj,'Type','UI','Include',true);
                end
            end
            if obj.isTxSj==1
                if obj.unitsTxSj==1
                    jitter.Tx_Sj=obj.TxSj;
                else
                    jitter.Tx_Sj=SimpleJitter(...
                    'Value',obj.TxSj,'Type','UI','Include',true);
                end
            end
            if obj.isTxSjFrequency==1
                jitter.Tx_Sj_Frequency=obj.TxSjFrequency;
            end
            if obj.isRxDCD==1
                if obj.unitsRxDCD==1
                    jitter.Rx_DCD=obj.RxDCD;
                else
                    jitter.Rx_DCD=SimpleJitter(...
                    'Value',obj.RxDCD,'Type','UI','Include',true);
                end
            end
            if obj.isRxRj==1
                if obj.unitsRxRj==1
                    jitter.Rx_Rj=obj.RxRj;
                else
                    jitter.Rx_Rj=SimpleJitter(...
                    'Value',obj.RxRj,'Type','UI','Include',true);
                end
            end
            if obj.isRxDj==1
                if obj.unitsRxDj==1
                    jitter.Rx_Dj=obj.RxDj;
                else
                    jitter.Rx_Dj=SimpleJitter(...
                    'Value',obj.RxDj,'Type','UI','Include',true);
                end
            end
            if obj.isRxSj==1
                if obj.unitsRxSj==1
                    jitter.Rx_Sj=obj.RxSj;
                else
                    jitter.Rx_Sj=SimpleJitter(...
                    'Value',obj.RxSj,'Type','UI','Include',true);
                end
            end
            if obj.isRxClockRecoveryMean==1
                if obj.unitsRxClockRecoveryMean==1
                    jitter.Rx_Clock_Recovery_Mean=obj.RxClockRecoveryMean;
                else
                    jitter.Rx_Clock_Recovery_Mean=SimpleJitter(...
                    'Value',obj.RxClockRecoveryMean,'Type','UI','Include',true);
                end
            end
            if obj.isRxClockRecoveryRj==1
                if obj.unitsRxClockRecoveryRj==1
                    jitter.Rx_Clock_Recovery_Rj=obj.RxClockRecoveryRj;
                else
                    jitter.Rx_Clock_Recovery_Rj=SimpleJitter(...
                    'Value',obj.RxClockRecoveryRj,'Type','UI','Include',true);
                end
            end
            if obj.isRxClockRecoveryDj==1
                if obj.unitsRxClockRecoveryDj==1
                    jitter.Rx_Clock_Recovery_Dj=obj.RxClockRecoveryDj;
                else
                    jitter.Rx_Clock_Recovery_Dj=SimpleJitter(...
                    'Value',obj.RxClockRecoveryDj,'Type','UI','Include',true);
                end
            end
            if obj.isRxClockRecoverySj==1
                if obj.unitsRxClockRecoverySj==1
                    jitter.Rx_Clock_Recovery_Sj=obj.RxClockRecoverySj;
                else
                    jitter.Rx_Clock_Recovery_Sj=SimpleJitter(...
                    'Value',obj.RxClockRecoverySj,'Type','UI','Include',true);
                end
            end
            if obj.isRxClockRecoveryDCD==1
                if obj.unitsRxClockRecoveryDCD==1
                    jitter.Rx_Clock_Recovery_DCD=obj.RxClockRecoveryDCD;
                else
                    jitter.Rx_Clock_Recovery_DCD=SimpleJitter(...
                    'Value',obj.RxClockRecoveryDCD,'Type','UI','Include',true);
                end
            end
            if obj.isRxReceiverSensitivity==1
                jitter.Rx_Receiver_Sensitivity=obj.RxReceiverSensitivity;
            end
            if obj.isRxGaussianNoise==1
                jitter.Rx_GaussianNoise=obj.RxGaussianNoise;
            end
            if obj.isRxUniformNoise==1
                jitter.Rx_UniformNoise=obj.RxUniformNoise;
            end
        end
    end
end
