function codeOut=replacetabs(codeIn,offset)
















    if nargin<2
        offset=0;
    end

    spacesPerTab=com.mathworks.widgets.text.EditorPrefsAccessor.getSpacesPerTab();
    tabChar=sprintf('\t');

    codeOut=codeIn;

    tabIndex=find(codeOut==tabChar);
    while~isempty(tabIndex)

        numSpaces=spacesPerTab-rem(tabIndex(1)+offset,spacesPerTab)+1;
        codeOut=regexprep(codeOut,'\t',char(32*ones(1,numSpaces)),'once');
        tabIndex=find(codeOut==tabChar);
    end
end

