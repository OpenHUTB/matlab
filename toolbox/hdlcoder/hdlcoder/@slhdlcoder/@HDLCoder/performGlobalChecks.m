function checks=performGlobalChecks(this)







    checks=this.performGlobalFloatChecks;




    globalChecks=performGlobalOptimizationChecks(this);
    checks=cat(2,checks,globalChecks);




    globalChecks=checkConfigSettings(this);
    checks=cat(2,checks,globalChecks);




    fpChecks=this.performFloatingPointTargetChecks;
    checks=cat(2,checks,fpChecks);




    dspbaGlobalChecks=this.performDSPBAGlobalChecks;
    checks=cat(2,checks,dspbaGlobalChecks);




    xsgGlobalChecks=this.performXSGGlobalChecks;
    checks=cat(2,checks,xsgGlobalChecks);




    filChecks=this.checkFILSettings;
    checks=cat(2,checks,filChecks);
end


function checks=performGlobalOptimizationChecks(this)
    checks=[];
    gp=pir;

    num=gp.NumValidateMessages;
    for i=1:num
        slbh=gp.getValidateSource(i-1);
        msg=message(gp.getValidateMessage(i-1));
        checks(end+1).level='Error';%#ok<AGROW>
        checks(end).path=getfullname(slbh);
        checks(end).type='model';
        checks(end).message=msg.getString;
        checks(end).MessageID=msg.Identifier;
    end


    portInfo=streamingmatrix.getStreamedPorts(gp.getTopNetwork);
    hasStreamedPorts=~isempty(portInfo.streamedInPorts);
    globalParamVal=hdlgetparameter('FrameToSampleConversion');

    if globalParamVal&&~hasStreamedPorts

        msg=message('hdlcommon:streamingmatrix:GlobalPortMismatch_NoPort');

        checks(end+1).level='Warning';
        checks(end).path=this.getStartNodeName;
        checks(end).type='model';
        checks(end).message=msg.getString;
        checks(end).MessageID=msg.Identifier;
    elseif~globalParamVal&&hasStreamedPorts

        for i=1:numel(portInfo.streamedInPorts)
            pt=portInfo.streamedInPorts(i).data;
            blkName=[this.getStartNodeName,'/',pt.Name];

            msg=message('hdlcommon:streamingmatrix:GlobalPortMismatch_NoGlobal',blkName);

            checks(end+1).level='Warning';%#ok<AGROW> 
            checks(end).path=blkName;
            checks(end).type='model';
            checks(end).message=msg.getString;
            checks(end).MessageID=msg.Identifier;
        end
    elseif hasStreamedPorts&&numel(gp.getCtxNames)>1


        msg=message('hdlcommon:streamingmatrix:FrameToSampleModelRefUnsupported');

        checks(end+1).level='Error';
        checks(end).path=this.getStartNodeName;
        checks(end).type='model';
        checks(end).message=msg.getString;
        checks(end).MessageID=msg.Identifier;
    end

end


