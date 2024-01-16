function[topLevelLines]=insertDTCBlocksForHDLDTO(this)

    inFileName=this.InModelFile;
    srcMdlObj=get_param(inFileName,'Object');

    rootNetworkName=this.RootNetworkName;

    topLevelLines=srcMdlObj.Lines;
    [dutSrcParentLines,dutDstLines]=getLines(get_param(rootNetworkName,'Object'));
    uniqueSrcParentLines=unique(dutSrcParentLines);
    topLevelLines=addDTCBlocks(this.OutModelFile,topLevelLines,uniqueSrcParentLines,dutDstLines,get_param(rootNetworkName,'Handle'));

end


function[srcParentLines,dstLines]=getLines(dut)

    lines=dut.LineHandles;
    srcLines=lines.Inport;
    dstLines=lines.Outport;

    if(srcLines==-1)
        srcLines=[];
    end
    if(dstLines==-1)
        dstLines=[];
    end

    srcParentLines=zeros(size(srcLines));
    for i=1:numel(srcParentLines)
        srcParentLines(i)=getTopParentLine(srcLines(i));
    end
end


function[newLines]=addDTCBlocks(outModelFile,lines,uniqueSrcParentLines,dutDstLines,dutBlock)
    newLines=lines;

    for i=1:numel(uniqueSrcParentLines)
        currSrcLine=uniqueSrcParentLines(i);
        dtcHandle=add_block('simulink/Signal Attributes/Data Type Conversion',[outModelFile,'/','Data Type Conversion'],'MakeNameUnique','on');
        lineFromDtc=copyLine(lines(1));
        lineFromDtc.SrcBlock=dtcHandle;
        lineFromDtc.SrcPort='1';        lineIdx=find([lines.Handle]==currSrcLine);

        currLine=lines(lineIdx);

        if(currLine.DstBlock==dutBlock)

            lineFromDtc.DstBlock=dutBlock;
            lineFromDtc.DstPort=currLine.DstPort;
            newLines(lineIdx).DstBlock=dtcHandle;
            newLines(lineIdx).DstPort='1';
        else            [newL,newB]=insertDTCBlock(currLine,dutBlock,dtcHandle);
            lineFromDtc.Branch=newB;
            if(~isempty(newL.Branch))                lineToDtc=copyLine(lines(1));
                lineToDtc.SrcBlock=currLine.SrcBlock;
                lineToDtc.SrcPort=currLine.SrcPort;
                lineToDtc.DstBlock=dtcHandle;
                lineToDtc.DstPort='1';
                newL.Branch=[newL.Branch;lineToDtc];
            else
                newL.DstBlock=dtcHandle;
                newL.DstPort='1';
            end

            newLines(lineIdx)=newL;
        end
        newLines=[newLines;lineFromDtc];
    end

    for i=1:length(dutDstLines)
        currDstLine=dutDstLines(i);
        dtcHandle=add_block('simulink/Signal Attributes/Data Type Conversion',[outModelFile,'/','Data Type Conversion'],'MakeNameUnique','on');
        lineFromDtc=copyLine(lines(1));
        lineFromDtc.SrcBlock=dtcHandle;
        lineFromDtc.SrcPort='1';
        lineIdx=find([lines.Handle]==currDstLine);

        currLine=lines(lineIdx);
        lineFromDtc.DstBlock=currLine.DstBlock;
        lineFromDtc.DstPort=currLine.DstPort;
        lineFromDtc.Branch=currLine.Branch;

        newLines(lineIdx).Branch=[];
        newLines(lineIdx).DstBlock=dtcHandle;
        newLines(lineIdx).DstPort='1';

        newLines=[newLines;lineFromDtc];

    end
end


function[newLine,branchFromDTC]=insertDTCBlock(startingLine,dutBlock,dtcBlock)

    newLine=startingLine;
    branchFromDTC=[];
    if(~isempty(startingLine.DstBlock)&&(startingLine.DstBlock==dutBlock))

        branchFromDTC=startingLine;

        branchFromDTC.SrcBlock=[];
        branchFromDTC.SrcPort=[];

        newLine.Handle=-1;

    elseif(~isempty(startingLine.Branch))

        for i=1:numel(startingLine.Branch)
            currBranch=startingLine.Branch(i);
            [nLine,branchDTC]=insertDTCBlock(currBranch,dutBlock,dtcBlock);

            newLine.Branch(i)=nLine;
            branchFromDTC=[branchFromDTC,branchDTC];
        end

        idx=1;
        for i=1:numel(newLine.Branch)
            if(newLine.Branch(idx).Handle==-1)
                newLine.Branch(idx)=[];
            else
                idx=idx+1;
            end
        end
        if(isempty(newLine.Branch)&&isempty(newLine.DstBlock))
            newLine.Handle=-1;
        end
    end
end


function newLineStruct=copyLine(line)
    newLineStruct=line;

    newLineStruct.Handle=[];
    newLineStruct.Name='';
    newLineStruct.Parent=[];
    newLineStruct.SrcBlock=[];
    newLineStruct.SrcPort='';
    newLineStruct.DstBlock=[];
    newLineStruct.DstPort=[];
    newLineStruct.Points=[];
    newLineStruct.Branch=[];

end


function parentLine=getTopParentLine(line)
    parentLine=line;

    lineObj=get_param(line,'Object');

    while(lineObj.LineParent~=-1)
        parentLine=lineObj.LineParent;
        lineObj=get_param(parentLine,'Object');
    end

end