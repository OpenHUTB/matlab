function inputDataT=transposeInputsBeforePredict(obj,dataInputs,~,~,~)















%#codegen



    coder.allowpcode('plain');
    coder.inline('always');


    inputDataT=dataInputs;

end



