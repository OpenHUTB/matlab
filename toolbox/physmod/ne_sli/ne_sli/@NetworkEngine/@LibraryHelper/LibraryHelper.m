function hObj=LibraryHelper(sourceFile,mlCommand,fPath,isSSCFunction)




    narginchk(4,4);

    hObj=NetworkEngine.LibraryHelper;

    hObj.SourceFile=sourceFile;
    hObj.Command=mlCommand;
    hObj.Path=fPath;
    hObj.IsSSCFunction=isSSCFunction;
end
