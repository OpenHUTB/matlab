function portListString=dpigenerator_getTbArgString(usecase)














    portListString='';
    SysInfo=dpigenerator_getcodeinfo();




    for i=1:SysInfo.NumInPorts
        if strcmp(usecase,'declare')
            portListString=[portListString,sprintf('\t\t')];
            portListString=[portListString,'output '];
            portListString=[portListString,dpigenerator_getSVDataType(SysInfo.InStruct(i).DataType)];
            portListString=[portListString,' ',SysInfo.InStruct(i).Name];
        elseif strcmp(usecase,'moduleinst')
            portListString=[portListString,sprintf('\t\t')];
            portListString=[portListString,'.',SysInfo.InStruct(i).Name];
            portListString=[portListString,'(',SysInfo.InStruct(i).Name,')'];
        elseif strcmp(usecase,'call')
            portListString=[portListString,sprintf('\t\t')];
            portListString=[portListString,SysInfo.InStruct(i).Name];
        end
        if i~=SysInfo.NumInPorts
            portListString=[portListString,',',sprintf('\n')];
        end
    end

    if SysInfo.NumOutPorts~=0
        portListString=[portListString,',',sprintf('\n')];
    end


    for i=1:SysInfo.NumOutPorts
        if strcmp(usecase,'declare')
            portListString=[portListString,sprintf('\t\t')];
            portListString=[portListString,'input '];
            portListString=[portListString,dpigenerator_getSVDataType(SysInfo.OutStruct(i).DataType)];
            portListString=[portListString,' ',SysInfo.OutStruct(i).Name];
        elseif strcmp(usecase,'moduleinst')
            portListString=[portListString,sprintf('\t\t')];
            portListString=[portListString,'.',SysInfo.OutStruct(i).Name];
            portListString=[portListString,'(',SysInfo.OutStruct(i).Name,')'];
        elseif strcmp(usecase,'call')
            portListString=[portListString,sprintf('\t\t')];
            portListString=[portListString,SysInfo.OutStruct(i).Name];
        end
        if i~=SysInfo.NumOutPorts
            portListString=[portListString,', ',sprintf('\n')];
        end
    end
