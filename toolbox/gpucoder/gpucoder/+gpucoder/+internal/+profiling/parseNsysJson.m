function[labels,data]=parseNsysJson(filename)




    jsonText=importdata(filename);

    if(numel(jsonText)<1)
        labels=[];
        data=[];
        return;
    end

    labels=jsondecode(jsonText{1});
    jsonData=cell(1,numel(jsonText)-1);
    for i=2:numel(jsonText)
        jsonData{i-1}=jsondecode(jsonText{i});
    end



    data={};
    j=1;
    for i=1:numel(jsonData)
        if isfield(jsonData{i},'NvtxEvent')||isfield(jsonData{i},'CudaEvent')||...
            isfield(jsonData{i},'DiagnosticEvent')||isfield(jsonData{i},'TraceProcessEvent')
            data{j}=jsonData{i};%#ok<AGROW>
            j=j+1;
        end
    end
end
