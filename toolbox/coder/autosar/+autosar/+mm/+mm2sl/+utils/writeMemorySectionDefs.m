function writeMemorySectionDefs(memorySections)





    filename='additionalAUTOSAR4MemorySections.m';

    [fileH,errmsg]=fopen(filename,'w');

    if(fileH==-1)
        DAStudio.error('RTW:autosar:unableToOpenFileForWriting',filename,errmsg);
    end

    comments=['%%ADDITIONALAUTOSAR4MEMORYSECTIONS : Provide additional memory sections for the \n'...
    ,'%%AUTOSAR4 Data Package. This file is modified during ARXML import. \n'...
    ,'%%Hand modification of this file is not recommended as it may prevent the \n'...
    ,'%%Simulink custom storage class designer from loading the associated classes \n'...
    ,'%%The contents of this file are arranged so that the Simulink custom storage \n'...
    ,'%%class designer can load the associated classes for editing. \n'...
    ,'%%Please ensure that this file is on the MATLAB path prior to creating \n'...
    ,'%%Data Objects of the AUTOSAR4 Package during a MATLAB session'];

    fprintf(fileH,'function defs = additionalAUTOSAR4MemorySections()');
    fprintf(fileH,'\n');
    fprintf(fileH,comments);
    fprintf(fileH,'\n\n');

    fprintf(fileH,'defs = []; \n\n');


    memorySections=setdiff(memorySections,{'Default','VAR','CAL','CONST',...
    'VOLATILE','CONST_VOLATILE'});
    for inx=1:length(memorySections)
        i_write_memory_section_def(fileH,memorySections{inx});
    end

    fclose(fileH);

end

function i_write_memory_section_def(fileH,memorySection)

    fprintf(fileH,'h = Simulink.MemorySectionRefDefn; \n');
    fprintf(fileH,['set(h, ''Name'', ''',memorySection,'''); \n']);
    fprintf(fileH,'set(h, ''OwnerPackage'', ''AUTOSAR4''); \n');
    fprintf(fileH,'set(h, ''RefPackageName'', ''AUTOSAR''); \n');
    fprintf(fileH,'set(h, ''RefDefnName'', ''SwAddrMethod''); \n');
    fprintf(fileH,'defs = [defs; h]; \n');
    fprintf(fileH,'\n');
end



