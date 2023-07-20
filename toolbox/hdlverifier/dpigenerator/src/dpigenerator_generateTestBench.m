function dpigenerator_generateTestBench(dpiname,tbname,dpig_codeinfo,buildInfo,dpig_config)




    try

        dpigTbOutDir='dpi_tb';



        LocalInterfaceInfo=struct('IsInterfaceEnabled',false,...
        'InterfaceId','',...
        'InterfaceType','');
        if(~isfield(dpig_codeinfo,{'MLCoderCodeGen'}))
            l_checkSampleTime(dpig_codeinfo);
            SVStructEnabled=dpig_config.SVStructEnabled;
            SVScalarizePortsEnabled=dpig_config.SVScalarizePortsEnabled;

            SrcPathTemp=pwd;
            [s,mess,messid]=mkdir(dpigTbOutDir);


            disp('### Starting test vector capture');
            tbobj=dpig.internal.CaptureVector(dpigenerator_getvariable('dpigSubsystemPath'),dpigenerator_getvariable('dpigSubsystemName'),dpig_codeinfo.TestPointStruct.AccessFcnInterface);


            LocalInterfaceInfo=dpig_codeinfo.InterfaceInfo;
        else
            SVScalarizePortsEnabled=false;
            SVStructEnabled=false;
            SrcPathTemp=MATLAB_DPICGen.DPICGenInst.SrcPath;

            tbobj.TestPointsToCaptureKeys={};
            [s,mess,messid]=mkdir([SrcPathTemp,filesep,dpigTbOutDir]);
        end

        if~s
            error(messid,mess);
        end



        svFile=fullfile(SrcPathTemp,dpigTbOutDir,[tbname,'.sv']);
        addNonBuildFiles(buildInfo,svFile);

        dpigenerator_disp(['Generating SystemVerilog test bench ',dpigenerator_getfilelink(svFile)]);
        genSV=dpig.internal.GenSVCode(svFile);
        genSV.addGeneratedBy('// ');
        genSV.getUniqueName(dpiname);
        genSV.getUniqueName(tbname);


        genSV.appendCode('`timescale 1ns / 1ns');
        genSV.addNewLine;


        genSV.appendCode(dpig.internal.GetSVFcn.getPackageCode('Import',...
        [dpiname,dpig.internal.GetSVFcn.getPackageFileSuffix()]));

        genSV.addNewLine;
        genSV.appendCode(['module ',tbname,';']);
        genSV.addIndent;






        MultirateCounters=containers.Map;


        inPortVars=containers.Map;
        inPortDataFileName=containers.Map;
        for idx0=1:dpig_codeinfo.InStruct.NumPorts




            if isfield(dpig_codeinfo,{'MLCoderCodeGen'})
                PortFlatName=dpig_codeinfo.InStruct.Port{idx0};
                PortInfo=dpig_codeinfo.PortMap(PortFlatName);
            else
                PortInfo=dpig_codeinfo.InStruct.Port(idx0);
            end
            if PortInfo.IsMultirate
                MultirateCounters(PortInfo.MultiRateCounter)=PortInfo.NormalizedSamplePeriod;
            end


            dpigenerator_getFlattenedSignalsMap(genSV,inPortVars,PortInfo,inPortDataFileName,'Input',isfield(dpig_codeinfo,{'MLCoderCodeGen'}));
        end

        clear dpigenerator_getFlattenedSignalsMap;

        outPortVars=containers.Map;
        outPortDataFileName=containers.Map;
        for idx1=1:dpig_codeinfo.OutStruct.NumPorts




            if isfield(dpig_codeinfo,{'MLCoderCodeGen'})
                PortFlatName=dpig_codeinfo.OutStruct.Port{idx1};
                PortInfo=dpig_codeinfo.PortMap(PortFlatName);
            else
                PortInfo=dpig_codeinfo.OutStruct.Port(idx1);
            end

            if PortInfo.IsMultirate
                MultirateCounters(PortInfo.MultiRateCounter)=PortInfo.NormalizedSamplePeriod;
            end


            dpigenerator_getFlattenedSignalsMap(genSV,outPortVars,PortInfo,outPortDataFileName,'Output',isfield(dpig_codeinfo,{'MLCoderCodeGen'}));
        end

        clear dpigenerator_getFlattenedSignalsMap;
        if isempty(outPortVars)
            outPortGoldVars=containers.Map;
            outPortGoldVarsExpected=containers.Map;
        else
            outPortGoldVars=containers.Map(keys(outPortVars),cellfun(@(x)genSV.getUniqueName([x,'_read']),keys(outPortVars),'UniformOutput',false));
            outPortGoldVarsExpected=containers.Map(keys(outPortVars),cellfun(@(x)genSV.getUniqueName([x,'_ref']),keys(outPortVars),'UniformOutput',false));
        end



        TestPointPortVars=containers.Map;
        TestPointPortDataFileName=containers.Map;

        for idx2=1:numel(tbobj.TestPointsToCaptureKeys)
            dpigenerator_getFlattenedSignalsMap(genSV,TestPointPortVars,dpig_codeinfo.TestPointStruct.TestPointContainer(tbobj.TestPointsToCaptureKeys{idx2}),TestPointPortDataFileName,'TestPoint',isfield(dpig_codeinfo,{'MLCoderCodeGen'}));
        end

        clear dpigenerator_getFlattenedSignalsMap;


        if isempty(TestPointPortVars)
            TestPointPortGoldVars=containers.Map;
            TestPointPortGoldVarsExpected=containers.Map;
        else
            TestPointPortGoldVars=containers.Map(keys(TestPointPortVars),cellfun(@(x)genSV.getUniqueName([x,'_read']),keys(TestPointPortVars),'UniformOutput',false));
            TestPointPortGoldVarsExpected=containers.Map(keys(TestPointPortVars),cellfun(@(x)genSV.getUniqueName([x,'_ref']),keys(TestPointPortVars),'UniformOutput',false));
        end




        KeyVal2TopStructName=containers.Map;
        TopStructName2StructInfo=containers.Map;
        KeyVal2StructTrueIdentifier=containers.Map;

        KeyVal2FlatScalarTrueIdentifier=containers.Map;
        TopStructVarsDeclared={};
        if~isfield(dpig_codeinfo,{'MLCoderCodeGen'})

            PortMap=[inPortVars;outPortVars;TestPointPortVars];
            for idx1_1=keys(PortMap)
                keyv=idx1_1{1};
                IsArrayOfStructs=PortMap(keyv).getIsArrayOfStructsVal;
                if SVStructEnabled
                    l_CreateTrueIdentifierMap4PortStructs(keyv,...
                    PortMap(keyv).StructFieldInfo,...
                    KeyVal2TopStructName,...
                    TopStructName2StructInfo);
                    if LocalInterfaceInfo.IsInterfaceEnabled&&~isKey(TestPointPortVars,PortMap(keyv).FlatName)

                        tempStructTrueIdentifier=PortMap(keyv).FlatName_uf2f('testbench',SVStructEnabled,SVScalarizePortsEnabled);
                        if IsArrayOfStructs&&SVScalarizePortsEnabled
                            KeyVal2StructTrueIdentifier(keyv)=cellfun(@(x)[LocalInterfaceInfo.InterfaceId,'.',x],tempStructTrueIdentifier,'UniformOutput',false);
                        else
                            KeyVal2StructTrueIdentifier(keyv)=[LocalInterfaceInfo.InterfaceId,'.',tempStructTrueIdentifier];
                        end
                    else
                        KeyVal2StructTrueIdentifier(keyv)=PortMap(keyv).FlatName_uf2f('testbench',SVStructEnabled,SVScalarizePortsEnabled);
                    end
                elseif SVScalarizePortsEnabled
                    if IsArrayOfStructs
                        if LocalInterfaceInfo.IsInterfaceEnabled&&~isKey(TestPointPortVars,PortMap(keyv).FlatName)

                            tempFlatScalarTrueIdentifier=PortMap(keyv).FlatName_uf2f('testbench',SVStructEnabled,SVScalarizePortsEnabled);
                            KeyVal2FlatScalarTrueIdentifier(keyv)=cellfun(@(x)[LocalInterfaceInfo.InterfaceId,'.',x],tempFlatScalarTrueIdentifier,'UniformOutput',false);
                        else
                            KeyVal2FlatScalarTrueIdentifier(keyv)=PortMap(keyv).FlatName_uf2f('testbench',SVStructEnabled,SVScalarizePortsEnabled);
                        end
                    end
                end
            end
        end


        InputKeys=keys(inPortVars);
        InputTrueIdentifiers=l_CreateTrueIdentifierMap4Interfaces(InputKeys,LocalInterfaceInfo.IsInterfaceEnabled,LocalInterfaceInfo.InterfaceId);

        OutputKeys=keys(outPortVars);
        OutputTrueIdentifiers=l_CreateTrueIdentifierMap4Interfaces(OutputKeys,LocalInterfaceInfo.IsInterfaceEnabled,LocalInterfaceInfo.InterfaceId);


        DataFileNames=[inPortDataFileName;outPortDataFileName;TestPointPortDataFileName];


        if LocalInterfaceInfo.IsInterfaceEnabled
            genSV.appendCode(sprintf('%s %s();\n',LocalInterfaceInfo.InterfaceType,LocalInterfaceInfo.InterfaceId));
        end


        IO_TP_Map=[inPortVars;outPortVars;TestPointPortVars];


        if(isfield(dpig_codeinfo,{'MLCoderCodeGen'}))


            p=MATLAB_DPICGen.DPICGenInst;
            currentDir=pwd;
            c=onCleanup(@()cd(currentDir));
            cd(p.topDir);
            varSizeDataActualSizeMap=MATLAB_DPICGen.DPICGenInst.captureTestVectors(dpigTbOutDir,DataFileNames,IO_TP_Map);
            cd(currentDir);
            for idx=keys(varSizeDataActualSizeMap)
                KeyVal=idx{1};


                curPortInfo=IO_TP_Map(KeyVal);
                if curPortInfo.IsComplex

                    curPortInfo.StructInfo.TopStructDim=varSizeDataActualSizeMap(KeyVal);
                else
                    curPortInfo.Dim=varSizeDataActualSizeMap(KeyVal);
                end
                IO_TP_Map(KeyVal)=curPortInfo;
                if isKey(inPortVars,KeyVal)
                    inPortVars(KeyVal)=curPortInfo;
                end
                if isKey(outPortVars,KeyVal)
                    outPortVars(KeyVal)=curPortInfo;
                end
            end
        else
            dpigenerator_captureTestVectors(dpigTbOutDir,tbobj);
        end

        TopStructVarsDeclared={};
        for idx3=[keys(inPortVars),keys(outPortVars),keys(TestPointPortVars)]
            keyval=idx3{1};








            if isfield(dpig_codeinfo,{'MLCoderCodeGen'})

                [FlattenedStructDimensions,IsStructArray]=l_getStructArrayInfo(IO_TP_Map(keyval).StructInfo);
            else

                [FlattenedStructDimensions,IsStructArray]=l_getStructArrayInfo(IO_TP_Map(keyval).StructFieldInfo);
            end




            IsStruct=isKey(KeyVal2TopStructName,keyval);

            if IsStruct&&~any(strcmp(KeyVal2TopStructName(keyval),TopStructVarsDeclared))&&~isKey(TestPointPortVars,keyval)
                if~LocalInterfaceInfo.IsInterfaceEnabled

                    TopStructVarsDeclared=[TopStructVarsDeclared,KeyVal2TopStructName(keyval)];%#ok<AGROW>

                    if TopStructName2StructInfo(KeyVal2TopStructName(keyval)).Dim>1
                        if SVScalarizePortsEnabled
                            declare='';
                            for idx3_1=1:TopStructName2StructInfo(KeyVal2TopStructName(keyval)).Dim
                                declare=sprintf('%s%s %s_%d;\n',declare,...
                                TopStructName2StructInfo(KeyVal2TopStructName(keyval)).SVDataType,...
                                TopStructName2StructInfo(KeyVal2TopStructName(keyval)).Name,...
                                idx3_1-1);
                            end
                            declare=sprintf('%s',declare(1:end-1));
                        else
                            declare=sprintf('%s %s [%d:%d];',TopStructName2StructInfo(KeyVal2TopStructName(keyval)).SVDataType,...
                            TopStructName2StructInfo(KeyVal2TopStructName(keyval)).Name,...
                            0,TopStructName2StructInfo(KeyVal2TopStructName(keyval)).Dim-1);
                        end
                    else
                        declare=sprintf('%s %s;',TopStructName2StructInfo(KeyVal2TopStructName(keyval)).SVDataType,...
                        TopStructName2StructInfo(KeyVal2TopStructName(keyval)).Name);
                    end
                else


                    declare='';
                end
            end


            if IO_TP_Map(keyval).Dim>1||IsStructArray

                if~isKey(TestPointPortVars,keyval)&&~IsStruct
                    if LocalInterfaceInfo.IsInterfaceEnabled
                        declare='';
                    else
                        if SVScalarizePortsEnabled
                            declare='';
                            if IsStructArray
                                tempIdentifiers=KeyVal2FlatScalarTrueIdentifier(keyval);
                                for idx3_2=1:(FlattenedStructDimensions*IO_TP_Map(keyval).Dim)
                                    declare=sprintf('%s%s %s;\n',declare,IO_TP_Map(keyval).SVDataType,tempIdentifiers{idx3_2});
                                end
                            else
                                for idx3_3=1:IO_TP_Map(keyval).Dim
                                    declare=sprintf('%s%s %s_%d;\n',declare,IO_TP_Map(keyval).SVDataType,keyval,idx3_3-1);
                                end
                            end
                            declare=sprintf('%s',declare(1:end-1));
                        else
                            if isfield(dpig_codeinfo,{'MLCoderCodeGen'})&&IO_TP_Map(keyval).IsVarSize&&strcmpi(IO_TP_Map(keyval).Direction,'output')


                                declare=sprintf('%s %s [];',IO_TP_Map(keyval).SVDataType,keyval);
                            else
                                declare=sprintf('%s %s [%d:%d];',IO_TP_Map(keyval).SVDataType,keyval,0,(FlattenedStructDimensions*IO_TP_Map(keyval).Dim)-1);
                            end
                        end
                    end
                end

                if isKey(outPortVars,keyval)
                    declare=sprintf('%s %s [%d:%d];\n%s',IO_TP_Map(keyval).SVDataType,outPortGoldVars(keyval),0,(FlattenedStructDimensions*IO_TP_Map(keyval).Dim)-1,declare);
                    declare=sprintf('%s %s [%d:%d];\n%s',IO_TP_Map(keyval).SVDataType,outPortGoldVarsExpected(keyval),0,(FlattenedStructDimensions*IO_TP_Map(keyval).Dim)-1,declare);
                end

                if isKey(TestPointPortVars,keyval)
                    declare=sprintf('%s %s [%d:%d];\n%s',IO_TP_Map(keyval).SVDataType,TestPointPortGoldVars(keyval),0,(FlattenedStructDimensions*IO_TP_Map(keyval).Dim)-1,declare);
                    declare=sprintf('%s %s [%d:%d];\n%s',IO_TP_Map(keyval).SVDataType,TestPointPortGoldVarsExpected(keyval),0,(FlattenedStructDimensions*IO_TP_Map(keyval).Dim)-1,declare);
                end
            else

                if~isKey(TestPointPortVars,keyval)&&~IsStruct
                    if LocalInterfaceInfo.IsInterfaceEnabled
                        declare='';
                    else
                        declare=sprintf('%s %s;',IO_TP_Map(keyval).SVDataType,keyval);
                    end
                end

                if isKey(outPortVars,keyval)
                    declare=sprintf('%s %s;\n%s',IO_TP_Map(keyval).SVDataType,outPortGoldVars(keyval),declare);
                    declare=sprintf('%s %s;\n%s',IO_TP_Map(keyval).SVDataType,outPortGoldVarsExpected(keyval),declare);
                end

                if isKey(TestPointPortGoldVars,keyval)
                    declare=sprintf('%s %s;\n%s',IO_TP_Map(keyval).SVDataType,TestPointPortGoldVars(keyval),declare);
                    declare=sprintf('%s %s;\n%s',IO_TP_Map(keyval).SVDataType,TestPointPortGoldVarsExpected(keyval),declare);
                end
            end

            genSV.appendCode(declare);
            declare='';
        end



        for idx3_3=keys(MultirateCounters)
            keyval=idx3_3{1};
            genSV.appendCode(['integer ',keyval,';']);
        end


        genSV.addComment('File Handles');


        FID_Names=containers.Map;
        for idx4=keys(IO_TP_Map)
            keyval=idx4{1};
            FID_Names(keyval)=genSV.addVarDecl('integer',['fid_',keyval]);
        end
        IsSequentialComp=isfield(dpig_codeinfo,{'MLCoderCodeGen'})&&strcmpi(dpig_codeinfo.ComponentTemplateType,'sequential')||...
        ~isfield(dpig_codeinfo,{'MLCoderCodeGen'})&&strcmpi(dpig_config.DPIComponentTemplateType,'sequential');

        genSV.addComment('Other test bench variables');

        if LocalInterfaceInfo.IsInterfaceEnabled
            if~IsSequentialComp


                clkVar=genSV.addVarDecl('bit',sprintf('%s',dpig_codeinfo.CtrlSigStruct(1).Name));
            else
                clkVar=sprintf('%s.%s',LocalInterfaceInfo.InterfaceId,dpig_codeinfo.CtrlSigStruct(1).Name);
                clkEnVar=sprintf('%s.%s',LocalInterfaceInfo.InterfaceId,dpig_codeinfo.CtrlSigStruct(2).Name);
                resetVar=sprintf('%s.%s',LocalInterfaceInfo.InterfaceId,dpig_codeinfo.CtrlSigStruct(3).Name);
            end
        else



            clkVar=genSV.addVarDecl('bit',sprintf('%s',dpig_codeinfo.CtrlSigStruct(1).Name));
            if IsSequentialComp


                clkEnVar=genSV.addVarDecl('bit',sprintf('%s',dpig_codeinfo.CtrlSigStruct(2).Name));
                resetVar=genSV.addVarDecl('bit',sprintf('%s',dpig_codeinfo.CtrlSigStruct(3).Name));
            end
        end
        fscanfStatusVar=genSV.addVarDecl('integer','fscanf_status');
        testFailureVar=genSV.addVarDecl('reg','testFailure');
        tbDoneVar=genSV.addVarDecl('reg','tbDone');
        realTmpVar=genSV.addVarDecl('bit[63:0]','real_bit64');
        shortrealTmpVar=genSV.addVarDecl('bit[31:0]','shortreal_bit64');

        clkPeriodParam=genSV.addParamDecl('CLOCK_PERIOD','10');
        if IsSequentialComp
            clkHoldParam=genSV.addParamDecl('CLOCK_HOLD','2');
            resetLenParam=genSV.addParamDecl('RESET_LEN',['2*',clkPeriodParam,'+',clkHoldParam]);
        end

        ReceivingDataVars=[outPortGoldVars;TestPointPortGoldVars;InputTrueIdentifiers];


        genSV.addComment('Initialize variables');
        genSV.appendCode('initial begin');
        genSV.addIndent;
        genSV.addBlockingAssign(clkVar,'1');
        if IsSequentialComp
            genSV.addBlockingAssign(clkEnVar,'0');
            genSV.addBlockingAssign(resetVar,'1');
        end
        genSV.addBlockingAssign(testFailureVar,'0');
        genSV.addBlockingAssign(tbDoneVar,'0');


        for idx5=keys(IO_TP_Map)
            keyval=idx5{1};
            genSV.addBlockingAssign(FID_Names(keyval),['$fopen("',DataFileNames(keyval),'","r")']);
            addNonBuildFiles(buildInfo,fullfile(SrcPathTemp,dpigTbOutDir,DataFileNames(keyval)));

            if isKey(inPortVars,keyval)

                [DimensionInfo,RcvDataId]=l_getDimensionAndRcvDataId(dpig_codeinfo,InputTrueIdentifiers,...
                KeyVal2TopStructName,KeyVal2StructTrueIdentifier,KeyVal2FlatScalarTrueIdentifier,...
                ReceivingDataVars,inPortVars,keyval,SVScalarizePortsEnabled);

                l_readFromDatFile(genSV,inPortVars(keyval).SVDataType,DimensionInfo,RcvDataId,FID_Names(keyval),...
                tbDoneVar,fscanfStatusVar,realTmpVar,shortrealTmpVar,true,SVScalarizePortsEnabled);
            end
        end




        if numel(keys(MultirateCounters))>0
            genSV.addComment('Initialize multirate counters');
        end
        for idx5_1=keys(MultirateCounters)
            keyval=idx5_1{1};
            genSV.appendCode([keyval,'=0;']);
        end
        if IsSequentialComp
            genSV.appendCode(sprintf('#%s %s = 0;',resetLenParam,resetVar));
        end
        genSV.reduceIndent;
        genSV.appendCode('end');

        genSV.addComment('Clock');
        genSV.appendCode(sprintf('always #(%s/2) %s = ~ %s;',clkPeriodParam,clkVar,clkVar));

        genSV.appendCode(sprintf('always@(posedge %s) begin',clkVar));
        genSV.addIndent;
        if IsSequentialComp
            genSV.appendCode(sprintf('if (%s == 0) begin',resetVar));
            genSV.addIndent;
            genSV.appendCode(['#',clkHoldParam]);
            genSV.appendCode(sprintf('%s <= 1;',clkEnVar));
        end




        for idx6=keys(IO_TP_Map)
            keyval=idx6{1};








            [DimensionInfo,RcvDataId]=l_getDimensionAndRcvDataId(dpig_codeinfo,InputTrueIdentifiers,...
            KeyVal2TopStructName,KeyVal2StructTrueIdentifier,KeyVal2FlatScalarTrueIdentifier,...
            ReceivingDataVars,IO_TP_Map,keyval,SVScalarizePortsEnabled);


            l_AddMultirateIfWrapper(genSV,IO_TP_Map(keyval).MultiRateCounter,'begin');

            if~isKey(inPortVars,keyval)
                IsScalarNeeded=false;
            else
                IsScalarNeeded=SVScalarizePortsEnabled;
            end

            l_readFromDatFile(genSV,IO_TP_Map(keyval).SVDataType,DimensionInfo,RcvDataId,FID_Names(keyval),...
            tbDoneVar,fscanfStatusVar,realTmpVar,shortrealTmpVar,false,IsScalarNeeded);
            if isKey(outPortGoldVarsExpected,keyval)
                genSV.appendCode(sprintf('%s <= %s;',outPortGoldVarsExpected(keyval),ReceivingDataVars(keyval)));
            end

            if isKey(TestPointPortGoldVarsExpected,keyval)
                genSV.appendCode(sprintf('%s <= %s;',TestPointPortGoldVarsExpected(keyval),ReceivingDataVars(keyval)));
            end

            l_AddMultirateIfWrapper(genSV,IO_TP_Map(keyval).MultiRateCounter,'end');

        end
        if IsSequentialComp
            genSV.appendCode(sprintf('if (%s == 1) begin',clkEnVar));
            genSV.addIndent;
        else
            genSV.appendCode('# 1');
            l_printTbDone(genSV,tbDoneVar,testFailureVar);
        end
        for idx7=keys(outPortVars)
            keyval=idx7{1};
            port=outPortVars(keyval);
            dtype=port.SVDataType;







            if isfield(dpig_codeinfo,{'MLCoderCodeGen'})

                [FlattenedStructDimensions,IsStructArray_a]=l_getStructArrayInfo(port.StructInfo);
            else

                [FlattenedStructDimensions,IsStructArray_a]=l_getStructArrayInfo(port.StructFieldInfo);
            end

            dim=FlattenedStructDimensions*port.Dim;


            l_AddMultirateIfWrapper(genSV,IO_TP_Map(keyval).MultiRateCounter,'begin');



            if isKey(KeyVal2TopStructName,keyval)
                OutDataId=KeyVal2StructTrueIdentifier(keyval);
                if~SVScalarizePortsEnabled
                    if IsStructArray_a



                        idxName=genSV.getUniqueName('idx');
                        OutDataId=strrep(OutDataId,'<index>',idxName);


                        if port.Dim>1
                            OutDataId=sprintf('%s[%s%%%d]',OutDataId,idxName,port.Dim);
                        end
                    elseif port.Dim>1


                        idxName=genSV.getUniqueName('idx');
                        OutDataId=sprintf('%s[%s]',OutDataId,idxName);
                    end
                end
            else
                if SVScalarizePortsEnabled&&IsStructArray_a
                    OutDataId=KeyVal2FlatScalarTrueIdentifier(keyval);
                else
                    OutDataId=OutputTrueIdentifiers(keyval);


                    if dim>1&&~SVScalarizePortsEnabled
                        idxName=genSV.getUniqueName('idx');
                        OutDataId=sprintf('%s[%s]',OutDataId,idxName);
                    end
                end
            end

            if dim==1
                l_generateAssertion(genSV,outPortGoldVarsExpected(keyval),OutDataId,dtype,testFailureVar)
            else
                if SVScalarizePortsEnabled
                    for idx7_1=1:dim
                        if IsStructArray_a
                            tempOutDataId=OutDataId{idx7_1};
                        else
                            tempOutDataId=sprintf('%s_%d',OutDataId,idx7_1-1);
                        end
                        l_generateAssertion(genSV,outPortGoldVarsExpected(keyval),tempOutDataId,dtype,testFailureVar,num2str(idx7_1-1));
                    end
                else
                    genSV.appendCode(sprintf('for(integer %s=0;%s<%d;%s=%s+1) begin',idxName,idxName,dim,idxName,idxName));
                    genSV.addIndent;
                    l_generateAssertion(genSV,outPortGoldVarsExpected(keyval),OutDataId,dtype,testFailureVar,idxName);
                    genSV.reduceIndent;
                    genSV.appendCode('end');
                end
            end


            l_AddMultirateIfWrapper(genSV,IO_TP_Map(keyval).MultiRateCounter,'end');

        end


        uname=genSV.getUniqueName(['u_',dpiname]);

        for idx8=keys(TestPointPortVars)
            keyval=idx8{1};
            port=TestPointPortVars(keyval);

            if isfield(dpig_codeinfo,{'MLCoderCodeGen'})

                [FlattenedStructDimensions,IsStructArray_a]=l_getStructArrayInfo(port.StructInfo);
            else

                [FlattenedStructDimensions,IsStructArray_a]=l_getStructArrayInfo(port.StructFieldInfo);
            end

            dim=FlattenedStructDimensions*port.Dim;
            dtype=port.SVDataType;
            if isKey(KeyVal2TopStructName,keyval)
                testPointID=KeyVal2StructTrueIdentifier(keyval);
                if dim==1
                    l_generateAssertion(genSV,TestPointPortGoldVarsExpected(keyval),[uname,'.',testPointID],dtype,testFailureVar)
                else
                    idxName=genSV.getUniqueName('idx');

                    testPointID=strrep(testPointID,'<index>',idxName);
                    genSV.appendCode(sprintf('for(integer %s=0;%s<%d;%s=%s+1) begin',idxName,idxName,dim,idxName,idxName));
                    genSV.addIndent;
                    l_generateAssertion(genSV,TestPointPortGoldVarsExpected(keyval),sprintf('%s',[uname,'.',testPointID]),dtype,testFailureVar,idxName);
                    genSV.reduceIndent;
                    genSV.appendCode('end');
                end
            else
                if dim==1
                    l_generateAssertion(genSV,TestPointPortGoldVarsExpected(keyval),[uname,'.',keyval],dtype,testFailureVar)
                else
                    idxName=genSV.getUniqueName('idx');
                    genSV.appendCode(sprintf('for(integer %s=0;%s<%d;%s=%s+1) begin',idxName,idxName,dim,idxName,idxName));
                    genSV.addIndent;
                    l_generateAssertion(genSV,TestPointPortGoldVarsExpected(keyval),sprintf('%s[%s]',[uname,'.',keyval],idxName),dtype,testFailureVar,idxName);
                    genSV.reduceIndent;
                    genSV.appendCode('end');
                end
            end
        end

        if IsSequentialComp
            l_printTbDone(genSV,tbDoneVar,testFailureVar);
            genSV.reduceIndent;
            genSV.appendCode('end');
        end

        if~isempty(MultirateCounters)
            genSV.addComment('Update multirate counters');
        end
        for idx8_1=keys(MultirateCounters)
            keyval=idx8_1{1};
            genSV.appendCode([keyval,'=(',keyval,'+1)%',num2str(MultirateCounters(keyval)),';']);
        end
        if IsSequentialComp
            genSV.reduceIndent;
            genSV.appendCode('end');
        end

        genSV.reduceIndent;
        genSV.appendCode('end');
        genSV.addNewLine;

        genSV.addComment('Instantiate DUT');
        genSV.appendCode(sprintf('%s %s(',dpiname,uname));


        if LocalInterfaceInfo.IsInterfaceEnabled
            genSV.appendCode(sprintf('.%s(%s)',LocalInterfaceInfo.InterfaceId,LocalInterfaceInfo.InterfaceId));
        else
            if IsSequentialComp
                genSV.appendCode(sprintf('.clk(%s),',clkVar));
                genSV.appendCode(sprintf('.clk_enable(%s),',clkEnVar));
                genSV.appendCode(sprintf('.reset(%s),',resetVar));
            end

            TopStructVarsDeclared={};
            for idx9=keys(inPortVars)

                keyval=idx9{1};
                if isKey(KeyVal2TopStructName,keyval)
                    if~any(strcmp(KeyVal2TopStructName(keyval),TopStructVarsDeclared))
                        TopStructVarsDeclared=[TopStructVarsDeclared,KeyVal2TopStructName(keyval)];%#ok<AGROW>
                        topmostStructDim=inPortVars(keyval).StructFieldInfo.TopStructDim(1);
                        if SVScalarizePortsEnabled&&topmostStructDim>1
                            for idx9_1=1:topmostStructDim
                                genSV.appendCode(sprintf('.%s_%d(%s_%d),',KeyVal2TopStructName(keyval),idx9_1-1,KeyVal2TopStructName(keyval),idx9_1-1));
                            end
                        else
                            genSV.appendCode(sprintf('.%s(%s),',KeyVal2TopStructName(keyval),KeyVal2TopStructName(keyval)));
                        end
                    end
                else
                    if~isfield(dpig_codeinfo,{'MLCoderCodeGen'})&&SVScalarizePortsEnabled
                        [FlattenedStructDimensions,IsStructArray_a]=l_getStructArrayInfo(inPortVars(keyval).StructFieldInfo);
                        dim=FlattenedStructDimensions*inPortVars(keyval).Dim;
                        if dim>1
                            if IsStructArray_a
                                SignalIds=KeyVal2FlatScalarTrueIdentifier(keyval);
                                for idx9_2=1:dim
                                    genSV.appendCode(sprintf('.%s(%s),',SignalIds{idx9_2},SignalIds{idx9_2}));
                                end
                            else
                                for idx9_3=1:dim
                                    genSV.appendCode(sprintf('.%s_%d(%s_%d),',inPortVars(keyval).FlatName,idx9_3-1,keyval,idx9_3-1));
                                end
                            end
                        else
                            genSV.appendCode(sprintf('.%s(%s),',inPortVars(keyval).FlatName,keyval));
                        end
                    else
                        genSV.appendCode(sprintf('.%s(%s),',inPortVars(keyval).FlatName,keyval));
                    end
                end
            end
            TopStructVarsDeclared={};
            for idx10=keys(outPortVars)
                keyval=idx10{1};
                if isKey(KeyVal2TopStructName,keyval)
                    if~any(strcmp(KeyVal2TopStructName(keyval),TopStructVarsDeclared))
                        TopStructVarsDeclared=[TopStructVarsDeclared,KeyVal2TopStructName(keyval)];%#ok<AGROW>
                        topmostStructDim=outPortVars(keyval).StructFieldInfo.TopStructDim(1);
                        if SVScalarizePortsEnabled&&topmostStructDim>1
                            for idx10_1=1:topmostStructDim
                                genSV.appendCode(sprintf('.%s_%d(%s_%d),',KeyVal2TopStructName(keyval),idx10_1-1,KeyVal2TopStructName(keyval),idx10_1-1));
                            end
                        else
                            genSV.appendCode(sprintf('.%s(%s),',KeyVal2TopStructName(keyval),KeyVal2TopStructName(keyval)));
                        end
                    end
                else
                    if~isfield(dpig_codeinfo,{'MLCoderCodeGen'})&&SVScalarizePortsEnabled
                        [FlattenedStructDimensions,IsStructArray_a]=l_getStructArrayInfo(outPortVars(keyval).StructFieldInfo);
                        dim=FlattenedStructDimensions*outPortVars(keyval).Dim;
                        if dim>1
                            if IsStructArray_a
                                SignalIds=KeyVal2FlatScalarTrueIdentifier(keyval);
                                for idx10_2=1:dim
                                    genSV.appendCode(sprintf('.%s(%s),',SignalIds{idx10_2},SignalIds{idx10_2}));
                                end
                            else
                                for idx10_3=1:dim
                                    genSV.appendCode(sprintf('.%s_%d(%s_%d),',outPortVars(keyval).FlatName,idx10_3-1,keyval,idx10_3-1));
                                end
                            end
                        else
                            genSV.appendCode(sprintf('.%s(%s),',outPortVars(keyval).FlatName,keyval));
                        end
                    else
                        genSV.appendCode(sprintf('.%s(%s),',outPortVars(keyval).FlatName,keyval));
                    end
                end
            end
            if genSV.mText(end-1)==','
                genSV.mText(end-1)='';
            end
        end
        genSV.appendCode(');');

        genSV.reduceIndent;
        genSV.appendCode('endmodule');


        dpipkgname=[dpiname,'_pkg'];



        if~isfield(dpig_codeinfo,{'MLCoderCodeGen'})&&(strcmp(computer,'PCWIN32')||strcmp(computer,'PCWIN64'))&&(~isempty(strfind(buildInfo.BuildTools.Toolchain,'64-bit Linux'))||~isempty(strfind(buildInfo.BuildTools.Toolchain,'32-bit Linux')))

            Porting=true;
        elseif isfield(dpig_codeinfo,{'MLCoderCodeGen'})&&(strcmp(computer,'PCWIN32')||strcmp(computer,'PCWIN64'))&&~(isempty(strfind(dpig_config.Toolchain,'64-bit Linux')))
            Porting=true;
        else
            Porting=false;
        end

        if~isempty(buildInfo.BuildTools)&&(~isempty(strfind(buildInfo.BuildTools.Toolchain,'QuestaSim/Modelsim')))||...
            isfield(dpig_codeinfo,{'MLCoderCodeGen'})&&(~isempty(strfind(dpig_config.Toolchain,'QuestaSim/Modelsim')))


            Generate_Modelsim_Script(false,LocalInterfaceInfo.IsInterfaceEnabled,InputTrueIdentifiers,OutputTrueIdentifiers,dpig_config,Porting);
        elseif~isempty(buildInfo.BuildTools)&&~isempty(strfind(buildInfo.BuildTools.Toolchain,'Xcelium (64-bit Linux)'))||...
            isfield(dpig_codeinfo,{'MLCoderCodeGen'})&&~isempty(strfind(dpig_config.Toolchain,'Xcelium (64-bit Linux)'))
            Generate_Xcelium_Script(false,Porting);
        else


            Generate_Modelsim_Script(true,LocalInterfaceInfo.IsInterfaceEnabled,InputTrueIdentifiers,OutputTrueIdentifiers,dpig_config,Porting);
            Generate_Xcelium_Script(true,Porting);
            Generate_VCS_Script();
            Generate_Vivado_Script();
        end
    catch ME
        if(isfield(dpig_codeinfo,{'MLCoderCodeGen'}))
            baseME=MException(message('HDLLink:DPIG:MATLABTestBenchGenerationFailed'));
        else
            baseME=MException(message('HDLLink:DPIG:TestBenchGenerationFailed'));
        end
        newME=addCause(baseME,ME);
        throw(newME);
    end

    function Generate_Modelsim_Script(IsGeneric,IsInterfaceEnabled,InTrID,OutTrId,dpig_config,Porting)

        doFile=fullfile(SrcPathTemp,dpigTbOutDir,'run_tb_mq.do');
        if Porting
            addNonBuildFiles(buildInfo,doFile);
        end
        dpigenerator_disp(['Generating test bench simulation script for Mentor Graphics QuestaSim/Modelsim ',dpigenerator_getfilelink(doFile)]);

        tcl_env_args_cell={
'# Arbitrary compilation arguments can be placed in $(EXTRA_SVDPI_COMP_ARGS) environment variable'
'if { [info exists ::env(EXTRA_SVDPI_COMP_ARGS)] } {'
'    set EXTRA_SVDPI_COMP_ARGS $env(EXTRA_SVDPI_COMP_ARGS)'
'} else {'
'    set EXTRA_SVDPI_COMP_ARGS ""'
'}'
'# Arbitrary simulation arguments can be placed in $(EXTRA_SVDPI_SIM_ARGS) environment variable'
'if { [info exists ::env(EXTRA_SVDPI_SIM_ARGS)] } {'
'    set EXTRA_SVDPI_SIM_ARGS $env(EXTRA_SVDPI_SIM_ARGS)'
'} else {'
'    set EXTRA_SVDPI_SIM_ARGS ""'
'}'
''
        };

        genSV=dpig.internal.GenSVCode(doFile);
        genSV.appendCode(sprintf('# Description: DO file for simulating generated test bench %s with Mentor Graphics QuestaSim/Modelsim ',tbname));
        genSV.addGeneratedBy('# ');
        genSV.appendCode(l_get_verify_plusargs_comments());
        genSV.addGuiOrBatchModeConditionInTcl_Questasim();
        genSV.appendCode(sprintf('%s\n',tcl_env_args_cell{:}));
        genSV.appendCode(sprintf('vlib work'));
        if Porting



            pathToSource='.';
        else
            pathToSource='..';
        end

        genSV.appendCode(sprintf('eval vlog +define+MG_SIM %s/%s.sv %s/%s.sv ./%s.sv $EXTRA_SVDPI_COMP_ARGS',pathToSource,dpipkgname,pathToSource,dpiname,tbname));

        if~(isfield(dpig_codeinfo,{'MLCoderCodeGen'}))&&dpig_config.IsTSVerifyPresent
            IsTSVerifyPresent=true;
            EnableClassDebug='$EXTRA_SVDPI_SIM_ARGS +define+MG_SIM -classdebug';
        else
            IsTSVerifyPresent=false;
            EnableClassDebug='$EXTRA_SVDPI_SIM_ARGS +define+MG_SIM';
        end

        if(isfield(dpig_codeinfo,{'MLCoderCodeGen'}))
            if~IsGeneric
                genSV.appendCode(sprintf('eval vsim -c -voptargs=+acc work.%s -L %s/work',tbname,pathToSource));
            else


                genSV.appendCode(sprintf('vsim -c -voptargs=+acc -sv_lib ../%s work.%s',dpig_codeinfo.BuildName,tbname));
            end
        elseif~IsGeneric
            if~hdlverifierfeature('VERBOSE_VERIFY')

                genSV.appendCode(sprintf('eval vsim %s -c -voptargs=+acc work.%s -L %s/work',EnableClassDebug,tbname,pathToSource));
            else
                genSV.appendCode(sprintf('eval vsim %s -c -voptargs=+acc work.%s -L %s/work +VERBOSE_VERIFY',EnableClassDebug,tbname,pathToSource));
            end
        else
            if~hdlverifierfeature('VERBOSE_VERIFY')
                if isunix
                    genSV.appendCode(sprintf('eval vsim %s -c -voptargs=+acc -sv_lib ../%s work.%s',EnableClassDebug,dpiname(1:end-4),tbname));
                elseif strcmp(computer,'PCWIN64')
                    genSV.appendCode(sprintf('eval vsim %s -c -voptargs=+acc -sv_lib ../%s work.%s',EnableClassDebug,[dpiname(1:end-4),'_win64'],tbname));
                else
                    genSV.appendCode(sprintf('eval vsim %s -c -voptargs=+acc -sv_lib ../%s work.%s',EnableClassDebug,[dpiname(1:end-4),'_win32'],tbname));
                end
            else
                if isunix
                    genSV.appendCode(sprintf('eval vsim %s -c -voptargs=+acc -sv_lib ../%s work.%s +VERBOSE_VERIFY',EnableClassDebug,dpiname(1:end-4),tbname));
                elseif strcmp(computer,'PCWIN64')
                    genSV.appendCode(sprintf('eval vsim %s -c -voptargs=+acc -sv_lib ../%s work.%s +VERBOSE_VERIFY',EnableClassDebug,[dpiname(1:end-4),'_win64'],tbname));
                else
                    genSV.appendCode(sprintf('eval vsim %s -c -voptargs=+acc -sv_lib ../%s work.%s +VERBOSE_VERIFY',EnableClassDebug,[dpiname(1:end-4),'_win32'],tbname));
                end
            end
        end


        if IsInterfaceEnabled
            New_str='/';
            SVStruct_Prefix=[LocalInterfaceInfo.InterfaceId,'/'];
        else
            New_str='.';
            SVStruct_Prefix='';
        end
        if IsSequentialComp
            genSV.appendCode(sprintf('add wave /%s/%s',tbname,replace(clkVar,'.',New_str)));
            genSV.appendCode(sprintf('add wave /%s/%s',tbname,replace(clkEnVar,'.',New_str)));
            genSV.appendCode(sprintf('add wave /%s/%s',tbname,replace(resetVar,'.',New_str)));
        end
        TopStructVarsDeclared={};
        for idx11=keys(inPortVars)
            keyval=idx11{1};
            if isKey(KeyVal2TopStructName,keyval)
                if~any(strcmp(KeyVal2TopStructName(keyval),TopStructVarsDeclared))

                    TopStructVarsDeclared=[TopStructVarsDeclared,KeyVal2TopStructName(keyval)];%#ok<AGROW>
                    topmostStructDim=inPortVars(keyval).StructFieldInfo.TopStructDim(1);
                    if dpig_config.SVScalarizePortsEnabled&&topmostStructDim>1
                        for idx11_1=1:topmostStructDim
                            genSV.appendCode(sprintf('add wave /%s/%s_%d',tbname,[SVStruct_Prefix,KeyVal2TopStructName(keyval)],idx11_1-1));
                        end
                    else
                        genSV.appendCode(sprintf('add wave /%s/%s',tbname,[SVStruct_Prefix,KeyVal2TopStructName(keyval)]));
                    end
                end
            else
                if~isfield(dpig_codeinfo,{'MLCoderCodeGen'})&&dpig_config.SVScalarizePortsEnabled
                    [FlattenedStructDimensions,IsStructArray_a]=l_getStructArrayInfo(inPortVars(keyval).StructFieldInfo);
                    dim=FlattenedStructDimensions*inPortVars(keyval).Dim;
                    if dim>1
                        if IsStructArray_a
                            SignalIds=KeyVal2FlatScalarTrueIdentifier(keyval);
                            for idx11_2=1:dim
                                genSV.appendCode(sprintf('add wave /%s/%s',tbname,replace(SignalIds{idx11_2},'.',New_str)));
                            end
                        else
                            for idx11_3=1:dim
                                genSV.appendCode(sprintf('add wave /%s/%s',tbname,replace([InTrID(keyval),'_',num2str(idx11_3-1)],'.',New_str)));
                            end
                        end
                    else
                        genSV.appendCode(sprintf('add wave /%s/%s',tbname,replace(InTrID(keyval),'.',New_str)));
                    end
                else
                    genSV.appendCode(sprintf('add wave /%s/%s',tbname,replace(InTrID(keyval),'.',New_str)));
                end
            end
        end
        for idx12=keys(outPortVars)
            keyval=idx12{1};
            if isKey(KeyVal2TopStructName,keyval)
                if~any(strcmp(KeyVal2TopStructName(keyval),TopStructVarsDeclared))

                    TopStructVarsDeclared=[TopStructVarsDeclared,KeyVal2TopStructName(keyval)];%#ok<AGROW>
                    topmostStructDim=outPortVars(keyval).StructFieldInfo.TopStructDim(1);
                    if dpig_config.SVScalarizePortsEnabled&&topmostStructDim>1
                        for idx12_1=1:topmostStructDim
                            genSV.appendCode(sprintf('add wave /%s/%s_%d',tbname,[SVStruct_Prefix,KeyVal2TopStructName(keyval)],idx12_1-1));
                        end
                    else
                        genSV.appendCode(sprintf('add wave /%s/%s',tbname,[SVStruct_Prefix,KeyVal2TopStructName(keyval)]));
                    end
                end
            else
                if~isfield(dpig_codeinfo,{'MLCoderCodeGen'})&&dpig_config.SVScalarizePortsEnabled
                    [FlattenedStructDimensions,IsStructArray_a]=l_getStructArrayInfo(outPortVars(keyval).StructFieldInfo);
                    dim=FlattenedStructDimensions*outPortVars(keyval).Dim;
                    if dim>1
                        if IsStructArray_a
                            SignalIds=KeyVal2FlatScalarTrueIdentifier(keyval);
                            for idx12_2=1:dim
                                genSV.appendCode(sprintf('add wave /%s/%s',tbname,replace(SignalIds{idx12_2},'.',New_str)));
                            end
                        else
                            for idx12_3=1:dim
                                genSV.appendCode(sprintf('add wave /%s/%s',tbname,replace([OutTrId(keyval),'_',num2str(idx12_3-1)],'.',New_str)));
                            end
                        end
                    else
                        genSV.appendCode(sprintf('add wave /%s/%s',tbname,replace(OutTrId(keyval),'.',New_str)));
                    end
                elseif isfield(dpig_codeinfo,{'MLCoderCodeGen'})

                    if~outPortVars(keyval).IsVarSize
                        genSV.appendCode(sprintf('add wave /%s/%s',tbname,replace(OutTrId(keyval),'.',New_str)));
                    end
                else
                    genSV.appendCode(sprintf('add wave /%s/%s',tbname,replace(OutTrId(keyval),'.',New_str)));
                end
            end
            genSV.appendCode(sprintf('add wave /%s/%s',tbname,outPortGoldVarsExpected(keyval)));
        end


        if IsTSVerifyPresent
            genSV.appendCode(sprintf('add wave /%s/%s/vcomp/vinfo',tbname,uname));
        end


        for idx13=keys(TestPointPortVars)
            keyval=idx13{1};
            if isKey(KeyVal2TopStructName,keyval)
                if~any(strcmp(KeyVal2TopStructName(keyval),TopStructVarsDeclared))

                    TopStructVarsDeclared=[TopStructVarsDeclared,KeyVal2TopStructName(keyval)];%#ok<AGROW>
                    genSV.appendCode(sprintf('add wave /%s/%s/%s',tbname,uname,KeyVal2TopStructName(keyval)));
                end
            else
                genSV.appendCode(sprintf('add wave /%s/%s/%s',tbname,uname,keyval));
            end
            [IsLogged,~,~]=intersect(keys(TestPointPortVars),{keyval});
            if~isempty(IsLogged)

                genSV.appendCode(sprintf('add wave /%s/%s',tbname,TestPointPortGoldVarsExpected(keyval)));
            end
        end

        genSV.appendCode(sprintf('eval $final_cmd'));
        if isunix()
            fileattrib(doFile,'+x','u');
        end
    end

    function Generate_Xcelium_Script(IsGeneric,Porting)

        shellFile=fullfile(SrcPathTemp,dpigTbOutDir,'run_tb_xcelium.sh');
        if Porting
            addNonBuildFiles(buildInfo,shellFile);
        end
        dpigenerator_disp(['Generating test bench simulation script for Cadence Xcelium ',dpigenerator_getfilelink(shellFile)]);
        genSV=dpig.internal.GenSVCode(shellFile);
        genSV.appendCode(sprintf('#!/bin/sh'));
        genSV.appendCode(sprintf('# Description: Shell script for simulating generated test bench %s with Cadence Xcelium',tbname));
        genSV.addGeneratedBy('# ');
        genSV.appendCode(l_get_verify_plusargs_comments());
        genSV.addGuiOrBatchModeConditionInSh_Cadence();

        cmdFirst='$EXTRA_SVDPI_SIM_ARGS -coverage u -covoverwrite';
        if~hdlverifierfeature('VERBOSE_VERIFY')
            vverify='';
        else
            vverify='+VERBOSE_VERIFY';
        end
        if Porting
            pathToSource='.';
        else
            pathToSource='..';
        end

        if~IsGeneric
            if isfield(dpig_codeinfo,{'MLCoderCodeGen'})
                runCmd=sprintf('xrun $mode -64bit -reflib %s/%s_IncisiveLib/worklib -sv_lib %s/%s_IncisiveLib/run.d/librun.so -sv %s.sv $final_cmd',...
                pathToSource,dpiname(1:end-4),pathToSource,dpiname(1:end-4),tbname);
            else
                runCmd=sprintf('xrun %s $mode -64bit -reflib %s/%s_IncisiveLib/worklib -sv_lib %s/%s_IncisiveLib/run.d/librun.so -sv %s.sv $EXTRA_SVDPI_COMP_ARGS $final_cmd %s',...
                cmdFirst,pathToSource,dpiname(1:end-4),pathToSource,dpiname(1:end-4),tbname,vverify);
            end
        else
            if(isfield(dpig_codeinfo,{'MLCoderCodeGen'}))


                runCmd=sprintf('xrun $EXTRA_SVDPI_SIM_ARGS $mode -64bit -sv_lib ../%s.so -sv ../%s.sv ../%s.sv ./%s.sv $final_cmd',...
                dpig_codeinfo.BuildName,dpipkgname,dpiname,tbname);
            else
                runCmd=sprintf('xrun %s $mode -64bit -sv_lib ../%s.so -sv ../%s.sv ../%s.sv ./%s.sv $EXTRA_SVDPI_COMP_ARGS $final_cmd %s',...
                cmdFirst,dpiname(1:end-4),dpipkgname,dpiname,tbname,vverify);
            end
        end
        genSV.appendCode(runCmd);
        if isunix()
            fileattrib(shellFile,'+x','u');
        end
    end

    function Generate_VCS_Script()

        shellFile=fullfile(SrcPathTemp,dpigTbOutDir,'run_tb_vcs.sh');
        dpigenerator_disp(['Generating test bench simulation script for Synopsys VCS ',dpigenerator_getfilelink(shellFile)]);
        genSV=dpig.internal.GenSVCode(shellFile);
        genSV.appendCode(sprintf('#!/bin/sh'));
        genSV.appendCode(sprintf('# Description: Shell script for simulating generated test bench %s with Synopsys VCS',tbname));
        genSV.addGeneratedBy('# ');
        genSV.appendCode(l_get_verify_plusargs_comments());
        genSV.addGuiOrBatchModeConditionInSh_VCS();
        genSV.appendCode(sprintf('vlogan -full64 -sverilog ../%s.sv ../%s.sv ./%s.sv',dpipkgname,dpiname,tbname));
        if(isfield(dpig_codeinfo,{'MLCoderCodeGen'}))


            soname=dpig_codeinfo.BuildName;
        else
            soname=dpiname(1:end-4);
        end
        if~hdlverifierfeature('VERBOSE_VERIFY')
            genSV.appendCode(sprintf('vcs $mode -full64 %s $EXTRA_SVDPI_COMP_ARGS',tbname));
            genSV.appendCode(sprintf('./simv $EXTRA_SVDPI_SIM_ARGS -sv_lib ../%s $final_cmd',soname));
        else
            genSV.appendCode(sprintf('vcs $mode -full64 %s $EXTRA_SVDPI_COMP_ARGS',tbname));
            genSV.appendCode(sprintf('./simv $EXTRA_SVDPI_SIM_ARGS -sv_lib ../%s $final_cmd +VERBOSE_VERIFY',soname));
        end
        if isunix()
            fileattrib(shellFile,'+x','u');
        end
    end

    function Generate_Vivado_Script

        if ispc
            comment='REM';
            fileext='.bat';
            call='call ';
            mode='%mode%';
        else
            comment='#';
            fileext='.sh';
            call='';
            mode='$mode';
        end

        shellFile=fullfile(SrcPathTemp,dpigTbOutDir,['run_tb_vivado',fileext]);
        dpigenerator_disp(['Generating test bench simulation script for Vivado Simulator ',dpigenerator_getfilelink(shellFile)]);
        genSV=dpig.internal.GenSVCode(shellFile);


        genSV.appendCode(sprintf('%s Description: Script for simulating generated test bench %s with Vivado Simulator',comment,tbname));
        genSV.addGeneratedBy([comment,' ']);
        genSV.appendCode(l_get_verify_plusargs_comments(comment));
        if ispc
            genSV.addGuiOrBatchModeConditionInBatch_Vivado();
        else
            genSV.addGuiOrBatchModeConditionInSh_Vivado();
        end
        genSV.appendCode(sprintf('%s xvlog -sv ../%s.sv ../%s.sv ./%s.sv',call,dpipkgname,dpiname,tbname));
        if(isfield(dpig_codeinfo,{'MLCoderCodeGen'}))


            libname=dpig_codeinfo.BuildName;
        else
            libname=dpiname(1:end-4);
        end
        if strcmp(computer,'PCWIN64')&&~isfield(dpig_codeinfo,{'MLCoderCodeGen'})
            libname=[libname,'_win64.dll'];
        elseif strcmp(computer,'PCWIN64')
            libname=[libname,'.dll'];
        else
            libname=[libname,'.so'];
        end

        if~hdlverifierfeature('VERBOSE_VERIFY')
            genSV.appendCode(sprintf('%s xelab -timescale 1ns/1ps %s -sv_root ../ -sv_lib %s -s %s_sim',call,tbname,libname,tbname));
        else
            genSV.appendCode(sprintf('%s xelab -timescale 1ns/1ps %s -sv_root ../ -sv_lib %s -s %s_sim +VERBOSE_VERIFY',call,tbname,libname,tbname));
        end
        genSV.appendCode(sprintf('%s xsim %s %s_sim',call,mode,tbname));
        if isunix()
            fileattrib(shellFile,'+x','u');
        end
    end
end



function l_checkSampleTime(dpig_codeInfo)
    allPorts=[];
    if dpig_codeInfo.InStruct.NumPorts>0
        allPorts=[allPorts;dpig_codeInfo.InStruct.Port(:)];
    end

    if dpig_codeInfo.OutStruct.NumPorts>0
        allPorts=[allPorts;dpig_codeInfo.OutStruct.Port(:)];
    end
    allPorts=allPorts';


    if nnz(arrayfun(@(x)isempty(x.SampleOffset),allPorts))>0||nnz(arrayfun(@(x)isempty(x.SamplePeriod),allPorts))>0
        error(message('HDLLink:DPIG:PortFromTriggerSubsysNotSupportedForTB'));
    end
    allOffset=arrayfun(@(x)x.SampleOffset,allPorts);
    if length(unique(allOffset))~=1
        error(message('HDLLink:DPIG:MultiOffsetNotSupported',num2str(allOffset)));
    end
end

function l_readFromDatFile(genSV,dtype,DimensionInfo,varName,fidVar,tbDoneVar,fscanfStatusVar,realTmp,shortrealTmp,isInit,IsScalarizePortsEnabled)
    if DimensionInfo.IsUFStructArray
        if IsScalarizePortsEnabled
            for idx=1:DimensionInfo.Dim4DataFileRead
                l_readOneFromDatFile(varName{idx},isInit);
            end
        else

            idxName=genSV.getUniqueName('idx');
            varName=strrep(varName,'<index>',idxName);
            genSV.appendCode(sprintf('for(integer %s=0;%s<%d;%s=%s+1) begin',idxName,idxName,DimensionInfo.Dim4DataFileRead,idxName,idxName));
            genSV.addIndent;


            if DimensionInfo.LeafDim==1
                l_readOneFromDatFile(varName,isInit);
            else
                tmpName=sprintf('%s[%s%%%d]',varName,idxName,DimensionInfo.LeafDim);
                l_readOneFromDatFile(tmpName,isInit);
            end
            genSV.reduceIndent;
            genSV.appendCode('end');
        end
    else
        if DimensionInfo.Dim4DataFileRead==1
            l_readOneFromDatFile(varName,isInit);
        else
            if IsScalarizePortsEnabled
                for idx=1:DimensionInfo.Dim4DataFileRead
                    tmpName=[varName,'_',num2str(idx-1)];
                    l_readOneFromDatFile(tmpName,isInit);
                end
            else
                idxName=genSV.getUniqueName('idx');
                genSV.appendCode(sprintf('for(integer %s=0;%s<%d;%s=%s+1) begin',idxName,idxName,DimensionInfo.Dim4DataFileRead,idxName,idxName));
                genSV.addIndent;
                tmpName=[varName,'[',idxName,']'];
                l_readOneFromDatFile(tmpName,isInit);
                genSV.reduceIndent;
                genSV.appendCode('end');
            end
        end
    end


    if isInit
        genSV.appendCode(sprintf('%s = $rewind(%s);',fscanfStatusVar,fidVar));
    end
    function l_readOneFromDatFile(localVarName,isInit)
        if strcmpi(dtype,'real')
            genSV.appendCode(sprintf('%s = $fscanf(%s, "%%h", %s);',fscanfStatusVar,fidVar,realTmp));
            genSV.appendCode(sprintf('%s = $bitstoreal(%s);',localVarName,realTmp));
        elseif strcmpi(dtype,'shortreal')
            genSV.appendCode(sprintf('%s = $fscanf(%s, "%%h", %s);',fscanfStatusVar,fidVar,shortrealTmp));
            genSV.appendCode(sprintf('%s = $bitstoshortreal(%s);',localVarName,shortrealTmp));
        else
            genSV.appendCode(sprintf('%s = $fscanf(%s, "%%h", %s);',fscanfStatusVar,fidVar,localVarName));
        end
        if~isInit
            genSV.appendCode(sprintf('if ($feof(%s)) ',fidVar))
            genSV.appendCode(sprintf('    %s = 1;',tbDoneVar));
        end
    end
end

function l_generateAssertion(genSV,ExpectedVar,OrigVar,dtype,testFailureVar,IdxName)
    if nargin==6
        errorDisp=sprintf('    $display("ERROR in output %s[%%0d] at time %%0t :", %s, $time);',ExpectedVar,IdxName);
        ExpectedVar=sprintf('%s[%s]',ExpectedVar,IdxName);
    else
        errorDisp=sprintf('    $display("ERROR in output %s at time %%0t :", $time);',ExpectedVar);
    end
    if strcmpi(dtype,'real')||strcmpi(dtype,'shortreal')
        genSV.appendCode(sprintf('assert ( ((%s - %s) < 2.22045e-16) && ((%s - %s) > -2.22045e-16) ) else begin',ExpectedVar,OrigVar,ExpectedVar,OrigVar));
        genSV.appendCode(sprintf('    %s = 1;',testFailureVar));
        genSV.appendCode(errorDisp);
        genSV.appendCode(sprintf('    $display("Expected %%e; Actual %%e; Difference %%e", %s, %s, %s-%s);',ExpectedVar,OrigVar,ExpectedVar,OrigVar));
    else
        genSV.appendCode(sprintf('assert (%s == %s) else begin',ExpectedVar,OrigVar));
        genSV.appendCode(sprintf('    %s = 1;',testFailureVar));
        genSV.appendCode(errorDisp);
        genSV.appendCode(sprintf('    $display("Expected %%h; Actual %%h", %s, %s);',ExpectedVar,OrigVar));
    end
    genSV.appendCode('end');
end

function[FlattenedDimensions,IsStructArray]=l_getStructArrayInfo(StructInfo)
    if isempty(StructInfo)
        FlattenedDimensions=1;
        IsStructArray=false;
    else
        if nnz(StructInfo.TopStructDim>1)>0
            FlattenedDimensions=prod(StructInfo.TopStructDim);
            IsStructArray=true;
        else
            FlattenedDimensions=1;
            IsStructArray=false;
        end
    end
end

function l_AddMultirateIfWrapper(genSV,MultiRateCounter,BeginOrEnd)



    if isempty(MultiRateCounter)
        return;
    end



    switch BeginOrEnd
    case 'begin'

        genSV.addComment('Multirate port scheduling');
        genSV.appendCode(['if(',MultiRateCounter,'==0)begin']);
        genSV.addIndent;
    case 'end'
        genSV.reduceIndent;
        genSV.appendCode(['end /* end: ',['if(',MultiRateCounter,'==0)'],'*/']);
    otherwise
    end
end

function l_CreateTrueIdentifierMap4PortStructs(keyv,...
    StructFieldInfo,...
    KeyVal2TopStructName,...
    TopStructName2StructInfo)
    if~isempty(StructFieldInfo)

        KeyVal2TopStructName(keyv)=StructFieldInfo.TopStructName{1};%#ok<NASGU>

        TopStructName2StructInfo(StructFieldInfo.TopStructName{1})=struct('SVDataType',StructFieldInfo.TopStructType{1},...
        'Name',StructFieldInfo.TopStructName{1},...
        'Dim',StructFieldInfo.TopStructDim(1));%#ok<NASGU>
    end
end

function IOTrueIdMap=l_CreateTrueIdentifierMap4Interfaces(IOKeys,IsInterfaceEnabled,InterfaceId)

    if isempty(IOKeys)
        IOTrueIdMap=containers.Map;
    elseif IsInterfaceEnabled
        IOTrueIdMap=containers.Map(IOKeys,cellfun(@(x)[InterfaceId,'.',x],IOKeys,'UniformOutput',false));
    else


        IOTrueIdMap=containers.Map(IOKeys,IOKeys);

    end
end
function[DimensionInfo,RcvDataId]=l_getDimensionAndRcvDataId(dpig_codeinfo,InputTrueIdentifiers,KeyVal2TopStructName,KeyVal2StructTrueIdentifier,KeyVal2FlatScalarTrueIdentifier,ReceivingDataVars,IO_TP_Map,IOVar,IsScalarizePortsEnabled)

    if isfield(dpig_codeinfo,{'MLCoderCodeGen'})

        [FlattenedStructDimensions,IsStructArray_r]=l_getStructArrayInfo(IO_TP_Map(IOVar).StructInfo);
    else

        [FlattenedStructDimensions,IsStructArray_r]=l_getStructArrayInfo(IO_TP_Map(IOVar).StructFieldInfo);
    end


    if isKey(InputTrueIdentifiers,IOVar)&&isKey(KeyVal2TopStructName,IOVar)
        RcvDataId=KeyVal2StructTrueIdentifier(IOVar);


        DimensionInfo=struct('IsUFStructArray',IsStructArray_r,...
        'LeafDim',IO_TP_Map(IOVar).Dim,...
        'FlattenedSADim',FlattenedStructDimensions,...
        'Dim4DataFileRead',FlattenedStructDimensions*IO_TP_Map(IOVar).Dim);
    elseif isKey(InputTrueIdentifiers,IOVar)&&IsStructArray_r&&IsScalarizePortsEnabled
        RcvDataId=KeyVal2FlatScalarTrueIdentifier(IOVar);
        DimensionInfo=struct('IsUFStructArray',true,...
        'LeafDim',IO_TP_Map(IOVar).Dim,...
        'FlattenedSADim',FlattenedStructDimensions,...
        'Dim4DataFileRead',FlattenedStructDimensions*IO_TP_Map(IOVar).Dim);
    else
        RcvDataId=ReceivingDataVars(IOVar);
        DimensionInfo=struct('IsUFStructArray',false,...
        'LeafDim',IO_TP_Map(IOVar).Dim,...
        'FlattenedSADim',FlattenedStructDimensions,...
        'Dim4DataFileRead',FlattenedStructDimensions*IO_TP_Map(IOVar).Dim);
    end
end


function str=l_get_verify_plusargs_comments(comment)
    if nargin==0
        comment='#';
    end
    comments_cell={
'# Using plusarg to determine coverage count for verify() PASS'
'# result.  If filtered, NO covergroup is created. '
'# Examples:'
'#   NO PLUSARG          : at_least=1 (default value)'
'#   +my_model:33:8      : FILTER -- DO NOT COVER (backward compatible behavior)'
'#   +my_model:33:8=0    : FILTER (alternative form)'
'#   +my_model:33:8=-1   : FILTER (alternative form)'
'#   +my_model:33:8=13   : at_least=13'
''
'# Using plusarg to get an INFO message for every unfiltered verify()'
'# result.'
'#   +VERBOSE_VERIFY'
''
    };
    comments_cell=regexprep(comments_cell,'^#',comment);
    str=sprintf('%s\n',comments_cell{:});
end





function l_printTbDone(genSVCode,tbDoneVar,testFailureVar)
    genSVCode.appendCode(sprintf('if (%s == 1) begin',tbDoneVar));
    genSVCode.appendCode(sprintf('    if (%s == 0) ',testFailureVar));
    genSVCode.appendCode('        $display("**************TEST COMPLETED (PASSED)**************");');
    genSVCode.appendCode('    else');
    genSVCode.appendCode('        $display("**************TEST COMPLETED (FAILED)**************");');
    genSVCode.appendCode('    $finish;');
    genSVCode.appendCode('end');
end
