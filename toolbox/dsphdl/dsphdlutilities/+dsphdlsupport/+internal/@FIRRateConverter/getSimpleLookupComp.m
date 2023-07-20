function cgirComp=getSimpleLookupComp(~,hN,hInSignals,hOutSignals,tableData,compName,desc)






    table_data=tableData(:);
    inType=hInSignals(1).Type;
    bpType=fi(0,inType.Signed,inType.WordLength,inType.FractionLength);
    input_values=cast((0:length(table_data)-1).','like',bpType);
    oType_ex=pirelab.getTypeInfoAsFi(hOutSignals(1).Type,'Nearest','Saturate');
    other_data=0;

    cgirComp=pirelab.getLookupComp(hN,hInSignals,hOutSignals,...
    input_values,table_data,other_data,oType_ex,compName,desc);

end

