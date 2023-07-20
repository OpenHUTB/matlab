function[entryPath,msg]=getEntryPath(dict,entryId)




    entryPath='';
    msg='';

    if~isempty(entryId)&&entryId(1)=='@'
        entryId=entryId(2:end);
    end

    if strncmp(entryId,'UUID_',length('UUID_'))


        if ischar(dict)

            if isempty(regexpi(dict,'\.sldd$'))
                dict=[dict,'.sldd'];
            end
            myConnection=rmide.connection(dict);
            if isempty(myConnection)
                msg=getString(message('Slvnv:rmide:DataDictNotFound',dict));
                return;
            end
        else
            myConnection=dict;
        end
        entryIdStr=strrep(entryId,'UUID_','UUID ');
        ddKey=Simulink.dd.DataSourceEntryKey.fromString(entryIdStr);
        entryPath=myConnection.getEntryPath(ddKey);
        if strncmp(entryPath,'Global.',length('Global.'))

            entryPath=strrep(entryPath,'Global.','Design.');
        end

    else

        entryPath=entryId;
    end

end

