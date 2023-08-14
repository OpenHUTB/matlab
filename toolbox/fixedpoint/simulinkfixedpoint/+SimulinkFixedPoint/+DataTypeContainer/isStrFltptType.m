function flag=isStrFltptType(DTString)






    toCompare={'fixdt(''single'')','fixdt(''double'')',...
    'numerictype(''single'')','numerictype(''double'')',...
    'float(''single'')','float(''double'')','fixdt(''half'')',...
    'numerictype(''half'')'};
    flag=SimulinkFixedPoint.DataTypeContainer.isStringBuiltInFloat(DTString)...
    ||any(strcmpi(DTString,toCompare));
end
