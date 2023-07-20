function setRAMNetworkFlags(ramNIC,ramComp)







    hN=ramNIC.ReferenceNetwork;

    hN.alwaysDontDraw;
    hN.renderCodegenPir(false);
    hN.setRAM(true);


    if ramComp.getGMHandle==-1
        switch class(ramComp)
        case 'hdlcoder.ram_single_comp'
            ramTypeEnum=0;
            readNewData=ramComp.getReadNewData;
        case 'hdlcoder.ram_simple_dual_comp'
            ramTypeEnum=1;
            readNewData=false;
        case 'hdlcoder.ram_dual_comp'
            ramTypeEnum=2;
            readNewData=ramComp.getReadNewData;
        otherwise
            return
        end

        IVStr=ramComp.getInitialVal;
        if~isnumeric(IVStr)
            IV=str2num(IVStr);%#ok<ST2NM>
        else
            IV=IVStr;
        end


        ramNIC.setSyntheticRam(ramTypeEnum,readNewData,IV);
    end
end
