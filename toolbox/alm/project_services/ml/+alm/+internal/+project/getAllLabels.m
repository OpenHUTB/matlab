function s=getAllLabels(rootFolder)
    p=matlab.internal.project.api.makeProjectAvailable(rootFolder);

    ff=p.Files;

    s=containers.Map();
    for i=1:numel(ff)
        f=ff(i);

        try
            labels=f.Labels;
            if~isempty(labels)
                slbl=struct("c","","l","");
                slbl=repmat(slbl,1,numel(labels));
                for j=1:numel(labels)
                    slbl(j).c=labels(j).CategoryName;
                    slbl(j).l=labels(j).Name;
                end
                s(f.Path)=slbl;
            end
        catch ME
            if ME.identifier~="MATLAB:project:management:LabelDoesNotExistsByUUID"
                rethrow ME;
            end
        end

    end

    s=jsonencode(s);

end
