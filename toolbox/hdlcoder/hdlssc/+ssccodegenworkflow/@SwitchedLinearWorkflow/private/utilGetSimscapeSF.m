function[simscapeSF,simscapeSFInputs,simscapeSFOutputs,solverPaths]=utilGetSimscapeSF(simscapeModel)




    try
        [simscapeSF,simscapeSFInputs,simscapeSFOutputs,solverPaths]=simscape.compiler.sli.componentModel(simscapeModel,true);
    catch me
        me=MException('checkSwitchedLinear:getSimscapeSF',me.message);
        throwAsCaller(me);
    end
end
