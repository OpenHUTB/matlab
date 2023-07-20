function var=makeTempVar(self,var)
    var=matlab.lang.makeValidName(var);
    var=matlab.lang.makeUniqueStrings(var,self.tempVars,namelengthmax-strlength(self.namespaces.temporaries));
    self.tempVars(end+1)=var;
    var=strcat(self.namespaces.temporaries,var);
end
