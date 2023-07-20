function schemaVer=getSchemaVersionForConfigSet(rawSchemaVer,isAdaptive)




    schemaVer=rawSchemaVer;
    if~isAdaptive
        if any(strcmp(rawSchemaVer,{'00044','00045'}))
            schemaVer='4.3';
        elseif any(strcmp(rawSchemaVer,{'00046','00047'}))
            schemaVer='4.4';
        elseif strcmp(rawSchemaVer,'00048')
            schemaVer='R19-11';
        elseif strcmp(rawSchemaVer,'00049')
            schemaVer='R20-11';
        elseif strncmp(schemaVer,'3',1)||strncmp(schemaVer,'2',1)
            assert(false,'Schemas prior to 4.x are no longer supported');
        end
    else
        schemaVer=arxml.convertSchemaToRelease(rawSchemaVer);
    end
