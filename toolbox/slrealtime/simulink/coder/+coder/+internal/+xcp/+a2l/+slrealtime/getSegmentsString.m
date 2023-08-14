function str=getSegmentsString(segments)






    str='';

    for ii=1:numel(segments)
        str=([str,newline,'       /begin MEMORY_SEGMENT '...
        ,segments(ii).Instance]);
        str=([str,newline,'       "',segments(ii).Instance,'"']);
        str=([str,newline,'       DATA']);
        str=([str,newline,'       FLASH']);
        str=([str,newline,'       INTERN']);
        str=([str,newline,'       0x0000 /* @ECU_Address@',segments(ii).Instance,'@ */']);

        str=([str,newline,'       0x00 /* @SEGMENT_SIZE@',segments(ii).Instance,'@ */']);
        str=([str,newline,'       -1 -1 -1 -1 -1']);

        str=([str,newline,getIFDATASegmentBlock(segments(ii).Index)]);
        str=([str,newline,'        /end MEMORY_SEGMENT']);

    end

end

function str=getIFDATASegmentBlock(segment_index)

    str=('       /begin IF_DATA XCP');
    str=([str,newline,'         /begin SEGMENT']);
    str=([str,newline,'            0x',dec2hex(segment_index,2)]);
    str=([str,newline,'            0x02']);
    str=([str,newline,'            0x00']);
    str=([str,newline,'            0x00']);
    str=([str,newline,'            0x00']);
    str=([str,newline,'            /begin PAGE']);
    str=([str,newline,'              0x00']);
    str=([str,newline,'              ECU_ACCESS_DONT_CARE']);
    str=([str,newline,'              XCP_READ_ACCESS_DONT_CARE']);
    str=([str,newline,'              XCP_WRITE_ACCESS_NOT_ALLOWED']);
    str=([str,newline,'            /end PAGE']);
    str=([str,newline,'            /begin PAGE']);
    str=([str,newline,'              0x01']);
    str=([str,newline,'              ECU_ACCESS_DONT_CARE']);
    str=([str,newline,'              XCP_READ_ACCESS_DONT_CARE']);
    str=([str,newline,'              XCP_WRITE_ACCESS_DONT_CARE']);
    str=([str,newline,'            /end PAGE']);
    str=([str,newline,'          /end SEGMENT']);
    str=([str,newline,'        /end IF_DATA']);
end
