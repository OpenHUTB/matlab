function IterComp=getDivPostCorrectionComp(hN,hInSignals,hOutSignals)




    out1type=pirelab.getTypeInfoAsFi(hOutSignals(1).Type);
    nt=numerictype(out1type);
    if(nt.Signed)
        positiveMaxValue=fi(2^(nt.WordLength-1)-1,1,nt.WordLength,0);
        negativeMinValue=fi(-2^(nt.WordLength-1),1,nt.WordLength,0);
    else
        positiveMaxValue=fi(2^(nt.WordLength)-1,0,nt.WordLength,0);
        negativeMinValue=fi(0,0,nt.WordLength,0);
    end

    IterComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name','postcorrection',...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName','hdleml_divide_postCorrection',...
    'EMLParams',{out1type,positiveMaxValue,negativeMinValue},...
    'EMLFlag_ParamsFollowInputs',true,...
    'EMLFlag_TreatInputBoolsAsUfix1','true');

end


