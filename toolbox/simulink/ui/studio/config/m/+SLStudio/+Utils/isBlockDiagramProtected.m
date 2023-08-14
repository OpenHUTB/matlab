function res=isBlockDiagramProtected(cbinfo)




    res=false;
    h=SLStudio.Utils.getModelHandle(cbinfo);
    protectionValue=get_param(h,'ProtectionState');
    if protectionValue~=0
        res=true;
    end
end
