function hasDlarrayInputs=hasDlarrayInputsForCustomLayers(layer,isInDLNetwork)









    hasDlarrayInputs=dltargets.internal.checkIfCustomLayer(layer)&&(isInDLNetwork||...
    isa(layer,'nnet.layer.Formattable')||...
    ~dltargets.internal.isClassMethod(layer,'backward'));

end
