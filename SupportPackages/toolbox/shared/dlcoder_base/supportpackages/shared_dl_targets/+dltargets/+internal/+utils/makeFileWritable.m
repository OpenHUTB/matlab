
function makeFileWritable(fullFileName)
    if isunix


        fileattrib(fullFileName,'+w','a');
    else
        fileattrib(fullFileName,'+w');
    end
end

