function v=validatePortDatatypes(this,hC)



    v=hdlvalidatestruct;
    slbh=hC.SimulinkHandle;


    constMatrix=getBlockInfo(this,slbh);


    inputSignal=hC.PirInputSignals(1);

    inputSignalType=getPirSignalLeafType(inputSignal.Type);

    if~inputSignalType.isSingleType&&~inputSignalType.isDoubleType
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedNfpScmInputType'));
    end

    if~isempty(constMatrix)

        size3ConstMatrix=size(constMatrix,3);


        if size3ConstMatrix==1
            wordLengthRequired=1;
        else
            wordLengthRequired=ceil(log2(size3ConstMatrix));
        end


        selectSignal=hC.PirInputSignals(2);

        selectSignalLeafType=getPirSignalLeafType(selectSignal.Type);

        selectSignalDataTypeInfo=pirgetdatatypeinfo(selectSignalLeafType);



        if(selectSignalLeafType.isFloatType)||...
            (selectSignalDataTypeInfo.binarypoint>0)||...
            (selectSignalDataTypeInfo.issigned)||...
            (selectSignalDataTypeInfo.wordsize<wordLengthRequired)
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:unsupportedNfpScmSelectType',wordLengthRequired));
        end
    end

end