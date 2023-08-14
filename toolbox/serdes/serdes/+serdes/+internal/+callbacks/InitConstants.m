




classdef InitConstants<handle

    properties(Constant)
        stDataPathLibrary='serdesDatapath';
        stDatapathBlocks=["AGC","CDR","CTLE","DFECDR","FFE","PassThrough","SaturatingAmplifier","VGA"];
        mlDataStoreWriteBlock='simulink/Signal Routing/Data Store Write';
        modulationParamName='Modulation';
        sampleIntervalParamName='SampleInterval';
        symbolTimeParamName='SymbolTime';
        impulseOutVar="ImpulseOut";
        impulseInVar="ImpulseIn";
        impulseLocalVar="LocalImpulse";
        waveTypeParam="WaveType";
        rowSizeParamName='RowSize';
        aggressorsParamName='Aggressors';
        pam4Signals={'PAM4_UpperThreshold','PAM4_CenterThreshold','PAM4_LowerThreshold'};
        pamNSignals={'PAM_Thresholds'};
        utilitiesVariablesAllowed={'ImpulseResponse','ImpulseSampleInterval'}
    end
end