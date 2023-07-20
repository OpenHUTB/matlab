


function generateSLBlockWithDelay(this,hC,originalBlkPath,targetBlkPath,delay)

    targetBlkPath=this.addSLBlockSubsystem(hC,originalBlkPath,targetBlkPath);
    [outputBlk,outputBlkPosition]=this.addSLBlockModel(hC,originalBlkPath,targetBlkPath);
    [turnhilitingon,color]=this.getHiliteInfo(hC);%#ok<ASGLU>
    this.addLatencyToOutports(hC,targetBlkPath,outputBlk,outputBlkPosition,color,delay);
