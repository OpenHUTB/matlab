function name=getResetInputPort(this,~)



    addReset=this.getImplParams('AddResetPort');

    addReset=isempty(addReset)||strcmpi(addReset,'on');

    if addReset
        resetName=this.getImplParams('ResetInputPort');
        if isempty(resetName)

            paramInfoMap=this.getImplParamInfo;
            paramInfo=paramInfoMap('resetinputport');
            name=paramInfo.DefaultValue;
        else
            name=hdllegalnamersvd(resetName);
        end
    else
        name='';
    end


