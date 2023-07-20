function out=compare(filename1,filename2)










    import comparisons.internal.util.APIUtils;

    APIUtils.parse('xmlcomp.compare',filename1,filename2);
    [filename1,filename2]=convertStringsToChars(filename1,filename2);

    try
        if nargout==0
            xmlcomp.internal.doComparison(...
            filename1,...
            filename2,...
            @()xmlcomp.internal.XMLComparisonBuilder(),...
            @editsFactory...
            );
        else
            out=xmlcomp.internal.doComparison(...
            filename1,...
            filename2,...
            @()xmlcomp.internal.XMLComparisonBuilder(),...
            @editsFactory...
            );
        end
    catch exception
        APIUtils.handleExceptionCallStack(exception);
    end
end

function edits=editsFactory(comparisonDriver)
    import com.mathworks.toolbox.rptgenxmlcomp.matlab.XMLEditsDriverFacade;
    driverFacade=XMLEditsDriverFacade(comparisonDriver.getComparison());

    edits=xmlcomp.internal.edits.Edits.create(driverFacade);
end
