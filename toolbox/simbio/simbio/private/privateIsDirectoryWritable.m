function[success,exception]=privateIsDirectoryWritable(directory)

    exception=[];
    [success,msgOrAttrib,msgid]=fileattrib(directory);
    if~success
        exception=MException(msgid,msgOrAttrib);
        return
    end

    if ispc

        [~,testFileBaseName]=fileparts(tempname);
        testFileName=fullfile(directory,testFileBaseName);
        fid=fopen(testFileName,'w');
        if fid==-1
            success=false;
            exception=createException(directory);
        else
            success=true;
            fclose(fid);
            delete(testFileName);
        end
    else

        success=msgOrAttrib.UserWrite;
        if~success
            exception=createException(directory);
        end
    end
end

function exception=createException(directory)
    exception=MException(message('SimBiology:DirectoryPermission:NotWritable',directory));
end
