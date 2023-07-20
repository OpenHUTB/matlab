function v_settings=block_validate_settings(this,hC)






    v_settings=this.base_validate_settings;


    v_settings.checknfp=false;
    if~isempty(hC)
        blockInfo=this.getBlockInfo(hC);

        if strcmpi(blockInfo.AlgorithmType,'GaussJordanElimination')
            v_settings.checknfpdouble=false;
        end
    end


    v_settings.checkportdatatypes=false;
    v_settings.incompatibleforxilinx=true;
    v_settings.incompatibleforaltera=true;
end
