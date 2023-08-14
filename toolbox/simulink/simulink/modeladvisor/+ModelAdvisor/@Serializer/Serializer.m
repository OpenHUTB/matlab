classdef Serializer<handle
    properties
        BaseCheckStruct=struct();
        BaseNodeStruct=struct();
        IPStruct=struct();
    end
    methods
        function this=Serializer()

            this.BaseCheckStruct.id='ID';
            this.BaseCheckStruct.label='Title';
            this.BaseCheckStruct.enable='Enable';
            this.BaseCheckStruct.description='Description';
            this.BaseCheckStruct.check='Selected';
            this.BaseCheckStruct.iscompile=[];
            this.BaseCheckStruct.InputParametersLayoutGrid_row=[];
            this.BaseCheckStruct.InputParametersLayoutGrid_col=[];
            this.BaseCheckStruct.action=[];
            this.BaseCheckStruct.InputParameters=[];
            this.BaseCheckStruct.helpPath=[];
            this.BaseCheckStruct.oldid=[];
            this.BaseCheckStruct.oldparent=[];

            this.BaseNodeStruct.id='ID';
            this.BaseNodeStruct.label='DisplayName';
            this.BaseNodeStruct.enable='Enable';
            this.BaseNodeStruct.description='Description';
            this.BaseNodeStruct.check='Selected';
            this.BaseNodeStruct.iscompile=[];
            this.BaseNodeStruct.isedittime=[];
            this.BaseNodeStruct.isblockconstraint=[];
            this.BaseNodeStruct.InputParametersLayoutGrid_row=[];
            this.BaseNodeStruct.InputParametersLayoutGrid_col=[];
            this.BaseNodeStruct.action=[];
            this.BaseNodeStruct.InputParameters=[];
            this.BaseNodeStruct.helpPath=[];
            this.BaseNodeStruct.oldid=[];
            this.BaseNodeStruct.oldparent=[];
            this.BaseNodeStruct.CSHParameters='CSHParameters';
            this.BaseNodeStruct.InputParametersCallback=[];
            this.BaseNodeStruct.originalnodeid='ID';
            this.BaseNodeStruct.Severity=[];
            this.BaseNodeStruct.EdittimeClassname=[];
            this.BaseNodeStruct.ConstraintXML=[];
            this.BaseNodeStruct.searchdata=[];
            this.BaseNodeStruct.iconUri=[];
            this.BaseNodeStruct.checkid=[];
            this.BaseNodeStruct.runStatus=[];
            this.BaseNodeStruct.parent=[];

            this.IPStruct.name='Name';
            this.IPStruct.index=[];
            this.IPStruct.type='Type';
            this.IPStruct.visible='Visible';
            this.IPStruct.entries=[];
            this.IPStruct.value=[];
            this.IPStruct.rowspan1=[];
            this.IPStruct.rowspan2=[];
            this.IPStruct.colspan1=[];
            this.IPStruct.colspan2=[];
            this.IPStruct.isenable='Enable';

        end

        out=serializeCheck(this,checkObj);
        out=serializeNode(this,NodeObj);
        out=serializeToConfig(this,inpObj);
    end

    methods(Access=private)
        out=createInputParameters(this,checkObj);
        out=serializeSingleNode(this,NodeObj)
    end

end