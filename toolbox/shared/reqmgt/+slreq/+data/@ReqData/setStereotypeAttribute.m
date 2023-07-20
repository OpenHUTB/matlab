function setStereotypeAttribute(this,reqLink,attributeName,value)




    if isa(reqLink,'slreq.data.Requirement')||isa(reqLink,'slreq.data.Link')
        mfReqLink=this.getModelObj(reqLink);
    elseif isa(reqLink,'slreq.datamodel.RequirementItem')||isa(reqLink,'slreq.datamodel.Link')
        mfReqLink=reqLink;
    elseif isa(reqLink,'slreq.datamodel.Link')
        error('Stereotype for link is not supported yet');

    end

    catt=mfReqLink.customAttributes.getByKey(attributeName);
    type=slreq.internal.ProfileReqType.getStereotypeAttrType(attributeName);

    needToAdd=false;
    if strcmp(type,'string')
        [catt,needToAdd]=createIfNeeded(@slreq.datamodel.StrCustAttrItem,catt,this.model,attributeName);
        catt.value=value;
    elseif any(strcmp(type,{'uint8','uint16','uint32','uint64'}))
        val=checkLimit(type,value);
        [catt,needToAdd]=createIfNeeded(@slreq.datamodel.IntCustAttrItem,catt,this.model,attributeName);

        if val<0
            error(message('Slvnv:slreq:OutOfRangeInputValue',val,type));
        else
            catt.value=val;
        end
    elseif any(strcmp(type,{'int8','int16','int32','int64'}))
        val=checkLimit(type,value);
        [catt,needToAdd]=createIfNeeded(@slreq.datamodel.IntCustAttrItem,catt,this.model,attributeName);

        catt.value=val;

    elseif any(strcmp(type,{'double','single'}))


        [catt,needToAdd]=createIfNeeded(@slreq.datamodel.RealCustAttrItem,catt,this.model,attributeName);
        if isa(value,'string')||isa(value,'char')
            catt.value=str2double(value);
        else
            catt.value=value;
        end
    elseif strcmp(type,'boolean')
        [catt,needToAdd]=createIfNeeded(@slreq.datamodel.BoolCustAttrItem,catt,this.model,attributeName);
        if isa(value,'string')||isa(value,'char')
            catt.value=logical(str2double(value));
        else
            catt.value=value;
        end
    elseif isenum(value)&&strcmp(class(value),type)
        [catt,needToAdd]=createIfNeeded(@slreq.datamodel.EnumCustAttrItem,catt,this.model,attributeName);
        catt.index=int32(value);
    elseif ismember(value,enumeration(type))
        [catt,needToAdd]=createIfNeeded(@slreq.datamodel.EnumCustAttrItem,catt,this.model,attributeName);
        catt.index=find(strcmp(enumeration(type),value))-1;
    else

        error("Not supported yet");
    end

    if needToAdd
        mfReqLink.customAttributes.add(catt);
    end
end

function val=checkLimit(type,value)
    persistent valueLimits
    if isempty(valueLimits)
        valueLimits=struct('int8',[-2^7,2^7-1],'int16',[-2^15,2^15-1],'int32',[-2^31,2^31-1],'int64',[-2^63,2^63-1],...
        'uint8',[0,2^8-1],'uint16',[0,2^16-1],'uint32',[0,2^32-1],'uint64',[0,2^64-1]);
    end
    val=value;
    if isa(value,'string')||isa(value,'char')
        val=str2double(value);
    end

    limits=valueLimits.(type);
    if val<limits(1)||val>limits(2)
        error(message('Slvnv:slreq:OutOfRangeInputValue',val,type));
    end
end

function[catt,needToAdd]=createIfNeeded(func,catt,model,name)
    needToAdd=false;
    if isempty(catt)
        catt=func(model);
        catt.name=name;
        needToAdd=true;
    end
end