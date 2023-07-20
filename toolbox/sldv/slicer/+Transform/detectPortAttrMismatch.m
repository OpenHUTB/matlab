function deviation=detectPortAttrMismatch(slicedMdl,throwError,UImode,sliceXfrmr,origAttrMap)










    deviation=struct([]);

    useOrigCache=isa(origAttrMap,'containers.Map');

    attr={'CompiledBusType',...
    'CompiledPortComplexSignal',...
    'CompiledPortAliasedThruDataType',...
    'CompiledPortDesignMax',...
    'CompiledPortDesignMin',...
    'CompiledPortDimensions',...
    'CompiledPortFrameData',...
'CompiledPortWidth'...
    ,'CompiledPortDimensionsMode'};

    if~(strcmp(get_param(slicedMdl,'SolverType'),'Fixed-step')...
        &&strcmp(get_param(slicedMdl,'SampleTimeConstraint'),'STIndependent'))
        attr{end+1}='CompiledSampleTime';
    end


    slicerMap=sliceXfrmr.sliceMapper;


    handles=[];
    if slfeature('NewSlicerBackend')


        nonVirtualBlocks=find_system(slicedMdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','Virtual','off');
        for i=1:length(nonVirtualBlocks)
            if~strcmp(get_param(nonVirtualBlocks{i},'BlockType'),'SubSystem')
                portHandles=get_param(nonVirtualBlocks{i},'PortHandles');
                handles=[handles;portHandles.Outport'];
            end
        end
    else
        ir=Analysis.createIR(slicedMdl);
        handles=cell2mat(ir.dfgVarIdxToPortHandle.values)';
    end




    inportBH=find_system(slicedMdl,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FindAll','on','LookUnderMasks','all','BlockType','Inport');
    inportPortH=arrayfun(@(x)getInportHandle(x),inportBH);
    handles=unique([handles;inportPortH]);

    CompiledPortAttrList={'CompiledPortWidth','CompiledPortAliasedThruDataType'
    'CompiledPortDimensions','CompiledPortDimensionsMode'};

    Mex={};
    for n=1:length(handles)
        try
            slicePObj=get(handles(n),'Object');
            if isKey(sliceXfrmr.inactiveInOutBlkPortHMap,slicePObj.Handle)

                continue;
            end
            portNum=slicePObj.PortNumber;
            portTypeLower=slicePObj.PortType;
            portType=[upper(portTypeLower(1)),portTypeLower(2:end)];
            sliceBH=get_param(get(slicePObj,'Parent'),'Handle');
            blkObj=get_param(sliceBH,'Object');
            if blkObj.isSynthesized
                continue;
            elseif strcmp(blkObj.MaskType,'ModelSlicer_replaced')


                continue;
            end
            if~useOrigCache
                origBH=slicerMap.findInOrig(sliceBH);
                tph=get_param(origBH,'PortHandles');
                origPObj=get(tph.(portType)(portNum),'Object');
                origPortH=origPObj.Handle;
            else
                thisAttrStruct=[];
                if origAttrMap.isKey(sliceBH)
                    thisAttrStruct=origAttrMap(sliceBH);
                    origBH=thisAttrStruct.OrigBlockHandle;
                    origPortH=thisAttrStruct.OrigPortHandle;
                else

                    continue;
                end
            end

            for m=1:length(attr)
                sliceAttr=slicePObj.(attr{m});
                if~useOrigCache
                    origAttr=origPObj.(attr{m});
                else
                    origAttr=thisAttrStruct.Attributes.(attr{m});
                end
                if~isequal(sliceAttr,origAttr)







                    if ismember(attr{m},CompiledPortAttrList)
                        if isa(blkObj,'Simulink.Inport')||isa(blkObj,'Simulink.Outport')
                            if isa(blkObj.getParent,'Simulink.SubSystem')&&...
                                startsWith(blkObj.OutDataTypeStr,'Bus:')
                                continue;
                            end
                        end
                    end

                    switch attr{m}
                    case 'CompiledSampleTime'
                        blockST=get_param(origBH,'CompiledSampleTime');
                        if origAttr(1)==-1||sliceAttr(1)==-1||iscell(blockST)








                            continue;
                        elseif isnumeric(origAttr)&&isnumeric(sliceAttr)...
                            &&isinf(origAttr(1))&&isinf(sliceAttr(1))


                            continue;
                        elseif strcmp(get_param(sliceBH,'BlockType'),'Inport')


                            parentSubSys=get_param(sliceBH,'Parent');
                            subsystemType=Simulink.SubsystemType(parentSubSys);
                            if subsystemType.isActionSubsystem
                                continue;
                            end
                        end
                    case 'CompiledPortFrameData'
                        if~strcmp(slicePObj.CompiledBusType,'NOT_BUS')

                            continue;
                        end
                    case 'CompiledPortDimensions'
                        if isequal(origAttr,[2,1,1])&&isequal(sliceAttr,[1,1])

                            continue;
                        elseif isequal(origAttr,[1,1])&&isequal(sliceAttr,[2,1,1])


                            continue;
                        end
                    end
                    dev=struct('OrigPortHandle',origPortH,...
                    'OrigBlockHandle',origBH,...
                    'SlicePortHandle',slicePObj.Handle,...
                    'SliceBlockHandle',sliceBH,...
                    'Attribute',attr{m},...
                    'OrigAttr',origAttr,...
                    'PrevAttr',sliceAttr,...
                    'FixedAttr','');
                    if isempty(deviation)
                        deviation=dev;
                    else
                        deviation(end+1)=dev;%#ok<AGROW>
                    end
                    if throwError
                        Mex{end+1}=Transform.utilThrowPortAttrError(dev,'error');%#ok<AGROW>
                    end
                end
            end
        catch

        end
    end



    if~isempty(Mex)
        if UImode
            for n=1:length(Mex)
                modelslicerprivate('MessageHandler','error',Mex{n})
            end
        else

            mex=Mex{1};
            for n=2:length(Mex)
                mex=mex.addCause(Mex{n});
            end
            throw(mex)
        end
    end
    function ph=getInportHandle(bh)
        aph=get(bh,'PortHandles');
        ph=aph.Outport(1);
    end
end
