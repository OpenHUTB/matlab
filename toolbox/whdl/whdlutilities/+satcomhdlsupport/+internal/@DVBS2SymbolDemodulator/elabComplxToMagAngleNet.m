function complxToMagAngle=elabComplxToMagAngleNet(~,topNet,~,rate,inpWL,inpFL)




    complxToMagAngleblkInfo.XILINX_MAXOUTPUT_WORDLENGTH=48;
    complxToMagAngleblkInfo.ALTERA_MAXOUTPUT_WORDLENGTH=44;

    complxToMagAngleblkInfo.outMode=boolean([0;0;1]);
    complxToMagAngleblkInfo.AngleFormat='Radians';
    complxToMagAngleblkInfo.ScaleOutput=true;
    complxToMagAngleblkInfo.UseMultipliers=true;
    complxToMagAngleblkInfo.NumIterationsSource='Auto';

    pirTyp1=pir_sfixpt_t(inpWL+1,inpFL);
    pirTyp2=pir_sfixpt_t(inpWL+3,-inpWL);

    inportNameComplxToMagAngle={'dataIn','validIn'};
    controlType=pir_ufixpt_t(1,0);
    inType=pir_complex_t(pir_sfixpt_t(inpWL,inpFL));
    inTypeComplxToMagAngle=[inType,controlType];
    inDataRateComplxToMagAngle=[rate,rate];

    outportNameComplxToMagAngle={'magOut','angleOut','validOut'};
    outTypeComplxToMagAngle=[pirTyp1,pirTyp2,controlType];

    complxToMagAngle=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','complxToMagAngle',...
    'InportNames',inportNameComplxToMagAngle,...
    'InportTypes',inTypeComplxToMagAngle,...
    'InportRates',inDataRateComplxToMagAngle,...
    'OutportNames',outportNameComplxToMagAngle,...
    'OutportTypes',outTypeComplxToMagAngle...
    );

    complxToMagAngleVector=complxToMagAngle;
    validIn=complxToMagAngle.PirInputSignals(2);
    validOut=complxToMagAngle.PirOutputSignals(3);

    COMPLXTOANGLE=dsphdlsupport.internal.ComplexToMagnitudeAngle;
    COMPLXTOANGLE.elaborateCORDICMagAngle(complxToMagAngle,complxToMagAngleblkInfo,complxToMagAngleVector,validIn,validOut);

end




