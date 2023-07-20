function pr=reduceCallPreAnchor(fcnHandle,input1)




%#codegen

    coder.allowpcode('plain');
    coder.inline('never');
    coder.internal.cfunctionname('#__gpu_reduction_preprocess');

    coder.ceval('-pure','#__gpu_reduction_input_keeper',coder.ref(input1));
    pr=fcnHandle(input1);
    coder.ceval('-pure','#__gpu_reduction_input_keeper',coder.ref(pr));
end
