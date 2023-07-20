function wsoptions=createWarmStartOptions()













%#codegen


    coder.allowpcode('plain');

    wsoptions=struct();




    wsoptions.MaxLinearEqualities=-1;
    wsoptions.MaxLinearInequalities=-1;

end