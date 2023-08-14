classdef GpuEmxArrayExternalDependency<coder.ExternalDependency&coder.internal.JITSupportedExternalDependency
%#codegen



    methods(Static)

        function bName=getDescriptiveName(~)
            bName='GpuEmxArrayAPI';
        end

        function tf=isSupportedContext(~)
            tf=true;
        end

        function copyFileLines(srcFile,dstFile)
            fidRead=fopen(srcFile);
            fidWrite=fopen(dstFile,'w');
            txtLine=fgetl(fidRead);
            while ischar(txtLine)
                fprintf(fidWrite,'%s%s',txtLine,newline);
                txtLine=fgetl(fidRead);
            end
            fclose(fidRead);
            fclose(fidWrite);
        end

        function updateBuildInfo(buildInfo,buildContext)
            srcDir=fullfile(buildInfo.Settings.Matlabroot,'toolbox','gpucoder','gpucoder','src','cuda');
            dstDir=buildContext.getBuildDir();
            fileName='coder_gpu_array.h';
            dstFile=fullfile(dstDir,fileName);
            coder.internal.EmxArrayExternalDependency.copyFileLines(fullfile(srcDir,fileName),dstFile);
            buildInfo.addIncludeFiles(fileName,dstDir);
        end
    end
end
