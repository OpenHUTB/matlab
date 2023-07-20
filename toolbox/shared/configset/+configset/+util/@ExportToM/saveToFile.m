function saveToFile(obj)


    filename=obj.name;
    fid=fopen(filename,'w','native','UTF-8');
    if fid<0
        DAStudio.error('Simulink:tools:unwritableError',filename);
    end

    fprintf(fid,'%s',obj.getString);
    fclose(fid);

