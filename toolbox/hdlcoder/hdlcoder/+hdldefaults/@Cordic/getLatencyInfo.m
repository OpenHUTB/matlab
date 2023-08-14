function latencyInfo=getLatencyInfo(this,hC)











    slbh=hC.SimulinkHandle;

    isSysObj=isa(hC,'hdlcoder.sysobj_comp');
    if isSysObj
        sysObjHandle=hC.getSysObjImpl;
        cordicInfo=getSysObjInfo(this,hC,sysObjHandle);
        iterNum=cordicInfo.iterNum;


        outputDelay=iterNum+1;
    else
        iterNum=this.hdlslResolve('NumberOfIterations',slbh);
        if(isempty(this.getImplParams('CustomLatency')))
            customLatency=0;
        else
            customLatency=this.getImplParams('CustomLatency');
        end

        if(isempty(this.getImplParams('LatencyStrategy')))
            latencyStrategy='MAX';
        else
            latencyStrategy=this.getImplParams('LatencyStrategy');
        end
        fName=get_param(slbh,'Operator');
        if(strcmpi(fName,'atan2'))
            if(strcmpi(latencyStrategy,'MAX'))
                outputDelay=iterNum+3;
            elseif(strcmpi(latencyStrategy,'CUSTOM'))
                outputDelay=customLatency;
            else
                outputDelay=0;
            end
        else

            if(strcmpi(latencyStrategy,'MAX'))
                outputDelay=iterNum+1;
            elseif(strcmpi(latencyStrategy,'CUSTOM'))
                outputDelay=customLatency;
            else
                outputDelay=0;
            end
        end
    end

    usePipelines=this.getUsePipelines(isSysObj);

    if(~usePipelines)
        outputDelay=0;
    end

    latencyInfo.inputDelay=0;
    latencyInfo.outputDelay=outputDelay;
    latencyInfo.samplingChange=1;
