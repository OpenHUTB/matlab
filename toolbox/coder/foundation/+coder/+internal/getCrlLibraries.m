



function libraries=getCrlLibraries(compositeLibNameString)
    delimiter=coder.internal.getCrlLibraryDelimiter();
    libraries=strtrim(strsplit(compositeLibNameString,delimiter));
end