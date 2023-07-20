function result=getBuiltinStorageClasses(includeAuto)




    if(nargin==0)
        includeAuto=true;
    end

    if includeAuto
        result={'Auto'};
    else
        result={};
    end

    result=[result;Simulink.data.getNameForModelDefaultSC];

    others={'ExportedGlobal'
'ImportedExtern'
'ImportedExternPointer'
    };

    result=[result;others];


