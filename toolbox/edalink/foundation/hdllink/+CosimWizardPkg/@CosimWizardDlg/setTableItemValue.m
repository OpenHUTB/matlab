function setTableItemValue(this,tag,rowAsName,colName,val)
    feval(['l_set',tag,'Value'],this,rowAsName,colName,val);
end









function l_setedaInPortListValue(this,rowAsName,colName,val)
    assert(strcmp(colName,'Type'),['(internal) bad colName: ',colName]);
    validatestring(val,hdlv.vc.stringValues('InputPortType'));
    allNames=cellfun(@(x)(x.Name),this.UserData.InPortList,'UniformOutput',false);
    rowIdx=find(strcmp(allNames,rowAsName));
    assert(~isempty(rowIdx),['Could not find specified port name: ',rowAsName]);
    row=this.UserData.InPortList{rowIdx};
    row.(colName)=hdlv.vc.toInteger('InputPortType',val);
end

function l_setedaOutPortListValue(this,rowAsName,colName,val)
    assert(strcmp(colName,'Type'),['(internal) bad colName: ',colName]);
    validatestring(val,hdlv.vc.stringValues('OutputPortType'));
    allNames=cellfun(@(x)(x.Name),this.UserData.OutPortList,'UniformOutput',false);
    rowIdx=find(strcmp(allNames,rowAsName));
    assert(~isempty(rowIdx),['Could not find specified port name: ',rowAsName]);
    row=this.UserData.OutPortList{rowIdx};
    row.(colName)=hdlv.vc.toInteger('OutputPortType',val);
end

function l_setedaUsedOutPortListValue(this,rowAsName,colName,val)

    switch colName
    case 'Sign'
        propName='OutputPortSigned';
        val=double(val);
        mustBeMember(val,hdlv.vc.integerValues(propName));
    case 'DataType'
        switch this.UserData.Workflow
        case 'Simulink',propName='OutputPortDataTypeSimulink';
        otherwise,propName='OutputPortDataTypeMATLAB';
        end
        validatestring(val,hdlv.vc.stringValues(propName));
        val=hdlv.vc.toInteger(propName,val);
    case{'SampleTime','FractionLength'}
        val=num2str(val);
    otherwise

    end

    allNames=cellfun(@(x)(x.Name),this.UserData.UsedOutPortList,'UniformOutput',false);
    rowIdx=find(strcmp(allNames,rowAsName));
    assert(~isempty(rowIdx),['Could not find specified port name: ',rowAsName]);
    row=this.UserData.UsedOutPortList{rowIdx};
    row.(colName)=val;
end

function l_setedaClocksValue(this,rowAsName,colName,val)
    switch colName
    case 'Edge'
        propName='ClockType';
        validatestring(val,hdlv.vc.stringValues(propName));
    case 'Period'
        val=num2str(val);
    otherwise

    end

    allNames=cellfun(@(x)(x.Name),this.UserData.ClkList,'UniformOutput',false);
    rowIdx=find(strcmp(allNames,rowAsName));
    assert(~isempty(rowIdx),['Could not find specified port name: ',rowAsName]);
    row=this.UserData.ClkList{rowIdx};
    row.(colName)=val;
end

function l_setedaResetsValue(this,rowAsName,colName,val)
    switch colName
    case 'Initial'
        val=num2str(val);
        propName='ResetType';
        validatestring(val,hdlv.vc.stringValues(propName));
    case 'Duration'
        val=num2str(val);
    otherwise

    end

    allNames=cellfun(@(x)(x.Name),this.UserData.RstList,'UniformOutput',false);
    rowIdx=find(strcmp(allNames,rowAsName));
    assert(~isempty(rowIdx),['Could not find specified port name: ',rowAsName]);
    row=this.UserData.RstList{rowIdx};
    row.(colName)=val;
end