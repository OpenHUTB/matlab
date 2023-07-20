function out=compare(filename1,filename2)











    import comparisons.internal.util.APIUtils;


    if~builtin('license','checkout','SIMULINK')
        slxmlcomp.internal.error('engine:SLLicenseUnavailable');
    end

    if strcmp(filename1,'check')



        out=[];
        return
    end

    APIUtils.parse('slxmlcomp.compare',filename1,filename2);
    [filename1,filename2]=convertStringsToChars(filename1,filename2);

    editsFactory=slxmlcomp.internal.EditsUtils.getEditsFactory();

    try
        if nargout==0
            xmlcomp.internal.doComparison(...
            filename1,...
            filename2,...
            @()slxmlcomp.internal.SLXMLComparisonBuilder(),...
editsFactory...
            );
        else
            out=xmlcomp.internal.doComparison(...
            filename1,...
            filename2,...
            @()slxmlcomp.internal.SLXMLComparisonBuilder(),...
editsFactory...
            );
        end
    catch exception
        APIUtils.handleExceptionCallStack(exception);
    end
end
