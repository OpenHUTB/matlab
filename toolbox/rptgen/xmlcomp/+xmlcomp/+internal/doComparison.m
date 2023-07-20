function out=doComparison(fileName1,fileName2,comparisonBuilderFactory,editsFactory)




    if~usejava('jvm')
        xmlcomp.internal.error('engine:NoJava');
    end



    comparisonBuilder=comparisonBuilderFactory();
    comparisonBuilder.addFile(fileName1)...
    .addFile(fileName2);


    if nargout==0
        xmlcomp.internal.launchXMLComparison(comparisonBuilder.Sources{:});
        return
    end

    comparisonDriver=comparisonBuilder.build();

    if~isempty(comparisonDriver.getComparison())

        out=editsFactory(...
comparisonDriver...
        );
    else
        out=[];
    end

end
