




classdef UtilityFunctionsWriter<handle
    properties(Access=private)
Writer
ModelInterface
CodeInfo
    end


    methods(Access=public)
        function this=UtilityFunctionsWriter(codeInfo,modelInterface,writer)
            this.CodeInfo=codeInfo;
            this.ModelInterface=modelInterface;
            this.Writer=writer;
        end


        function write(this)
            this.writeRAccelMethods;
            this.writeGlobalDSMDeclarations;
            this.writeNonInlinedSFunctionDeclarations;
        end
    end


    methods(Access=private)
        function writeRAccelMethods(this)




            this.Writer.writeLine('const char* rt_GetMatSignalLoggingFileName(void) {');
            this.Writer.writeLine('return NULL;');
            this.Writer.writeLine('}');

            this.Writer.writeLine('const char* rt_GetMatSigLogSelectorFileName(void) {');
            this.Writer.writeLine('return NULL;');
            this.Writer.writeLine('}');

            this.Writer.writeLine('void* rt_GetOSigstreamManager(void) {');
            this.Writer.writeLine('return NULL;');
            this.Writer.writeLine('}');

            this.Writer.writeLine('void* rt_slioCatalogue(void) {');
            this.Writer.writeLine('return NULL;');
            this.Writer.writeLine('}');

            this.Writer.writeLine('void* rtwGetPointerFromUniquePtr(void* uniquePtr) {');
            this.Writer.writeLine('return NULL;');
            this.Writer.writeLine('}');



            this.Writer.writeLine('void* CreateDiagnosticAsVoidPtr(const char* id, int nargs, ...) {');
            this.Writer.writeLine('void* voidPtrDiagnostic = NULL;');
            this.Writer.writeLine('va_list args;');
            this.Writer.writeLine('va_start(args, nargs);');
            this.Writer.writeLine('slmrCreateDiagnostic(id, nargs, args, &voidPtrDiagnostic);');
            this.Writer.writeLine('va_end(args);');
            this.Writer.writeLine('return voidPtrDiagnostic;');
            this.Writer.writeLine('}');
            this.Writer.writeLine('void rt_ssSet_slErrMsg(void* S, void* diag) {');
            this.Writer.writeLine('SimStruct* simStrcut = (SimStruct*)S;');
            this.Writer.writeLine('if(!_ssIsErrorStatusAslErrMsg(simStrcut)) {');
            this.Writer.writeLine('_ssSet_slLocalErrMsg(simStrcut, diag);');
            this.Writer.writeLine('} else {');
            this.Writer.writeLine('_ssDiscardDiagnostic(simStrcut, diag);');
            this.Writer.writeLine('}');
            this.Writer.writeLine('}');
            this.Writer.writeLine('void rt_ssReportDiagnosticAsWarning(void* S, void* diag) {');
            this.Writer.writeLine('_ssReportDiagnosticAsWarning((SimStruct*)S, diag);');
            this.Writer.writeLine('}');
            this.Writer.writeLine('void rt_ssReportDiagnosticAsInfo(void* S, void* diag) {');
            this.Writer.writeLine('_ssReportDiagnosticAsInfo((SimStruct*)S, diag);');
            this.Writer.writeLine('}');
            this.Writer.writeLine('const char* rt_CreateFullPathToTop(const char* toppath, const char* subpath) {');
            this.Writer.writeLine('char* fullpath = NULL;');
            this.Writer.writeLine('slmrCreateFullPathToTop(toppath, subpath, &fullpath);');
            this.Writer.writeLine('return fullpath;');
            this.Writer.writeLine('}');










            this.Writer.writeLine('boolean_T slIsRapidAcceleratorSimulating(void) {');
            this.Writer.writeLine('return false;');
            this.Writer.writeLine('}');










            this.Writer.writeLine('void  rt_RAccelReplaceFromFilename(const char *blockpath, char *fileName) {');
            this.Writer.writeLine('(void)blockpath;');
            this.Writer.writeLine('(void)fileName;');
            this.Writer.writeLine('}');










            this.Writer.writeLine('void  rt_RAccelReplaceToFilename(const char *blockpath, char *fileName) {');
            this.Writer.writeLine('(void)blockpath;');
            this.Writer.writeLine('(void)fileName;');
            this.Writer.writeLine('}');

            if slfeature('ModelRefAccelSupportsOPForSimscapeBlocks')<4











                this.Writer.writeLine('void  slsaCacheDWorkPointerForSimTargetOP(void* ss, void** ptr) {');
                this.Writer.writeLine('(void)ss;');
                this.Writer.writeLine('(void)ptr;');
                this.Writer.writeLine('}');

                this.Writer.writeLine('void  slsaCacheDWorkDataForSimTargetOP(void* ss, void* ptr, unsigned int sizeInBytes) {');
                this.Writer.writeLine('(void)ss;');
                this.Writer.writeLine('(void)ptr;');
                this.Writer.writeLine('(void)sizeInBytes;');
                this.Writer.writeLine('}');


                this.Writer.writeLine('void slsaSaveRawMemoryForSimTargetOP(void* ss, const char* key, void** ptr, unsigned int sizeInBytes,');
                this.Writer.writeLine('void* (*customOPSaveFcn) (void* dworkPtr, unsigned int* sizeInBytes),');
                this.Writer.writeLine('void  (*customOPRestoreFcn) (void* dworkPtr, const void* data, unsigned int sizeInBytes)) {');
                this.Writer.writeLine('(void)ss;');
                this.Writer.writeLine('(void)key;');
                this.Writer.writeLine('(void)ptr;');
                this.Writer.writeLine('(void)sizeInBytes;');
                this.Writer.writeLine('(void)customOPSaveFcn;');
                this.Writer.writeLine('(void)customOPRestoreFcn;');
                this.Writer.writeLine('}');
            end
        end


        function writeGlobalDSMDeclarations(this)
            if(~isempty(fields(this.ModelInterface.GlobalDSMDeclarations)))
                dsmDeclarations=this.ModelInterface.GlobalDSMDeclarations.DSMDeclaration;
                if(length(dsmDeclarations)==1)
                    dsmDeclarations={dsmDeclarations};
                end

                writtenDecls=containers.Map('KeyType','char','ValueType','char');
                for i=1:length(dsmDeclarations)
                    dsmDecl=dsmDeclarations{i};

                    name=dsmDecl.Name;
                    if(~writtenDecls.isKey(name))
                        decl=dsmDecl.Declaration;
                        writtenDecls(name)=decl;
                        this.Writer.writeLine(decl);
                    end
                end
            end
        end


        function writeNonInlinedSFunctionDeclarations(this)
            if(~isempty(fields(this.ModelInterface.NonInlinedSFcnNames)))
                names=this.ModelInterface.NonInlinedSFcnNames.Function;
                if(length(names)==1)
                    names={names};
                end

                names=unique(cellfun(@(x)x.Name,names,'UniformOutput',false));
                for i=1:length(names)
                    name=names{i};


                    this.Writer.writeLine(['void ',name,'(SimStruct *S) {']);
                    this.Writer.writeLine('(void)S;');
                    this.Writer.writeLine('}');
                end
            end
        end
    end
end


