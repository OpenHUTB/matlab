function code_model_header_file(fileNameInfo,modelName,buildInfo,auxInfo)



    import CGXE.Coder.*;

    fileName=fullfile(fileNameInfo.targetDirName,fileNameInfo.modelHeaderFile);

    file=fopen(fileName,'Wt');
    if file<0
        throw(MException('Simulink:cgxe:FailedToCreateFile',strrep(fileName,'\','\\')));
    end

    fprintf(file,'#ifndef __%s_cgxe_h__\n',modelName);
    fprintf(file,'#define __%s_cgxe_h__\n',modelName);

    fprintf(file,'\n');
    fprintf(file,'/* Include files */   \n');
    fprintf(file,'#include "simstruc.h"\n');
    fprintf(file,'#include "rtwtypes.h"\n');
    if strcmp(get_param(bdroot,'HasImageDataType'),'on')
        fprintf(file,'#include "image_type.h"\n');
    end
    fprintf(file,'#include "multiword_types.h"\n');
    fprintf(file,'#include "emlrt.h"\n');
    fprintf(file,'#include "covrt.h"\n');
    fprintf(file,'#include "cgxert.h"\n');
    fprintf(file,'#include "cgxeooprt.h"\n');
    fprintf(file,'#include "slccrt.h"\n');
    fprintf(file,'\n');
    if isfield(auxInfo,'includeFiles')
        for i=1:length(auxInfo.includeFiles)
            if auxInfo.includeFiles(i).FileName(1)=='<'
                delim='';
            else
                delim='"';
            end
            fprintf(file,'#include %s%s%s\n',delim,auxInfo.includeFiles(i).FileName,delim);
        end
    end
    fprintf(file,'\n');

    customCodeSettings=cgxeprivate('get_custom_code_settings',modelName);
    customCodeString=customCodeSettings.customCode;
    if~isempty(customCodeString)&&~fileNameInfo.hasSLCCCustomCode
        fprintf(file,'/* Custom Code from Simulation Target dialog*/\n');
        fprintf(file,'%s\n',customCodeString);
        fprintf(file,'\n');
    end
    fprintf(file,'#define rtInf (mxGetInf())\n');
    fprintf(file,'#define rtMinusInf (-(mxGetInf()))\n');
    fprintf(file,'#define rtNaN (mxGetNaN())\n');
    fprintf(file,'#define rtInfF ((real32_T)mxGetInf())\n');
    fprintf(file,'#define rtMinusInfF (-(real32_T)mxGetInf())\n');
    fprintf(file,'#define rtNaNF ((real32_T)mxGetNaN())\n');
    fprintf(file,'#define rtIsNaN(X) ((int)mxIsNaN(X))\n');
    fprintf(file,'#define rtIsInf(X) ((int)mxIsInf(X))\n');
    fprintf(file,'\n');
    fprintf(file,'extern unsigned int cgxe_%s_method_dispatcher(SimStruct* S, int_T method, void* data);\n',modelName);
    fprintf(file,'\n');






    fprintf(file,'#endif\n');
    fprintf(file,'	\n');

    fclose(file);
    try_indenting_file(fileName);

end

