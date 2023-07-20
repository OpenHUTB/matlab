



function anno=getAnnotationData(~,data)
    tableData=values(data);
    anno={};
    if~isempty(tableData)
        field=fields(tableData{1});
        for i=1:numel(tableData)
            dt=tableData{i};
            anno{end+1}=dt.(field{1});%#ok
        end
    end
end