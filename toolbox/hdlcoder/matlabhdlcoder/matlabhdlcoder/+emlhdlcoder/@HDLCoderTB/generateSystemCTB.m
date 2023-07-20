function generateSystemCTB(this,in,out,moduleName,codegenDirectory,testCases)
















    hppFileName=codegenDirectory+"/"+moduleName+"Class_tb"+".hpp";

    fileLink='### Generating test bench file: <a href="matlab:edit(''%s'')">%s</a>\n';
    fprintf(fileLink,hppFileName,moduleName+"Class_tb"+".hpp");

    hppFileID=fopen(hppFileName,'w');

    isXilinxVitisHLS=contains(this.hCgInfo.codegenSettings.SynthesisTool,'Xilinx Vitis HLS');
    if isXilinxVitisHLS
        typePrefix='ap_';
    else
        typePrefix='sc_';
    end

    fprintf(hppFileID,'#pragma once\n');
    fprintf(hppFileID,'#include <fstream>\n');
    fprintf(hppFileID,'#include "rtwtypes.hpp"\n');
    fprintf(hppFileID,'\n');


    fprintf(hppFileID,'struct input_struct {\n');
    for i=1:length(in)
        if(~in(i).isVector)
            fprintf(hppFileID,'\t%s %s;\n',in(i).type,in(i).name);
        else
            fprintf(hppFileID,'\t%s %s[%d];\n',in(i).type,in(i).name,in(i).dim);
        end
    end
    fprintf(hppFileID,'};\n');

    fprintf(hppFileID,'struct output_struct {\n');
    for i=1:length(out)
        if(~out(i).isVector)
            fprintf(hppFileID,'\t%s %s;\n',out(i).type,out(i).name);
        else
            fprintf(hppFileID,'\t%s %s[%d];\n',out(i).type,out(i).name,out(i).dim);
        end
    end
    fprintf(hppFileID,'};\n');


    fprintf(hppFileID,"class %s\n",moduleName+"Class_tb");
    fprintf(hppFileID,'{\n');
    fprintf(hppFileID,'private:\n');
    fprintf(hppFileID,'\tint num_test_cases;\n');
    fprintf(hppFileID,'\tint input_test_cases;\n');
    fprintf(hppFileID,'\tint output_test_cases;\n');
    fprintf(hppFileID,'\n');

    fprintf(hppFileID,"\tbool sim_passes;\n");
    fprintf(hppFileID,"\tbool stimuli_done;\n");
    fprintf(hppFileID,"\tbool checker_done;\n");
    fprintf(hppFileID,'\n');

    for i=1:length(in)
        if(~in(i).isConst)
            fprintf(hppFileID,'\tstd::ifstream fstream_%s;\n',in(i).name);
        end
    end

    for i=1:length(out)
        if(~out(i).isConst)
            fprintf(hppFileID,'\tstd::ifstream fstream_%s;\n',out(i).name);
        end
    end


    fprintf(hppFileID,'\n');
    fprintf(hppFileID,'public:\n');
    fprintf(hppFileID,"\t%s()\n",moduleName+"Class_tb");
    fprintf(hppFileID,'\t{\n');
    fprintf(hppFileID,'\t\tnum_test_cases = %d;\n',testCases);
    fprintf(hppFileID,'\t\tinput_test_cases = 0;\n');
    fprintf(hppFileID,'\t\toutput_test_cases = 0;\n');
    fprintf(hppFileID,'\n');
    fprintf(hppFileID,'\t\tsim_passes = true;\n');
    fprintf(hppFileID,'\t\tstimuli_done = false;\n');
    fprintf(hppFileID,'\t\tchecker_done = false;\n');
    fprintf(hppFileID,'\n');
    for i=1:length(in)
        if(~in(i).isConst)
            fprintf(hppFileID,'\t\tfstream_%s.open("%s.dat");\n',in(i).name,in(i).name);
        end
    end
    for i=1:length(out)
        if(~out(i).isConst)
            fprintf(hppFileID,'\t\tfstream_%s.open("%s_expected.dat");\n',out(i).name,out(i).name);
        end
    end
    fprintf(hppFileID,'\t}\n');

    fprintf(hppFileID,"\t~%s()\n",moduleName+"Class_tb");
    fprintf(hppFileID,'\t{\n');
    for i=1:length(in)
        if(~in(i).isConst)
            fprintf(hppFileID,'\t\tfstream_%s.close();\n',in(i).name);
        end
    end
    for i=1:length(out)
        if(~out(i).isConst)
            fprintf(hppFileID,'\t\tfstream_%s.close();\n',out(i).name);
        end
    end
    fprintf(hppFileID,'\t}\n');

    fprintf(hppFileID,'\n');
    fprintf(hppFileID,"\tbool is_sim_passing()\n");
    fprintf(hppFileID,'\t{\n');
    fprintf(hppFileID,'\t\treturn sim_passes;\n');
    fprintf(hppFileID,'\t}\n');
    fprintf(hppFileID,'\n');
    fprintf(hppFileID,"\tbool is_stimuli_done()\n");
    fprintf(hppFileID,'\t{\n');
    fprintf(hppFileID,'\t\treturn stimuli_done;\n');
    fprintf(hppFileID,'\t}\n');
    fprintf(hppFileID,'\n');
    fprintf(hppFileID,"\tbool is_checker_done()\n");
    fprintf(hppFileID,'\t{\n');
    fprintf(hppFileID,'\t\treturn checker_done;\n');
    fprintf(hppFileID,'\t}\n');
    fprintf(hppFileID,'\n');
    fprintf(hppFileID,"\tvoid print_pass_fail()\n");
    fprintf(hppFileID,'\t{\n');
    fprintf(hppFileID,'\t\tif(sim_passes) {\n');
    fprintf(hppFileID,'\t\t\tstd::cout << "**************TEST COMPLETED (PASSED)**************" << std::endl;\n');
    fprintf(hppFileID,'\t\t}\n');
    fprintf(hppFileID,'\t\telse {\n');
    fprintf(hppFileID,'\t\t\tstd::cout << "**************TEST COMPLETED (FAILED)**************" << std::endl;\n');
    fprintf(hppFileID,'\t\t}\n');
    fprintf(hppFileID,'\t}\n');





    fprintf(hppFileID,'\tvoid generate_stimulus(input_struct& in)\n');
    fprintf(hppFileID,'\t{\n');
    for i=1:length(in)
        if(in(i).isConst)
            if(in(i).isVector)
                for j=1:in(i).dim
                    fprintf(hppFileID,'\t\t%s %s_loc_%d;\n',in(i).type,in(i).name,j-1);
                    if in(i).isIntType
                        fprintf(hppFileID,'\t\t%s_loc_%d = %sbiguint<128>("0x%s");\n',in(i).name,j-1,typePrefix,in(i).val(j,:));
                    else
                        fprintf(hppFileID,'\t\t%s_loc_%d.range() = %sbiguint<128>("0x%s");\n',in(i).name,j-1,typePrefix,in(i).val(j,:));
                    end
                    fprintf(hppFileID,'\t\tin.%s[%d] = %s_loc_%d;\n',in(i).name,j-1,in(i).name,j-1);
                    fprintf(hppFileID,'\n');
                end
            else
                fprintf(hppFileID,'\t\t%s %s_loc;\n',in(i).type,in(i).name);
                if in(i).isIntType
                    fprintf(hppFileID,'\t\t%s_loc = %sbiguint<128>("0x%s");\n',in(i).name,typePrefix,in(i).val(:));
                else
                    fprintf(hppFileID,'\t\t%s_loc.range() = %sbiguint<128>("0x%s");\n',in(i).name,typePrefix,in(i).val(:));
                end
                fprintf(hppFileID,'\t\tin.%s = %s_loc;\n',in(i).name,in(i).name);
                fprintf(hppFileID,'\n');
            end
        end
    end

    for i=1:length(in)
        if(~in(i).isConst)
            if(in(i).isVector)
                fprintf(hppFileID,'\t\tfor (int j = 0; j < %d; j++) {\n',in(i).dim);
                fprintf(hppFileID,'\t\t\tstd::string %s_ref_str;\n',in(i).name);
                fprintf(hppFileID,'\t\t\tfstream_%s >> %s_ref_str;\n',in(i).name,in(i).name);
                fprintf(hppFileID,'\t\t\t%s_ref_str = "0x" + %s_ref_str;\n',in(i).name,in(i).name);
                fprintf(hppFileID,'\t\t\t%sbiguint<128> %s_ref = %s_ref_str.c_str();\n',typePrefix,in(i).name,in(i).name);
                fprintf(hppFileID,'\t\t\t%s %s_loc;\n',in(i).type,in(i).name);
                if in(i).isIntType
                    fprintf(hppFileID,'\t\t\t%s_loc = %s_ref;\n',in(i).name,in(i).name);
                else
                    fprintf(hppFileID,'\t\t\t%s_loc.range() = %s_ref;\n',in(i).name,in(i).name);
                end
                fprintf(hppFileID,'\t\t\tin.%s[j] = %s_loc;\n',in(i).name,in(i).name);
                fprintf(hppFileID,'\t\t}\n');
            else
                fprintf(hppFileID,'\t\tstd::string %s_ref_str;\n',in(i).name);
                fprintf(hppFileID,'\t\tfstream_%s >> %s_ref_str;\n',in(i).name,in(i).name);
                fprintf(hppFileID,'\t\t%s_ref_str = "0x" + %s_ref_str;\n',in(i).name,in(i).name);
                fprintf(hppFileID,'\t\t%sbiguint<128> %s_ref = %s_ref_str.c_str();\n',typePrefix,in(i).name,in(i).name);
                fprintf(hppFileID,'\t\t%s %s_loc;\n',in(i).type,in(i).name);
                if in(i).isIntType
                    fprintf(hppFileID,'\t\t%s_loc = %s_ref;\n',in(i).name,in(i).name);
                else
                    fprintf(hppFileID,'\t\t%s_loc.range() = %s_ref;\n',in(i).name,in(i).name);
                end
                fprintf(hppFileID,'\t\tin.%s = %s_loc;\n',in(i).name,in(i).name);
            end
        end
        fprintf(hppFileID,'\n');
    end
    fprintf(hppFileID,'\t\tinput_test_cases++;\n');
    fprintf(hppFileID,'\t\tif (input_test_cases == num_test_cases)\n');
    fprintf(hppFileID,'\t\t{\n');
    fprintf(hppFileID,'\t\t\tstimuli_done = true;\n');
    fprintf(hppFileID,'\t\t}\n');
    fprintf(hppFileID,'\t}\n');

    fprintf(hppFileID,'\tvoid check_output(output_struct& out)\n');
    fprintf(hppFileID,'\t{\n');
    for i=1:length(out)
        if(out(i).isVector)
            fprintf(hppFileID,'\n');
            if out(i).isConst
                fprintf(hppFileID,'\t\t%s %s_ref[%d];\n',out(i).type,out(i).name,out(i).dim);
                for j=1:out(i).dim
                    if out(i).isIntType
                        fprintf(hppFileID,'\t\t%s_ref[%d] = %sbiguint<128>("0x%s");\n',out(i).name,j-1,typePrefix,out(i).val(j,:));
                    else
                        fprintf(hppFileID,'\t\t%s_ref[%d].range() = %sbiguint<128>("0x%s");\n',out(i).name,j-1,typePrefix,out(i).val(j,:));
                    end
                end
            end
            fprintf(hppFileID,'\n');
            fprintf(hppFileID,'\t\tfor (int i = 0; i < %d; i++) {\n',out(i).dim);
            if~out(i).isConst
                fprintf(hppFileID,'\t\t\tstd::string %s_ref_str;\n',out(i).name);
                fprintf(hppFileID,'\t\t\tfstream_%s >> %s_ref_str;\n',out(i).name,out(i).name);
                fprintf(hppFileID,'\t\t\t%s_ref_str = "0x" + %s_ref_str;\n',out(i).name,out(i).name);
                fprintf(hppFileID,'\t\t\t%s %s_ref;\n',out(i).type,out(i).name);
                if out(i).isIntType
                    fprintf(hppFileID,'\t\t\t%s_ref = %sbiguint<128>(%s_ref_str.c_str());\n',out(i).name,typePrefix,out(i).name);
                else
                    fprintf(hppFileID,'\t\t\t%s_ref.range() = %sbiguint<128>(%s_ref_str.c_str());\n',out(i).name,typePrefix,out(i).name);
                end
            end
            if out(i).isIntType
                fprintf(hppFileID,'\t\t\t%s %s_act = out.%s[i];\n',out(i).type,out(i).name,out(i).name);
            else
                fprintf(hppFileID,'\t\t\t%s %s_act = out.%s[i];\n',out(i).type,out(i).name,out(i).name);
            end
            if out(i).isConst
                fprintf(hppFileID,'\t\t\tif (%s_act != %s_ref[i]) {\n',out(i).name,out(i).name);
            else
                fprintf(hppFileID,'\t\t\tif (%s_act != %s_ref) {\n',out(i).name,out(i).name);
            end
            fprintf(hppFileID,'\t\t\t\tsim_passes = false;\n');
            fprintf(hppFileID,'\t\t\t\tstd::cout << "** INCORRECT ** " << std::endl;\n');
            if isXilinxVitisHLS
                fprintf(hppFileID,'\t\t\t\tstd::cout << "ERROR in %s" << std::endl;\n',out(i).name);
            else
                fprintf(hppFileID,'\t\t\tstd::cout << "ERROR in %s at time " << sc_simulation_time() << std::endl;\n',out(i).name);
            end
            if out(i).isConst
                fprintf(hppFileID,'\t\t\t\tstd::cout << "Expected: " << std::hex << %s_ref[i] << std::endl;\n',out(i).name);
            else
                fprintf(hppFileID,'\t\t\t\tstd::cout << "Expected: " << std::hex << %s_ref << std::endl;\n',out(i).name);
            end
            fprintf(hppFileID,'\t\t\t\tstd::cout << "Actual: " << %s_act << std::endl;\n',out(i).name);
            fprintf(hppFileID,'\t\t\t\tstd::cout << std::endl;\n');
            fprintf(hppFileID,'\t\t\t}\n');
            fprintf(hppFileID,'\t\t}\n');
        else
            fprintf(hppFileID,'\n');
            fprintf(hppFileID,'\t\t%s %s_ref;\n',out(i).type,out(i).name);
            if out(i).isConst
                if out(i).isIntType
                    fprintf(hppFileID,'\t\t%s_ref = %sbiguint<128>("0x%s");\n',out(i).name,typePrefix,out(i).val(:));
                else
                    fprintf(hppFileID,'\t\t%s_ref.range() = %sbiguint<128>("0x%s");\n',out(i).name,typePrefix,out(i).val(:));
                end
            else
                fprintf(hppFileID,'\t\tstd::string %s_ref_str;\n',out(i).name);
                fprintf(hppFileID,'\t\tfstream_%s >> %s_ref_str;\n',out(i).name,out(i).name);
                fprintf(hppFileID,'\t\t%s_ref_str = "0x" + %s_ref_str;\n',out(i).name,out(i).name);
                if out(i).isIntType
                    fprintf(hppFileID,'\t\t%s_ref = %sbiguint<128>(%s_ref_str.c_str());\n',out(i).name,typePrefix,out(i).name);
                else
                    fprintf(hppFileID,'\t\t%s_ref.range() = %sbiguint<128>(%s_ref_str.c_str());\n',out(i).name,typePrefix,out(i).name);
                end
            end
            if out(i).isIntType
                fprintf(hppFileID,'\t\t%s %s_act = out.%s;\n',out(i).type,out(i).name,out(i).name);
            else
                fprintf(hppFileID,'\t\t%s %s_act = out.%s;\n',out(i).type,out(i).name,out(i).name);
            end
            fprintf(hppFileID,'\t\tif (%s_act != %s_ref) {\n',out(i).name,out(i).name);
            fprintf(hppFileID,'\t\t\tsim_passes = false;\n');
            fprintf(hppFileID,'\t\t\tstd::cout << "** INCORRECT ** " << std::endl;\n');
            if isXilinxVitisHLS
                fprintf(hppFileID,'\t\t\tstd::cout << "ERROR in %s " << std::endl;\n',out(i).name);
            else
                fprintf(hppFileID,'\t\t\tstd::cout << "ERROR in %s at time " << sc_simulation_time() << std::endl;\n',out(i).name);
            end
            fprintf(hppFileID,'\t\t\tstd::cout << "Expected: " << std::hex << %s_ref << std::endl;\n',out(i).name);
            fprintf(hppFileID,'\t\t\tstd::cout << "Actual: " << %s_act << std::endl;\n',out(i).name);
            fprintf(hppFileID,'\t\t\tstd::cout << std::endl;\n');
            fprintf(hppFileID,'\t\t}\n');
        end
    end
    fprintf(hppFileID,'\t\toutput_test_cases++;\n');
    fprintf(hppFileID,'\t\tif (output_test_cases == num_test_cases)\n');
    fprintf(hppFileID,'\t\t{\n');
    fprintf(hppFileID,'\t\t\tchecker_done = true;\n');
    fprintf(hppFileID,'\t\t}\n');
    fprintf(hppFileID,'\t}\n');
    fprintf(hppFileID,'};');

    fclose(hppFileID);


    c_beautifier(convertStringsToChars(hppFileName));


    if contains(this.hCgInfo.codegenSettings.SynthesisTool,'Xilinx Vitis HLS')
        generateMainFcn(codegenDirectory,moduleName,this.hCgInfo.TopFunctionName,in,out);
    end
end

function generateMainFcn(codegenDirectory,moduleName,topFcnName,inputs,outputs)
    mainFcnFileName=fullfile(codegenDirectory,moduleName+"_main"+".cpp");
    fileLink='### Generating main function file: <a href="matlab:edit(''%s'')">%s</a>\n';
    fprintf(fileLink,mainFcnFileName,moduleName+"_main"+".cpp");

    mainFcnID=fopen(mainFcnFileName,'w');
    fprintf(mainFcnID,'#include "%sClass.hpp"\n',moduleName);
    fprintf(mainFcnID,'#include "%sClass_tb.hpp"\n',moduleName);
    fprintf(mainFcnID,'\n');
    fprintf(mainFcnID,'int main() {\n');
    fprintf(mainFcnID,'\t%sClass_tb tb;\n',moduleName);
    fprintf(mainFcnID,'\tinput_struct inputs;\n');
    fprintf(mainFcnID,'\toutput_struct outputs;\n');
    fprintf(mainFcnID,'\twhile(!tb.is_stimuli_done()) {\n');
    fprintf(mainFcnID,'\t\ttb.generate_stimulus(inputs);\n');
    if size(outputs,2)==1&&~outputs(1).isVector
        fprintf(mainFcnID,'\t\toutputs.%s = %s_wrapper(',outputs(1).name,topFcnName);
        for inIndex=1:size(inputs,2)
            if inIndex~=1
                fprintf(mainFcnID,', ');
            end
            fprintf(mainFcnID,'inputs.%s',inputs(inIndex).name);
        end
    else
        fprintf(mainFcnID,'\t\t%s_wrapper(',topFcnName);
        for inIndex=1:size(inputs,2)
            if inIndex~=1
                fprintf(mainFcnID,', ');
            end
            fprintf(mainFcnID,'inputs.%s',inputs(inIndex).name);
        end

        for outIndex=1:size(outputs,2)
            fprintf(mainFcnID,', outputs.%s',outputs(outIndex).name);
        end
    end
    fprintf(mainFcnID,');\n');
    fprintf(mainFcnID,'\t\ttb.check_output(outputs);\n');
    fprintf(mainFcnID,'\t}\n');
    fprintf(mainFcnID,'\ttb.print_pass_fail();\n');
    fprintf(mainFcnID,'\tif (tb.is_sim_passing()) { return 0; }\n');
    fprintf(mainFcnID,'\telse { return 1; }\n');
    fprintf(mainFcnID,'}\n');

    fclose(mainFcnID);


    c_beautifier(convertStringsToChars(mainFcnFileName));
end
