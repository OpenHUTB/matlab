function tf=isScalarText(text)
    isCharVector=ischar(text);
    isScalarString=isstring(text)&&isscalar(text);
    tf=isCharVector||isScalarString;
end