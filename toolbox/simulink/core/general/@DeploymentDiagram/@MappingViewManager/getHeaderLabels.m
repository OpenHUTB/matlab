function labelInfo=getHeaderLabels(~)





    columns={'Block','Name','TriggerType','Period','Autogenerated'};
    headerInfo=[];
    for i=1:numel(columns)
        headerInfo=[headerInfo,struct('name',columns{i},'width',-1,'icon','')];
    end
    labelInfo=jsonencode(struct('columns',headerInfo));
