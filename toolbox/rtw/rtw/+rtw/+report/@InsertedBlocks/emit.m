function emit(obj,rpt,type,template)
    import mlreportgen.dom.*;
    chapter=DocumentPart(type,template);

    blocks=obj.Data;
    if~iscell(blocks)
        blocks={blocks};
    end
    numEntries=length(blocks);
    col1=cell(numEntries,1);
    col2=cell(numEntries,1);
    col3=cell(numEntries,1);
    col4=cell(numEntries,1);
    nl=sprintf('\n');
    for k=1:numEntries
        b=blocks{k};

        col1{k}=[DAStudio.message('RTW:report:InsertedBlockType',b.Type),' : ',b.Name];
        src='';

        if isfield(b,'SrcBlock')
            srcBlock=obj.getHyperlink(b.SrcBlock.SID);
            src=DAStudio.message('RTW:report:InsertedAtOutport',srcBlock,b.SrcBlock.OutputPort+1);
        elseif isfield(b,'DstBlock')

            hPort=obj.getPortHandles(b.DstBlock.SID);
            line=get_param(hPort.Inport(b.DstBlock.InputPort+1),'Line');
            srcBlocks=get_param(line,'SrcBlockHandle');
            srcPorts=get_param(line,'SrcPortHandle');
            src=cell(length(srcBlocks),1);
            for n=1:length(srcBlocks)
                srcBlock=obj.getHyperlink(Simulink.ID.getSID(srcBlocks(n)));
                src{n}=[DAStudio.message('RTW:report:InsertedAtOutport',srcBlock,get_param(srcPorts(n),'PortNumber')),nl];
            end
            src=strcat(src{:});
        end
        col2{k}=src;

        dst='';
        if isfield(b,'DstBlock')
            dstBlock=obj.getHyperlink(b.DstBlock.SID);
            dst=DAStudio.message('RTW:report:InsertedAtInport',dstBlock,b.DstBlock.InputPort+1);
        elseif isfield(b,'SrcBlock')

            hPort=obj.getPortHandles(b.SrcBlock.SID);
            line=get_param(hPort.Outport(b.SrcBlock.OutputPort+1),'Line');
            dstBlocks=get_param(line,'DstBlockHandle');
            dstPorts=get_param(line,'DstPortHandle');
            dst=cell(length(dstBlocks),1);
            for n=1:length(dstBlocks)
                dstBlock=obj.getHyperlink(Simulink.ID.getSID(dstBlocks(n)));
                dst{n}=[DAStudio.message('RTW:report:InsertedAtInport',dstBlock,get_param(dstPorts(n),'PortNumber')),nl];
            end
            dst=strcat(dst{:});
        end
        col3{k}=dst;
        col4{k}=blocks{k}.Comment;
    end
    col1=[DAStudio.message('RTW:report:InsertedBlock');col1];
    col2=[DAStudio.message('RTW:report:InsertedBlockSource');col2];
    col3=[DAStudio.message('RTW:report:InsertedBlockDest');col3];
    col4=[DAStudio.message('RTW:report:InsertedBlockComment');col4];
    t=Table([col1,col2,col3,col4],'TableStyleAltRow');
    while~strcmp(chapter.CurrentHoleId,'#end#')
        switch chapter.CurrentHoleId
        case 'InsertedBlocks'
            chapter.append(t);
        end
        moveToNextHole(chapter);
    end
    rpt.append(chapter);
end
