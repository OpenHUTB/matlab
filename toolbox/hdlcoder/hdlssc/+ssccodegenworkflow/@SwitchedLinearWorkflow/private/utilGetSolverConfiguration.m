function solverPaths=utilGetSolverConfiguration(simscapeModel)





    try
        [~,~,~,solverPaths]=simscape.compiler.sli.componentModel(simscapeModel,true);
    catch me
        me=MException('checkSwitchedLinear:getSimscapeSF',me.message);
        throwAsCaller(me);
    end
end
