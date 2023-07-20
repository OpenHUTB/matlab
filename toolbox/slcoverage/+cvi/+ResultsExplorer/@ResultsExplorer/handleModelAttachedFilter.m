function handleModelAttachedFilter(obj,node)




    try
        filterFile='';
        cvd=node.data.getCvd;
        if isa(cvd,'cvdata')
            filterFile=cvd.filter;
        else
            cvds=cvd.getAll;
            for idx=1:numel(cvds)
                ccvd=cvds{idx};
                filterFile=ccvd.filter;
                if~isempty(filterFile)


                    break;
                end
            end
        end

        if~isempty(filterFile)
            if isempty(obj.filterExplorer)
                if obj.filterEditor.isEmpty
                    loadFilter(obj,filterFile);
                end
            else
                if~iscell(filterFile)
                    filterFile={filterFile};
                end
                obj.filterExplorer.addFilterFiles(filterFile);
            end
        end
    catch MEx
        rethrow(MEx);
    end
end