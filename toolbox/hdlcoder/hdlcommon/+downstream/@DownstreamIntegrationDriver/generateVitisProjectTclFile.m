function generateVitisProjectTclFile(this,vitisHLSPrjName,stage)




    codegenDirectory=this.hCodeGen.CodegenDir;
    moduleName=this.hCodeGen.EntityTop;
    if contains(stage,'simulation')
        scriptTclFileName=fullfile(codegenDirectory,'sim_script.tcl');
    elseif contains(stage,'synthesis')
        scriptTclFileName=fullfile(codegenDirectory,'syn_script.tcl');
    end

    if contains(stage,'simulation')
        fileLink='### Generating sim_script.tcl file: <a href="matlab:edit(''%s'')">%s</a>\n';
        fprintf(fileLink,scriptTclFileName,'sim_script.tcl');
    elseif contains(stage,'synthesis')
        fileLink='### Generating syn_script.tcl file: <a href="matlab:edit(''%s'')">%s</a>\n';
        fprintf(fileLink,scriptTclFileName,'syn_script.tcl');
    end

    scriptTclFileID=fopen(scriptTclFileName,'w');
    fprintf(scriptTclFileID,'open_project %s\n',vitisHLSPrjName);
    fprintf(scriptTclFileID,'set_top %s_wrapper\n',this.hCodeGen.getDutName);
    fprintf(scriptTclFileID,'add_files %sClass.hpp\n',moduleName);
    fprintf(scriptTclFileID,'add_files rtwtypes.hpp\n');
    fprintf(scriptTclFileID,'add_files %s_wrapper.cpp\n',moduleName);
    if this.hCodeGen.hCHandle.cgInfo.HDLConfig.GenerateHDLTestBench
        fprintf(scriptTclFileID,'add_files -tb %sClass_tb.hpp\n',moduleName);
        fprintf(scriptTclFileID,'add_files -tb %s_main.cpp\n',moduleName);
        fileList=dir(codegenDirectory);
        fileList=regexp({fileList.name},'.*.dat','match');
        datFileList=[fileList{:}];
        for i=1:size(datFileList,2)
            fprintf(scriptTclFileID,'add_files -tb %s\n',datFileList{i});
        end
    end
    fprintf(scriptTclFileID,'open_solution "solution1" -flow_target vivado\n');
    if contains(stage,'synthesis')
        fprintf(scriptTclFileID,'set_part xcvu11p-flga2577-1-e\n');
    end
    fprintf(scriptTclFileID,'create_clock -period 10 -name default\n');

    if contains(stage,'simulation')
        fprintf(scriptTclFileID,'csim_design\n');
    elseif contains(stage,'synthesis')
        fprintf(scriptTclFileID,'csynth_design\n');
    end
    fprintf(scriptTclFileID,'close_project\n');

    fclose(scriptTclFileID);
end
