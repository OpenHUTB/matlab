
function[inheritanceError,messages]=checkDefiningClassInheritance(this,classdefNode,messages)




    inheritanceError=0;
    cexpr=classdefNode.Cexpr;
    if strcmp(cexpr.kind,'LT')

        baseClassNode=cexpr.Right;
        [inheritanceError,messages]=this.checkBaseClass(baseClassNode,messages);
    else

    end
end
