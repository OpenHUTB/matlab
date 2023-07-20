function lutCount=getLUTCount(hPC)

    deviceUnsupported=false;

    deviceFamily=hPC.SynthesisToolChipFamily;
    if(strcmpi(deviceFamily,'Zynq UltraScale+')||strcmpi(deviceFamily,'Zynq'))
        device=1;
    elseif(strcmpi(deviceFamily,'Arria 10'))
        device=2;
    else
        deviceUnsupported=true;
    end

    if(strcmpi(hPC.ProcessorDataType,'single'))
        kDatatype=1;
    elseif(strcmpi(hPC.ProcessorDataType,'int8'))
        kDatatype=2;
    else
        deviceUnsupported=true;
    end

    if(deviceUnsupported)
        warning(message("dnnfpga:config:UnsupportedDeviceLUT",deviceFamily,"Zynq, Zynq UltraScale+ and Arria 10"));
        lutCount=0;
    else

        convLUTCount=getConvLUTCount(hPC,device,kDatatype);
        customLUTCount=getCustomModuleLUTCount(hPC,device,kDatatype);
        fcLUTCount=getFCModuleLUTCount(hPC,device,kDatatype);
        constantLUTCount=getDesignConstantLUTCount(device,kDatatype);
        lutCount=convLUTCount+customLUTCount+fcLUTCount+constantLUTCount;
    end
end

function c=getDesignConstantLUTCount(device,kDatatype)
    count={};




    count{1,1}=[4055,12261];

    count{2,1}=[3201,15806];


    count{1,2}=[3656,12798];

    count{2,2}=[3119,14605];
    c=sum(count{device,kDatatype});
end

function convLUTCount=getConvLUTCount(hPC,device,kDatatype)
    moduleGen=contains(hPC.getModuleProperty('conv','ModuleGeneration'),'on');
    cThread=hPC.getModuleProperty('conv','ConvThreadNumber');
    segFlag=contains(hPC.getModuleProperty('conv','SegmentationBlockGeneration'),'on');
    lrnFlag=contains(hPC.getModuleProperty('conv','LRNBlockGeneration'),'on');
    coeff=getConvCoefficients(device,kDatatype);
    convLUTCount=moduleGen*(coeff(1)+...
    cThread*(coeff(2)+coeff(4)*segFlag+coeff(6)*lrnFlag)+...
    (coeff(3)+coeff(5)*segFlag+coeff(7)*lrnFlag));
end

function c=getConvCoefficients(device,kDatatype)







    coeff={};


    coeff{1,1}=[1755,9244.6,18587,900.4,1155,530.7,10542];

    coeff{2,1}=[3153,1763.2,16923,603.6,2379,92.5,3133];


    coeff{1,2}=[1445,884.2,16003,201.7,4291,538,19855];

    coeff{2,2}=[4653,788.32,16914,127.78,3204,611.38,20175];
    c=coeff{device,kDatatype};
end

function convLUTCount=getCustomModuleLUTCount(hPC,device,kDatatype)
    moduleGen=contains(hPC.getModuleProperty('custom','ModuleGeneration'),'on');
    cThread=hPC.getModuleProperty('conv','ConvThreadNumber');
    resizeFlag=contains(hPC.getModuleProperty('custom','Resize2D'),'on');
    tanhFlag=contains(hPC.getModuleProperty('custom','TanhLayer'),'on');
    sigmoidFlag=contains(hPC.getModuleProperty('custom','Sigmoid'),'on');
    coeff=getCustomModuleCoefficients(device,kDatatype);
    convLUTCount=moduleGen*(coeff(1)+...
    2^(ceil(log2(sqrt(cThread))))^2*(coeff(2)+coeff(4)*resizeFlag+coeff(6)*tanhFlag+coeff(8)*sigmoidFlag)+...
    (coeff(3)+coeff(5)*resizeFlag+coeff(7)*tanhFlag+coeff(9)*sigmoidFlag));
end

function c=getCustomModuleCoefficients(device,kDatatype)









    coeff={};


    coeff{1,1}=[2245,62.6,3294.5,9,323.2,417.4,8625.5,302.1,6036.2];



    coeff{2,1}=[5277,30.9,3181.7,0,0,0,0,87,1650.1];




    coeff{1,2}=[2955,92,3816.5,0,0,0,0,0,0];



    coeff{2,2}=[1715,105,3896,0,0,0,0,0,0];
    c=coeff{device,kDatatype};
end

function fcLUTCount=getFCModuleLUTCount(hPC,device,kDatatype)
    moduleGen=contains(hPC.getModuleProperty('fc','ModuleGeneration'),'on');
    fcThread=hPC.getModuleProperty('fc','FCThreadNumber');
    softmax=contains(hPC.getModuleProperty('fc','SoftmaxBlockGeneration'),'on');
    sigmoid=contains(hPC.getModuleProperty('fc','SigmoidBlockGeneration'),'on');


    combinedFlag=0;
    if(softmax&&sigmoid)
        softmax=0;
        sigmoid=0;
        combinedFlag=1;
    end
    coeff=getFCCoefficients(device,kDatatype);
    fcLUTCount=moduleGen*(coeff(1)+...
    fcThread*(coeff(2)+...
    coeff(4)*sigmoid+...
    coeff(6)*softmax+...
    coeff(8)*combinedFlag)+...
    (coeff(3)+...
    coeff(5)*sigmoid+...
    coeff(7)*softmax+...
    coeff(9)*combinedFlag));
end

function c=getFCCoefficients(device,kDatatype)











    coeff={};


    coeff{1,1}=[1439,1680,1285.5,3261.2,657,3445.8,552.5,3927.1,360];

    coeff{2,1}=[3070,668.45,1501.5,855.25,887.5,1851.05,1018,956.85,1012];


    coeff{1,2}=[602,1295.9,808,3795.7,457,3980.2,605,4501.6,354.5];

    coeff{2,2}=[4213,1302.8,1367.5,3964.8,570.5,4104.1,750.5,4609.9,454.5];
    c=coeff{device,kDatatype};
end


















