function initModel(this)



    try
        prevEVCGFeature=slfeature('EVCGEnableSimThruCGXENPSS',0);
        oc=onCleanup(@()slfeature('EVCGEnableSimThruCGXENPSS',prevEVCGFeature));

        if~this.isModelCompiled
            hdldisp(message('hdlcoder:hdldisp:BeginModelComp',this.ModelName));
            if~this.selfCompiled

                this.selfCompiled=true;
                this.prepareModelForInit;
            end



            if strcmp(this.initMode,'HDL')
                set_param(this.ModelName,'HDLCodeGenStatus','Running');

                setInferenceReportCacheFlag(this.System);
            end
            this.Model.init(this.initMode);
        end
        hdlresetgcb(this.System);


        [~,this.SubsystemName]=getmodelnodename(this.ModelName,this.System,~this.CalledForGeneratedModel);
        if isempty(this.SubsystemName)
            this.SubsystemName=this.ModelName;
        end

    catch E
        hdldisp(message('hdlcoder:hdldisp:FailureToInit',this.ModelName));
        this.termModel;
        msgId=E.identifier;
        if strcmpi(msgId,'MATLAB:MException:MultipleErrors')&&...
            strcmpi(E.cause{end}.identifier,'Simulink:Engine:EI_CannotCompleteEI')
            if strcmpi(E.cause{1}.identifier,'Simulink:Engine:NoBlocksInModel')
                errMsg=message('hdlcoder:engine:emptyDUT',this.System);
            elseif hdlgetparameter('debug')


                errMsg=message('hdlcoder:engine:cannotconnecttomodeldbg',...
                this.Model.Name,E.message);



                feval(this.Model.Name,[],[],[],'compile');
            else

                errMsg=message('hdlcoder:engine:cannotconnecttomodel',this.Model.Name);
            end
            new_ex=MException(errMsg.Identifier,errMsg.getString);
            new_ex=new_ex.addCause(E.cause{1});
            new_ex.throw;
        elseif strcmpi(msgId,'Simulink:Commands:ParamUnknown')
            hdlcc=gethdlcc(this.Model.Name);
            if isempty(hdlcc)
                errMsg=message('hdlcoder:engine:nohdlcc',this.Model.Name);
            else
                if hdlgetparameter('debug')
                    errMsg=message('hdlcoder:engine:cannotconnecttomodeldbg',...
                    this.Model.Name,E.message);



                    feval(this.Model.Name,[],[],[],'compile');
                else

                    errMsg=message('hdlcoder:engine:cannotconnecttomodel',this.Model.Name);
                end
            end
            new_ex=MException(errMsg.Identifier,errMsg.getString);
            new_ex.throw;
        else
            rethrow(E)
        end
    end
end

function setInferenceReportCacheFlag(systemName)



    hdldriver=hdlcurrentdriver;
    if~isa(hdldriver,'slhdlcoder.HDLCoder')

        return;
    end
    val=hdldriver.getParameter('cache_mlfb_inference_reports');



    if~val
        switch hdldriver.getParameter('using_ml2pir')
        case 0

            val=false;
        case 1

            fpConfig=hdldriver.getParameter('floatingPointTargetConfiguration');
            if~isempty(fpConfig)&&strcmp(fpConfig.Library,'NativeFloatingPoint')


                val=true;
            else

                mlfbPaths=find_system(systemName,'FollowLinks','On',...
                'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
                'LookUnderMasks','All','SFBlockType','MATLAB Function');
                if~isempty(mlfbPaths)
                    for mlfb=mlfbPaths
                        hdlData=get_param(mlfb{1},'HDLData');
                        if~isempty(hdlData)&&strcmp(hdlData.archSelection,'MATLAB Datapath')


                            val=true;
                            break;
                        end
                    end
                end
            end
        case 2

            val=true;
        end

        hdldriver.setParameter('cache_mlfb_inference_reports',val);
    end
end



