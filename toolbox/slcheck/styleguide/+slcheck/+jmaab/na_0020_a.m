classdef na_0020_a<slcheck.subcheck

    methods
        function obj=na_0020_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='na_0020_a';
        end

        function result=run(this)
            result=false;
            inputParams=this.getInputParamByName(DAStudio.message('ModelAdvisor:jmaab:na_0020_input'));
            inputParams=str2double(inputParams);
            failureFlag=[];
            currBlk=this.getEntity();
            curVSSBlk=get_param(currBlk,'Parent');
            curVSSBlk=get_param(curVSSBlk,'Handle');
            inpVSS=get_param(find_system(curVSSBlk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','on','BlockType','Inport'),'PortName');
            outVSS=find_system(curVSSBlk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','on','BlockType','Outport');
            outVSS_name=get_param(outVSS,'PortName');
            enablePort=0;
            triggerPort=0;
            currInp={};
            currOut={};
            currOut_name={};

            if strcmp(get_param(currBlk,'BlockType'),'ModelReference')
                if strcmp(get_param(currBlk,'protectedModel'),'on')

                    return
                end
                refMdl=get_param(currBlk,'ModelName');


                if 4==exist(refMdl)





                    if bdIsLoaded(refMdl)
                        currInp=get_param(find_system(refMdl,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','on','BlockType','Inport'),'PortName');
                        currOut=find_system(refMdl,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','on','BlockType','Outport');
                        currOut_name=get_param(currOut,'PortName');

                        blkPorts=get_param(currBlk,'Ports');
                        enablePort=blkPorts(3);
                        triggerPort=blkPorts(4);
                    else
                        load_system(refMdl);
                        currInp=get_param(find_system(refMdl,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','on','BlockType','Inport'),'PortName');
                        currOut=find_system(refMdl,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','on','BlockType','Outport');
                        currOut_name=get_param(currOut,'PortName');

                        blkPorts=get_param(currBlk,'Ports');
                        enablePort=blkPorts(3);
                        triggerPort=blkPorts(4);
                        close_system(refMdl);
                    end
                else

                end
            else
                currInp=get_param(find_system(currBlk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','on','BlockType','Inport'),'PortName');
                currOut=find_system(currBlk,'SearchDepth',1,'FollowLinks','on','LookUnderMasks','on','BlockType','Outport');
                currOut_name=get_param(currOut,'PortName');


                blkPorts=get_param(currBlk,'Ports');
                enablePort=blkPorts(3);
                triggerPort=blkPorts(4);

            end


            if~iscell(currInp)
                currInp={currInp};
            end
            if~iscell(inpVSS)
                inpVSS={inpVSS};
            end
            if~iscell(currOut_name)
                currOut_name={currOut_name};
            end
            if~iscell(outVSS_name)
                outVSS_name={outVSS_name};
            end




            currInp=unique(currInp);
            inpVSS=unique(inpVSS);

            currOut_name=unique(currOut_name);
            outVSS_name=unique(outVSS_name);


            lenInp=length(currInp)+enablePort+triggerPort;



            if any(~ismember(strtrim(currInp),strtrim(inpVSS)))||any(~ismember(strtrim(currOut_name),strtrim(outVSS_name)))


                vObj=ModelAdvisor.ResultDetail;
                vObj.Title=DAStudio.message('ModelAdvisor:jmaab:na_0020_Invalid_title');
                vObj.Status=DAStudio.message('ModelAdvisor:jmaab:na_0020_Invalid_warn');
                vObj.RecAction=DAStudio.message('ModelAdvisor:jmaab:na_0020_Invalid_rec_action');
                ModelAdvisor.ResultDetail.setData(vObj,'SID',currBlk);
                result=this.setResult(vObj);
                return
            end

            if~isequal(lenInp,length(inpVSS))
                failureFlag=currBlk;


            elseif~isequal(length(currOut_name),length(outVSS_name))
                if inputParams
                    missingPort=setdiff(outVSS_name,currOut_name);



                    specifyOutput=cellfun(@(x)get_param([get_param(curVSSBlk,'Parent'),'/',get_param(curVSSBlk,'Name'),'/',x],'OutputWhenUnConnected'),missingPort,'UniformOutput',false);
                    if any(ismember(specifyOutput,'off'))
                        failureFlag=currBlk;
                    end
                else
                    failureFlag=currBlk;
                end
            end
            if~isempty(failureFlag)
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'Custom',...
                DAStudio.message('ModelAdvisor:jmaab:na_0020_a_Col1'),...
                Simulink.ID.getSID(get_param(failureFlag,'Parent')),...
                DAStudio.message('ModelAdvisor:jmaab:na_0020_a_Col2'),...
                Simulink.ID.getSID(failureFlag));
                result=this.setResult(vObj);
            end
        end
    end
end