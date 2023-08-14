function test=generateTests(numberOfNodes,checkIdVgs,checkIdVds,checkQiss,checkQoss,checkBreakdown,vt,vds,ciss,coss,breakdownScalingForVds)
















































    i=1;
    if checkIdVgs==1
        if(numberOfNodes==3)||(numberOfNodes==4)
            test(i)=ee.internal.validation.mosfet.generateTestStructure(strcat("idvgst",string(numberOfNodes)),vt,vds);
            i=i+1;
        end
        if numberOfNodes==5
            test(i)=ee.internal.validation.mosfet.generateTestStructure("idvgst5tj27",vt,vds);
            i=i+1;
            test(i)=ee.internal.validation.mosfet.generateTestStructure("idvgst5tj75",vt,vds);
            i=i+1;
        end
        if numberOfNodes==6
            test(i)=ee.internal.validation.mosfet.generateTestStructure("idvgst6tj27",vt,vds);
            i=i+1;
            test(i)=ee.internal.validation.mosfet.generateTestStructure("idvgst6tj75",vt,vds);
            i=i+1;
        end
    end
    if checkIdVds==1
        test(i)=ee.internal.validation.mosfet.generateTestStructure(strcat("idvdst",string(numberOfNodes)),vt,vds);
        i=i+1;
    end
    if checkQiss==1
        test(i)=ee.internal.validation.mosfet.generateTestStructure(strcat("qisst",string(numberOfNodes)),vt,vds,ciss);
        i=i+1;
    end
    if checkQoss==1
        test(i)=ee.internal.validation.mosfet.generateTestStructure(strcat("qosst",string(numberOfNodes)),vt,vds,coss);
        i=i+1;
    end
    if checkBreakdown==1
        test(i)=ee.internal.validation.mosfet.generateTestStructure(strcat("breakdownt",string(numberOfNodes)),vt,vds,breakdownScalingForVds);
    end

    if~exist("test","var")
        pm_error("physmod:ee:SPICE2sscvalidation:TestError");
    end
end

