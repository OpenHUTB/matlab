




classdef TargetInterface<coder.profile.TargetInterface

    properties
initFcn
instrumentationFcn
uploadResultsFcn
isPerFileTRData
    end

    methods(Access=public)
        function this=TargetInterface(initFcn,instrumentationFcn,uploadResultsFcn,isPerFileTRData)
            this.initFcn=initFcn;
            this.instrumentationFcn=instrumentationFcn;
            this.uploadResultsFcn=uploadResultsFcn;
            this.isPerFileTRData=isPerFileTRData;
        end

        function invocation=targetWritePauseCall(this)
            invocation=sprintf('%s();',this.uploadResultsFcn);
        end

        function invocation=targetWriteTerminateCall(this)
            invocation=sprintf('%s();',this.uploadResultsFcn);
        end

        function invocation=targetWriteStepCall(this)
            invocation=sprintf('%s();',this.uploadResultsFcn);
        end

        function invocation=targetWriteInitCall(this)
            invocation=sprintf('%s();',this.initFcn);
        end

        function targetWriteProbeExportedFcnPrototypes(this,writer,~)
            writer.wComment('Indicate that instrumentation point was hit');
            writer.writeLine('void %s(%s sectionId);',...
            this.instrumentationFcn,...
            this.IdentifierCDataType);



            writer.writeLine('void %s(void);',this.uploadResultsFcn);
            writer.writeLine('void %s(void);',this.initFcn);
        end

        function targetWriteSectionFcns(this,writer,targetCollectDataFcnName,~)
            writer.writeLine('#include <string.h>');

            sectionIdVar='sectionId';
            fcnSignature=sprintf('void %s(%s %s)',...
            this.instrumentationFcn,...
            this.IdentifierCDataType,...
            sectionIdVar);

            writer.wBlockStart('%s',fcnSignature);
            if isempty(targetCollectDataFcnName)
                writer.writeLine('(void) %s;',sectionIdVar);
            else
                writer.wComment('Send information that instrumentation point was hit to host');
                lCodeInstrSizeCDataType=...
                coder.profile.ExecTimeConfig.getCodeInstrNumElsCDataType...
                (this.TargetWordSize);

                writer.writeLine('%s((void *)0, (%s)(0), %s);',...
                targetCollectDataFcnName,...
                lCodeInstrSizeCDataType,...
                sectionIdVar);
            end
            writer.wBlockEnd;

            allProbes=this.GlobalRegistry.getAllProbes();

            allVarRadixes={};
            allSectionIds=[];

            for ii=1:numel(allProbes)
                if~strcmp(allProbes{ii}{1},'CODECOV_PROBE')
                    continue
                end
                moduleName=allProbes{ii}{2}{2};
                dbFile=codeinstrum.internal.codecov.ModuleUtils.getCodeCovDataFiles(moduleName);

                if this.isPerFileTRData
                    psCovRslt=internal.cxxfe.instrum.runtime.ResultHitsManager.import(dbFile);
                    lstFileStr=psCovRslt.getFiles();
                    for i=1:length(lstFileStr)
                        subdbFile=fullfile(fileparts(dbFile),[lstFileStr(i).uniqueId,'.db']);
                        instrumenter=codeinstrum.internal.Instrumenter.instance(subdbFile,this.isPerFileTRData);
                        instrumenter.UniqueID=lstFileStr(i).uniqueId;
                        writer.writeLine(instrumenter.generateInstrumUtilsSrc(false));
                        allSectionIds(end+1)=allProbes{ii}{2}{1};%#ok<AGROW>
                    end
                    if isempty(lstFileStr)
                        allSectionIds(end+1)=allProbes{ii}{2}{1};%#ok<AGROW>
                    end
                else
                    instrumenter=codeinstrum.internal.Instrumenter.instance(dbFile);
                    writer.writeLine(instrumenter.generateInstrumUtilsSrc(false));
                    allVarRadixes{end+1}=instrumenter.InstrVarRadix;%#ok<AGROW>
                    allSectionIds(end+1)=allProbes{ii}{2}{1};%#ok<AGROW>
                end
            end
            if this.isPerFileTRData


                writer.writeLine('typedef struct __mw_instrum_node {');
                writer.writeLine('    const char * uniqueID;');
                writer.writeLine(sprintf('    %s * hitsTbl;',lCodeInstrSizeCDataType));
                writer.writeLine('    void* profilingTbl;');
                writer.writeLine('    struct __mw_instrum_node* next;');
                writer.writeLine(sprintf('    %s numHits;',lCodeInstrSizeCDataType));
                writer.writeLine(sprintf('    %s numProfiling;',lCodeInstrSizeCDataType));
                writer.writeLine(sprintf('    %s internalInfo[1];',lCodeInstrSizeCDataType));
                writer.writeLine('}__mw_instrum_node;');

                writer.writeLine('static __mw_instrum_node* head = NULL;');
                writer.writeCellLines...
                ({'/* Functions with a C call interface */';
                '#ifdef __cplusplus';
                'extern "C" {';
                '#endif'});
                writer.writeLine('void psprofile_register_file(__mw_instrum_node* pFileData, %s fcnEnterId);',lCodeInstrSizeCDataType);
                writer.writeCellLines...
                ({'#ifdef __cplusplus';
                '}';
                '#endif'});
                writer.writeLine('void psprofile_register_file(__mw_instrum_node* pFileData, %s fcnEnterId) {',lCodeInstrSizeCDataType);
                writer.writeLine('  ((__mw_instrum_node*)(pFileData))->next = head;');
                writer.writeLine('  head = pFileData;');
                writer.writeLine('  memset((void *)&head->hitsTbl[0], 0, (%s)(head->numHits * sizeof(uint32_T)));',...
                lCodeInstrSizeCDataType);
                writer.writeLine('}');
            end



            writer.writeLine('void %s(void) {',this.uploadResultsFcn);
            if~isempty(targetCollectDataFcnName)
                writer.writeLine('  %s sz;',lCodeInstrSizeCDataType);
                if this.isPerFileTRData
                    writer.writeLine('  %s length;',lCodeInstrSizeCDataType);
                    writer.writeLine('  unsigned char last;');
                    writer.writeLine("  struct __mw_instrum_node* ptr;");
                    writer.writeLine("  ptr = head;");
                    writer.writeLine('  while (ptr != NULL) {');
                    writer.writeLine('    sz = (%s)(ptr->numHits * sizeof(%s));',...
                    lCodeInstrSizeCDataType,lCodeInstrSizeCDataType);
                    writer.writeLine('    length = (%s)strlen(ptr->uniqueID);',lCodeInstrSizeCDataType);
                    writer.writeLine('    %s((void *)&length, sizeof(length), %d);',...
                    targetCollectDataFcnName,...
                    allSectionIds(1));
                    writer.writeLine('    %s((void *)ptr->uniqueID, length, %d);',...
                    targetCollectDataFcnName,...
                    allSectionIds(1));
                    writer.writeLine('    %s((void *)ptr->hitsTbl, sz, %d);',...
                    targetCollectDataFcnName,...
                    allSectionIds(1));
                    writer.writeLine('    last = (ptr->next!=NULL)?0:1;');
                    writer.writeLine('    %s((void *)&last, sizeof(last), %d);',...
                    targetCollectDataFcnName,...
                    allSectionIds(1));

                    writer.writeLine('    memset((void *) ptr->hitsTbl, 0, sz);');
                    writer.writeLine('    ptr = ptr->next;');
                    writer.writeLine('  }');
                end

                for ii=1:numel(allVarRadixes)
                    instrVarRadix=allVarRadixes{ii};
                    sectionId=allSectionIds(ii);
                    if~this.isPerFileTRData

                        writer.writeLine('  sz = (%s)(%s_hits_size * sizeof(uint32_T));',...
                        lCodeInstrSizeCDataType,instrVarRadix);
                        writer.writeLine('  %s((void *)%s_hits, sz, %d);',...
                        targetCollectDataFcnName,instrVarRadix,...
                        sectionId);

                        writer.writeLine('  memset((void *) %s_hits, 0, sz);',instrVarRadix);
                    end
                end
            end
            writer.writeLine('}');




            writer.writeLine('void %s(void) {',this.initFcn);
            if~isempty(targetCollectDataFcnName)&&~this.isPerFileTRData
                writer.writeLine('  %s sz;',lCodeInstrSizeCDataType);
                for ii=1:numel(allVarRadixes)
                    instrVarRadix=allVarRadixes{ii};
                    writer.writeLine('  sz = (%s)(%s_hits_size * sizeof(uint32_T));',...
                    lCodeInstrSizeCDataType,instrVarRadix);
                    writer.writeLine('  memset((void *) %s_hits, 0, sz);',instrVarRadix);
                end
            end
            writer.writeLine('}');
        end

        function targetWriteInit(~,~)

        end
    end
end


