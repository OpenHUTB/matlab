function genWrapperHeaderAndSource(modelName,customCodeSettings,settingsChecksum,fcnList,isDebuggerSupported)



    persistent builtinDataTypes;

    if isempty(builtinDataTypes)
        builtinDataTypes=containers.Map({'double','single','int8','int16','int32','uint8','uint16','uint32','boolean','int64','uint64'},...
        {false,false,false,false,false,false,false,false,false,false,false});
    end

    indentL1='    ';
    indentL2=[indentL1,indentL1];
    indentL3=[indentL1,indentL2];
    indentL4=[indentL1,indentL3];

    isCPP=customCodeSettings.isCpp;


    dataTypeMap=containers.Map({'double','single','int8','int16','int32','uint8','uint16','uint32','boolean','int64','uint64','char','void'},...
    {'real_T','real32_T','int8_T','int16_T','int32_T','uint8_T','uint16_T','uint32_T','boolean_T','int64_T','uint64_T','char_T','uint8_T'});

    interfaceHeaderFile=[settingsChecksum,'_interface.h'];
    if isCPP
        interfaceSourceFile=[settingsChecksum,'_interface.cpp'];
    else
        interfaceSourceFile=[settingsChecksum,'_interface.c'];
    end


    enum_list_nonCTag={};
    struct_list_nonCTag={};
    enum_list_CTag={};
    struct_list_CTag={};
    for idx=1:length(fcnList)
        for argIdx=1:length(fcnList(idx).ArgsInfo)
            if fcnList(idx).ArgsInfo(argIdx).ArgBaseTypeCat==1
                if fcnList(idx).ArgsInfo(argIdx).ArgBaseTypeFromCTag==1
                    enum_list_CTag=[enum_list_CTag,{fcnList(idx).ArgsInfo(argIdx).ArgCBaseType}];
                else
                    enum_list_nonCTag=[enum_list_nonCTag,{fcnList(idx).ArgsInfo(argIdx).ArgCBaseType}];
                end
            elseif fcnList(idx).ArgsInfo(argIdx).ArgBaseTypeCat==2
                if fcnList(idx).ArgsInfo(argIdx).ArgBaseTypeFromCTag==1
                    struct_list_CTag=[struct_list_CTag,{fcnList(idx).ArgsInfo(argIdx).ArgCBaseType}];
                else
                    struct_list_nonCTag=[struct_list_nonCTag,{fcnList(idx).ArgsInfo(argIdx).ArgCBaseType}];
                end
            end
        end
    end
    enum_list_nonCTag=unique(enum_list_nonCTag,'stable');
    struct_list_nonCTag=unique(struct_list_nonCTag,'stable');
    enum_list_CTag=unique(enum_list_CTag,'stable');
    struct_list_CTag=unique(struct_list_CTag,'stable');

    for idx=1:length(enum_list_nonCTag)
        dataTypeMap(enum_list_nonCTag{idx})=enum_list_nonCTag{idx};
    end
    for idx=1:length(struct_list_nonCTag)
        dataTypeMap(struct_list_nonCTag{idx})=struct_list_nonCTag{idx};
    end

    for idx=1:length(enum_list_CTag)
        dataTypeMap(enum_list_CTag{idx})=['enum ',enum_list_CTag{idx}(1:end-5)];
    end
    for idx=1:length(struct_list_CTag)
        dataTypeMap(struct_list_CTag{idx})=['struct ',struct_list_CTag{idx}(1:end-5)];
    end

    struct_list=[struct_list_nonCTag,struct_list_CTag];


    fid=fopen(interfaceHeaderFile,'Wt','n',slCharacterEncoding);
    fprintf(fid,'#include "rtwtypes.h"\n\n');
    fprintf(fid,'/* Custom Code from Simulation Target dialog */\n%s\n\n',customCodeSettings.customCode);

    fclose(fid);


    fid=fopen(interfaceSourceFile,'Wt','n',slCharacterEncoding);
    fprintf(fid,'/* Interface file for out-of-process execution of library:\n * %s\n */\n\n',settingsChecksum);
    fprintf(fid,'#include "xil_interface.h"\n#include "xil_data_stream.h"\n\n');
    fprintf(fid,'#include "%s"\n\n',interfaceHeaderFile);
    fprintf(fid,'#include <stdlib.h>\n\n');
    if~isempty(struct_list)
        fprintf(fid,'#include <string.h>\n\n');
    end

    if~isempty(customCodeSettings.customSourceCode)
        fprintf(fid,'/* Custom Source Code */\n%s\n\n',customCodeSettings.customSourceCode);
    end


    initFcnName=['customcode_',settingsChecksum,'_initializer'];
    termFcnName=['customcode_',settingsChecksum,'_terminator'];
    isAllowToDebugFcnName=['customcode_',settingsChecksum,'_isdebug'];
    fprintf(fid,'/* Function Init/Term */\n');
    fprintf(fid,'void %s(void)\n',initFcnName);
    fprintf(fid,'{\n');
    if~isempty(customCodeSettings.customInitializer)
        fprintf(fid,'   %s\n',customCodeSettings.customInitializer);
    end
    fprintf(fid,'}\n');
    fprintf(fid,'\n');

    fprintf(fid,'void %s(void)\n',termFcnName);
    fprintf(fid,'{\n');
    if~isempty(customCodeSettings.customTerminator)
        fprintf(fid,'   %s\n',customCodeSettings.customTerminator);
    end
    fprintf(fid,'}\n');
    fprintf(fid,'\n');

    fprintf(fid,'/* Function isDebug */\n');
    fprintf(fid,'boolean_T %s(void)\n',isAllowToDebugFcnName);
    fprintf(fid,'{\n');
    if isDebuggerSupported
        fprintf(fid,'   return true;\n');
    else
        fprintf(fid,'   return false;\n');
    end
    fprintf(fid,'}\n');
    fprintf(fid,'\n');

    fclose(fid);


    slcc('OOP_dumpAutoStubFcns',get_param(modelName,'handle'),interfaceSourceFile);


    slcc('OOP_dumpCPPWrappers',get_param(modelName,'handle'),interfaceSourceFile);

    fid=fopen(interfaceSourceFile,'At','n',slCharacterEncoding);


    fprintf(fid,'\n\nXIL_INTERFACE_ERROR_CODE xilInitTargetData()\n{\n');
    fprintf(fid,[indentL1,'return XIL_INTERFACE_SUCCESS;\n}\n\n']);


    fprintf(fid,'\n\nXIL_INTERFACE_ERROR_CODE xilGetHostToTargetData(uint32_T xilFcnId, XIL_COMMAND_TYPE_ENUM xilCommandType, uint32_T xilCommandIdx, XILIOData **xilIOData)\n{\n');
    fprintf(fid,[indentL1,'UNUSED_PARAMETER(xilFcnId);\n',indentL1,'UNUSED_PARAMETER(xilCommandType);\n',indentL1,'UNUSED_PARAMETER(xilCommandIdx);\n',indentL1,'UNUSED_PARAMETER(xilIOData);\n\n',...
    indentL1,'return XIL_INTERFACE_UNKNOWN_TID;\n}\n\n']);



    fprintf(fid,['XIL_INTERFACE_ERROR_CODE xilOutput(uint32_T xilFcnId, uint32_T xilTID)\n{\n',indentL1,'UNUSED_PARAMETER(xilTID);\n\n',indentL1,'static uint32_T sizeData = (uint32_T) sizeof(uint32_T);\n',...
    indentL1,'static uint32_T sizeScopeID = (uint32_T) sizeof(uint8_T);\n\n',indentL1,'switch (xilFcnId) {\n']);

    for idx=1:length(fcnList)
        fprintf(fid,[indentL1,'case %d:\n',indentL1,'{'],idx-1);
        for argIdx=1:length(fcnList(idx).ArgsInfo)
            fprintf(fid,['\n',indentL2,'uint32_T dataWidth_',fcnList(idx).ArgsInfo(argIdx).ArgName,' = 0;\n']);
            fprintf(fid,[indentL2,'xilReadData((MemUnit_T *) &dataWidth_',fcnList(idx).ArgsInfo(argIdx).ArgName,', sizeData);\n']);
            fprintf(fid,[indentL2,'uint8_T scopeID_',fcnList(idx).ArgsInfo(argIdx).ArgName,' = 0;\n']);
            fprintf(fid,[indentL2,'xilReadData((MemUnit_T *) &scopeID_',fcnList(idx).ArgsInfo(argIdx).ArgName,', sizeScopeID);\n']);


            isReturnByRef=fcnList(idx).ArgsInfo(argIdx).ArgPtrArrayInfo==4&&fcnList(idx).ArgsInfo(argIdx).IsReturnArg;

            isFcnClassPassByRefOrPtr=~isempty(fcnList(idx).ArgsInfo(argIdx).ClassArgCast);

            if fcnList(idx).ArgsInfo(argIdx).ArgPtrArrayInfo==0||isReturnByRef||isFcnClassPassByRefOrPtr
                if fcnList(idx).ArgsInfo(argIdx).ArgBaseTypeCat==0
                    fprintf(fid,[indentL2,dataTypeMap(fcnList(idx).ArgsInfo(argIdx).ArgCBaseType),' ',fcnList(idx).ArgsInfo(argIdx).ArgName,' = 0;\n']);
                    if~fcnList(idx).ArgsInfo(argIdx).IsReturnArg
                        fprintf(fid,[indentL2,'xilReadData((MemUnit_T *) &',fcnList(idx).ArgsInfo(argIdx).ArgName,', (uint32_T) sizeof(',dataTypeMap(fcnList(idx).ArgsInfo(argIdx).ArgCBaseType),'));\n']);
                    end
                elseif fcnList(idx).ArgsInfo(argIdx).ArgBaseTypeCat==1
                    fprintf(fid,[indentL2,dataTypeMap(fcnList(idx).ArgsInfo(argIdx).ArgCBaseType),' ',fcnList(idx).ArgsInfo(argIdx).ArgName,';\n']);
                    if~fcnList(idx).ArgsInfo(argIdx).IsReturnArg
                        fprintf(fid,[indentL2,'xilReadData((MemUnit_T *) &',fcnList(idx).ArgsInfo(argIdx).ArgName,', (uint32_T) sizeof(',dataTypeMap(fcnList(idx).ArgsInfo(argIdx).ArgCBaseType),'));\n']);
                    end
                elseif fcnList(idx).ArgsInfo(argIdx).ArgBaseTypeCat==2
                    fprintf(fid,[indentL2,dataTypeMap(fcnList(idx).ArgsInfo(argIdx).ArgCBaseType),' ',fcnList(idx).ArgsInfo(argIdx).ArgName,';\n']);
                    if~fcnList(idx).ArgsInfo(argIdx).IsReturnArg
                        fprintf(fid,[indentL2,'xilReadData((MemUnit_T *) &',fcnList(idx).ArgsInfo(argIdx).ArgName,', (uint32_T) sizeof(',dataTypeMap(fcnList(idx).ArgsInfo(argIdx).ArgCBaseType),'));\n']);
                    end
                end
            else
                fprintf(fid,[indentL2,dataTypeMap(fcnList(idx).ArgsInfo(argIdx).ArgCBaseType),' *',fcnList(idx).ArgsInfo(argIdx).ArgName,' = (',...
                dataTypeMap(fcnList(idx).ArgsInfo(argIdx).ArgCBaseType),' *) calloc((size_t) dataWidth_',...
                fcnList(idx).ArgsInfo(argIdx).ArgName,', sizeof(',dataTypeMap(fcnList(idx).ArgsInfo(argIdx).ArgCBaseType),'));\n']);
                if~fcnList(idx).ArgsInfo(argIdx).IsReturnArg
                    if fcnList(idx).ArgsInfo(argIdx).ArgFinalBaseTypeConstness
                        fprintf(fid,[indentL2,'xilReadData((MemUnit_T *) ',fcnList(idx).ArgsInfo(argIdx).ArgName,', dataWidth_',fcnList(idx).ArgsInfo(argIdx).ArgName,...
                        ' * ((uint32_T) sizeof(',dataTypeMap(fcnList(idx).ArgsInfo(argIdx).ArgCBaseType),')));\n']);
                    else
                        fprintf(fid,[indentL2,'if (scopeID_',fcnList(idx).ArgsInfo(argIdx).ArgName,' < 2) {\n']);
                        fprintf(fid,[indentL3,'xilReadData((MemUnit_T *) ',fcnList(idx).ArgsInfo(argIdx).ArgName,', dataWidth_',fcnList(idx).ArgsInfo(argIdx).ArgName,...
                        ' * ((uint32_T) sizeof(',dataTypeMap(fcnList(idx).ArgsInfo(argIdx).ArgCBaseType),')));\n',indentL2,'}\n']);
                    end
                end
            end
        end

        if~isempty(fcnList(idx).ArgsInfo)&&fcnList(idx).ArgsInfo(1).IsReturnArg
            fcnCallStatement=[fcnList(idx).ArgsInfo(1).ArgName,' = ',fcnList(idx).FunctionName,'('];
        else
            fcnCallStatement=[fcnList(idx).FunctionName,'('];
        end
        for argIdx=1:length(fcnList(idx).ArgsInfo)
            if fcnList(idx).ArgsInfo(argIdx).IsReturnArg
                continue;
            end

            argName=fcnList(idx).ArgsInfo(argIdx).ArgName;
            argPtrArrayInfo=fcnList(idx).ArgsInfo(argIdx).ArgPtrArrayInfo;
            if argPtrArrayInfo==2||argPtrArrayInfo==3
                assert(~isempty(fcnList(idx).ArgsInfo(argIdx).ArgArrayDims));
                if argPtrArrayInfo==2
                    startIdx=2;
                elseif argPtrArrayInfo==3
                    startIdx=1;
                end
                if startIdx<=length(fcnList(idx).ArgsInfo(argIdx).ArgArrayDims)
                    if fcnList(idx).ArgsInfo(argIdx).ArgFinalBaseTypeConstness
                        fcnCallStatement=[fcnCallStatement,'(const ',dataTypeMap(fcnList(idx).ArgsInfo(argIdx).ArgCBaseType),' (*)'];
                    else
                        fcnCallStatement=[fcnCallStatement,'(',dataTypeMap(fcnList(idx).ArgsInfo(argIdx).ArgCBaseType),' (*)'];
                    end
                    for arrIdx=startIdx:length(fcnList(idx).ArgsInfo(argIdx).ArgArrayDims)
                        fcnCallStatement=[fcnCallStatement,sprintf('[%d]',fcnList(idx).ArgsInfo(argIdx).ArgArrayDims(arrIdx))];
                    end
                    fcnCallStatement=[fcnCallStatement,') '];
                end
            end
            fcnCallStatement=[fcnCallStatement,argName];%#ok<*AGROW>  

            if argIdx~=length(fcnList(idx).ArgsInfo)
                fcnCallStatement=[fcnCallStatement,', '];
            end
        end
        fcnCallStatement=[fcnCallStatement,');'];
        fprintf(fid,['\n\n\n',indentL2,fcnCallStatement,'\n\n\n\n']);

        fprintf(fid,[indentL2,'MemUnit_T responseId = XIL_RESPONSE_OUTPUT_DATA;\n',...
        indentL2,'if (xilWriteData(&responseId, (uint32_T) sizeof(MemUnit_T)) != XIL_DATA_STREAM_SUCCESS) {\n',indentL3,'return XIL_INTERFACE_COMMS_FAILURE;\n',indentL2,'}\n\n']);

        for argIdx=1:length(fcnList(idx).ArgsInfo)
            if fcnList(idx).ArgsInfo(argIdx).IsReturnArg
                if fcnList(idx).ArgsInfo(argIdx).ArgPtrArrayInfo==0||fcnList(idx).ArgsInfo(argIdx).ArgPtrArrayInfo==4
                    fprintf(fid,[indentL2,'if (xilWriteData((MemUnit_T *) &',fcnList(idx).ArgsInfo(argIdx).ArgName,', (uint32_T) sizeof(',dataTypeMap(fcnList(idx).ArgsInfo(argIdx).ArgCBaseType),...
                    ')) != XIL_DATA_STREAM_SUCCESS) {\n',indentL3,'return XIL_INTERFACE_COMMS_FAILURE;\n',indentL2,'}\n\n']);
                else
                    fprintf(fid,[indentL2,'if (xilWriteData((MemUnit_T *) ',fcnList(idx).ArgsInfo(argIdx).ArgName,', dataWidth_',fcnList(idx).ArgsInfo(argIdx).ArgName,' * ((uint32_T) sizeof(',...
                    dataTypeMap(fcnList(idx).ArgsInfo(argIdx).ArgCBaseType),'))) != XIL_DATA_STREAM_SUCCESS) {\n',indentL3,'return XIL_INTERFACE_COMMS_FAILURE;\n',indentL2,'}\n\n']);
                end
            else
                if fcnList(idx).ArgsInfo(argIdx).ArgPtrArrayInfo~=0&&~fcnList(idx).ArgsInfo(argIdx).ArgFinalBaseTypeConstness&&~isFcnClassPassByRefOrPtr
                    fprintf(fid,[indentL2,'if (scopeID_',fcnList(idx).ArgsInfo(argIdx).ArgName,' > 0) {\n',...
                    indentL3,'if (xilWriteData((MemUnit_T *) ',fcnList(idx).ArgsInfo(argIdx).ArgName,', dataWidth_',fcnList(idx).ArgsInfo(argIdx).ArgName,' * ((uint32_T) sizeof(',...
                    dataTypeMap(fcnList(idx).ArgsInfo(argIdx).ArgCBaseType),'))) != XIL_DATA_STREAM_SUCCESS) {\n',...
                    indentL4,'return XIL_INTERFACE_COMMS_FAILURE;\n',indentL3,'}\n',indentL2,'}\n\n']);
                end
            end
        end

        for argIdx=1:length(fcnList(idx).ArgsInfo)

            isReturnByRef=fcnList(idx).ArgsInfo(argIdx).ArgPtrArrayInfo==4&&fcnList(idx).ArgsInfo(argIdx).IsReturnArg;
            isFcnClassPassByRefOrPtr=~isempty(fcnList(idx).ArgsInfo(argIdx).ClassArgCast);

            if fcnList(idx).ArgsInfo(argIdx).ArgPtrArrayInfo~=0&&~isReturnByRef&&~isFcnClassPassByRefOrPtr
                fprintf(fid,[indentL2,'free(',fcnList(idx).ArgsInfo(argIdx).ArgName,');\n']);
            end
        end

        fprintf(fid,['\n',indentL2,'break;\n',indentL1,'}\n\n']);
    end

    fprintf(fid,[indentL1,'default:\n',indentL2,'return XIL_INTERFACE_UNKNOWN_FCNID;\n',indentL1,'}\n\n',indentL1,'return XIL_INTERFACE_SUCCESS;\n}\n\n']);



    fprintf(fid,'XIL_INTERFACE_ERROR_CODE xilGetTargetToHostData(uint32_T xilFcnId, XIL_COMMAND_TYPE_ENUM xilCommandType, uint32_T xilCommandIdx, XILIOData **xilIOData, MemUnit_T responseId, uint32_T serverFcnId)\n{\n');
    fprintf(fid,[indentL1,'UNUSED_PARAMETER(xilFcnId);\n',indentL1,'UNUSED_PARAMETER(xilCommandType);\n',indentL1,'UNUSED_PARAMETER(xilCommandIdx);\n',indentL1,'UNUSED_PARAMETER(xilIOData);\n',indentL1,'UNUSED_PARAMETER(responseId);\n',indentL1,'UNUSED_PARAMETER(serverFcnId);\n\n',...
    indentL1,'return XIL_INTERFACE_UNKNOWN_TID;\n}\n\n']);


    fprintf(fid,'XIL_INTERFACE_ERROR_CODE xilGetTargetToHostPreData(uint32_T xilFcnId, XIL_COMMAND_TYPE_ENUM xilCommandType, uint32_T xilCommandIdx, XILIOData **xilIOData, MemUnit_T responseId, uint32_T serverFcnId)\n{\n');
    fprintf(fid,[indentL1,'UNUSED_PARAMETER(xilFcnId);\n',indentL1,'UNUSED_PARAMETER(xilCommandType);\n',indentL1,'UNUSED_PARAMETER(xilCommandIdx);\n',indentL1,'UNUSED_PARAMETER(xilIOData);\n',indentL1,'UNUSED_PARAMETER(responseId);\n',indentL1,'UNUSED_PARAMETER(serverFcnId);\n\n',...
    indentL1,'return XIL_INTERFACE_UNKNOWN_TID;\n}\n\n']);

    fclose(fid);

end
