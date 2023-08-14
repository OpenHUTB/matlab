function validateEndianess(modelName,targetEndianess,isHostBased,isPWS)







    if~(isHostBased&&isPWS)
        assert(~strcmp(targetEndianess,'Unspecified'),...
        'Need to be sure of endianess');
    end



    if isHostBased&&~isPWS&&strcmp(targetEndianess,'BigEndian')
        DAStudio.error('Simulink:Extmode:XCPExtModeHostMustBeLittleEndian',modelName)
    end

end