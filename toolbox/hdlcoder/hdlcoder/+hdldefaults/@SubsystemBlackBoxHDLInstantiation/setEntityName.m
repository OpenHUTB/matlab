function isDefaultName=setEntityName(this,hC)

    isDefaultName=false;

    bfp=hC.SimulinkHandle;

    if bfp>0&&strcmp(get_param(bfp,'BlockType'),'ModelReference')
        if isprop(get_param(bfp,'Object'),'ProtectedModel')&&strcmp(get_param(bfp,'ProtectedModel'),'on')
            modelname=hdllegalnamersvd(get_param(bfp,'Name'));
        else
            modelname=hdllegalnamersvd(get_param(bfp,'ModelName'));
        end

        if isempty(this.getImplParams('EntityName'))
            this.addImplParam('EntityName',modelname);
            isDefaultName=true;
        end
    end
end

