function cdef=createEmptyCoderDict(m)




    container=coderdictionary.data.Container(m);
    container.CDefinitions=coderdictionary.data.C_Definitions(m);
    cdef=container.CDefinitions;
end
