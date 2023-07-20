function obj=initializeNetwork(obj,codegenInputSizes)














%#codegen
%#internal

    coder.allowpcode('plain');

    coder.internal.prefer_const(codegenInputSizes)


    obj.initializeOrResetState(codegenInputSizes);
    obj.initializeLayers();
