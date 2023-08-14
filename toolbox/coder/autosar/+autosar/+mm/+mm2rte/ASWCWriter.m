classdef ASWCWriter<autosar.mm.mm2rte.RTEWriter




    properties(Access='private')
        ModelHeaderFileName;
        PIMsInitFcnForHeaderFromTLC;
        PIMsInitFcnForSourceFromTLC;
        ParamsInitFromTLC;
        IsCFileRequired;

        WriterProfileInfo;
        NumProfileInfoFcns;
    end

    properties
        RequiresPbCfg=false;
    end

    methods(Access='public')
        function this=ASWCWriter(ASWCBuilder,modelHeaderFileName)
            this=this@autosar.mm.mm2rte.RTEWriter(ASWCBuilder);
            this.ModelHeaderFileName=modelHeaderFileName;
            rteDir=ASWCBuilder.RTEGenerator.RTEFilesLocation;

            this.IsCFileRequired=this.isCFileRequired;





            pimFileHeader=autosar.mm.mm2rte.ASWCWriter.getRtePimHeaderFileName(...
            rteDir,ASWCBuilder.ASWCName);
            pimFileSource=autosar.mm.mm2rte.ASWCWriter.getRtePimSourceFileName(...
            rteDir,ASWCBuilder.ASWCName);
            this.PIMsInitFcnForHeaderFromTLC=[];
            this.PIMsInitFcnForSourceFromTLC=[];
            if~isempty(dir(pimFileHeader))
                this.PIMsInitFcnForHeaderFromTLC=fileread(pimFileHeader);
                delete(pimFileHeader);
            end
            if~isempty(dir(pimFileSource))
                this.PIMsInitFcnForSourceFromTLC=fileread(pimFileSource);
                delete(pimFileSource);
            end


            this.ParamsInitFromTLC=containers.Map;
            paramInitFile=autosar.mm.mm2rte.ASWCWriter.getRteParamInitFileName(rteDir);
            if~isempty(dir(paramInitFile))
                paramInitText=fileread(paramInitFile);
                paramInitData=regexp(paramInitText,...
                '<param>\n<id>(.*?)</id>\n<value>(.*?)</value>\n</param>','tokens');
                for i=1:length(paramInitData)
                    this.ParamsInitFromTLC(paramInitData{i}{1})=paramInitData{i}{2};
                end
                delete(paramInitFile);
            end

            this.File_h_name=fullfile(rteDir,['Rte_',this.RTEBuilder.ASWCName,'.h']);
            this.WriterHFile=rtw.connectivity.CodeWriter.create(...
            'callCBeautifier',true,...
            'filename',this.File_h_name,...
            'append',false);


            this.NumProfileInfoFcns=0;
            profileInfoFile=fullfile(rteDir,'profileInfo.txt');
            this.WriterProfileInfo=rtw.connectivity.CodeWriter.create(...
            'callCBeautifier',false,...
            'filename',profileInfoFile,...
            'append',false);


            this.WriterProfileInfo.wLine('#%s',this.File_h_name);


            this.WriterProfileInfo.wLine(['#this file contains the list of '...
            ,'RTE methods that the profiling must filter out']);

            if this.IsCFileRequired
                this.File_c_name=fullfile(rteDir,['Rte_',this.RTEBuilder.ASWCName,'.c']);
                this.WriterCFile=rtw.connectivity.CodeWriter.create(...
                'callCBeautifier',true,...
                'filename',this.File_c_name,...
                'append',false);
            end
        end

        function fileNames=getWrittenFiles(this)
            fileNames=getWrittenFiles@autosar.mm.mm2rte.RTEWriter(this);
            if this.IsCFileRequired
                fileNames{end+1}=this.File_c_name;
            end
        end

        function write(this)


            this.writeFileDescription(this.WriterHFile);

            autosar.mm.mm2rte.RTEWriter.writeFileGuardStart(...
            this.WriterHFile,this.File_h_name);


            this.WriterHFile.wLine('#include "%s"',...
            autosar.mm.mm2rte.TypeWriter.RTETypeFileNameH);
            if this.RequiresPbCfg
                this.WriterHFile.wLine('#include "%s"',...
                autosar.mm.mm2rte.PbCfgWriter.RTETypeFileNameH);
            end
            this.WriterHFile.wLine('#include "Compiler.h"');


            rteDataItems=this.RTEBuilder.RTEData.DataItems;
            runnableFcns=rteDataItems(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemRunnable'),rteDataItems));
            accessFcns=rteDataItems(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemAccessFcn'),rteDataItems));
            irvFcns=rteDataItems(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemIRVFcn'),rteDataItems));
            operationCalls=rteDataItems(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemOperationCall')...
            &&~isa(x,'autosar.mm.mm2rte.RTEDataItemServer'),rteDataItems));
            serverFcns=rteDataItems(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemServer'),rteDataItems));
            internalTriggeringPointCalls=rteDataItems(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemInternalTriggeringPoint'),rteDataItems));
            mdgFcns=rteDataItems(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemModeDeclGroupAccess'),rteDataItems));
            cTypedPims=rteDataItems(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemCTypedPIM'),rteDataItems));
            arTypedPims=rteDataItems(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemARTypedPIM'),rteDataItems));
            paramDataItems=rteDataItems(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemParameter'),rteDataItems));
            signalInvDataItems=rteDataItems(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemSignInvInitValue'),rteDataItems));
            exclusiveAreas=rteDataItems(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemExclusiveArea'),rteDataItems));

            if~isempty(cTypedPims)&&this.RTEBuilder.IsMultiInstantiable






                this.WriterHFile.wLine('#include "%s"\n',this.ModelHeaderFileName);
            end

            if~isempty(accessFcns)
                this.emitTransformerErrorDefinition(accessFcns);

                this.WriterHFile.wComment('Data access functions');
                accessFcnNames=this.writeAccessFcns(accessFcns);

                profile=false;
                this.writeProfileInfo(profile,accessFcnNames);
            end

            if~isempty(irvFcns)
                this.WriterHFile.wComment('IRV functions');
                accessFcnNames=this.writeAccessFcns(irvFcns);

                profile=false;
                this.writeProfileInfo(profile,accessFcnNames);
            end

            if~isempty(runnableFcns)
                this.WriterHFile.wComment('Entry point functions');
                this.writeRunnableFcns(runnableFcns);
            end

            if~isempty(operationCalls)

                this.WriterHFile.wComment('Server operation call points');
                accessFcnNames=this.writeAccessFcns(operationCalls);




                serverOps=cell(1,length(serverFcns));
                for serverIdx=1:length(serverFcns)
                    serverOps{serverIdx}=serverFcns{serverIdx}.getOperationName();
                end
                for opIdx=1:length(operationCalls)
                    op=operationCalls{opIdx}.getOperationName();
                    isLocalOp=ismember(op,serverOps);

                    this.writeProfileInfo(isLocalOp,accessFcnNames(opIdx));
                end
            end

            if~isempty(serverFcns)

                this.WriterHFile.wComment('Server functions');
                this.writeAccessFcns(serverFcns);
            end

            if~isempty(internalTriggeringPointCalls)
                this.WriterHFile.wComment('Internal triggering points');
                this.writeIntTrigPointFcns(internalTriggeringPointCalls);
            end

            if~isempty(mdgFcns)
                this.WriterHFile.wComment('Mode Declaration Groups Access Functions');
                accessFcnNames=this.writeAccessFcns(mdgFcns);

                profile=false;
                this.writeProfileInfo(profile,accessFcnNames);
            end

            if~isempty(paramDataItems)
                this.WriterHFile.wComment('Parameters');
                for i=1:length(paramDataItems)
                    accessFcnName=paramDataItems{i}.writeForHeader(...
                    this,...
                    this.WriterHFile);

                    profile=false;
                    this.writeProfileInfo(profile,{accessFcnName});
                end
            end

            if~isempty(cTypedPims)
                this.WriterHFile.wComment('C-Typed Per Instance Memories');
                for i=1:length(cTypedPims)
                    accessFcnName=cTypedPims{i}.writeForHeader(...
                    this.WriterHFile,...
                    this.RTEBuilder.ASWCName,...
                    this.RTEBuilder.IsMultiInstantiable);

                    profile=false;
                    this.writeProfileInfo(profile,{accessFcnName});
                end
            end

            if~isempty(arTypedPims)
                this.WriterHFile.wComment('AR-Typed Per Instance Memories');
                for i=1:length(arTypedPims)
                    accessFcnName=arTypedPims{i}.writeForHeader(this.WriterHFile,...
                    this.RTEBuilder.IsMultiInstantiable);

                    profile=false;
                    this.writeProfileInfo(profile,{accessFcnName});
                end
            end

            if~isempty(signalInvDataItems)

                invInitValNameMap=containers.Map;
                this.WriterHFile.wComment('Signal Invalidation Initial-Value');
                for i=1:length(signalInvDataItems)
                    newInitValName=signalInvDataItems{i}.getInitValVarName;
                    if~isKey(invInitValNameMap,newInitValName)
                        invInitValNameMap(newInitValName)=1;
                        signalInvDataItems{i}.writeForHeader(...
                        this.WriterHFile);
                    end
                end
            end

            if~isempty(exclusiveAreas)
                this.WriterHFile.wComment('ExclusiveAreas');
                for i=1:length(exclusiveAreas)
                    exclusiveAreas{i}.writeForHeader(this.WriterHFile);
                end
            end

            if~isempty(this.PIMsInitFcnForHeaderFromTLC)
                this.WriterHFile.wComment('Initialization functions for Per Instance Memories');
                this.WriterHFile.wLine(this.PIMsInitFcnForHeaderFromTLC);
            end

            autosar.mm.mm2rte.RTEWriter.writeFileGuardEnd(this.WriterHFile);
            this.WriterHFile.close;



            if this.IsCFileRequired
                this.writeFileDescription(this.WriterCFile);


                [~,fileName,fileExt]=fileparts(this.File_h_name);
                this.WriterCFile.wLine('#include "%s"\n',[fileName,fileExt]);

                if~isempty(paramDataItems)
                    this.WriterCFile.wComment('Parameters');
                    for i=1:length(paramDataItems)
                        paramDataItems{i}.writeForSource(...
                        this.WriterCFile,...
                        this.RTEBuilder.IsMultiInstantiable,...
                        this.ParamsInitFromTLC);
                    end
                end

                if~isempty(cTypedPims)
                    this.WriterCFile.wComment('C-Typed Per Instance Memories');
                    for i=1:length(cTypedPims)
                        cTypedPims{i}.writeForSource(...
                        this.WriterCFile,...
                        this.RTEBuilder.ASWCName,...
                        this.RTEBuilder.IsMultiInstantiable);
                    end
                end

                if~isempty(arTypedPims)
                    this.WriterCFile.wComment('AR-Typed Per Instance Memories');
                    for i=1:length(arTypedPims)
                        arTypedPims{i}.writeForSource(this.WriterCFile,...
                        this.RTEBuilder.IsMultiInstantiable);
                    end
                end

                if~isempty(this.PIMsInitFcnForSourceFromTLC)
                    this.WriterCFile.wComment('Initialization functions for Per Instance Memories');
                    this.WriterCFile.wLine(this.PIMsInitFcnForSourceFromTLC);
                end

                if~isempty(signalInvDataItems)

                    invInitValNameMap=containers.Map;
                    this.WriterCFile.wComment('Signal Invalidation Initial-Value');
                    for i=1:length(signalInvDataItems)
                        newInitValName=signalInvDataItems{i}.getInitValVarName;
                        if~isKey(invInitValNameMap,newInitValName)
                            invInitValNameMap(newInitValName)=1;
                            signalInvDataItems{i}.writeForSource(this.WriterCFile);
                        end
                    end
                end

                if~isempty(exclusiveAreas)
                    this.WriterCFile.wComment('ExclusiveAreas');
                    for i=1:length(exclusiveAreas)
                        exclusiveAreas{i}.writeForSource(this.WriterCFile);
                    end
                end

                this.WriterCFile.close;
            end


            assert(length(rteDataItems)==...
            (...
            length(runnableFcns)+...
            length(accessFcns)+...
            length(irvFcns)+...
            length(mdgFcns)+...
            length(paramDataItems)+...
            length(cTypedPims)+...
            length(arTypedPims)+...
            length(operationCalls)+...
            length(internalTriggeringPointCalls)+...
            length(serverFcns)+...
            length(signalInvDataItems)+...
            length(exclusiveAreas)),...
            'ASWCWriter: Not all rteData.DataItems have been processed!');




            expectedNumProfileInfoFcns=length(rteDataItems)-...
            length(runnableFcns)-...
            length(serverFcns)-...
            length(signalInvDataItems)-...
            length(exclusiveAreas)-...
            length(internalTriggeringPointCalls);
            assert(this.NumProfileInfoFcns==expectedNumProfileInfoFcns,...
            'Unexpected number of profile info functions!');
        end
    end

    methods(Access='private')

        function accessFcnNames=writeAccessFcns(this,dataItems)
            accessFcnNames=cell(1,length(dataItems));
            for i=1:length(dataItems)
                dataItem=dataItems{i};

                accessFcnName=dataItem.getAccessFcnName;
                accessFcnNames{i}=accessFcnName;
                rhsArgs=dataItem.getAccessFcnRHSArgs;
                if this.RTEBuilder.IsMultiInstantiable&&...
                    isa(dataItem,'autosar.mm.mm2rte.RTEDataItemOperationCall')
                    RteInstanceArg=[AUTOSAR.CSC.getRTEInstanceType,' ',...
                    AUTOSAR.CSC.getRTEInstanceName];
                    commaOpt='';
                    if~isempty(rhsArgs)
                        commaOpt=', ';
                    end
                    rhsArgs=string([RteInstanceArg,commaOpt,rhsArgs]);
                end

                lhsArg=dataItem.getAccessFcnLHSArg;


                if~isa(dataItem,'autosar.mm.mm2rte.RTEDataItemServer')
                    this.writeRTEContractPhaseAPIMapping(this.WriterHFile,accessFcnName);
                end


                this.WriterHFile.wLine(...
                '%s %s(%s);',...
                lhsArg,...
                accessFcnName,...
rhsArgs...
                );
            end
        end

        function writeProfileInfo(this,profile,fcns)

            for fcnIdx=1:length(fcns)
                if profile
                    prefix='+';
                else
                    prefix='-';
                end
                this.WriterProfileInfo.wLine('%s%s',prefix,fcns{fcnIdx});

                this.NumProfileInfoFcns=this.NumProfileInfoFcns+1;
            end
        end

        function writeRunnableFcns(this,dataItems)
            for i=1:length(dataItems)
                dataItem=dataItems{i};
                accessFcnName=dataItem.RunnableSymbol;
                rhsArgs=dataItem.getAccessFcnRHSArgs(this.RTEBuilder.IsMultiInstantiable);
                lhsArg=dataItem.getAccessFcnLHSArg(this.RTEBuilder.ASWCName);


                this.WriterHFile.wLine(...
                '%s %s(%s);',...
                lhsArg,...
                accessFcnName,...
rhsArgs...
                );
            end
        end

        function writeIntTrigPointFcns(this,dataItems)
            for i=1:length(dataItems)
                dataItem=dataItems{i};

                accessFcnName=dataItem.getAccessFcnName;
                rhsArgs='';
                if this.RTEBuilder.IsMultiInstantiable
                    RteInstanceArg=[AUTOSAR.CSC.getRTEInstanceType,' ',...
                    AUTOSAR.CSC.getRTEInstanceName];
                    rhsArgs=RteInstanceArg;
                end


                this.WriterHFile.wLine(...
                '#define %s(%s) %s(%s)',...
                accessFcnName,...
                rhsArgs,...
                dataItem.getTriggeredRunnableSymbol(),...
rhsArgs...
                );
            end
        end

        function requireCFile=isCFileRequired(this)


            rteDataItems=this.RTEBuilder.RTEData.DataItems;
            requireCFile=any(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemParameter'),rteDataItems))||...
            any(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemARTypedPIM'),rteDataItems))||...
            any(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemCTypedPIM'),rteDataItems))||...
            any(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemSignInvInitValue'),rteDataItems))||...
            any(cellfun(@(x)isa(x,'autosar.mm.mm2rte.RTEDataItemExclusiveArea'),rteDataItems));
        end

        function emitTransformerErrorDefinition(this,accessFcns)
            emitTransformerErrorStruct=false;

            for i=1:length(accessFcns)
                if accessFcns{i}.hasTransformerError()
                    emitTransformerErrorStruct=true;
                    break;
                end
            end

            if emitTransformerErrorStruct
                this.WriterHFile.wLine('/* Transformer Classes */');
                this.WriterHFile.wLine('typedef enum {');
                this.WriterHFile.wLine('    RTE_TRANSFORMER_UNSPECIFIED = 0x00,');
                this.WriterHFile.wLine('    RTE_TRANSFORMER_SERIALIZER = 0x01,');
                this.WriterHFile.wLine('    RTE_TRANSFORMER_SAFETY = 0x02,');
                this.WriterHFile.wLine('    RTE_TRANSFORMER_SECURITY = 0x03,');
                this.WriterHFile.wLine('    RTE_TRANSFORMER_CUSTOM = 0xff');
                this.WriterHFile.wLine('} Rte_TransformerClass;');
                this.WriterHFile.wNewLine;

                this.WriterHFile.wLine('typedef uint8 Rte_TransformerErrorCode;');
                this.WriterHFile.wNewLine;

                this.WriterHFile.wLine('typedef struct {');
                this.WriterHFile.wLine('    Rte_TransformerErrorCode errorCode;');
                this.WriterHFile.wLine('    Rte_TransformerClass transformerClass;');
                this.WriterHFile.wLine('} Rte_TransformerError;');
                this.WriterHFile.wNewLine;
            end
        end
    end

    methods(Hidden,Static,Access='public')

        function hFile=getRtePimHeaderFileName(rteFilesLocation,swcName)
            hFile=fullfile(rteFilesLocation,['Rte_',swcName,'_PIM.h']);
        end

        function cFile=getRtePimSourceFileName(rteFilesLocation,swcName)
            cFile=fullfile(rteFilesLocation,['Rte_',swcName,'_PIM.c']);
        end

        function paramInitFile=getRteParamInitFileName(rteFilesLocation)
            paramInitFile=fullfile(rteFilesLocation,'paramInit.txt');
        end

        function success=writeDSMPimInitFcnFromTLC(rteFilesLocation,swcName,isHeader,initFcn)

            try
                if isHeader
                    fileName=autosar.mm.mm2rte.ASWCWriter.getRtePimHeaderFileName(rteFilesLocation,swcName);
                else
                    fileName=autosar.mm.mm2rte.ASWCWriter.getRtePimSourceFileName(rteFilesLocation,swcName);
                end
                writer=rtw.connectivity.CodeWriter.create(...
                'filename',fileName,...
                'append',true);
                writer.wLine(initFcn);
                writer.close;
                success=true;
            catch ME
                autosar.mm.util.MessageReporter.print(ME.getReport);
                success=false;
            end
        end

        function success=writeParamInitFromTLC(rteFilesLocation,...
            paramId,...
            paramInitStr)

            try
                fileName=autosar.mm.mm2rte.ASWCWriter.getRteParamInitFileName(rteFilesLocation);
                writer=rtw.connectivity.CodeWriter.create(...
                'filename',fileName,...
                'append',true);
                writer.wLine('<param>\n<id>%s</id>\n<value>%s</value>\n</param>',paramId,paramInitStr);
                writer.close;
                success=true;
            catch ME
                autosar.mm.util.MessageReporter.print(ME.getReport);
                success=false;
            end
        end
    end
end


