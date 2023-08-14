function[id,arg]=check_headerfile_string_msg(hdrfile)












    id='';
    arg='';
    if ischar(hdrfile)
        locHdr=strtrim(hdrfile);


        if isempty(locHdr)

            return;
        end


        locHdr=chompOffEnclosing(locHdr);

        locHdr=getSubstituteHeaderName(locHdr);


        nDelims=length(find(locHdr=='"'))+...
        length(find(locHdr=='<'))+...
        length(find(locHdr=='>'));
        if nDelims>0
            id='Simulink:dialog:InvalidHeaderFileDelimiters';
            return;
        end







        [~,fname]=fileparts(locHdr);
        fname=strtrim(fname);
        if isempty(fname)
            id='Simulink:dialog:HeaderFileNotEmptyDelimSpec';
            return;
        end


        if~strcmp(locHdr,strtrim(locHdr))
            id='Simulink:dialog:HeaderFileStartEndWhiteSpace';
            return;
        end


        coreHeaderFiles={'rtwtypes'};
        if ismember(fname,coreHeaderFiles)
            id='Simulink:dialog:HeaderFileCannotBeCoreHeaderFile';
            arg=locHdr;
            return;
        end

    else

        id='Simulink:dialog:HeaderFileMustBeString';
        return;
    end
end

function headerFileName=chompOffEnclosing(headerFileName)
    if((headerFileName(1)=='"')&&(headerFileName(end)=='"')||...
        (headerFileName(1)=='<')&&(headerFileName(end)=='>'))
        headerFileName=headerFileName(2:end-1);
    end
end

function headerFileName=getSubstituteHeaderName(headerFileName)
    mf0mdl=mf.zero.Model;
    parser=coder.identifiers.NamingRuleParser(mf0mdl);
    if(parser.isNamingRuleStringValid(headerFileName))
        segments=parser.getNamingRuleParts(headerFileName);
        nextIdx=1;
        for segment=segments
            switch segment.type
            case coder.identifiers.SegmentType.SEGMENT_TOKEN
                headerFileName(nextIdx)='T';
                nextIdx=nextIdx+1;
            case coder.identifiers.SegmentType.SEGMENT_DECORATOR
                headerFileName(nextIdx)='D';
                nextIdx=nextIdx+1;
            case coder.identifiers.SegmentType.SEGMENT_LITERAL
                segmentLength=numel(segment.content);
                headerFileName(nextIdx:(nextIdx+segmentLength-1))=segment.content;
                nextIdx=nextIdx+segmentLength;
            end
        end
        headerFileName(nextIdx:end)='';
    end
end



