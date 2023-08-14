function[srcPort,dstPort,irvSLName]=getOrCreateIrvPorts(self,m3iIrvData,srcSS,dstSS,onlyGet)




    if nargin<5
        onlyGet=false;
    end

    srcPort=[];
    dstPort=[];
    irvSLName='';

    if~isempty(srcSS)||~isempty(dstSS)
        irvSLName=getSLNameForIRV(self,m3iIrvData);



        if~isempty(srcSS)
            if onlyGet
                srcPort=getSrcPort(self,m3iIrvData,irvSLName,srcSS);
            else
                srcPort=getOrCreateSrcPort(self,m3iIrvData,irvSLName,srcSS);
            end
        end

        if~isempty(dstSS)
            dstPort=getOrCreateDstPort(self,m3iIrvData,irvSLName,dstSS);
        end

    end


    function irvSLName=getSLNameForIRV(self,m3iIrvData)


        irvSLName=m3iIrvData.Name;



        if self.UpdateMode

            m3iIrvDataQName=m3iIrvData.qualifiedName;
            if self.IRVQNameToSLNameMap.isKey(m3iIrvDataQName)
                irvSLName=self.IRVQNameToSLNameMap(m3iIrvDataQName);
            else


                [isMapped,mappedTo]=self.isIRVMapped(m3iIrvData);
                if isMapped
                    self.IRVQNameToSLNameMap(m3iIrvDataQName)=mappedTo;
                    irvSLName=mappedTo;
                    assert(~isempty(irvSLName),'irvSLName should not be empty');
                end
            end
        end


        function srcPort=getOrCreateSrcPort(self,m3iIrvData,irvSLName,srcSS)


            srcPort=[];
            if~isempty(srcSS)

                blkName=[m3iIrvData.Name,'_write'];
                blkType='Outport';

                srcPort=getSrcPort(self,m3iIrvData,irvSLName,srcSS);
                if~isempty(srcPort)
                    blkName=get_param(self.getBlockFromSSPort(srcPort),'Name');
                end

                sBlk=self.createOrUpdateSimulinkPortWithType(...
                getfullname(srcSS),...
                m3iIrvData.Type,...
                blkType,blkName,[],m3iIrvData.desc);



                if isempty(sBlk)
                    return
                end

                srcPort=self.getSSPortFromBlock(sBlk);

            end


            function srcPort=getSrcPort(self,m3iIrvData,irvSLName,srcSS)


                srcPort=[];
                if~isempty(srcSS)

                    blkName=[m3iIrvData.Name,'_write'];
                    blkType='Outport';


                    srcPort=[];
                    if strcmp(self.ModelPeriodicRunnablesAs,'AtomicSubsystem')


                        if self.UpdateMode
                            assert(strcmp(get_param(irvSLName,'BlockType'),'RateTransition'),...
                            'expected %s to be a Rate Transition block',irvSLName);
                            rtbPorts=get_param(irvSLName,'PortHandles');
                            rtbSrcLine=get_param(rtbPorts.Inport,'Line');
                            if rtbSrcLine~=-1
                                srcPort=get_param(rtbSrcLine,'Srcporthandle');
                            end
                        end
                    else

                        srcPorts=get_param(srcSS,'PortHandles');
                        for jj=1:numel(srcPorts.Outport)
                            sLine=get_param(srcPorts.Outport(jj),'Line');

                            if i_dstLineHasSignalName(sLine,irvSLName)

                                srcPort=srcPorts.Outport(jj);
                                break
                            end
                        end
                    end

                    if isempty(srcPort)
                        srcPort=find_system(srcSS,'SearchDepth',1,'BlockType',blkType,'Name',blkName);
                        if~isempty(srcPort)
                            srcPort=self.getSSPortFromBlock(get_param(srcPort(1),'Handle'));
                        end
                    end

                end



                function dstPort=getOrCreateDstPort(self,m3iIrvData,irvSLName,dstSS)


                    dstPort=[];
                    if~isempty(dstSS)

                        blkName=[m3iIrvData.Name,'_read'];
                        blkType='Inport';
                        dstPort=[];
                        if strcmp(self.ModelPeriodicRunnablesAs,'AtomicSubsystem')


                            if self.UpdateMode
                                assert(strcmp(get_param(irvSLName,'BlockType'),'RateTransition'),...
                                'expected %s to be a Rate Transition block',irvSLName);
                                rtbPorts=get_param(irvSLName,'PortHandles');
                                rtbDstLine=get_param(rtbPorts.Outport,'Line');
                                if rtbDstLine~=-1
                                    dstPort=get_param(rtbDstLine,'Dstporthandle');
                                end
                            end
                        else

                            dstPorts=get_param(dstSS,'PortHandles');
                            for jj=1:numel(dstPorts.Inport)
                                dLine=get_param(dstPorts.Inport(jj),'Line');
                                if i_srcLineHasSignalName(dLine,irvSLName)

                                    dstPort=dstPorts.Inport(jj);
                                    break
                                end
                            end
                        end

                        if isempty(dstPort)
                            dstPort=find_system(dstSS,'SearchDepth',1,'BlockType',blkType,'Name',blkName);
                            if~isempty(dstPort)
                                dstPort=self.getSSPortFromBlock(get_param(dstPort(1),'Handle'));
                            end
                        else
                            blkName=get_param(self.getBlockFromSSPort(dstPort),'Name');
                        end


                        [dBlk,~]=self.createOrUpdateSimulinkBlock(...
                        getfullname(dstSS),...
                        blkType,blkName,[],[],{});

                        if isempty(dBlk)
                            return
                        end

                        dstPort=self.getSSPortFromBlock(dBlk);
                    end


                    function signalNameFound=i_srcLineHasSignalName(sLine,signalName)

                        signalNameFound=false;
                        if sLine<0
                            return
                        end

                        if strcmp(signalName,get_param(sLine,'Name'))
                            signalNameFound=true;
                            return
                        end

                        srcBlk=get_param(sLine,'SrcBlockHandle');
                        if srcBlk==-1
                            return
                        end

                        switch(get_param(srcBlk,'BlockType'))
                        case 'From'

                            blkObj=get_param(srcBlk,'Object');
                            blk=blkObj.GotoBlock.handle;
                            dstPorts=get_param(blk,'PortHandles');
                            for jj=1:numel(dstPorts.Inport)
                                sLine=get_param(dstPorts.Inport(jj),'Line');
                                if i_srcLineHasSignalName(sLine,signalName)
                                    signalNameFound=true;
                                    return
                                end
                            end
                        case{'VariantSource','VariantSink'}

                            variantPorts=get_param(srcBlk,'PortHandles');
                            for jj=1:numel(variantPorts.Inport)
                                sLine=get_param(variantPorts.Inport(jj),'Line');
                                if i_srcLineHasSignalName(sLine,signalName)
                                    signalNameFound=true;
                                    return
                                end
                            end
                        case 'SubSystem'
                            if strcmp(get_param(srcBlk,'IsSubsystemVirtual'),'on')
                                if isempty(get_param(sLine,'Name'))





                                    if signalLabelExistsInsideVSS(srcBlk,signalName)
                                        set_param(sLine,'Name',signalName);
                                        signalNameFound=true;
                                        return
                                    end
                                end
                            end
                        case 'Inport'
                            if isempty(get_param(sLine,'Name'))
                                parentName=get_param(srcBlk,'Parent');
                                parentBlk=getSimulinkBlockHandle(parentName);
                                if parentBlk>0
                                    if strcmp(get_param(parentBlk,'IsSubsystemVirtual'),'on')




                                        srcPortHdl=get(sLine,'SrcPortHandle');
                                        propagatedSrcSignal=get(srcPortHdl,'RefreshedPropSignals');
                                        if strcmp(signalName,propagatedSrcSignal)
                                            set_param(sLine,'Name',signalName);
                                            signalNameFound=true;
                                            return
                                        end
                                    end
                                end
                            end
                        otherwise

                            return
                        end

                        function signalNameFound=i_dstLineHasSignalName(dLine,signalName)

                            signalNameFound=false;
                            if dLine<0
                                return
                            end

                            if strcmp(signalName,get_param(dLine,'Name'))
                                signalNameFound=true;
                                return
                            end

                            dstBlk=get_param(dLine,'DstBlockHandle');
                            if dstBlk==-1
                                return
                            end

                            if strcmpi(get_param(dstBlk,'BlockType'),'Goto')

                                blkObj=get_param(dstBlk,'Object');
                                fromBlks={blkObj.FromBlocks.handle};
                                for fromIdx=1:numel(fromBlks)
                                    blk=fromBlks{fromIdx};
                                    srcPorts=get_param(blk,'PortHandles');
                                    for jj=1:numel(srcPorts.Outport)
                                        dLine=get_param(srcPorts.Outport(jj),'Line');
                                        if i_dstLineHasSignalName(dLine,signalName)
                                            signalNameFound=true;
                                            return
                                        end
                                    end
                                end
                            elseif strcmpi(get_param(dstBlk,'BlockType'),'SubSystem')
                                if strcmp(get_param(dstBlk,'IsSubsystemVirtual'),'on')
                                    if isempty(get_param(dLine,'Name'))





                                        if signalLabelExistsInsideVSS(dstBlk,signalName)
                                            set_param(dLine,'Name',signalName);
                                            signalNameFound=true;
                                            return
                                        end
                                    end
                                end
                            else

                                return
                            end

                            function signalNameFound=signalLabelExistsInsideVSS(blkH,signalName)


                                signalNameFound=false;
                                if strcmp(get_param(blkH,'IsSubsystemVirtual'),'on')
                                    signalsInVSS=get_param(blkH,'Lines');
                                    for jj=1:numel(signalsInVSS)
                                        signalNameInsideVSS=signalsInVSS(jj).Name;
                                        if strcmp(signalName,signalNameInsideVSS)
                                            signalNameFound=true;
                                        end
                                    end
                                end




