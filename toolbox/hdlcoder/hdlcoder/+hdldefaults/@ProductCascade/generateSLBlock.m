function generateSLBlock(this,hC,targetBlkPath)






    reporterrors(this,hC);

    validBlk=1;

    try
        originalBlkPath=getfullname(hC.SimulinkHandle);
    catch
        validBlk=0;
    end

    latencyInfo=this.getLatencyInfo(hC);

    if validBlk

        if length(hC.SLInputPorts)>1
            error(message('hdlcoder:validate:TooManyInputs'));
        end


        in1=hC.SLInputPorts(1).Signal;
        in1vect=hdlsignalvector(in1);


        out=hC.SLOutputPorts(1).Signal;
        opvect=hdlsignalvector(out);




        if(length(hC.SLInputPorts)==1&&...
            isequal(opvect,in1vect))
            targetBlkPath=addSLBlock(this,hC,originalBlkPath,targetBlkPath);
        else
            targetBlkPath=this.addSLBlockSubsystem(hC,originalBlkPath,targetBlkPath);
            [outputBlk,outputBlkPosition]=this.addSLBlockModel(hC,originalBlkPath,targetBlkPath);
            this.addSLBlockLatency(hC,targetBlkPath,latencyInfo,outputBlk,outputBlkPosition);
        end
    end
