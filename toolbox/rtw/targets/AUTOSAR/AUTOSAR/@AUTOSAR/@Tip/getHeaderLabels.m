





function labelInfo=getHeaderLabels(h)
    explorer=h.Explorer;
    mcosRef=explorer.getTreeSelection;
    headerInfo=[];
    if~isempty(mcosRef)

        columns=mcosRef.getARExplorerProperties;
        for i=1:numel(columns)
            headerInfo=[headerInfo,struct('name',columns{i},'width',-1,'icon','')];%#ok<AGROW>
        end
    end
    labelInfo=mls.internal.toJSON(struct('columns',headerInfo));
end


