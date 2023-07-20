function isWritable=isWritable(file)


    [~,attr]=fileattrib(file);
    isWritable=attr.UserWrite;
end
