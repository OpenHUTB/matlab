function retval=hideElabNetworkinGM(this,~,hC)


























    [~,~,~,~,~,interpVal]=this.getBlockInfo(hC);
    nfpOptions=this.getNFPBlockInfo;
    if interpVal==0

        retval=true;
    elseif~nfpOptions.PrecomputeCoefficients


        retval=true;
    else



        retval=false;
    end
end