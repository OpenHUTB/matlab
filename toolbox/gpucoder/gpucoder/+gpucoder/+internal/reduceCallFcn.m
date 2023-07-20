function red=reduceCallFcn(fcnHandle,input1,input2)




%#codegen

    coder.allowpcode('plain');
    coder.inline('never');
    coder.internal.cfunctionname('#__gpu_reduction_operator');

    coder.ceval('-pure','#__gpu_reduction_input_keeper',coder.ref(input1),coder.ref(input2));
    red=fcnHandle(input1,input2);
    coder.ceval('-pure','#__gpu_reduction_input_keeper',coder.ref(red));
end
