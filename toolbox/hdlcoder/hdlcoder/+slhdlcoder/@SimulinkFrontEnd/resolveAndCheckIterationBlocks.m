function newblocklist=resolveAndCheckIterationBlocks(this,blocklist,hN)





    newblocklist=zeros(1,numel(blocklist),'like',blocklist);
    newCount=1;

    for ii=1:numel(blocklist)
        slbh=blocklist(ii);
        blkName=getfullname(slbh);

        blk=get_param(slbh,'Object');
        typ=get_param(slbh,'BlockType');

        if(blk.isSynthesized&&strcmp(blk.getSyntReason,'SL_SYNT_BLK_REASON_ALGLOOP'))


            [newblocklist,newCount]=expandSynthesizedAtomicSubsystem(slbh,newblocklist,newCount);
        elseif blk.isSynthesized&&strcmp(blk.getSyntReason,'SL_SYNT_BLK_REASON_FOREACH_CORE_SUBSYS')
            innerblocklist=getCompiledBlockList(get_param(slbh,'ObjectAPI_FP'));
            for jj=1:numel(innerblocklist)


                algBlk=get_param(innerblocklist(jj),'Object');
                if(algBlk.isSynthesized&&strcmp(algBlk.getSyntReason,'SL_SYNT_BLK_REASON_ALGLOOP'))
                    [newblocklist,newCount]=expandSynthesizedAtomicSubsystem(innerblocklist(jj),newblocklist,newCount);
                else
                    newblocklist(newCount)=innerblocklist(jj);
                    newCount=newCount+1;
                end
            end

        elseif strcmp(typ,'ForEach')



            if strcmp(get_param(slbh,'ShowIterationIndex'),'on')


                error(message('hdlcoder:validate:ForEachPartitionIndex',blkName));
            end

            if~strcmp(get_param(slbh,'SpecifiedNumIters'),'-1')
                msgobj=message('hdlcoder:validate:ForEachSpecifiedNumIters',blkName);
                this.updateChecks(blkName,'block',msgobj,'Error');
            end



            fedt=hN.getForEachNetworkDataTag;

            partitionWidth=get_param(slbh,'InputPartitionWidth');
            partitionOffset=get_param(slbh,'InputPartitionOffset');
            partitionDimension=get_param(slbh,'InputPartitionDimension');
            concatDimension=get_param(slbh,'OutputConcatenationDimension');
            MaskPartitionDimension=get_param(slbh,'SubsysMaskParameterPartitionDimension');
            MaskPartitionWidth=get_param(slbh,'SubsysMaskParameterPartitionWidth');


            for jj=1:length(blk.InputPartition)
                if strcmp(blk.InputPartition(jj),'on')
                    width=slResolve(partitionWidth{jj},slbh);
                    offset=slResolve(partitionOffset{jj},slbh);
                    dimension=slResolve(partitionDimension{jj},slbh);



                    fedt.addSignalPartitionData(jj-1,width,offset,dimension);
                end
            end


            for jj=1:length(blk.OutputConcatenationDimension)
                fedt.addSignalConcatData(jj-1,concatDimension{jj});
            end


            for jj=1:length(blk.SubsysMaskParameterPartition)
                if strcmp(blk.SubsysMaskParameterPartition(jj),'on')
                    width=slResolve(MaskPartitionWidth{jj},slbh);
                    dimension=slResolve(MaskPartitionDimension{jj},slbh);

                    if~(dimension==1||dimension==2)
                        msgobj=message('hdlcoder:validate:ForEachMaskUnsupPartDim',blkName);
                        this.updateChecks(blkName,'block',msgobj,'Error');
                    end

                    blkParent=getSimulinkBlockHandle(blk.Parent);
                    maskValuesUnresolved=get_param(blkParent,'MaskValues');
                    maskNames=get_param(blkParent,'MaskNames');
                    maskValues=slResolve(maskValuesUnresolved{jj},...
                    getSimulinkBlockHandle(blk.Parent));
                    maskValuesFi=pirelab.convertInt2fi(maskValues);

                    if isfi(maskValuesFi)
                        maskValuesInt=maskValuesFi.int;

                        fedt.addMaskPartitionData(maskNames{jj},...
                        width,dimension,maskValuesInt);
                    end

                end
            end

        elseif strcmp(typ,'ForIterator')&&strcmp(hdlfeature('EnableForIterator'),'on')



            if~strcmp(get_param(slbh,'IterationSource'),'internal')
                msgobj=message('hdlcoder:validate:ForIterIterationSource',blkName);
                this.updateChecks(blkName,'block',msgobj,'Error');
            end




            if~strcmp(get_param(slbh,'ExternalIncrement'),'off')
                msgobj=message('hdlcoder:validate:ForIterExternalIncrement',blkName);
                this.updateChecks(blkName,'block',msgobj,'Error');
            end




            if~strcmp(get_param(slbh,'ResetStates'),'held')
                msgobj=message('hdlcoder:validate:ForIterResetStates',blkName);
                this.updateChecks(blkName,'block',msgobj,'Error');
            end




            forIterSys=get_param(slbh,'Parent');
            portHandles=get_param(forIterSys,'PortHandles');
            if numel(portHandles.Inport)+numel(portHandles.Outport)==0
                forIterSysName=getfullname(forIterSys);
                msgobj=message('hdlcoder:validate:ForIterNoIO',forIterSysName);
                this.updateChecks(forIterSysName,'block',msgobj,'Error');
            end



            fidt=hN.getForIterDataTag;



            fidt.setIsFromML2PIR(false);
            fidt.setLocation(strrep(getfullname(forIterSys),newline,' '));

            fidt.setResetStates(false);

            iterations=slResolve(get_param(slbh,'IterationLimit'),slbh);
            fidt.setIterations(iterations);




            keepBlock=strcmp(get_param(slbh,'ShowIterationPort'),'on');

            if keepBlock
                newblocklist(newCount)=slbh;
                newCount=newCount+1;
            end
        elseif strcmp(typ,'Neighborhood')&&this.HDLCoder.getParameter('FrameToSampleConversion')




            npudt=hN.getNPUDataTag;

            neighborhoodDimsStr=get_param(slbh,'NeighborhoodDimension');
            neighborhoodDims=slResolve(neighborhoodDimsStr,slbh);

            npudt.setKernelRows(neighborhoodDims(1));
            npudt.setKernelCols(neighborhoodDims(2));

            npuSysName=getfullname(slbh);
            if~ismember(this.HDLCoder.getParameter('SamplesPerCycle'),[1,2,4,8])
                msgobj=message('hdlcoder:validate:NPUSamplesPerCyclePowerOfTwo',npuSysName);
                this.updateChecks(npuSysName,'block',msgobj,'Error');
            end

            bm=get_param(slbh,'PaddingMethod');
            if~strcmpi(bm,'Constant')
                msgobj=message('hdlcoder:validate:NPUUnsupportedBM',npuSysName,bm);
                this.updateChecks(npuSysName,'block',msgobj,'Error');
            end

            npudt.setBoundaryMethod(bm);

            boundaryConstantValue=slResolve(get_param(slbh,'PaddingValue'),slbh);
            npudt.setBoundaryConstantValue(boundaryConstantValue);

            allPortInfos=jsondecode(get_param(slbh,'InportNeighborhood'));
            for i=1:numel(allPortInfos)
                portInfo=allPortInfos(i);
                if strcmp(portInfo.InputPartition,'on')
                    npudt.setStreamedInput(portInfo.PortIdx);
                end
            end



            [parentNetworkPath,~,~]=fileparts(hN.Fullpath);
            parentSlbh=get_param(parentNetworkPath,'Handle');
            parentBlocklist=getCompiledBlockList(get_param(parentSlbh,'ObjectAPI_FP'));

            parentBlockTyp=get_param(parentBlocklist,'BlockType');
            parentPorts=parentBlocklist(strcmp(parentBlockTyp,'Inport'));
            allPortRates=arrayfun(@this.getSigRate,parentPorts);
            if~allfinite(allPortRates)
                msgobj=message('hdlcoder:validate:NPUInfRateError',parentNetworkPath);
                this.updateChecks(parentNetworkPath,'block',msgobj,'Error');
            elseif~all(allPortRates==allPortRates(1))
                msgobj=message('hdlcoder:validate:NPUInRateError',parentNetworkPath);
                this.updateChecks(parentNetworkPath,'block',msgobj,'Error');
            end

        elseif strcmp(typ,'EVCGImplicitAssignment')||strcmp(typ,'EVCGImplicitSelector')



        else
            newblocklist(newCount)=slbh;
            newCount=newCount+1;
        end
    end


    newblocklist(newCount:end)=[];

end


function[newblocklist,newCount]=expandSynthesizedAtomicSubsystem(slbh,newblocklist,newCount)
    algloopblocklist=getCompiledBlockList(get_param(slbh,'ObjectAPI_FP'));
    for kk=1:numel(algloopblocklist)
        newblocklist(newCount)=algloopblocklist(kk);
        newCount=newCount+1;
    end
end

