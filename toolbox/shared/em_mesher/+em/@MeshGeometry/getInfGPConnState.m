function propVal=getInfGPConnState(obj)
    if isfield(obj.MesherStruct,'infGPconnected')
        propVal=obj.MesherStruct.infGPconnected;
    else
        propVal=[];
    end
end