function genComplexTypesHeader(complexTypeDefs,...
    complexTypesFileWithPath,fixedWidthIntHeader,...
    startComplexIncludeGuard,endComplexIncludeGuard)




    fid=fopen(complexTypesFileWithPath,'w');
    fprintf(fid,'%s',startComplexIncludeGuard);
    fprintf(fid,'#include %s\n\n',fixedWidthIntHeader);
    fprintf(fid,'%s\n',complexTypeDefs);
    fprintf(fid,'%s',endComplexIncludeGuard);
    fclose(fid);
