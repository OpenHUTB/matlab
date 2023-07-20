function generateMain(modelName)





    code_desc=coder.getCodeDescriptor(modelName);

    fiTypes=string(code_desc.getFunctionInterfaceTypes());
    if fiTypes(1)~="Initialize"||fiTypes(2)~="Output"||fiTypes(3)~="Terminate"

    end



    cppfile=fullfile(code_desc.BuildDir,'main.cpp');
    writer=rtw.connectivity.CodeWriter.create(...
    'callCBeautifier',false,...
    'filename',cppfile,...
    'append',false);

    writer.wComment(sprintf('Main generated for Simulink Real-Time model %s',...
    code_desc.ModelName));


    hasPageSwitchingSupport=slrealtime.internal.cal.ParameterServiceGenerator.hasPageSwitchingSupport(code_desc);
    include_headers(writer,code_desc,hasPageSwitchingSupport);


    writer.wLine("");
    writer.wComment("Task descriptors");
    [taskArrayStr,numTasks]=tasks(writer,code_desc);


    if hasPageSwitchingSupport
        pointerTablePtr='slrealtime::getSegmentVector()';
    else
        pointerTablePtr='slrealtime::SegmentVector()';
    end


    writer.wLine("");
    writer.wComment("Executable base address for XCP");
    writer.wLine("#ifdef __linux__");
    writer.wLine("extern char __executable_start;");
    writer.wLine("static uintptr_t const base_address = reinterpret_cast<uintptr_t>(&__executable_start);");
    writer.wLine("#else");
    writer.wComment("Set 0 as placeholder, to be parsed later from /proc filesystem");
    writer.wLine("static uintptr_t const base_address = 0;");
    writer.wLine("#endif");


    writer.wLine("");
    writer.wComment("Model descriptor");
    writer.wLine(sprintf('slrealtime::ModelInfo %s_Info =',code_desc.ModelName));
    writer.wLine("{");
    writer.incIndent();
    writer.wLine(sprintf('"%s",',code_desc.ModelName));
    writer.wLine(sprintf('%s,',code_desc.getFunctionInterfaces("Initialize").Prototype.Name));
    writer.wLine(sprintf('%s,',code_desc.getFunctionInterfaces("Terminate").Prototype.Name));
    writer.wLine(sprintf("[]()->char const*& { return %s_M->errorStatus; },",...
    code_desc.ModelName));
    writer.wLine(sprintf("[]()->unsigned char& { return %s_M->Timing.stopRequestedFlag; },",...
    code_desc.ModelName));
    writer.wLine(sprintf('%s,',taskArrayStr));
    writer.wLine('%s',pointerTablePtr);
    writer.decIndent();
    writer.wLine("};");


    writer.wLine("");
    writer.wBlockStart('int main(int argc, char *argv[])');
    writer.wLine("slrealtime::BaseAddress::set(base_address);");
    writer.wLine(sprintf("return slrealtime::runModel(argc, argv, %s_Info);",...
    code_desc.ModelName));
    writer.wBlockEnd();

end




function include_headers(writer,code_desc,hasPageSwitchingSupport)
    writer.wLine("#include <ModelInfo.hpp>");
    writer.wLine("#include <utilities.hpp>");

    headers=string.empty();
    functions=[code_desc.getFunctionInterfaces('Output'),...
    code_desc.getFunctionInterfaces('Initialize'),...
    code_desc.getFunctionInterfaces('Terminate')];

    for ii=1:length(functions)
        headers(ii)=convertCharsToStrings(functions(ii).Prototype.HeaderFile);
    end

    if hasPageSwitchingSupport
        modelName=code_desc.ModelName;
        headers(end)=slrealtime.internal.cal.ParameterServiceGenerator.getInterfaceFile(modelName);
    end

    if~isempty(headers)
        headers=unique(headers);
        for ii=1:length(headers)

            if strcmp(headers(ii),"")==1
                continue;
            end
            writer.wLine('#include "%s"',headers(ii));
        end
    end

end


function[taskArrayStr,numTasks]=tasks(writer,code_desc)
    ofun=code_desc.getFunctionInterfaces('Output');





    idx=1;
    while idx<=length(ofun)
        if isa(ofun(idx),"coder.descriptor.SimulinkFunctionInterface")||strcmp(ofun(idx).Timing.TimingMode,'RESETWITHINIT')==1
            ofun(idx)=[];
        else
            idx=idx+1;
        end
    end

    taskArrayStr="{ ";
    numTasks=length(ofun);


    numPeriodic=0;
    for ii=1:length(ofun)
        if strcmp(ofun(ii).Timing.TimingMode,'PERIODIC')==1
            numPeriodic=numPeriodic+1;
        end
    end

    for ii=1:length(ofun)


        if strcmp(ofun(ii).Timing.TimingMode,'ASYNCHRONOUS')==1
            ln=sprintf("extern void %s(void);",ofun(ii).Prototype.Name);
            writer.wLine(ln);
        end


        if strcmp(ofun(ii).Timing.TimingMode,'APERIODIC')==1
            continue
        end


        ln=sprintf("slrealtime::TaskInfo task_%u( ",ii);


        ln=ln+sprintf("%du, ",ofun(ii).Timing.TaskIndex);




        ln=ln+sprintf("std::bind(%s), ",...
        ofun(ii).Prototype.Name);


        ln=ln+sprintf("slrealtime::TaskInfo::%s, ",...
        string(ofun(ii).Timing.TimingMode));


        ln=ln+sprintf("%g, ",ofun(ii).Timing.SamplePeriod);


        ln=ln+sprintf("%g, ",ofun(ii).Timing.SampleOffset);


        ln=ln+sprintf("%d);",ofun(ii).Timing.Priority);
        writer.wLine(ln);

        if ii~=1
            taskArrayStr=taskArrayStr+", ";
        end
        taskArrayStr=taskArrayStr+sprintf("task_%u",ii);
    end
    taskArrayStr=taskArrayStr+" }";
end
