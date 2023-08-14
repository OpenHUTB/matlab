function filePath=getFilePath(source)






    if ischar(source)

        [fdir,fname,fext]=fileparts(source);

        if~isempty(fdir)

            if exist(source,'file')==2
                filePath=source;
            else
                filePath='';
            end
            return;

        else

            if isempty(fext)
                dictName=[fname,'.sldd'];
            else
                dictName=source;
            end
        end

    else

        dictName=source.getPropValue('DataSource');
    end


    filePath=rmide.resolveDict(dictName);
end

