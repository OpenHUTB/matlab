





function[frequencyData,zData]=interpretImpedanceData(obj,dataobj,dataObjType,freq)
    allDataTypes={'Constant','FunctionHandle','AnalyzeCapableCircuitObject','CircuitObject','AntennaObject','RFDataObject','SParamObject','AnalyzeCapableDataObject'};
    noFrequencyDataTypes=allDataTypes(1:5);
    hasFrequencyDataTypes=allDataTypes(6:8);



    if((isempty(freq))&&~isempty(find(strcmp(dataObjType,noFrequencyDataTypes),1)))
        frequencyData=[0,inf];
        return;
    end




    if(isempty(freq))
        i=find(strcmp(dataObjType,hasFrequencyDataTypes),1);
        switch(i)
        case 1


            dataobj.restore();
            frequencyData=dataobj.Freq;
        case 2
            frequencyData=dataobj.Frequencies;
        case 3


            dataobj.restore();
            frequencyData=dataobj.AnalyzedResult.Freq;
        end
        return;
    end



    frequencyData=freq;
    i=find(strcmp(dataObjType,allDataTypes),1);
    switch(i)
    case 1
        zData=dataobj*ones(1,length(freq));
    case 2
        zData=dataobj(freq);
    case 3
        analyze(dataobj,freq);
        zData=gamma2z(dataobj.AnalyzedResult.S_Parameters,dataobj.AnalyzedResult.Z0);
    case 4
        temp=sparameters(dataobj,freq);
        zData=gamma2z(temp.Parameters,temp.Impedance);
    case 5
        zData=impedance(dataobj,freq);

    case 6
        dataobj.analyze(freq);

        zData=gamma2z(dataobj.S_Parameters,dataobj.Z0);
    case 7
        temp=rfinterp1(dataobj,freq);

        zData=gamma2z(temp.Parameters,temp.Impedance);
    case 8
        analyze(dataobj,freq);
        zData=gamma2z(dataobj.AnalyzedResult.S_Parameters,dataobj.AnalyzedResult.Z0);
    end


end
