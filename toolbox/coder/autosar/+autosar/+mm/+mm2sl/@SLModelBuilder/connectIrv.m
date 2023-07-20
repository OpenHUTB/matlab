




function connectIrv(self,m3iIrvData,srcSS,dstSS)

    assert(~isempty(m3iIrvData.Name),'An Irv must be named.');

    [srcPort,dstPort,~]=self.getOrCreateIrvPorts(m3iIrvData,srcSS,dstSS);

    if isempty(srcSS)||isempty(dstSS)
        return
    end


    srcSSPath=getfullname(srcSS);

    slDesc=autosar.mm.util.DescriptionHelper.getSLDescFromM3IDesc(m3iIrvData.desc);


    initValue=[];
    if strcmp(self.ModelPeriodicRunnablesAs,'AtomicSubsystem')
        initValue=i_getRateTransitionBlockInitValue(self.SLConstantBuilder,m3iIrvData);
    end

    connectSrcPortToDstPort(...
    self,...
    m3iIrvData.Name,...
    slDesc,...
    get_param(srcSSPath,'Parent'),...
    srcPort,...
    dstPort,...
    initValue);

    if isFeedbackLoop(self,dstSS,m3iIrvData)

        dstInportBlk=self.getBlockFromSSPort(dstPort);
        set_param(dstInportBlk,'LatchInputForFeedbackSignals','on');
    end


    function isFeedbackLoop=isFeedbackLoop(self,dstSS,m3iIrvData)

        feedbackPort=getFeedbackPort(self,m3iIrvData,dstSS);
        isFeedbackLoop=~isempty(feedbackPort);

        function srcPort=getFeedbackPort(self,m3iIrvData,dstSS)

            onlyGet=true;
            [srcPort,~]=self.getOrCreateIrvPorts(m3iIrvData,dstSS,[],onlyGet);


            function connectSrcPortToDstPort(self,irvName,slDesc,workingSS,srcPort,...
                dstPort,initValue)





                srcBlk=get_param(srcPort,'Parent');
                srcBlkType=get_param(srcBlk,'BlockType');
                isSrcBlkTypeValid=any(strcmp(srcBlkType,{'SubSystem','Merge'}));
                assert(isSrcBlkTypeValid,'Did not recognize BlockType %s',srcBlkType);


                dstBlk=get_param(dstPort,'Parent');
                dstBlkType=get_param(dstBlk,'BlockType');
                isDstBlkTypeValid=any(strcmp(dstBlkType,{'SubSystem','Merge'}));
                assert(isDstBlkTypeValid,'Did not recognize BlockType %s',dstBlkType);


                dstLine=get_param(dstPort,'Line');


                if(dstLine~=-1)
                    if(get_param(dstLine,'SrcPortHandle')==-1)
                        delete_line(dstLine);
                        dstLine=get_param(dstPort,'Line');
                    end
                end



                if dstLine<0
                    srcLine=get_param(srcPort,'Line');


                    if(srcLine~=-1)
                        if(get_param(srcLine,'DstPortHandle')==-1)
                            delete_line(srcLine);
                            srcLine=get_param(srcPort,'Line');
                        end
                    end

                    if(srcLine~=-1)
                        dstPortOfSrcLine=get_param(srcLine,'DstPortHandle');
                        if numel(dstPortOfSrcLine)==1

                            dstPortOfSrcLine=get_param(srcLine,'DstPortHandle');
                            dstBlkOfSrcLine=get_param(dstPortOfSrcLine,'Parent');
                            dstBlkTypeOfSrcLine=get_param(dstBlkOfSrcLine,'BlockType');

                            switch dstBlkTypeOfSrcLine
                            case{'Merge','VariantSource','VariantSink'}

                                srcBlk=dstBlkOfSrcLine;
                                blockPorts=get_param(srcBlk,'PortHandles');
                                srcPort=blockPorts.Outport(1);
                            case{'SubSystem','Goto','Terminator'}

                            otherwise
                                assert(false,'Did not recognize block type: %s',dstBlkTypeOfSrcLine);
                            end
                        end
                    end


                    modelIRVConnectionBetweenRunnables(...
                    self,...
                    workingSS,...
                    srcBlk,dstBlk,...
                    srcPort,dstPort,...
                    irvName,...
                    slDesc,...
                    initValue);
                else





                    srcPortOfDstLine=get_param(dstLine,'SrcPortHandle');
                    srcBlkOfDstLine=get_param(srcPortOfDstLine,'Parent');
                    srcBlkTypeOfDstLine=get_param(srcBlkOfDstLine,'BlockType');


                    if any(strcmpi(srcBlkTypeOfDstLine,{'From','VariantSource','VariantSink'}))

                        if strcmpi(srcBlkTypeOfDstLine,'From')
                            traveresedSrcPort=i_traverseToSrcPort(dstPort);
                        else
                            variantPorts=get_param(srcBlkOfDstLine,'PortHandles');

                            traveresedSrcPort=i_traverseToSrcPort(variantPorts.Inport);
                        end
                        if(srcPort==traveresedSrcPort)

                            return;
                        end



                        if strcmp(get_param(get_param(traveresedSrcPort,'Parent'),'BlockType'),'Merge')
                            srcBlkOfDstLine=get_param(traveresedSrcPort,'Parent');
                            srcBlkTypeOfDstLine=get_param(srcBlkOfDstLine,'BlockType');
                        end
                    end

                    if strcmpi(srcBlkTypeOfDstLine,'Merge')




                        mergeBlkPortHandles=get_param(srcBlkOfDstLine,'PortHandles');
                        mergeBlkInports=mergeBlkPortHandles.Inport;
                        for pIdx=1:length(mergeBlkInports)

                            traveresedSrcPort=i_traverseToSrcPort(mergeBlkInports(pIdx));
                            if(srcPort==traveresedSrcPort)

                                return;
                            end
                        end


                        set_param(srcBlkOfDstLine,'Inputs',num2str(str2double(get_param(srcBlkOfDstLine,'Inputs'))+1));
                        mergeBlockPorts=get_param(srcBlkOfDstLine,'PortHandles');


                        newLine2SrcPort=[get_param(srcBlk,'Name'),'/',sprintf('%d',get_param(srcPort,'PortNumber'))];
                        newLine2DstPort=[get_param(srcBlkOfDstLine,'Name'),'/',sprintf('%d',numel(mergeBlockPorts.Inport))];
                        cLine=autosar.mm.mm2sl.layout.LayoutHelper.addLine(getfullname(workingSS),...
                        newLine2SrcPort,newLine2DstPort);
                        set_param(cLine,'Name',irvName);


                        sigLine=autosar.composition.mm2sl.SLSignalLine(workingSS,newLine2SrcPort,newLine2DstPort);
                        self.ChangeLogger.logAddition('Automatic',...
                        message('RTW:autosar:updateReportSignalLineLabel').getString(),...
                        autosar.updater.Report.getMATLABHyperlink(...
                        sigLine.getHiliteLineCommand(),...
                        sigLine.getLineLabel()));
                    else




                        if srcPortOfDstLine==srcPort

                            return
                        end

                        delete_line(dstLine);
                        dstBlkName=get_param(dstBlk,'Name');
                        mergeBlk=add_block('built-in/Merge',...
                        [workingSS,'/',dstBlkName,'_merge'],...
                        'MakeNameUnique','on');

                        self.ChangeLogger.logAddition('Automatic','Merge block',getfullname(mergeBlk));

                        dstPortPos=get_param(dstPort,'Position');
                        mergeBlkPos=get_param(mergeBlk,'Position');
                        dx=mergeBlkPos(3)-mergeBlkPos(1);
                        dy=mergeBlkPos(4)-mergeBlkPos(2);
                        mergeBlkPos=[dstPortPos(1)-dx-20,dstPortPos(2)-fix(dy/2),dstPortPos(1)-20,dstPortPos(2)-fix(dy/2)+dy];
                        set_param(mergeBlk,...
                        'Position',mergeBlkPos,...
                        'ShowName','off');
                        mergeBlkName=get_param(mergeBlk,'Name');



                        newLine1SrcPort=[get_param(srcBlkOfDstLine,'Name'),'/',sprintf('%d',get_param(srcPortOfDstLine,'PortNumber'))];
                        newLine1DstPort=[mergeBlkName,'/1'];
                        cLine=autosar.mm.mm2sl.layout.LayoutHelper.addLine(workingSS,...
                        newLine1SrcPort,newLine1DstPort);
                        set_param(cLine,'Name',irvName);


                        sigLine1=autosar.composition.mm2sl.SLSignalLine(workingSS,newLine1SrcPort,newLine1DstPort);
                        self.ChangeLogger.logAddition('Automatic',...
                        message('RTW:autosar:updateReportSignalLineLabel').getString(),...
                        autosar.updater.Report.getMATLABHyperlink(...
                        sigLine1.getHiliteLineCommand(),...
                        sigLine1.getLineLabel()));



                        newLine2SrcPort=[get_param(srcBlk,'Name'),'/',sprintf('%d',get_param(srcPort,'PortNumber'))];
                        newLine2DstPort=[mergeBlkName,'/2'];
                        cLine=autosar.mm.mm2sl.layout.LayoutHelper.addLine(workingSS,...
                        newLine2SrcPort,newLine2DstPort);
                        set_param(cLine,'Name',irvName);


                        sigLine2=autosar.composition.mm2sl.SLSignalLine(workingSS,newLine2SrcPort,newLine2DstPort);
                        self.ChangeLogger.logAddition('Automatic',...
                        message('RTW:autosar:updateReportSignalLineLabel').getString(),...
                        autosar.updater.Report.getMATLABHyperlink(...
                        sigLine2.getHiliteLineCommand(),...
                        sigLine2.getLineLabel()));


                        cLine=autosar.mm.mm2sl.layout.LayoutHelper.addLine(workingSS,...
                        [mergeBlkName,'/1'],...
                        [dstBlkName,'/',sprintf('%d',get_param(dstPort,'PortNumber'))]);
                        set_param(cLine,'Name',irvName);
                    end
                end





                function modelIRVConnectionBetweenRunnables(self,workingSS,srcBlk,dstBlk,srcPort,...
                    dstPort,irvName,slDesc,initValue)
                    if isequal(self.ModelPeriodicRunnablesAs,'FunctionCallSubsystem')
                        assert(isempty(initValue),'initValue for IRV line should be empty.');
                        newLineSrcPort=[get_param(srcBlk,'Name'),'/',sprintf('%d',get_param(srcPort,'PortNumber'))];
                        newLineDstPort=[get_param(dstBlk,'Name'),'/',sprintf('%d',get_param(dstPort,'PortNumber'))];
                        cLine=autosar.mm.mm2sl.layout.LayoutHelper.addLine(getfullname(workingSS),...
                        newLineSrcPort,newLineDstPort);
                        set_param(cLine,'Name',irvName);
                        if~isempty(slDesc)
                            set_param(cLine,'Description',slDesc);
                        end


                        sigLine=autosar.composition.mm2sl.SLSignalLine(workingSS,newLineSrcPort,newLineDstPort);
                        self.ChangeLogger.logAddition('Automatic',...
                        message('RTW:autosar:updateReportSignalLineLabel').getString(),...
                        autosar.updater.Report.getMATLABHyperlink(...
                        sigLine.getHiliteLineCommand(),...
                        sigLine.getLineLabel()));
                    else
                        gap=10;
                        blkWidth=50;
                        blkHeight=50;
                        srcPos=get_param(srcPort,'Position');
                        rateBlkPosition=[srcPos(1)+gap,srcPos(2)-blkHeight/2,srcPos(1)+gap+blkWidth,srcPos(2)+blkHeight/2];
                        rateBlk=add_block('built-in/RateTransition',...
                        [workingSS,'/',irvName],...
                        'Deterministic','off',...
                        'Integrity','on',...
                        'OutPortSampleTimeOpt','Inherit',...
                        'Position',rateBlkPosition,...
                        'Description',slDesc,...
                        'InitialCondition',initValue);
                        self.positionBlockInLayout(getfullname(rateBlk));


                        autosar.mm.mm2sl.layout.LayoutHelper.addLine(getfullname(workingSS),...
                        [get_param(srcBlk,'Name'),'/',sprintf('%d',get_param(srcPort,'PortNumber'))],...
                        [get_param(rateBlk,'Name'),'/1']);


                        newLineSrcPort=[get_param(rateBlk,'Name'),'/1'];
                        newLineDstPort=[get_param(dstBlk,'Name'),'/',sprintf('%d',get_param(dstPort,'PortNumber'))];
                        autosar.mm.mm2sl.layout.LayoutHelper.addLine(getfullname(workingSS),...
                        newLineSrcPort,newLineDstPort);


                        self.ChangeLogger.logAddition('Automatic','RateTransition block',getfullname(rateBlk));
                        sigLine=autosar.composition.mm2sl.SLSignalLine(workingSS,newLineSrcPort,newLineDstPort);
                        self.ChangeLogger.logAddition('Automatic',...
                        message('RTW:autosar:updateReportSignalLineLabel').getString(),...
                        autosar.updater.Report.getMATLABHyperlink(...
                        sigLine.getHiliteLineCommand(),...
                        sigLine.getLineLabel()));

                    end






                    function initValueStr=i_getRateTransitionBlockInitValue(slConstantBuilder,m3iIrvData)


                        initValueStr=slConstantBuilder.getBlockInitialValueStringForType(m3iIrvData.Type);





                        function srcPort=i_traverseToSrcPort(dstPort)
                            srcPort=-1;


                            dstLine=get_param(dstPort,'Line');
                            if dstLine==-1
                                return;
                            end


                            srcPortOfDstLine=get_param(dstLine,'SrcPortHandle');
                            srcBlkOfDstLine=get_param(srcPortOfDstLine,'Parent');
                            srcBlkTypeOfDstLine=get_param(srcBlkOfDstLine,'BlockType');


                            if strcmpi(srcBlkTypeOfDstLine,'From')

                                srcBlkObj=get_param(srcBlkOfDstLine,'Object');
                                gotoBlkH=srcBlkObj.GotoBlock.handle;
                                gotoBlkPortHandles=get_param(gotoBlkH,'PortHandles');
                                gotoDstPort=gotoBlkPortHandles.Inport;


                                srcPort=i_traverseToSrcPort(gotoDstPort);
                            else

                                srcPort=srcPortOfDstLine;
                            end


