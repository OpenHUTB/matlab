function[elementPath,elementName]=splitQualifiedName(qualifiedName)














    assert((ischar(qualifiedName)||isStringScalar(qualifiedName))||iscell(qualifiedName),...
    'input must be char or cell array of char.');


    if iscell(qualifiedName)
        qualifiedNames=qualifiedName;
    else
        qualifiedNames=cellstr(qualifiedName);
    end


    nodeNames=cell(1,length(qualifiedNames));
    nodePaths=cell(1,length(qualifiedNames));
    for idx=1:length(qualifiedNames)
        tokens=arxml.splitAbsolutePath(qualifiedNames{idx});
        nodeNames{idx}=tokens{end};
        nodePath='';
        for ii=1:length(tokens)-1
            nodePath=[nodePath,'/',tokens{ii}];%#ok
        end
        nodePaths{idx}=nodePath;
    end


    if iscell(qualifiedName)
        elementPath=nodePaths;
        elementName=nodeNames;
    else
        elementPath=nodePaths{1};
        elementName=nodeNames{1};
    end


