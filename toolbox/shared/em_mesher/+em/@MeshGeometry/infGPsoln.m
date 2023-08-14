function infGPsoln(obj,bool,isconnected)
    if nargin==3
        obj.MesherStruct.infGPconnected=isconnected;
    else
        obj.MesherStruct.infGPconnected=false;
    end
    obj.MesherStruct.infGP=bool;
end