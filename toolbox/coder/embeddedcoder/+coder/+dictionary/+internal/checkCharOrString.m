function checkCharOrString(value)




    if~(ischar(value)||isstring(value))
        DAStudio.error('SimulinkCoderApp:data:CharacterVectorOrStringExpected');
    end
end
