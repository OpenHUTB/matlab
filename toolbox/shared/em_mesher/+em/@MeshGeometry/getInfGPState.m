function propVal=getInfGPState(obj)
    if isfield(obj.MesherStruct,'infGP')
        propVal=obj.MesherStruct.infGP;
    else
        propVal=[];
    end
end