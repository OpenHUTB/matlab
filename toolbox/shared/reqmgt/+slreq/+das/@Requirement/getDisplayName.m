function name=getDisplayName(this,propName)






    if any(strcmp(propName,this.BuiltinProperties))
        name=this.getDisplayNameForBuiltin(propName);
    else
        name=propName;
    end
end
