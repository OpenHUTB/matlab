function code_module_header_file(targetDirName,md5ChecksumStr,modelName,codingOpenMP,gencpp)



    import CGXE.Coder.*;

    moduleFileName=['m_',md5ChecksumStr];


    if gencpp
        ext='.hpp';
    else
        ext='.h';
    end
    fileName=fullfile(targetDirName,[moduleFileName,ext]);

    file=fopen(fileName,'Wt');
    if file<0
        throw(MException('Simulink:cgxe:FailedToCreateFile',fileName));
    end

    fprintf(file,'#ifndef __%s_h__\n',md5ChecksumStr);
    fprintf(file,'#define __%s_h__\n',md5ChecksumStr);
    fprintf(file,'\n');
    fprintf(file,'/* Include files */\n');
    fprintf(file,'#include "simstruc.h"\n');
    fprintf(file,'#include "rtwtypes.h"\n');
    fprintf(file,'#include "multiword_types.h"\n');
    fprintf(file,'#include "slexec_vm_zc_functions.h"\n');
    fprintf(file,'#include "slexec_vm_simstruct_bridge.h"\n');

    fprintf(file,'#include "sl_sfcn_cov/sl_sfcn_cov_bridge.h"\n');

    if codingOpenMP
        if~ismac
            fprintf(file,'#include <omp.h>\n');
        else
            fprintf(file,'#include <dispatch/dispatch.h>\n');
        end
    end
    fprintf(file,'\n');

    file=dump_module(fileName,file,md5ChecksumStr,'header',modelName);
    if file<0
        return;
    end

    fprintf(file,'extern void method_dispatcher_%s(SimStruct *S, int_T method, void* data);\n',md5ChecksumStr);
    fprintf(file,'\n');
    fprintf(file,'#endif\n');
    fprintf(file,'\n');

    fclose(file);
    try_indenting_file(fileName);
