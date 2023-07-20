


function output=toStruct(this)
    list={'Data','IsViolation','IsInformer','Description','Title','Information','Status','RecAction','Tags','Severity','TaskID','CheckID','ID','CustomData'};
    output=struct;
    for i=1:numel(list)
        output.(list{i})=this.(list{i});
    end
    switch this.Type
    case ModelAdvisor.ResultDetailType.Signal
        output.Data='';
    case ModelAdvisor.ResultDetailType.Constraint
        if(iscell(output.Data))
            output.CustomData=output.Data;
        else
            output.CustomData={output.Data};
        end
        output.Data='Constraint Object';
    case ModelAdvisor.ResultDetailType.BlockParameter
        output.Block=this.DetailedInfo.Block;
        output.Parameter=this.DetailedInfo.Parameter;
    case ModelAdvisor.ResultDetailType.ConfigurationParameter
        output.Model=this.DetailedInfo.ModelName;
        output.Parameter=this.DetailedInfo.Parameter;
    case ModelAdvisor.ResultDetailType.Mfile
        output.Expression=this.DetailedInfo.Expression;
        output.FileName=this.DetailedInfo.FileName;
        output.Line=this.DetailedInfo.Line;
        output.Column=this.DetailedInfo.Column;
    end

    if isnumeric(output.Data)
        output.Data=num2str(output.Data);
    end

    output.ID=char(output.ID);
    output.IsViolation=int32(output.IsViolation);
    output.IsInformer=int32(output.IsInformer);
    output.Type=int32(this.Type);
end
