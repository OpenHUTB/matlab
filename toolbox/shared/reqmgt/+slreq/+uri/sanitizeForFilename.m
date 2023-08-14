function out=sanitizeForFilename(in)

    out=regexprep(in,'\W','_');
    out=regexprep(out,'__*','_');

end
