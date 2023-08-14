function updateClassicSymbols(sourceFile,destinationFile,buildDir)






    codeDescriptor=coder.internal.getCodeDescriptorInternal(buildDir);
    ci=codeDescriptor.getFullComponentInterface;
    uint8Type=ci.getPlatformDataTypeByName('uint8');
    uint16Type=ci.getPlatformDataTypeByName('uint16');
    uint32Type=ci.getPlatformDataTypeByName('uint32');
    int8Type=ci.getPlatformDataTypeByName('int8');
    int16Type=ci.getPlatformDataTypeByName('int16');
    int32Type=ci.getPlatformDataTypeByName('int32');
    booleanType=ci.getPlatformDataTypeByName('boolean');
    charType=ci.getPlatformDataTypeByName('char');


    replacementTable={
    'MAX_int8_T',int8Type.SymbolMax
    'MIN_int8_T',int8Type.SymbolMin
    'MAX_int16_T',int16Type.SymbolMax
    'MIN_int16_T',int16Type.SymbolMin
    'MAX_int32_T',int32Type.SymbolMax
    'MIN_int32_T',int32Type.SymbolMin
    'MAX_uint8_T',uint8Type.SymbolMax
    'MAX_uint16_T',uint16Type.SymbolMax
    'MAX_uint32_T',uint32Type.SymbolMax
    'int8_T',int8Type.Symbol
    'int16_T',int16Type.Symbol
    'int32_T',int32Type.Symbol
    'uint8_T',uint8Type.Symbol
    'uint16_T',uint16Type.Symbol
    'uint32_T',uint32Type.Symbol
    'boolean_T',booleanType.Symbol
    'char_T',charType.Symbol
    };


    fid=fopen(sourceFile,'rt');
    sourceFileContent=fread(fid,[1,Inf],'*char');
    fclose(fid);


    fileUpdater=coder.make.internal.FileUpdater(destinationFile);


    updatedContent=coder.internal.replaceSymbols(sourceFileContent,...
    replacementTable(:,1),replacementTable(:,2));






    basicTypeHeaders=coder.internal.getHeadersForSymbols...
    (ci,{'uint32_T','boolean_T','real_T'});

    newIncludes="#include "+basicTypeHeaders;
    newIncludes=strtrim(newIncludes);
    newIncludes=join(newIncludes,newline);

    oldInclude='#include\s+"rtwtypes.h"';


    updatedContent=regexprep(updatedContent,oldInclude,...
    newIncludes);


    fileUpdater.setUpdatedContent(updatedContent);