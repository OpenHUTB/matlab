function files=resolveFiles(filename1,filename2,filename3)






























    import java.io.File;

    if(nargin<3)
        inputs=struct(...
        'Name',{'filename1','filename2'},...
        'Side',{'Left','Right'},...
        'Value',{filename1,filename2}...
        );
    else
        inputs=struct(...
        'Name',{'baseFile','mineFile','theirsFile'},...
        'Side',{'Base','Mine','Theirs'},...
        'Value',{filename1,filename2,filename3}...
        );
    end

    parseInputs(inputs);
    for input=inputs
        files.(input.Side)=File(...
        comparisons.internal.resolvePath(char(input.Value))...
        );
    end

end

function parseInputs(files)
    parser=inputParser();
    for file=files
        parser.addRequired(...
        file.Name,...
        @(x)validateattributes(x,{'string','char'},{})...
        );
    end
    parser.parse(files(:).Value);
end