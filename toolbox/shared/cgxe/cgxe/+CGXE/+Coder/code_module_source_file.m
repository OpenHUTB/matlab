function code_module_source_file(targetDirName,md5ChecksumStr,modelName,fallbackInfo,gencpp)



    import CGXE.Coder.*;

    moduleFileName=['m_',md5ChecksumStr];

    if gencpp
        ext='.cpp';
        headerext='.hpp';
    else
        ext='.c';
        headerext='.h';
    end
    fileName=fullfile(targetDirName,[moduleFileName,ext]);


    file=fopen(fileName,'Wt');
    if file<0
        throw(MException('Simulink:cgxe:FailedToCreateFile',fileName));
    end

    fprintf(file,'/* Include files */\n');
    fprintf(file,'#include "modelInterface.h"\n');
    fprintf(file,'#include "%s"\n',[moduleFileName,headerext]);

    tfl=get_param(modelName,'SimTargetFcnLibHandle');
    tflHeaders=tfl.getRecordedUsedHeaders;
    for fileIdx=1:length(tflHeaders)



        if strcmp(tflHeaders{fileIdx},'"sfc_mex.h"')
            continue;
        end
        fprintf(file,'#include %s\n',tflHeaders{fileIdx});
    end
    tfl.resetUsageCounts;
    fprintf(file,'\n');

    file=dump_module(fileName,file,md5ChecksumStr,'source',modelName);
    if file<0
        return;
    end

    file=glue_module_code(md5ChecksumStr,file,fallbackInfo,modelName);

    fclose(file);
    try_indenting_file(fileName);
