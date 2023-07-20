function complxToAngle=elabComplxToAngleNet(~,topNet,~,rate,inpWL,inpFL)




    complxToAngleblkInfo.outMode=boolean([0;1;0]);
    complxToAngleblkInfo.AngleFormat='Radians';
    complxToAngleblkInfo.ScaleOutput=true;
    complxToAngleblkInfo.NumIterationsSource='Auto';

    pirTyp1=pir_sfixpt_t(inpWL+3,-inpWL);

    inportNameComplxToAngle={'dataIn','validIn'};
    controlType=pir_ufixpt_t(1,0);
    inType=pir_complex_t(pir_sfixpt_t(inpWL,inpFL));
    inTypeComplxToAngle=[inType,controlType];
    inDataRateComplxToAngle=[rate,rate];

    outportNameComplxToAngle={'angleOut','validOut'};
    outTypeComplxToAngle=[pirTyp1,controlType];

    complxToAngle=pirelab.createNewNetwork(...
    'Network',topNet,...
    'Name','complxToAngle',...
    'InportNames',inportNameComplxToAngle,...
    'InportTypes',inTypeComplxToAngle,...
    'InportRates',inDataRateComplxToAngle,...
    'OutportNames',outportNameComplxToAngle,...
    'OutportTypes',outTypeComplxToAngle...
    );

    complxToAngleVector=complxToAngle;
    validIn=complxToAngle.PirInputSignals(2);
    validOut=complxToAngle.PirOutputSignals(2);

    COMPLXTOANGLE=dsphdlsupport.internal.ComplexToMagnitudeAngle;
    COMPLXTOANGLE.elaborateCORDICAngle(complxToAngle,complxToAngleblkInfo,complxToAngleVector,validIn,validOut);

end




