function newContentWritten=genZcTypesHeader(zcTypesFileWithPath,fixedWidthIntHeader,typeForUint8)





    if isfile(zcTypesFileWithPath)
        newContentWritten=false;
        return
    else
        newContentWritten=true;
    end

    if~startsWith(fixedWidthIntHeader,'<')
        fixedWidthIntHeader=['"',fixedWidthIntHeader,'"'];
    end


    zc_defs_buffer=coder.internal.generateZeroCrossingTypes;



    zc_defs_buffer=replace(zc_defs_buffer,'uint8_T',typeForUint8);

    content=['#ifndef ZERO_CROSSING_TYPES_H',newline,newline'];
    content=[content,'#define ZERO_CROSSING_TYPES_H',newline];
    content=sprintf('%s#include %s\n',content,fixedWidthIntHeader);
    content=sprintf('%s\n%s',content,zc_defs_buffer);
    content=[content,'#endif /* ZERO_CROSSING_TYPES_H */'];

    f=fopen(zcTypesFileWithPath,'wt');
    fprintf(f,'%s',content);
    fclose(f);
    c_beautifier(zcTypesFileWithPath);

