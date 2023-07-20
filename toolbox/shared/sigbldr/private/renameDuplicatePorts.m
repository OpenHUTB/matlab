function renameDuplicatePorts(handleStruct,channels,sigCnt)



















    outportNames=get(handleStruct.outPortH,'name');


    [~,ia,ib]=intersect({channels(:).label},outportNames);




    for sigIdx=1:sigCnt


        idxDuplicateName=find(ia==sigIdx,1);


        if~isempty(idxDuplicateName)&&...
            ((ia(ia==sigIdx)~=ib(ia==sigIdx)))...

            sigbuilder_block('rename_outport',handleStruct,ib(ia==sigIdx),[blanks(1),outportNames{ib(ia==sigIdx)}]);

            sigbuilder_block('rename_outport',handleStruct,sigIdx,channels(sigIdx).label);
        else
            sigbuilder_block('rename_outport',handleStruct,sigIdx,channels(sigIdx).label);
        end


        outportNames=get(handleStruct.outPortH,'name');


        [~,ia,ib]=intersect({channels(:).label},outportNames);

    end

