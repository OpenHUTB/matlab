function parse(funcName,filename1,filename2)

    try
        parser=getParser(funcName);
        parser.parse(filename1,filename2);
    catch exception
        exception.throwAsCaller();
    end
end

function parser=getParser(funcName)
    parser=inputParser();
    parser.FunctionName=funcName;
    for name={'filename1','filename2'}
        parser.addRequired(...
        name{:},...
        @(x)validateattributes(x,{'char','string'},{'scalartext'})...
        );
    end
end
