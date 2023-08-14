function labelInfo=getHeaderLabels(this)

    headerInfo=[];
    columns=this.view.Columns;
    for i=1:numel(columns)
        headerInfo=[headerInfo,struct('name',columns{i},'width',-1,'icon','')];
    end
    labelInfo=mls.internal.toJSON(struct('columns',headerInfo));
end
