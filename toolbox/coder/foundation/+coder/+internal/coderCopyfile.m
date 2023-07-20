







function coderCopyfile(srcFilename,dstFilename)
    if~exist(dstFilename,'file')&&exist(srcFilename,'file')
        try
            copyfile(srcFilename,dstFilename,'f');
        catch me


            status=-1;
            if isunix
                sys_cmd=['cp ',srcFilename,' ',dstFilename,' -f'];
                status=system(sys_cmd);
            end
            if status~=0
                rethrow(me);
            end
        end
        try
            fileattrib(dstFilename,'+w');
        catch
        end
    end
end
