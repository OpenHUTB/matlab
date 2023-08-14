function execute(obj)

    blocks=obj.Data;
    if~iscell(blocks)
        blocks={blocks};
    end
    numEntries=length(blocks);
    tableContents=cell(numEntries,1);
    for k=1:numEntries
        b=blocks{k};

        tableContents{k,1}=[DAStudio.message('RTW:report:InsertedBlockType',b.Type),' : ',rtwprivate('rtwhtmlescape',b.Name)];
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
                src{n}=[DAStudio.message('RTW:report:InsertedAtOutport',srcBlock,get_param(srcPorts(n),'PortNumber')),'<br />'];
            end
            src=strcat(src{:});
        end
        tableContents{k,2}=src;

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
                dst{n}=[DAStudio.message('RTW:report:InsertedAtInport',dstBlock,get_param(dstPorts(n),'PortNumber')),'<br />'];
            end
            dst=strcat(dst{:});
        end
        tableContents{k,3}=dst;
        tableContents{k,4}=blocks{k}.Comment;
    end
    t=Advisor.Table(numEntries,4);
    t.setBorder(1);
    t.setStyle('AltRow');
    t.setColHeading(1,DAStudio.message('RTW:report:InsertedBlock'));
    t.setColHeading(2,DAStudio.message('RTW:report:InsertedBlockSource'));
    t.setColHeading(3,DAStudio.message('RTW:report:InsertedBlockDest'));
    t.setColHeading(4,DAStudio.message('RTW:report:InsertedBlockComment'));
    t.setEntries(tableContents);
    obj.addItem(t);
end
