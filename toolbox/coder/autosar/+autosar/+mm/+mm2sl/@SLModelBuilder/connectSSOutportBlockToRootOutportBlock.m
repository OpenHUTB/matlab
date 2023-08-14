




function srcBlk=connectSSOutportBlockToRootOutportBlock(self,dstBlk,srcSS,enableEnsureOutputIsVirtual)



    currSS=get_param(get_param(dstBlk,'Parent'),'Handle');
    currSSPath=getfullname(currSS);
    srcSSFullPath=getfullname(srcSS);
    relPath=regexprep(srcSSFullPath,currSSPath,'','once');
    nextSSName=strtok(relPath,'/');


    dstBlkName=get_param(dstBlk,'Name');


    srcPort=getExpectedSubsystemSrcPortThroughVirtualBlock(currSSPath,nextSSName,srcSSFullPath,dstBlk);
    srcBlk=autosar.mm.mm2sl.SLModelBuilder.getBlockFromSSPort(srcPort);

    if~isempty(srcBlk)
        return
    end






    onCleanupObj=self.forceAutomatedBlkAdditions();%#ok<NASGU>
    srcBlk=self.createOrUpdateSimulinkBlock([currSSPath,'/',nextSSName],'Outport',[dstBlkName,'_write'],'',[],{});









    if enableEnsureOutputIsVirtual
        isConditionallyExecutedSS=~isempty(find_system(srcSSFullPath,...
        'SearchDepth',1,'BlockType','TriggerPort'));
        if isConditionallyExecutedSS
            set_param(srcBlk,'EnsureOutportIsVirtual','on');
        end
    end


    dataTypeStr=get_param(dstBlk,'OutDataTypeStr');
    isBusPort=strncmp(dataTypeStr,'Bus:',4);
    if isBusPort
        srcBlkH=get_param(srcBlk,'Handle');
        self.PostAddtermsResetOutDataTypeStrMap(srcBlkH)=get_param(srcBlk,'OutDataTypeStr');
        set_param(srcBlk,'OutDataTypeStr',dataTypeStr);
        set_param(srcBlk,'PortDimensions',get_param(dstBlk,'PortDimensions'));
    end


    dstPath=getfullname(dstBlk);
    variantPath=self.BlockVariantBuilder.getVariantBlock(dstPath);
    if~isempty(variantPath)



        dstBlk=getSimulinkBlockHandle(variantPath);
        dstBlkName=get_param(dstBlk,'Name');
    end



    dstPorts=get_param(dstBlk,'PortHandles');
    dstPort=dstPorts.Inport(1);
    dstLine=get_param(dstPort,'Line');
    if dstLine<0

        autosar.mm.mm2sl.layout.LayoutHelper.addLine(currSSPath,...
        [nextSSName,'/',get_param(srcBlk,'Port')],...
        [dstBlkName,'/1']);
    else


        srcPortLine=get_param(dstLine,'SrcPortHandle');
        srcPortBlock=get_param(srcPortLine,'Parent');
        if~strcmpi(get_param(srcPortBlock,'BlockType'),'Merge')
            delete_line(dstLine);
            mergeBlk=add_block('built-in/Merge',...
            [currSSPath,'/',dstBlkName,'_merge'],...
            'MakeNameUnique','on');
            self.positionBlockInLayout(mergeBlk);
            dstBlkPos=get_param(dstBlk,'Position');
            mergeBlkPos=get_param(mergeBlk,'Position');
            dx=mergeBlkPos(3)-mergeBlkPos(1);
            dy=mergeBlkPos(4)-mergeBlkPos(2);
            mergeBlkPos=[dstBlkPos(1)-dx-20,dstBlkPos(2)-fix(dy/2),dstBlkPos(1)-20,dstBlkPos(2)-fix(dy/2)+dy];
            set_param(mergeBlk,...
            'Position',mergeBlkPos,...
            'ShowName','off');
            mergeBlkName=get_param(mergeBlk,'Name');
            mergeBlkPorts=get_param(mergeBlk,'PortHandles');



            autosar.mm.mm2sl.layout.LayoutHelper.addLine(currSSPath,...
            [get_param(srcPortBlock,'Name'),'/',num2str(get_param(srcPortLine,'PortNumber'))],...
            [mergeBlkName,'/',num2str(get_param(mergeBlkPorts.Inport(1),'PortNumber'))]);



            autosar.mm.mm2sl.layout.LayoutHelper.addLine(currSSPath,...
            [nextSSName,'/',get_param(srcBlk,'Port')],...
            [mergeBlkName,'/2']);


            autosar.mm.mm2sl.layout.LayoutHelper.addLine(currSSPath,...
            [mergeBlkName,'/1'],...
            [dstBlkName,'/1']);
        else

            set_param(srcPortBlock,'Inputs',[get_param(srcPortBlock,'Inputs'),'+ 1']);
            srcPortBlockPorts=get_param(srcPortBlock,'PortHandles');




            autosar.mm.mm2sl.layout.LayoutHelper.addLine(currSSPath,...
            [nextSSName,'/',get_param(srcBlk,'Port')],...
            [get_param(srcPortBlock,'Name'),'/',sprintf('%d',numel(srcPortBlockPorts.Inport))]);

        end
    end



    function srcPort=getExpectedSubsystemSrcPortThroughVirtualBlock(currSSPath,nextSSName,srcSSFullPath,cBlk,inportNum)
        if nargin<5
            inportNum=1;
        end

        srcPort=[];

        cBlkType=get_param(cBlk,'BlockType');
        if~strcmpi(cBlkType,'Outport')&&...
            ~strcmpi(cBlkType,'Merge')&&...
            strcmp(get_param(cBlk,'Virtual'),'off')

            return
        end

        cLine=get_param(cBlk,'LineHandles');
        if iscell(cLine)
            cLine=cLine{1};
        end

        if cLine.Inport(inportNum)>0
            sPort=get_param(cLine.Inport(inportNum),'SrcPortHandle');
            if~isempty(sPort)&&sPort>0
                pBlock=get_param(sPort,'Parent');
                pBlockType=get_param(pBlock,'BlockType');

                if strcmpi(pBlockType,'From')

                    blkObj=get_param(pBlock,'Object');
                    gBlk=blkObj.GotoBlock.handle;
                    srcPort=getExpectedSubsystemSrcPortThroughVirtualBlock(...
                    currSSPath,nextSSName,srcSSFullPath,gBlk);
                    if~isempty(srcPort)
                        return
                    end
                elseif strcmpi(pBlockType,'Merge')

                    ports=get_param(pBlock,'PortHandles');
                    for jj=1:numel(ports.Inport)


                        srcPort=getExpectedSubsystemSrcPortThroughVirtualBlock(...
                        currSSPath,nextSSName,srcSSFullPath,pBlock,jj);
                        if~isempty(srcPort)
                            return
                        end
                    end

                elseif strcmpi(pBlockType,'SubSystem')

                    if strcmp(get_param(pBlock,'Name'),nextSSName)||...
                        strcmp(getfullname(pBlock),srcSSFullPath)
                        srcPort=sPort;
                        return
                    else
                        outPortIdx=num2str(get_param(sPort,'PortNumber'));
                        outPort=find_system(pBlock,'SearchDepth',1,...
                        'FollowLinks','on','LookUnderMasks','all','Type','Block',...
                        'BlockType','Outport','Port',outPortIdx);
                        srcPort=getExpectedSubsystemSrcPortThroughVirtualBlock(...
                        currSSPath,nextSSName,srcSSFullPath,outPort);
                        return
                    end
                elseif strcmpi(pBlockType,'Inport')&&...
                    strcmp(get_param(pBlock,'Virtual'),'on')


                    parentSubsys=get_param(pBlock,'Parent');
                    portNum=str2double(get_param(pBlock,'Port'));
                    srcPort=getExpectedSubsystemSrcPortThroughVirtualBlock(...
                    currSSPath,nextSSName,srcSSFullPath,parentSubsys,portNum);
                    if~isempty(srcPort)
                        return
                    end
                elseif strcmp(get_param(pBlock,'Virtual'),'on')





                    ports=get_param(pBlock,'PortHandles');
                    for jj=1:numel(ports.Inport)


                        srcPort=getExpectedSubsystemSrcPortThroughVirtualBlock(...
                        currSSPath,nextSSName,srcSSFullPath,pBlock,jj);
                        if~isempty(srcPort)
                            return
                        end
                    end
                else


                    return
                end
            end
        end


