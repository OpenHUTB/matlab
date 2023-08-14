function matlabCodeAsCellArray=getMatlabCodeAsCellArray(fileName)




    fileContentsAsString=matlab.internal.getCode(fileName);
    if(isempty(fileContentsAsString))
        matlabCodeAsCellArray={};
    else
        matlabCodeAsCellArray=strsplit(fileContentsAsString,{'\r\n','\n','\r'},'CollapseDelimiters',false)';
    end
end
