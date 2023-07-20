function APM_Blocks(obj)

























    if isR2019aOrEarlier(obj.ver)


        dvbsapskmod_Blocks=obj.findBlocksWithMaskType('DVBS-APSK Modulator Baseband');


        dvbsapskdemod_Blocks=obj.findBlocksWithMaskType('DVBS-APSK Demodulator Baseband');


        apskdemod_Blocks=obj.findBlocksWithMaskType('M-APSK Demodulator Baseband');


        milqamdemod_Blocks=obj.findBlocksWithMaskType('MIL-188 QAM Demodulator Baseband');

        dvbsapsk_blocks=[dvbsapskmod_Blocks;dvbsapskdemod_Blocks];
        apmdemod_blocks=[dvbsapskdemod_Blocks;apskdemod_Blocks;milqamdemod_Blocks];


        isSLX=obj.ver.isSLX;



        for i=1:length(dvbsapsk_blocks)

            blk=dvbsapsk_blocks{i};
            refBlock=get_param(blk,'ReferenceBlock');
            srcBlk=strrep(refBlock,newline,'\n');
            modOrder=get_param(blk,'ModOrder');
            stdval=get_param(blk,'StdSuffix');
            fLenval=get_param(blk,'FrameLength');

            if strcmp(stdval,'S2X')&&strcmp(fLenval,'Normal')
                rule=generateRule(isSLX,srcBlk,'<StdSuffix|S2X><FrameLength|Normal><ModOrder:rename MSimulinkS2XN>');
            elseif strcmp(stdval,'S2')
                rule=generateRule(isSLX,srcBlk,'<StdSuffix|S2><ModOrder:rename MSimulinkS2>');
            elseif(strcmp(stdval,'S2X')&&strcmp(fLenval,'Short'))
                rule=generateRule(isSLX,srcBlk,'<StdSuffix|S2X><FrameLength|Short><ModOrder:rename MSimulinkS2>');
            else
                rule=generateRule(isSLX,srcBlk,'<StdSuffix|SH><ModOrder:rename MSimulinkSH>');
            end
            obj.appendRules(rule);

            if strcmp(stdval,'S2X')
                codeIDF_propName=['CodeIDF',modOrder,stdval,fLenval(1)];
                rule=generateRule(isSLX,srcBlk,['<StdSuffix|S2X><CodeIDF:rename ',codeIDF_propName,'>']);
            elseif strcmp(stdval,'S2')
                codeIDF_propName=['CodeIDF',modOrder,stdval,fLenval(1)];
                rule=generateRule(isSLX,srcBlk,['<StdSuffix|S2><CodeIDF:rename ',codeIDF_propName,'>']);
            else
                rule=generateRule(isSLX,srcBlk,'<StdSuffix|SH><CodeIDF:remove>');
            end
            obj.appendRules(rule);
        end





        for i=1:length(apmdemod_blocks)

            blk=apmdemod_blocks{i};
            refBlock=get_param(blk,'ReferenceBlock');
            srcBlk=strrep(refBlock,newline,'\n');
            outTypeVal=get_param(blk,'OutputType');
            decTypeVal=get_param(blk,'DecisionType');

            if strcmp(outTypeVal,'Integer')
                rule=generateRule(isSLX,srcBlk,'<OutputType|Integer><OutputDataType:rename OutputDataTypeInt>');
            elseif strcmp(outTypeVal,'Bit')&&strcmp(decTypeVal,'Hard decision')
                rule=generateRule(isSLX,srcBlk,'<OutputType|Bit><DecisionType|"Hard decision"><OutputDataType:rename OutputDataTypeBit>');
            elseif strcmp(outTypeVal,'Bit')&&strcmp(decTypeVal,'Log-likelihood ratio')
                rule=generateRule(isSLX,srcBlk,'<OutputType|Bit><DecisionType|"Log-likelihood ratio"><OutputDataType:rename OutputDataTypeSoft>');
            else
                rule=generateRule(isSLX,srcBlk,'<OutputType|Bit><DecisionType|"Approximate log-likelihood ratio"><OutputDataType:rename OutputDataTypeSoft>');
            end
            obj.appendRules(rule);
        end

    end
end

function rule=generateRule(isSLX,srcBlk,r)
    if isSLX
        rule=sprintf('<Block<BlockType|Reference><SourceBlock|"%s"><InstanceData%s>>',srcBlk,r);
    else
        rule=sprintf('<Block<BlockType|Reference><SourceBlock|"%s">%s>',srcBlk,r);
    end
end
