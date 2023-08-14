function hs=nonTopDutDriver(this,hs)





    if(this.nonTopDut&&strcmp(hdlfeature('NonTopNoModelReference'),'off'))||this.isDutModelRef
        gp=pir;
        gp.startTimer('Convert DUT To Model Reference','Phase cmr');


        if this.isDutModelRef
            mdlName=this.OrigStartNodeName;
            if strcmp(get_param(mdlName,'ProtectedModel'),'on')
                error(message('hdlcoder:validate:ModelRefProtectedModelAtTopLevel'));
            end
        end

        if strcmp(get_param(this.ModelName,'InlineParams'),'off')
            inline_param_msg=message('hdlcoder:validate:optDefaultParamBehaviorName').getString();
            if this.isDutModelRef
                error(message('hdlcoder:validate:InlineParamsModelRefDUT',inline_param_msg,this.ModelName));
            else
                error(message('hdlcoder:validate:InlineParamsNonTopDUT',inline_param_msg,this.ModelName));
            end

        end



        this.createConnection(this.getStartNodeName);
        this.connectToModel;
        algebraicLoopCheckFailed=hdlshared.algebraicLoopCheck(this.ModelConnection)==0;
        if algebraicLoopCheckFailed
            error(message('hdlcoder:engine:algebraicLoop'));
        end
        infRatePortName=this.checkForInfRatePorts;

        if this.isDutModelRef
            blkH=get_param(this.OrigStartNodeName,'Handle');
            DutMdlName=get_param(blkH,'ModelName');
            dutConnection=slhdlcoder.SimulinkConnection(DutMdlName);
            dutConnection.initModel;




            phan=get_param(this.OrigStartNodeName,'PortHandles');
            if~isempty(phan.Inport)
                phanForRate=phan.Inport(1);
            else
                phanForRate=phan.Outport(1);
            end
            cst=get_param(phanForRate,'CompiledSampleTime');
            this.DutSTIRate=cst(1);
            try
                dutConnection.termModel;
            catch me



                if~strcmp(me.identifier,'Simulink:Engine:SimCantChangeBDPropDuringSim')
                    me.rethrow;
                end
            end
        end

        this.closeConnection;
        if~isempty(infRatePortName)
            warning(message('hdlcoder:engine:NonTopDUTInfRate',infRatePortName));
        end

        if strcmp(get_param(this.getStartNodeName,'Mask'),'on')
            if~isempty(get_param(this.getStartNodeName,'MaskTunableValues'))||...
                ~isempty(get_param(this.getStartNodeName,'MaskInitialization'))
                error(message('hdlcoder:validate:MaskOnNonTopLevel'));
            end
        end
        if~isempty(find_system(this.getStartNodeName,'SearchDepth',1,'BlockType','TriggerPort'))
            error(message('hdlcoder:validate:topDUT'));
        end
        if~isempty(find_system(this.getStartNodeName,'SearchDepth',1,'BlockType','EnablePort'))
            error(message('hdlcoder:validate:topDUT'));
        end
        if~isempty(find_system(this.getStartNodeName,'SearchDepth',1,'BlockType','ResetPort'))
            error(message('hdlcoder:validate:topDUT'));
        end
        if~isempty(find_system(this.getStartNodeName,'SearchDepth',1,'BlockType','Inport','IsComposite','on'))
            error(message('hdlcoder:validate:nontopDUTwithbuselementports'));
        end
        if~isempty(find_system(this.getStartNodeName,'SearchDepth',1,'BlockType','Outport','IsComposite','on'))
            error(message('hdlcoder:validate:nontopDUTwithbuselementports'));
        end


        oldMode=hs.oldMode;
        hs=this.convertDutToModelRef;
        hs.oldMode=oldMode;
        gp.stopTimer;
    else
        this.DUTMdlRefHandle=0;
    end
end


