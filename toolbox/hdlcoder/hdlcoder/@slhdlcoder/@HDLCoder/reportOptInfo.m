function reportOptInfo(this)




    gp=pir;
    balanceMsg=true;
    if gp.streamingRequested||gp.sharingRequested
        failures=reportAllInfo(this,gp.getTopPirCtx,this.getParameter('debug')>1);
        if failures
            modelParams=this.getModelParams;
            optRptParamNameIndex=strcmp(modelParams,'OptimizationReport');

            optRptParamValue=modelParams([false,optRptParamNameIndex(1:end-1)]);
            if strcmpi(optRptParamValue,'on')


                msg=message('hdlcoder:engine:streamsharefailOptRptOn');
            else
                msg=message('hdlcoder:engine:streamsharefail',this.ModelName);
            end
            this.addCheck(this.ModelName,'Warning',msg)
        else
            balanceMsg=false;
        end
    end

    reportDelayBalancingInfo(this,gp,balanceMsg);
end


function reportDelayBalancingInfo(this,gp,needsMessage)
    if~gp.isDelayBalancable&&gp.needsDelayBalancing
        blkname=gp.getBalanceFailureCulprit;
        msg=gp.getBalanceFailureReason;


        if~isempty(blkname)
            try
                isBlackBox=strcmpi(hdlget_param(blkname,'Architecture'),'BlackBox');
            catch mEx
                assert(any(strcmpi({'Simulink:LoadSave:InvalidBlockDiagramName',...
                'Simulink:Commands:InvSimulinkObjectName',...
                'Simulink:Commands:ParamUnknown'},mEx.identifier)));
                isBlackBox=false;
            end
        end

        failureType='Error';
        if(strcmpi(this.getParameter('TreatDelayBalancingFailureAs'),'Warning'))
            failureType='Warning';
        end

        if isempty(blkname)
            this.addCheck(this.ModelName,failureType,message('hdlcoder:engine:pathbalancing',msg));
        elseif isBlackBox&&strcmpi(msg,DAStudio.message('hdlcoder:srsdiagnostics:UnsupportedBlock'))
            this.addCheck(this.ModelName,failureType,message('hdlcoder:engine:pathbalancingBlackBox',blkname,blkname));
        else
            this.addCheck(this.ModelName,failureType,message('hdlcoder:engine:pathbalancing1',msg,blkname),'block',blkname);
        end
    end
    hdlReportDelayBalancingInfo(gp.getTopPirCtx,needsMessage);
end


function failures=reportAllInfo(this,p,debugOn)
    failures=false;

    vN=p.Networks;
    for ii=1:length(vN)
        hN=vN(ii);
        sf=hN.getStreamingFactor;
        if sf>0
            if reportStreamingInfo(this,hN,debugOn)
                failures=true;
            end
        end
        sf=hN.getSharingFactor;
        if sf>0
            if reportSharingInfo(this,hN,debugOn)
                failures=true;
            end
        end
    end
end

function failures=reportStreamingInfo(this,hN,debugOn)%#ok<INUSL>

    failures=false;
    nwpath=hN.fullPath;
    hdldisp(['Streaming Report for ',nwpath],1,debugOn);
    if hN.streamingSuccess()
        hdldisp('Streaming successful',1,debugOn);
    else
        msg=hN.streamingStatusMsg;
        id=hN.streamingStatusId;
        hC=hN.getStreamingCulprit;
        failures=true;
        if debugOn
            message('hdlcoder:engine:streaming',msg,id)

            if~isempty(hC)
                hdldisp(['Offending Block: ',hC]);
            end
        end
    end
    sHint=hN.getStreamingHint;

    if sHint>0
        allFactors=sprintf('%d ',unique(factor(sHint)));
        hdldisp(['Legal streaming factor values: ',allFactors],1,debugOn);
    else
        hdldisp('No legal streaming factor values available for this subsystem',1,debugOn);
    end
end

function failures=reportSharingInfo(this,hN,debugOn)
    failures=false;
    nwpath=hN.fullPath;
    hdldisp(['Sharing Report for ',nwpath],1,debugOn);
    if hN.sharingSuccess()
        hdldisp('Sharing successful',1,debugOn);
    else
        msg=hN.sharingStatusMsg;
        id=hN.sharingStatusId;
        hC=hN.getSharingCulprit;
        failures=true;
        if debugOn
            this.addCheck(this.ModelName,'Warning',message('hdlcoder:engine:reportSharingInfo',msg,id));

            if~isempty(hC)
                hdldisp(['Offending Block: ',hC]);
            end
        end
    end
    sHint=hN.getSharingHint;

    if sHint>1
        hdldisp(['Potential sharing factor values are in the range [2..',num2str(sHint),']'],1,debugOn);
    else
        hdldisp('No legal sharing factor values available for this subsystem',1,debugOn);
    end
end


