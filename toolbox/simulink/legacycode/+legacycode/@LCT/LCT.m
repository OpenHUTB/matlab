classdef LCT





    properties
        SFunctionName=legacycode.LCT.DefaultSpecStruct.SFunctionName;
        InitializeConditionsFcnSpec=legacycode.LCT.DefaultSpecStruct.InitializeConditionsFcnSpec;
        OutputFcnSpec=legacycode.LCT.DefaultSpecStruct.OutputFcnSpec;
        StartFcnSpec=legacycode.LCT.DefaultSpecStruct.StartFcnSpec;
        TerminateFcnSpec=legacycode.LCT.DefaultSpecStruct.TerminateFcnSpec;
        GlobalVarSpec=legacycode.LCT.DefaultSpecStruct.GlobalVarSpec;
        GetSetSpec=legacycode.LCT.DefaultSpecStruct.GetSetSpec;
        HeaderFiles=legacycode.LCT.DefaultSpecStruct.HeaderFiles;
        SourceFiles=legacycode.LCT.DefaultSpecStruct.SourceFiles;
        HostLibFiles=legacycode.LCT.DefaultSpecStruct.HostLibFiles;
        TargetLibFiles=legacycode.LCT.DefaultSpecStruct.TargetLibFiles;
        IncPaths=legacycode.LCT.DefaultSpecStruct.IncPaths;
        SrcPaths=legacycode.LCT.DefaultSpecStruct.SrcPaths;
        LibPaths=legacycode.LCT.DefaultSpecStruct.LibPaths;
        SampleTime=legacycode.LCT.DefaultSpecStruct.SampleTime;
        Options=legacycode.LCT.DefaultSpecStruct.Options;
    end

    properties(Constant,Access=private)
        DefaultSpecStruct=struct(...
        'SFunctionName','',...
        'InitializeConditionsFcnSpec','',...
        'OutputFcnSpec','',...
        'StartFcnSpec','',...
        'TerminateFcnSpec','',...
        'GlobalVarSpec',{{}},...
        'GetSetSpec',{{}},...
        'HeaderFiles',{{}},...
        'SourceFiles',{{}},...
        'HostLibFiles',{{}},...
        'TargetLibFiles',{{}},...
        'IncPaths',{{}},...
        'SrcPaths',{{}},...
        'LibPaths',{{}},...
        'SampleTime','inherited',...
        'Options',legacycode.LCT.DefaultOptionsStruct...
        );

        DefaultOptionsStruct=struct(...
        'isMacro',false,...
        'isVolatile',true,...
        'canBeCalledConditionally',true,...
        'useTlcWithAccel',true,...
        'language','C',...
        'singleCPPMexFile',false,...
        'supportsMultipleExecInstances',false,...
        'convertNDArrayToRowMajor',false,...
        'supportCoverage',false,...
        'supportCoverageAndDesignVerifier',false,...
        'supportCodeReuseAcrossModels',false,...
        'outputsConditionallyWritten',false,...
        'stubSimBehavior',false,...
        'isRowMajorLayoutForCodeGen',false,...
        'translateLegacyTypeDefGuards',false,...
        'namedTypeSource',Simulink.data.DataAccessor.createWithNoContext,...
        'LibGroup',{{}}...
...
...
        );

        HiddenSpecFields={
'GlobalVarSpec'...
        ,'GetSetSpec'...
        };

        HiddenOptionFields={
'stubSimBehavior'...
        ,'isRowMajorLayoutForCodeGen',...
        'translateLegacyTypeDefGuards',...
'namedTypeSource'...
        ,'LibGroup'...
        };
    end


    methods




        function obj=LCT(varargin)


            if(nargin>=1)

                lctStruct=legacycode.LCT.validateInputStruct('FieldNames',varargin{1});

                for i=1:length(lctStruct)




                    obj(i).Options=lctStruct(i).Options;%#ok<AGROW>

                    obj(i).SFunctionName=lctStruct(i).SFunctionName;%#ok<AGROW>

                    obj(i).InitializeConditionsFcnSpec=lctStruct(i).InitializeConditionsFcnSpec;%#ok<AGROW>
                    obj(i).OutputFcnSpec=lctStruct(i).OutputFcnSpec;%#ok<AGROW>
                    obj(i).StartFcnSpec=lctStruct(i).StartFcnSpec;%#ok<AGROW>
                    obj(i).TerminateFcnSpec=lctStruct(i).TerminateFcnSpec;%#ok<AGROW>

                    obj(i).GlobalVarSpec=lctStruct(i).GlobalVarSpec;%#ok<AGROW>
                    obj(i).GetSetSpec=lctStruct(i).GetSetSpec;%#ok<AGROW>
                    obj(i).HeaderFiles=lctStruct(i).HeaderFiles;%#ok<AGROW>
                    obj(i).SourceFiles=lctStruct(i).SourceFiles;%#ok<AGROW>
                    obj(i).HostLibFiles=lctStruct(i).HostLibFiles;%#ok<AGROW>
                    obj(i).TargetLibFiles=lctStruct(i).TargetLibFiles;%#ok<AGROW>
                    obj(i).IncPaths=lctStruct(i).IncPaths;%#ok<AGROW>
                    obj(i).SrcPaths=lctStruct(i).SrcPaths;%#ok<AGROW>
                    obj(i).LibPaths=lctStruct(i).LibPaths;%#ok<AGROW>

                    obj(i).SampleTime=lctStruct(i).SampleTime;%#ok<AGROW>


                    legacycode.LCT.conflictingCFileExists(lctStruct(i));
                end
            end

        end




        out=generatesfcn(obj);

        compile(obj,varargin);

        generatetlc(obj);

        generatemakecfg(obj,varargin);

        generateslblock(obj,varargin);

        generatesimfiles(obj,varargin);

    end




    methods



        function obj=set.SFunctionName(obj,strSFcnName)
            obj.SFunctionName=legacycode.LCT.validateInputStruct('SFunctionName',strSFcnName);
        end

        function obj=set.InitializeConditionsFcnSpec(obj,strFcnSpec)
            obj.InitializeConditionsFcnSpec=legacycode.LCT.validateInputStruct('InitializeConditionsFcnSpec',strFcnSpec);
        end

        function obj=set.OutputFcnSpec(obj,strFcnSpec)
            obj.OutputFcnSpec=legacycode.LCT.validateInputStruct('OutputFcnSpec',strFcnSpec);
        end

        function obj=set.StartFcnSpec(obj,strFcnSpec)
            obj.StartFcnSpec=legacycode.LCT.validateInputStruct('StartFcnSpec',strFcnSpec);
        end

        function obj=set.TerminateFcnSpec(obj,strFcnSpec)
            obj.TerminateFcnSpec=legacycode.LCT.validateInputStruct('TerminateFcnSpec',strFcnSpec);
        end

        function obj=set.HeaderFiles(obj,cellStr)
            obj.HeaderFiles=legacycode.LCT.validateInputStruct('HeaderFiles',cellStr);
        end

        function obj=set.SourceFiles(obj,cellStr)
            if strcmp(obj.Options.language,'C')%#ok
                strFileExt='.c';
            else
                strFileExt='.cpp';
            end
            obj.SourceFiles=legacycode.LCT.validateInputStruct('SourceFiles',cellStr,strFileExt);
        end

        function obj=set.HostLibFiles(obj,cellStr)
            obj.HostLibFiles=legacycode.LCT.validateInputStruct('HostLibFiles',cellStr);
        end

        function obj=set.TargetLibFiles(obj,cellStr)
            obj.TargetLibFiles=legacycode.LCT.validateInputStruct('TargetLibFiles',cellStr);
        end

        function obj=set.IncPaths(obj,cellStr)
            obj.IncPaths=legacycode.LCT.validateInputStruct('IncPaths',cellStr);
        end

        function obj=set.SrcPaths(obj,cellStr)
            obj.SrcPaths=legacycode.LCT.validateInputStruct('SrcPaths',cellStr);
        end

        function obj=set.LibPaths(obj,cellStr)
            obj.LibPaths=legacycode.LCT.validateInputStruct('LibPaths',cellStr);
        end

        function obj=set.SampleTime(obj,inputSampleTime)
            obj.SampleTime=legacycode.LCT.validateInputStruct('SampleTime',inputSampleTime);
        end

        function obj=set.Options(obj,inputOptStruct)
            obj.Options=legacycode.LCT.validateInputStruct('Options',inputOptStruct);
        end

    end





    methods(Static=true)
        function help()
            helpview([docroot,'/toolbox/simulink/helptargets.map'],'legacy_code_tool');
        end

        userStruct=getSpecStruct(getUserStruct,lctObj);

        txtBuffer=generateSpecConstructionCmd(iStruct,type);

        varargout=legacyCodeImpl(action,varargin);

        bool=conflictingCFileExists(lctSpec);

    end

    methods(Static=true,Access='protected')
        str=generatePtrCastForMultiDimArg(kind,arg1,arg2);

        varargout=validateInputStruct(varargin);
    end

    methods(Static=true,Hidden=true)
        matInfo=get2DMatrixMarshalingInfo(infoStruct,typeId,dims)
        out=getOrCompareDataTypeChecksum(modelName,dtypeName,expectedChk)
    end




    methods(Access='protected')




        str=generateSfcnDataDimStr(obj,infoStruct,thisType,thisDataId,defaultStr);

        dimStr=generateSfcnDataDimStrRecursively(obj,infoStruct,thisType,thisDataId,thisDim,defaultStr);

        protoStr=generateSfcnFcnCallString(obj,infoStruct,fcnInfo);

        writeSfcnArgumentAccess(obj,fid,infoStruct,fcnStruct);

        writeSfcnMdlCheckParameters(obj,fid,infoStruct);

        writeSfcnMdlDefines(obj,fid,infoStruct);

        writeSfcnMdlHeader(obj,fid,infoStruct);

        writeSfcnMdlInitializeConditions(obj,fid,infoStruct);

        writeSfcnMdlInitializeSampleTimes(obj,fid,infoStruct);

        writeSfcnMdlInitializeSizes(obj,fid,infoStruct);

        writeSfcnMdlOutputs(obj,fid,infoStruct);

        writeSfcnMdlSetDefaultPortDimensionInfo(obj,fid,infoStruct);

        writeSfcnMdlSetInputPortDimensionInfo(obj,fid,infoStruct);

        writeSfcnMdlSetOutputPortDimensionInfo(obj,fid,infoStruct);

        writeSfcnMdlStart(obj,fid,infoStruct);

        writeSfcnMdlTerminate(obj,fid,infoStruct);

        writeSfcnMdlTrailer(obj,fid,infoStruct);

        writeSfcnMdlWorkWidths(obj,fid,infoStruct);

        writeSfcnPWorkUpdate(obj,fid,infoStruct,fcnStruct);

        writeSfcnSLStructToUserStruct(obj,fid,infoStruct,fcnInfo);

        writeSfcnSSOptions(obj,fid,infoStruct);

        writeSfcnTempVariableForUserStruct(obj,fid,infoStruct,fcnInfo);

        writeSfcnUserStructToSLStruct(obj,fid,infoStruct,fcnInfo);

        writeSfcnTempVariableForStructInfo(obj,fid,infoStruct);

        writeSfcnTempVariableFor2DRowMatrix(obj,fid,infoStruct,fcnInfo);

        writeSfcn2DMatrixConversion(h,fid,infoStruct,fcnInfo,col2Row);




        writeSfcnCGIRClass(obj,fid,infoStruct);

        str=generateSfcnCGIRSizeArgString(obj,infoStruct,thisArg);




        protoStr=generateTlcFcnCallInWrapperString(obj,infoStruct,fcnInfo);

        protoStr=generateTlcFcnCallString(obj,infoStruct,fcnInfo,skipLhs);

        protoStr=generateTlcFcnWrapperCallString(obj,infoStruct,fcnInfo,fcnType);

        protoStr=generateTlcFcnWrapperProtoString(obj,infoStruct,fcnInfo,fcnType);

        str=generateTlcSizeArgString(obj,infoStruct,thisArg);

        writeTlcAddToHeaderFilesListing(obj,fid,headerFileList,spaceDelimiter);

        writeTlcAddToSourceFilesListing(obj,fid,sourceFileList,spaceDelimiter);

        writeTlcArgumentAccess(obj,fid,infoStruct,fcnStruct,isBlockOutputSignal);

        writeTlcAssignSLStructToUserStruct(obj,fid,infoStruct,fcnInfo);

        writeTlcAssignUserStructToSLStruct(obj,fid,infoStruct,fcnInfo);

        writeTlcBlockInstanceSetup(obj,fid,infoStruct);

        writeTlcBlockOutputSignal(obj,fid,infoStruct);

        writeTlcBlockTypeSetup(obj,fid,infoStruct);

        writeTlcFcnGenerateUniqueFileName(obj,fid,infoStruct);

        writeTlcHeader(obj,fid,infoStruct);

        writeTlcInitializeConditions(obj,fid,infoStruct);

        writeTlcOutputs(obj,fid,infoStruct);

        writeTlcStart(obj,fid,infoStruct);

        writeTlcTempVariableForUserStruct(obj,fid,infoStruct,fcnInfo);

        writeTlcTerminate(obj,fid,infoStruct);

        writeTlcTrailer(obj,fid,infoStruct);

        localParam=writeTlcWrapperArgumentAccess(obj,fid,infoStruct,fcnStruct);

        writeTlc2DMatrixConversion(h,fid,infoStruct,fcnInfo,col2Row);

        writeTlcTempVariableFor2DMatrix(h,fid,infoStruct,fcnInfo,fromWrapper);

        writeUserDefinedHeaderIf(obj,fid,infoStruct);




        writeMkCfgCorrectPathName(obj,fid);

        writeMkCfgCorrectPathSep(obj,fid);

        writeMkCfgFindFileExtension(obj,fid);

        writeMkCfgFunctionHeader(obj,fid);

        writeMkCfgGetBuildType(obj,fid);

        writeMkCfgGetSerializedInfo(obj,fid,singleCPPMexFile);

        writeMkCfgInitVar(obj,fid,hasLib,singleCPPMexFile);

        writeMkCfgIsAbsolutePath(obj,fid);

        writeMkCfgLoopForResolvingPaths(obj,fid,hasLib,singleCPPMexFile);

        writeMkCfgMakeInfoStructAssignment(obj,fid,hasLib,singleCPPMexFile);

        writeMkCfgMlPaths(obj,fid);

        writeMkCfgResolveFileInfo(obj,fid);

        writeMkCfgResolvePathInfo(obj,fid);

        writeMkCfgVerifySimulinkVersion(obj,fid);


    end

end


