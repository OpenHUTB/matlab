function Autotimescale(this,isPushButton)




















    portSampleTimes=l_GetPortSampleTimes(this,isPushButton);
    clkSampleTimes=l_GetClockSampleTime(this);
    hdlPrecision=l_GetHdlPrecision(this);

    allSampleTimes=[portSampleTimes,clkSampleTimes];


    if(length(allSampleTimes)==1)
        baseTime=allSampleTimes;
    else
        baseTime=computeBaseRate(allSampleTimes);
    end




    maxSampleTime=max(allSampleTimes);
    detailsMsg=l_GetDetailMsg(allSampleTimes,maxSampleTime,baseTime);





    badBaseRate=false;
    for m=1:length(allSampleTimes)
        r=isSecondMultipleOfFirst(baseTime,allSampleTimes(m));
        if~r
            badBaseRate=true;
            break;
        end
    end


    if(badBaseRate)
        errMsg=l_GenBadBaseRateMsg();
        errObj=l_GenMException('HDLLink:AutoTimescale:ErrBadBaseRate',...
        errMsg,detailsMsg);
        l_ShowCustomDialog(this.ProductName,errObj.identifier,'Error',...
        errObj.message,errObj.cause{1}.message);


        return;
    end


    maxAllowedTicks=2^31-1;
    if(maxSampleTime/baseTime>maxAllowedTicks)
        errMsg=l_GenRangeErrMsg();
        detailsMsg=[detailsMsg,l_GenRangeDetailsMsg(maxSampleTime,baseTime)];
        errObj=l_GenMException('HDLLink:AutoTimescale:ErrRangeTooLarge',...
        errMsg,detailsMsg);
        l_ShowCustomDialog(this.ProductName,errObj.identifier,'Error',...
        errObj.message,errObj.cause{1}.message);


        return;
    end





    ticksPerBaseTime=max(round(baseTime/hdlPrecision),1);
    scaleFactor=ticksPerBaseTime/baseTime;





    if(maxSampleTime*scaleFactor<=maxAllowedTicks)
        newScaleFactor=scaleFactor*hdlPrecision;



    else
        newScaleFactor=1/baseTime*hdlPrecision;
    end


    this.TimingScaleFactor=num2str(newScaleFactor,'%16.15g');
    this.TimingMode='s';


    h=hdllinkddg.AutoTimescaleDlg(this,newScaleFactor,portSampleTimes,hdlPrecision,isPushButton);
    DAStudio.Dialog(h);







end

















function portSampleTimes=l_GetPortSampleTimes(this,isPushButton)
    savedByPassMode=this.Block.CosimBypass;
    this.Block.CosimBypass='Confirm Interface Only';

    currentModel=this.Root.Name;
    ports=this.Block.portHandles;
    portHandles=[ports.Inport,ports.Outport];
    numPorts=length(portHandles);



    if(numPorts==0)
        error(message('HDLLink:AutoTimescale:ErrNoPorts'));
    end


    try

        if(isPushButton)
            feval(currentModel,[],[],[],'compileForSizes')
        end

        portSampleTimes=zeros(1,numPorts);
        for idx=1:numPorts
            time_pair=get_param(portHandles(idx),'CompiledSampleTime');
            portSampleTimes(idx)=time_pair(1);
        end

        if(isPushButton)
            feval(currentModel,[],[],[],'term')
        end

    catch ME
        this.Block.CosimBypass=savedByPassMode;
        rethrow(ME);
    end
    this.Block.CosimBypass=savedByPassMode;

end


function clkSampleTimes=l_GetClockSampleTime(this)
    clkData=this.ClockTableSource.GetSourceData;
    numClks=size(clkData,1);
    clkSampleTimes=zeros(1,numClks);
    for idx=1:numClks
        clkSampleTimes(idx)=slResolve(clkData{idx,3},this.Block.Handle)/2;
    end
end


function hdlPrecision=l_GetHdlPrecision(this)


    cInfo=this.CommSource.GetConnInfo;
    hdlPrecisionExponent=autopopulate(...
    '%^getPrecision^%',...
    double(cInfo.isOnLocalHost),...
    double(cInfo.isShared),...
    cInfo.hostName,...
    cInfo.portNumber);
    hdlPrecision=10^hdlPrecisionExponent;
end






function ME=l_GenMException(id,errMsg,detailsMsg)
    errME=MException(id,errMsg);
    ME=errME.addCause(MException(id,detailsMsg));
end


function fh=l_ShowCustomDialog(prodName,msgId,msgType,msg,detailMsg)
    fh=hdllinkddg.AutoTimescaleErr(prodName,msgId,msgType,msg,detailMsg);
    DAStudio.Dialog(fh);
    return;
end




function msg=l_GenBadBaseRateMsg()
    msg=sprintf(['The HDL Verifier software cannot calculate a base rate for the given sample times.  ',...
    'The specified sample times cannot be related to each other using',...
    ' simple integer multiples of a fundamental base rate.\n',...
    '\nYou must modify your Simulink sample times in order to cosimulate.\n']);
end
function msg=l_GetDetailMsg(allSampleTimes,maxSampleTime,baseTime)
    allUnique=unique(allSampleTimes);
    allBaseMults=allUnique/baseTime;
    msg=sprintf(...
    ['%s%s\n\n',...
    '%s\n        %16.15e\n',...
    '%s\n        %16.15e\n',...
    '\n%s%s\n\n'],...
    'The following lists all unique port and clock sample times:',...
    sprintf('\n        %16.15e',allUnique),...
    'Maximum sample time:',maxSampleTime,...
    'Fundamental sample time:',baseTime,...
    'The following lists all sample times expressed as a base rate multiplier.  All multipliers must be integers for a valid cosimulation:',...
    sprintf('\n        %16.15e',allBaseMults));
end

function msg=l_GenRangeErrMsg()
    msg=sprintf(...
    ['The HDL Verifier software cannot calculate a timescale for the given sample times because the ratio',...
    ' between the largest sample time and the fundamental sample time exceeds',...
    ' 2^31-1.  This large ratio can occur if you have either of the following conditions:\n\n',...
    ' 1. Very close, but not quite identical, sample times that require a small base rate\n',...
    ' 2. A very large range of sample times\n',...
    '\nYou must modify your Simulink sample times in order to cosimulate.\n']...
    );
end

function msg=l_GenRangeDetailsMsg(maxSampleTime,baseTime)
    msg=sprintf(...
    ['\n%s\n        %16.15e\n',...
    '%s\n        %16.15e\n'],...
    'Maximum sample time expressed as number of fundamental sample times:',...
    maxSampleTime/baseTime,...
    'Maximum allowable number of fundamental samples (2^31-1):',...
    2^31-1...
    );
end




