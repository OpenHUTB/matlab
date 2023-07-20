function schema=ne_lookupschemaimpl(schemaFcn)




    key=pm_mfilename(3);
    schema=ne_libraryitemregistry(key);




    if~isempty(schema)
        pm_assert(strcmp(key,schema.info.SourceFile),...
        'key (%s) and sourcefile (%s) don''t match',key,schema.info.SourceFile);
        fileAttr=dir(schema.info.SourceFile);

        schemaNeedsUpdate=datenum(schema.info.SrcModTime,'yyyymmddTHHMMSS')<fileAttr.datenum;
    else
        schemaNeedsUpdate=true;
    end


    if schemaNeedsUpdate
        if isa(schemaFcn,'function_handle')




            if exist('simscape.FileDispatchReturnAsSettingManager','class')~=0
                mgr=simscape.FileDispatchReturnAsSettingManager(...
                simscape.FileDispatchReturnAs.Classic);
            else
                mgr=[];
            end
            schema=schemaFcn();

            mgr=[];

            fileAttr=dir(schema.info.SourceFile);
            schema.info.SrcModTime=datestr(fileAttr.datenum,30);

            ne_libraryitemregistry(key,schema);
        else
            pm_error('physmod:network_engine:ne_lookupschema:InputNotFunctionHandle');
        end
    end

end
