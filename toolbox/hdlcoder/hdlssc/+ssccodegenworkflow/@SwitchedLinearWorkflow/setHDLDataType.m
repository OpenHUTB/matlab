function setHDLDataType(obj,type)




    if~(strcmpi(type,'single')||strcmpi(type,'double')||strcmpi(type,'MixedDoubleSingle'))
        me=MException('generateHDLModel:SetHDLDataTypeFailed',...
        message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:SetHDLDataTypeFailed',obj.SimscapeModel).getString);
        throwAsCaller(me);
    end
    obj.HDLAlgorithmDataType=lower(type);
end
