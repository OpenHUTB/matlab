function htmlOut=matdiff(filename1,filename2)

    import comparisons.internal.util.process;
    import comparisons.internal.util.APIUtils;

    narginchk(2,2);
    error(javachk('jvm'));

    APIUtils.parse('matdiff',filename1,filename2);
    [filename1,filename2]=convertStringsToChars(filename1,filename2);

    try
        if nargout==0
            error(javachk('swing'));


            process(...
            @()comparisons_private('comparefiles',filename1,filename2)...
            );
        else
            htmlOut=process(...
            @()comparisons_private('matdiff',filename1,filename2,'')...
            );
        end
    catch exception
        APIUtils.handleExceptionCallStack(exception);
    end