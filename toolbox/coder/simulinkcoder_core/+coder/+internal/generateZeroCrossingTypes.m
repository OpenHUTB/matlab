function[zcdefs_buf,zcdefs_macro]=generateZeroCrossingTypes






    simstruc_types_content=fileread(fullfile(matlabroot,'simulink','include','simstruc_types.h'));

    zcdefs_macro='ZERO_CROSSING_TYPES_H';




    zcdefs_buf=regexprep(simstruc_types_content,['.*?#define\s+',zcdefs_macro,'\s*'],'');


    zcdefs_buf=regexprep(zcdefs_buf,['\s*#endif\s*\/\*\s* ',zcdefs_macro,'.*'],'');


