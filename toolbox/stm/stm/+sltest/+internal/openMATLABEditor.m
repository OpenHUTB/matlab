function fileOpened=openMATLABEditor(testFileName,varargin)



    if nargin>1
        testCaseName=regexprep(varargin{1},'\([^\)]+\)$','');
        doc=matlab.desktop.editor.openAndGoToFunction(testFileName,testCaseName);
    else
        doc=matlab.desktop.editor.openDocument(testFileName);
    end
    fileOpened=~isempty(doc);
end