function[blkAttribsVec,blkCell]=getCompiledPortAttributesForLibBlk(rManager,origBlkPath,portNumber)















    blkAttribsVec=Simulink.variant.reducer.utils.getCompiledPortAttribsStruct();
    blkCell={};%#ok<NASGU>


    Simulink.variant.reducer.utils.assert(~rManager.CompiledPortAttributesMap.isKey(origBlkPath));


    portNumber=portNumber-1;


    bdNameRedBDNameMap=rManager.BDNameRedBDNameMap;


    redBDNameBDNameMap=i_invertMap(bdNameRedBDNameMap);


    invertedLibBlkMap=rManager.LibBlkToModelInstanceMap;


    Simulink.variant.reducer.utils.assert(invertedLibBlkMap.isKey(origBlkPath));


    blkCell=getAllTerminalBlocks(invertedLibBlkMap,origBlkPath);


    attribStructVecToCompare(1,numel(blkCell))=Simulink.variant.reducer.utils.getCompiledPortAttribsStruct(false);
    for ii=1:numel(blkCell)
        blk=blkCell{ii};

        Simulink.variant.reducer.utils.assert(rManager.CompiledPortAttributesMap.isKey(blk));

        compiledPortAttribsVec=rManager.CompiledPortAttributesMap(blk);
        blkAttribsVec=compiledPortAttribsVec;


        boolIdx=arrayfun(@(x)searchByPortNumberAndType(x,portNumber,'inport'),compiledPortAttribsVec);

        attrStruct=compiledPortAttribsVec(boolIdx);

        Simulink.variant.reducer.utils.assert(numel(attrStruct)==1,'More than one attrib struct found');

        attribStructVecToCompare(ii)=attrStruct;
    end


    if numel(attribStructVecToCompare)==1
        return;
    end





    for ii=2:numel(attribStructVecToCompare)
        if~isequal(attribStructVecToCompare(1).CompiledSignalHierarchy,attribStructVecToCompare(ii).CompiledSignalHierarchy)


            throwAsCaller(MSLException(message('Simulink:VariantReducer:DiffBusHierToLibBlk',...
            rManager.getOptions().TopModelOrigName,...
            i_getModifiedBlockPath(origBlkPath,redBDNameBDNameMap),...
            num2str(portNumber+1),...
            i_getModifiedBlockPath(blkCell{1},redBDNameBDNameMap),...
            i_getModifiedBlockPath(blkCell{ii},redBDNameBDNameMap))));
        end
    end


    for ii=2:numel(attribStructVecToCompare)
        if~compareBusStructs(rManager,attribStructVecToCompare(1).CompiledBusStruct,attribStructVecToCompare(ii).CompiledBusStruct)


            throwAsCaller(MSLException(message('Simulink:VariantReducer:DiffBusAttribsToLibBlk',...
            rManager.getOptions().TopModelOrigName,...
            i_getModifiedBlockPath(origBlkPath,redBDNameBDNameMap),...
            num2str(portNumber+1),...
            i_getModifiedBlockPath(blkCell{1},redBDNameBDNameMap),...
            i_getModifiedBlockPath(blkCell{ii},redBDNameBDNameMap))));
        end
    end

    blkAttribsVec=attribStructVecToCompare(1);
end





function blkCell=getAllTerminalBlocks(invertedLibBlkMap,origBlkPath)
    blkCell={};
    Simulink.variant.reducer.utils.assert(invertedLibBlkMap.isKey(origBlkPath));

    resBlks=invertedLibBlkMap(origBlkPath);
    resBlks=setdiff(resBlks,origBlkPath);

    for ii=1:numel(resBlks)
        tmpBlk=resBlks{ii};
        if invertedLibBlkMap.isKey(tmpBlk)
            tmpBlk=getAllTerminalBlocks(invertedLibBlkMap,resBlks{ii});
        end
        blkCell=unique([blkCell;tmpBlk]);
    end
end




function status=searchByPortNumberAndType(struct,num,type)
    status=(struct.PortNumber==num)&&strcmp(type,struct.PortType);
end


function isEqual=compareBusStructs(rManager,attrStruct1,attrStruct2)
    isEqual=true;


    if isempty(attrStruct1)&&isempty(attrStruct2)
        isEqual=true;
        return;
    end

    Simulink.variant.reducer.utils.assert(numel(attrStruct1.signals)==numel(attrStruct2.signals),'');

    if~isempty(attrStruct1.signals)
        for ii=1:numel(attrStruct1.signals)
            if~compareBusStructs(rManager,attrStruct1.signals(ii),attrStruct2.signals(ii))
                isEqual=false;
                return;
            end
        end
    else
        srcBlk1=attrStruct1.src;
        srcPort1=attrStruct1.srcPort;

        srcBlk2=attrStruct2.src;
        srcPort2=attrStruct2.srcPort;

        Simulink.variant.reducer.utils.assert(rManager.CompiledBusSrcPortAttribsMap.isKey(srcBlk1));
        Simulink.variant.reducer.utils.assert(rManager.CompiledBusSrcPortAttribsMap.isKey(srcBlk2));


        portType='outport';

        src1CompiledAttrVec=rManager.CompiledBusSrcPortAttribsMap(srcBlk1);
        boolIdx=arrayfun(@(x)searchByPortNumberAndType(x,srcPort1,portType),src1CompiledAttrVec);
        src1CompiledAttr=src1CompiledAttrVec(boolIdx);
        Simulink.variant.reducer.utils.assert(numel(src1CompiledAttr)==1,'More than one attrib struct found');

        src2CompiledAttrVec=rManager.CompiledBusSrcPortAttribsMap(srcBlk2);
        boolIdx=arrayfun(@(x)searchByPortNumberAndType(x,srcPort2,portType),src2CompiledAttrVec);
        src2CompiledAttr=src2CompiledAttrVec(boolIdx);
        Simulink.variant.reducer.utils.assert(numel(src2CompiledAttr)==1,'More than one attrib struct found');

        attribsOfInterest={...
        'CompiledPortAliasedThruDataType',...
        'CompiledPortDesignMax',...
        'CompiledPortDesignMin',...
        'CompiledPortDimensions',...
        'CompiledPortSampleTime',...
        'CompiledPortComplexSignal',...
        'CompiledPortUnits'};

        Simulink.variant.reducer.utils.assert(isequal(fields(src1CompiledAttr),fields(src1CompiledAttr)));

        allFileds=fields(src1CompiledAttr);

        attribsToRemove=setdiff(allFileds,attribsOfInterest);

        src1CompiledAttr=rmfield(src1CompiledAttr,attribsToRemove);
        src2CompiledAttr=rmfield(src2CompiledAttr,attribsToRemove);

        src1CompiledAttr.CompiledPortSampleTime=...
        Simulink.variant.reducer.utils.getSampleTimeStr(src1CompiledAttr.CompiledPortSampleTime);
        src2CompiledAttr.CompiledPortSampleTime=...
        Simulink.variant.reducer.utils.getSampleTimeStr(src2CompiledAttr.CompiledPortSampleTime);

        isEqual=isequal(src1CompiledAttr,src2CompiledAttr);
    end
end


