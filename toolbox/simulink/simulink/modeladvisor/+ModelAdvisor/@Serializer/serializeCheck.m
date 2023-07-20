function out=serializeCheck(this,checkObj)

    out=this.BaseCheckStruct;

    fields=fieldnames(out);
    for i=1:numel(fields)
        if~isempty(out.(fields{i}))&&isprop(checkObj,out.(fields{i}))
            out.(fields{i})=checkObj.(out.(fields{i}));
        end
    end

    out.iscompile=~strcmp(checkObj.CallbackContext,'None');

    if isempty(checkObj.InputParametersLayoutGrid)
        out.InputParametersLayoutGrid_row=0;
        out.InputParametersLayoutGrid_col=0;
    else
        out.InputParametersLayoutGrid_row=checkObj.InputParametersLayoutGrid(1);
        out.InputParametersLayoutGrid_col=checkObj.InputParametersLayoutGrid(2);
    end

    if size(checkObj.Action,2)>0
        out.action=struct('Name',checkObj.Action.Name,...
        'Description',checkObj.Action.Description,...
        'Enable',checkObj.Action.enable);
    else
        out.action=struct('Name','NA',...
        'Description','NA',...
        'Enable','NA');
    end

    out.InputParameters=this.createInputParameters(checkObj);
    out.helpPath='';
    out.oldid='';
    out.oldparent='';
end