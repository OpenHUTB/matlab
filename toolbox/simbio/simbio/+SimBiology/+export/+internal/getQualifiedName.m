function varargout=getQualifiedName(componentArray)













    varargout=get(componentArray,{'FullyQualifiedName'});

    varargout=regexprep(varargout,'^(?:\[.*?\]|.*?)\.','');

end