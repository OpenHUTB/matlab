function propNames=getFileProperties(fileName)



    propNames=tdmsreadprop(fileName).Properties.VariableNames;
end
