function anyInportOfAnyCUTHasConstSampleTime=setInputTempLoggingNames(obj,sigObjs,portType)

































    anyInportOfAnyCUTHasConstSampleTime=false;
    subs=obj.subs;
    for j=1:obj.numOfComps
        try
            if obj.proceedToNextStep(j)
                blockType='';
                if Simulink.SubsystemType.isBlockDiagram(subs{j}.handle)
                    if strcmp(portType,'From')||strcmp(portType,'EnablePort')||strcmp(portType,'TriggerPort')||strcmp(portType,'ResetPort')


                        continue;
                    end
                    assert(strcmp(portType,'Inport'),"Port type other than Inport.");

                    portBlockHandles=get_param(find_system(subs{j}.handle,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','BlockType',portType,'OutputFunctionCall','off'),'Handle');
                else
                    blockType=get_param(subs{j}.handle,'BlockType');
                    if strcmp(portType,'From')


                        portBlockHandles=sigObjs{j}.fromBlks;
                        gotoBlkPortHdls=arrayfun(@(x)get_param(x,'porthandles'),sigObjs{j}.fromSrcBlks);
                        sigObjs{j}=arrayfun(@(x)x.Inport(1),gotoBlkPortHdls);
                        sigObjs{j}=arrayfun(@(s)stm.internal.TestForSubsystem.returnSourceBlockOutportHandle(s),sigObjs{j});
                    else
                        subsysHdl=subs{j}.handle;




                        if strcmp(blockType,'ModelReference')


                            mref=getRefMdlName(subsysHdl);
                            if~bdIsLoaded(mref)
                                load_system(mref);
                                oc=onCleanup(@()close_system(mref));
                            end
                            subsysHdl=get_param(mref,'Handle');
                        end






                        portBlockHandles=get_param(find_system(subsysHdl,'SearchDepth',1,'LookUnderMasks','all','FollowLinks','on','BlockType',portType),'Handle');
                    end
                end


                if~iscell(portBlockHandles)
                    portBlockHandles=num2cell(portBlockHandles);
                end


                if strcmp(portType,'Inport')&&~anyInportOfAnyCUTHasConstSampleTime
                    anyInportOfAnyCUTHasConstSampleTime=checkForConstantTimePorts(portBlockHandles,obj.topModel);
                end

                for i=1:length(sigObjs{j})

                    srcPortHandle=sigObjs{j}(i);
                    if srcPortHandle==-1
                        continue;
                    end




                    dataLoggingName=obj.setTempLoggingNames(srcPortHandle,i,['sltest_',portType],j);





                    if Simulink.SubsystemType.isBlockDiagram(subs{j}.handle)||strcmp(blockType,'SubSystem')||strcmp(blockType,'ModelReference')
                        inpBlkName=get_param(portBlockHandles{i},'Name');
                        inpBlkName=fixCtrlPortNameForMdlRefBlks(blockType,portType,subs{j}.handle,inpBlkName);
                    else

                        inpBlkName=[get_param(subs{j}.handle,'Name'),'_In',num2str(i)];
                    end


                    inpBlkName=regexprep(inpBlkName,'\n',' ');



                    obj.cacheBlkStructInMap(dataLoggingName,'inputs',portType,'',inpBlkName,'PortIndex',i,'ComponentIndex',j);

                end
            end
        catch me
            obj.populateErrorContainer(me,j);
        end
    end
end

function isConst=checkForConstantTimePorts(subsysPortHandles,topModel)
    cmplAttr=[];
    for i=1:length(subsysPortHandles)
        sampleTime=get_param(subsysPortHandles{i},'CompiledSampleTime');
        if iscell(sampleTime)


            sampleTime=cellfun(@(a)a(1),sampleTime);
        end
        if ismember(Inf,sampleTime)

            if isempty(cmplAttr)

                cmplAttr=feval(topModel,[],[],[],'compile');
                ocf=onCleanup(@()feval(topModel,[],[],[],'term'));
            end


            dataType=get_param(subsysPortHandles{i},'CompiledPortDataTypes');

            for opIdx=1:length(dataType.Outport)
                pObj=parseDataType(dataType.Outport{opIdx});


                isString=~isempty(Simulink.internal.getStringDTExprFromDTName(dataType.Outport{opIdx}));

                if pObj.isEnum||pObj.isFixed||isString
                    isConst=true;
                    return;
                end
            end
        end
    end
    isConst=false;
end

function mref=getRefMdlName(blkHndl)

    [~,mref,~]=fileparts(get_param(blkHndl,"ModelFile"));
end

function inpBlkName=fixCtrlPortNameForMdlRefBlks(blockType,portType,hndl,inpBlkName)












    if blockType=="ModelReference"&&(portType=="EnablePort"||portType=="TriggerPort")
        mref=getRefMdlName(hndl);
        if portType=="EnablePort"
            inpBlkName=[mref,'_enable'];
        else
            inpBlkName=[mref,'_trigger'];
        end
    end
end

