function setCompiledPortAttributeMap(obj,prop,val)





    narginchk(2,3);
    debugInfoFlag=(Simulink.variant.reducer.utils.getDebugLevel()>=2);




    compAttrMap=obj.(prop);

    if strcmp(prop,'CompiledPortAttributesMap')
        busSrcBlkHVec=[];
    end

    createZeroSizeStruct=false;
    attrStruct=Simulink.variant.reducer.utils.getCompiledPortAttribsStruct(createZeroSizeStruct);
    attrNames=fieldnames(attrStruct);
    attrNames=setdiff(attrNames,'CollectionStatus');
    attrNames=setdiff(attrNames,{'PortBlockName','PortNumber'});

    attribNamesPostCompile={...
    'CompiledPortComplexSignal',...
    'CompiledPortAliasedThruDataType',...
    'CompiledPortDesignMax',...
    'CompiledPortDesignMin',...
    'CompiledPortFrameData',...
    'CompiledPortDimensionsMode',...
    'CompiledPortWidth',...
    'CompiledPortSampleTime',...
    'CompiledPortDimensions',...
    'CompiledBusType',...
    'CompiledSignalHierarchy',...
    'CompiledPortSymbolicDimensions'};

    busUselessAttribs={'CompiledPortFrameData',...
    'CompiledPortDimensionsMode',...
    'CompiledPortWidth'};

    if obj.SLCompEvent==Simulink.variant.reducer.EngineCompileEvent.PRE_INACTIVE_VARIANT_REMOVAL
        if strcmp(prop,'CompiledPortAttributesMap')
            attrNames=setdiff(attrNames,attribNamesPostCompile);
        else
            Simulink.variant.reducer.utils.assert(strcmp(prop,'CompiledBusStructPortAttribsMap'));
            attrNames=setdiff(attrNames,busUselessAttribs);
        end
    elseif obj.SLCompEvent==Simulink.variant.reducer.EngineCompileEvent.COMP_PASSED_EVENT
        attrNames=attribNamesPostCompile;
    end


    if obj.SLCompEvent==Simulink.variant.reducer.EngineCompileEvent.COMP_PASSED_EVENT
        Simulink.variant.reducer.utils.assert(strcmp('CompiledPortAttributesMap',prop));

        blks=compAttrMap.keys;


        if debugInfoFlag
            disp([newline,'$$$$$$$$$$$$$$$$$$$$$','     ','Start of ',prop,'     ','$$$$$$$$$$$$$$$$$$$$$']);
        end

        for blkIdx=1:numel(blks)
            blk=blks{blkIdx};

            if debugInfoFlag

                disp(['>>>>>>>>>>>>>>>>>>>>>>    ',blk,'    <<<<<<<<<<<<<<<<<<<<<']);
            end

            portAttribStructsVec=compAttrMap(blk);

            for portIdx=1:numel(portAttribStructsVec)
                if portAttribStructsVec(portIdx).CollectionStatus
                    continue;
                end

                pH=portAttribStructsVec(portIdx).Handle;

                for attrIdx=1:numel(attrNames)
                    if debugInfoFlag
                        disp(attrNames{attrIdx});
                    end
                    try
                        portAttribStructsVec(portIdx).(attrNames{attrIdx})=get(pH,attrNames{attrIdx});
                    catch ex %#ok<NASGU>
                        portAttribStructsVec(portIdx).(attrNames{attrIdx})=[];
                    end
                end
                portAttribStructsVec(portIdx).CollectionStatus=true;
            end

            compAttrMap(blk)=portAttribStructsVec;
        end

        obj.(prop)=compAttrMap;


        if debugInfoFlag
            disp(['$$$$$$$$$$$$$$$$$$$$$','     ','End of ',prop,'     ','$$$$$$$$$$$$$$$$$$$$$',newline]);
        end

        return;
    end




    if nargin==3

        blocks=val;
    else

        blocks=obj.Blocks;
    end


    if debugInfoFlag
        disp([newline,'$$$$$$$$$$$$$$$$$$$$$','     ','Start of ',prop,'     ','$$$$$$$$$$$$$$$$$$$$$']);
    end

    for n=1:numel(blocks)

        if strcmp(prop,'CompiledBusStructPortAttribsMap')
            blk=blocks(n);
        else
            blk=blocks{n};
        end

        compiledAttrStructsVec=Simulink.variant.reducer.utils.getCompiledPortAttribsStruct();

        blkName=blk;
        if isa(blkName,'double')
            Simulink.variant.reducer.utils.assert(strcmp(prop,'CompiledBusStructPortAttribsMap'));
            blkName=getfullname(blkName);
            blkName=i_replaceCarriageReturnWithSpace(blkName);
        end

        if debugInfoFlag

            disp(['>>>>>>>>>>>>>>>>>>>>>>    ',blkName,'    <<<<<<<<<<<<<<<<<<<<<']);
        end

        if isKey(compAttrMap,blkName)
            if debugInfoFlag

                disp(['>>>>    "',blkName,'"  is already present in the compiled port attribute map    <<<<']);
            end
            continue;
        end

        try
            blkObj=get(get_param(blk,'Handle'),'Object');
            portObjs=get([blkObj.PortHandle.Inport,blkObj.PortHandle.Outport],'Object');
            if iscell(portObjs)
                portObjs=cell2mat(portObjs);
            end
            nPorts=numel(portObjs);



            if strcmp(blkObj.BlockType,'SubSystem')
                portBlocks=get_param(find_system(blk,...
                'LookUnderMasks','all',...
                'FollowLinks','on',...
                'SearchDepth',1,...
                'MatchFilter',@Simulink.match.allVariants,...
                'regexp','on',...
                'BlockType','Inport|Outport'),'Name');
            elseif blkObj.isModelReference
                if strcmp(get_param(blk,'ProtectedModel'),'off')
                    refModel=get_param(blk,'ModelName');








                    if~bdIsLoaded(refModel)
                        load_system(refModel);
                    end
                    portBlocks=get_param(find_system(refModel,...
                    'LookUnderMasks','all',...
                    'FollowLinks','on',...
                    'SearchDepth',1,...
                    'regexp','on',...
                    'BlockType','Inport|Outport'),'Name');
                else
                    portBlocks=cell(1,nPorts);
                end
            else
                portBlocks=cell(1,nPorts);
            end






            try
                if debugInfoFlag
                    disp('CompiledPortUnits');
                end
                compUnitStruct=get_param(blk,'CompiledPortUnits');
            catch
                compUnitStruct=[];
            end

            nInports=numel(blkObj.PortHandle.Inport);
            for portIter=1:nPorts
                portObj=portObjs(portIter);
                thisAttrStruct=attrStruct;





                if portIter<=numel(portBlocks)
                    thisAttrStruct.PortBlockName=portBlocks{portIter};
                end

                for m=1:length(attrNames)
                    if debugInfoFlag
                        disp(attrNames{m});
                    end


                    if strcmp(attrNames{m},'CompiledPortUnits')
                        continue;
                    end

                    if obj.CompileCalledForValidation&&...
                        any(strcmp(attrNames{m},{'CompiledSignalHierarchy','CompiledBusStruct'}))
                        continue;
                    end



                    if any(strcmp(blkObj.BlockType,{'Switch','MultiPortSwitch','Concatenate'}))&&...
                        any(strcmp(attrNames{m},{'CompiledPortDesignMax','CompiledPortDesignMin'}))



                        continue;
                    end






                    try
                        thisAttrStruct.(attrNames{m})=get(portObj,attrNames{m});
                    catch ex %#ok<NASGU>
                        thisAttrStruct.(attrNames{m})=[];
                    end


                    if~obj.CompileCalledForValidation&&...
                        strcmp(prop,'CompiledPortAttributesMap')...
                        &&any(strcmp(get(portObj,'PortType'),{'inport','trigger','enable','reset'}))...
                        &&strcmp('CompiledBusStruct',attrNames{m})...
                        &&~isempty(thisAttrStruct.CompiledBusStruct)
                        [tempBusSrcBlkHVec,thisAttrStruct.CompiledBusStruct]=fetchBusSrcs(thisAttrStruct.CompiledBusStruct);
                        busSrcBlkHVec=unique([busSrcBlkHVec;tempBusSrcBlkHVec]);
                    end

                end


                if portIter<=nInports

                    if~isempty(compUnitStruct)
                        thisAttrStruct.CompiledPortUnits=compUnitStruct.Inport{portIter};
                    end
                    thisAttrStruct.PortNumber=portIter-1;
                else

                    if~isempty(compUnitStruct)
                        thisAttrStruct.CompiledPortUnits=compUnitStruct.Outport{portIter-nInports};
                    end
                    thisAttrStruct.PortNumber=portIter-nInports-1;
                end
                compiledAttrStructsVec(end+1)=thisAttrStruct;%#ok<AGROW>
            end

            compAttrMap(blkName)=compiledAttrStructsVec;

        catch ex %#ok<NASGU>







            if~isKey(compAttrMap,blk)
                if exist('nPorts','var')
                    compAttrMap(blk)=repmat(attrStruct,nPorts);
                else
                    compAttrMap(blk)=attrStruct;
                end
            end
        end
    end

    obj.(prop)=compAttrMap;


    if debugInfoFlag
        disp(['$$$$$$$$$$$$$$$$$$$$$','     ','End of ',prop,'     ','$$$$$$$$$$$$$$$$$$$$$',newline]);
    end

    if strcmp(prop,'CompiledPortAttributesMap')&&~obj.CompileCalledForValidation
        Simulink.variant.reducer.CompileManager.callSetBusStructPortAttribsMap(busSrcBlkHVec);
    end
end






function[busSrcBlkHVec,compiledBusStruct]=fetchBusSrcs(compiledBusStruct)
    busSrcBlkHVec=[];



    if isempty(compiledBusStruct.signals)
        busSrcBlkHVec=compiledBusStruct.src;
    else
        for signalIdx=1:numel(compiledBusStruct.signals)
            [tempBusSrcBlkHVec,compiledBusStruct.signals(signalIdx)]=fetchBusSrcs(compiledBusStruct.signals(signalIdx));
            busSrcBlkHVec=unique([busSrcBlkHVec;tempBusSrcBlkHVec]);
        end
    end



    compiledBusStruct.src=getfullname(compiledBusStruct.src);
    compiledBusStruct.src=i_replaceCarriageReturnWithSpace(compiledBusStruct.src);
end

function blkName=i_replaceCarriageReturnWithSpace(blkName)
    blkName=strrep(blkName,newline,' ');
    blkName=strtrim(blkName);
end


