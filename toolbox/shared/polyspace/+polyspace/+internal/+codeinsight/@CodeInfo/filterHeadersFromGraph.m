function headerFileList=filterHeadersFromGraph(headerList,includeFileList,headerGraph)




    headerIsNeeded=false(size(headerList));
    if ispc


        OriginalHeaderStrings=lower(headerList);
        typeIncludesStrings=lower(includeFileList);
    else
        OriginalHeaderStrings=headerList;
        typeIncludesStrings=includeFileList;
    end
    for includeFile=typeIncludesStrings

        originalHeaderIdx=find(ismember(OriginalHeaderStrings,includeFile),1);
        if~isempty(originalHeaderIdx)
            headerIsNeeded(originalHeaderIdx)=1;
        else
            if headerGraph.findnode(includeFile)
                includedBy=headerGraph.predecessors(includeFile);



                originalHeaderIdx=find(ismember(OriginalHeaderStrings,includedBy),1);
                if~isempty(originalHeaderIdx)
                    headerIsNeeded(originalHeaderIdx)=1;
                end
            end
        end
    end

    headerFileList=headerList(headerIsNeeded);
end

