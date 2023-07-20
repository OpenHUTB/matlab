function matMulStrategy=getMatMulStrategy(this,hC)

    matMulStrategy=this.getImplParams('DotProductStrategy');
    if isempty(matMulStrategy)


        hN=hC.Owner;
        if~isempty(hN)&&~isempty(hN.FullPath)&&contains(hN.FullPath,'/')
            impl=slprops.hdlblkdlg(hN.FullPath);
            implInfo=impl.getCurrentArchImplParams;
            if isKey(implInfo,'dotproductstrategy')
                currParamInfo=implInfo('dotproductstrategy');
                matMulStrategy=currParamInfo.Value;
            end
        end
    end
end
