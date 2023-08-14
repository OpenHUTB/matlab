

function incrementHeaderPath(aObj,aHeaderPath)

    if ischar(aHeaderPath)
        invalidChars=',';
        if~isempty(regexp(aHeaderPath,invalidChars,'ONCE'))
            DAStudio.error('Slci:ui:HeaderPathMustBeValid',aHeaderPath,invalidChars)
        else
            aObj.fEDGOptions.Preprocessor.IncludeDirs{end+1}=aHeaderPath;
        end
    else
        DAStudio.error('Slci:slci:DerivedHeaderPathMustBeString')
    end
end