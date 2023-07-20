function createDataVariant(ddConn,ddRefDict,scope,entryID,newName,variant)





    cur_ddConn=Simulink.dd.open(ddRefDict);
    if slfeature('SLDataDictionaryVariants')==1
        if~isempty(cur_ddConn.getVariant())
            if~cur_ddConn.entryExists([scope,'.',newName],false)
                try
                    cur_ddConn.insertEntry(scope,newName,Simulink.dd.DataVariant(ddConn.filespec,entryID,''));
                catch E %#ok
                end
            end
        end
    else
        if slfeature('SLDataDictionaryVariants')==2
            try
                cur_ddConn.insertEntry(scope,newName,Simulink.dd.DataVariant(ddConn.filespec,entryID,''),variant);
            catch E %#ok
            end
        end
    end
end
