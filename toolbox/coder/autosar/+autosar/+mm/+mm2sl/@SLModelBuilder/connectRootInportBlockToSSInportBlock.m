




function dstBlk=connectRootInportBlockToSSInportBlock(self,currBlk,dstSS)



    currSS=get_param(get_param(currBlk,'Parent'),'Handle');
    currSSPath=getfullname(currSS);
    dstSSFullPath=getfullname(dstSS);
    relPath=regexprep(dstSSFullPath,currSSPath,'','once');
    nextSSName=strtok(relPath,'/');


    currBlkName=get_param(currBlk,'Name');

    dstPort=getExpectedSubsystemDstPortThroughVirtualBlock(nextSSName,dstSSFullPath,currBlk);
    dstBlk=autosar.mm.mm2sl.SLModelBuilder.getBlockFromSSPort(dstPort);

    if~isempty(dstBlk)
        return
    end


    onCleanupObj=self.forceAutomatedBlkAdditions();%#ok<NASGU>
    dstBlk=self.createOrUpdateSimulinkBlock([currSSPath,'/',nextSSName],'Inport',[currBlkName,'_read'],'',[],{});

    variantPath=self.BlockVariantBuilder.getVariantBlock([currSSPath,'/',currBlkName]);
    if~isempty(variantPath)
        currPort=[get_param(variantPath,'Name'),'/1'];
    else
        currPort=[currBlkName,'/1'];
    end
    autosar.mm.mm2sl.layout.LayoutHelper.addLine(currSSPath,...
    currPort,...
    [nextSSName,'/',get_param(dstBlk,'Port')]);




    function dstPort=getExpectedSubsystemDstPortThroughVirtualBlock(nextSSName,dstSSFullPath,cBlk)

        dstPort=[];
        if isempty(cBlk)||(~strcmpi(get_param(cBlk,'BlockType'),'Inport')&&...
            ~strcmpi(get_param(cBlk,'BlockType'),'From'))

            return
        end


        dstPortHs=autosar.mm.mm2sl.SLModelBuilder.getAllDestinationPortsThroughVirtualBlocks(cBlk);
        for ii=1:numel(dstPortHs)
            pBlock=get_param(dstPortHs{ii},'Parent');
            if strcmp(get_param(pBlock,'Name'),nextSSName)||...
                strcmp(getfullname(pBlock),dstSSFullPath)
                dstPort=dstPortHs{ii};
                break;
            end
        end


