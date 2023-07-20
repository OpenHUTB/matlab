



function errorWithContext(ex,errorPrefix,varargin)



    errorDesc='';

    foldersOfInterest=[{fullfile('+internal','+mtree')},varargin];

    for i=1:numel(ex.stack)
        stack=ex.stack(i);

        if contains(stack.file,foldersOfInterest)
            errorDesc=[stack.name,': ',num2str(stack.line),': ',ex.message];
            break
        end
    end

    if isempty(errorDesc)
        stack=ex.stack(1);
        errorDesc=[stack.name,': ',num2str(stack.line),': ',ex.message];
    end

    error([errorPrefix,errorDesc]);
end
