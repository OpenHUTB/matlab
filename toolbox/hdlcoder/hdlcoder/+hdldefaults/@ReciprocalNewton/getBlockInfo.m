function newtonInfo=getBlockInfo(this,hC)









    slbh=hC.SimulinkHandle;
    newtonInfo.networkName=get_param(slbh,'name');


    newtonInfo.rndMode='Floor';
    newtonInfo.satMode='Saturate';

    blockType=get_param(slbh,'BlockType');
    if strcmpi(blockType,'Math')

        newtonInfo.iterNum=this.hdlslResolve('Iterations',slbh);
    else

        newtonInfo.iterNum=this.hdlslResolve('NumberOfIterations',slbh);
    end



    newtonInfo.isMultirate=true;
    newtonInfo.upFactor=2;


    newtonInfo.isRsqrtBased=false;




    newtonInfo.intermDT='';
    newtonInfo.internalRule='';








