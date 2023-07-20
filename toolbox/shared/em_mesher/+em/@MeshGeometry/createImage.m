function[pimage,timage]=createImage(obj,pactual,tactual)

    if obj.MesherStruct.conductivity~=inf||obj.MesherStruct.thickness~=0
        error(message('antenna:antennaerrors:NoConductorInIGP'));
    end
    pimage=pactual;
    pimage(3,:)=-pactual(3,:);
    if obj.MesherStruct.infGPconnected

        saveGroundConnection(obj,[],[]);
    end
    timage=tactual;
end