function result=modelref_CodeReplacementLibrary(csTop,csChild,varargin)













    topCodeReplacementLibraries=csTop.get_param('CodeReplacementLibrary');
    childCodeReplacementLibraries=csChild.get_param('CodeReplacementLibrary');
    result=~isequal(topCodeReplacementLibraries,childCodeReplacementLibraries);


    if result
        topCodeReplacementLibraryArray=coder.internal.getCrlLibraries(topCodeReplacementLibraries);
        childCodeReplacementLibraryArray=coder.internal.getCrlLibraries(childCodeReplacementLibraries);
        topLeng=length(topCodeReplacementLibraryArray);
        bottomLeng=length(childCodeReplacementLibraryArray);
        if topLeng~=bottomLeng
            return;
        else
            allMatches=true;
            for i=1:topLeng
                allMatches=(allMatches&&...
                RTW.isTflEq(topCodeReplacementLibraryArray{i},...
                childCodeReplacementLibraryArray{i}));
            end
            if allMatches
                result=false;
            end
        end
    end
end
