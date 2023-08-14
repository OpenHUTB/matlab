function out=serializeSingleNode(this,NodeObj)

    out=this.BaseNodeStruct;

    fields=fieldnames(out);
    for i=1:numel(fields)
        if~isempty(out.(fields{i}))&&isprop(NodeObj,out.(fields{i}))
            out.(fields{i})=NodeObj.(out.(fields{i}));
        end
    end

    out.helpPath='';
    out.oldid='';
    out.oldparent='';
    out.InputParametersCallback=false;

    if isa(NodeObj,'ModelAdvisor.Task')||isempty(NodeObj.InputParametersLayoutGrid)
        out.InputParametersLayoutGrid_row=0;
        out.InputParametersLayoutGrid_col=0;
    else
        out.InputParametersLayoutGrid_row=NodeObj.InputParametersLayoutGrid(1);
        out.InputParametersLayoutGrid_col=NodeObj.InputParametersLayoutGrid(2);
    end

    out.description=NodeObj.Description;
    out.InputParameters=[];
    out.originalNodeObjid=NodeObj.ID;
    out.Severity='';
    out.EdittimeClassname='';
    out.ConstraintXML='';

    if isa(NodeObj,'ModelAdvisor.Task')
        out.InputParameters=this.createInputParameters(NodeObj.Check);

        if~isempty(NodeObj.Check.InputParametersCallback)
            out.InputParametersCallback=true;
        end

        out.Severity=NodeObj.Severity;

        if~isempty(NodeObj.Check.Callback)&&ischar(NodeObj.Check.CallbackHandle)
            out.EdittimeClassname=NodeObj.Check.CallbackHandle;
        end
    end

    out.check=true;
    out.iscompile=false;
    out.isedittime=false;
    out.isblockconstraint=false;
    out.iconUri=NodeObj.getDisplayIcon;

    if isa(NodeObj,'ModelAdvisor.Group')
        out.checkid=NaN;
        out.searchdata=[out.label,' ',out.description];
    else

        out.checkid=NodeObj.Check.ID;
        out.iscompile=~strcmp(NodeObj.Check.CallbackContext,'None');
        out.searchdata=[out.label,' ',out.checkid,' ',out.description];

        if NodeObj.Check.SupportsEditTime

            out.searchdata=[out.searchdata,' ','@edit_time_supported_check'];
            out.isedittime=true;
        end

        if NodeObj.Check.getIsBlockConstraintCheck
            out.isblockconstraint=true;
            if~isempty(out.InputParameters)&&strcmp(out.InputParameters.name,'Data File')
                if exist(out.InputParameters.value,"file")
                    out.ConstraintXML=fileread(out.InputParameters.value);
                end
            else
                out.ConstraintXML=NodeObj.Check.getConstraintString();
            end
        end
    end


    out.runStatus=ModelAdvisor.CheckStatusUtil.getText(NodeObj.state);



    if isempty(deblank(out.iconUri))
        out.iconUri=NaN;
    else
        out.iconUri=['/',out.iconUri];
    end

    out.parent=NodeObj.ParentObj;
    if isempty(out.parent)
        out.parent=NaN;
    else
        out.parent=out.parent.ID;
    end

end
