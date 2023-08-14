function ret=save(model)




    ret={};


    [filename,path]=uiputfile('Untitled.xml');

    if~isequal(filename,0)
        ret.file=[path,filename];


        try
            serializer=mf.zero.io.XmlSerializer;
            serializer.serializeToFile(model,ret.file);
        catch ME
            ret.errorTitle=message('ssm:genericUI:ErrorSaveFile').getString;
            ret.error=ME.message;
        end
    end
end