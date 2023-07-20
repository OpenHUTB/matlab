function[result]=isCodeGenFeatureEnabled()



    result=(slfeature('ProtectedModelRemoveSimulinkCoderCheck')&&builtin('license','test','Real-Time_Workshop'))||...
    (~slfeature('ProtectedModelRemoveSimulinkCoderCheck'));

end