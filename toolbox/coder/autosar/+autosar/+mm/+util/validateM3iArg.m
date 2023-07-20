function validateM3iArg(m3iArg,expectedClass)




    narginchk(2,2);

    autosar.mm.util.validateArg(m3iArg,expectedClass);

    assert(m3iArg.isvalid,'Invalid M3I argument!');
end
