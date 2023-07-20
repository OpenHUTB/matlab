function fileList=createFileListFromString(file)







    jFile=java.io.File(file);
    fileList=matlab.internal.project.util.asArrayList(jFile);

end

