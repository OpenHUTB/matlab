function[objExt,objAssemblerExt]=getObjectFileExtension(targetLanguage,tcInfo)




    objAssemblerExt='';

    if isempty(tcInfo)

        if ispc
            objExt='.obj';
        else
            objExt='.o';
        end
    else

        if any(strcmp(targetLanguage,{'C++','C++ (Encapsulated)'}))
            buildtool=tcInfo.getBuildTool('C++ Compiler');
        else
            buildtool=tcInfo.getBuildTool('C Compiler');
        end
        objExt=buildtool.getFileExtension('Object');

        hasAssmblerBuildTool=any(strcmp(tcInfo.getBuildTools,'Assembler'));
        if hasAssmblerBuildTool
            buildtoolAssembler=tcInfo.getBuildTool('Assembler');
            objAssemblerExt=buildtoolAssembler.getFileExtension('Object');
        end
    end
end
