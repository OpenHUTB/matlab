



classdef HandwrittenInstrumenter<codeinstrum.internal.SFcnInstrumenter



    properties(Access=private)
HandwrittenHandler
    end

    methods
        function obj=HandwrittenInstrumenter(tmpDir,buildOpts)

            sldvDir=fullfile(tmpDir,'mwsldv');
            mkdir(sldvDir);
            obj@codeinstrum.internal.SFcnInstrumenter(sldvDir,buildOpts);

            obj.HandwrittenHandler=sldv.code.sfcn.internal.HandwrittenFEHandler();
        end

        function[instrumentedFiles,moduleName,extraFiles]=instrument(obj)


            obj.generateWrapperFiles();

            [instrumentedFiles,moduleName,extraFiles]=obj.instrument@codeinstrum.internal.SFcnInstrumenter();

            internal.cxxfe.util.printFEMessages(obj.HandwrittenHandler.SFcnMessages);
        end
    end

    methods(Access=protected)
        function setCustomMacroEmitter(~,instrumObj)
            sldv.code.internal.setCustomMacroEmitter(instrumObj.InstrumImpl);
        end

        function ctx=instrumentBeforeParsing(obj,ctx)
            ctx=obj.instrumentBeforeParsing@codeinstrum.internal.SFcnInstrumenter(ctx);

            if~isfield(ctx.extraOpts,'extraFeHandlers')
                ctx.extraOpts.extraFeHandlers={};
            end
            ctx.extraOpts.extraFeHandlers{end+1}=obj.HandwrittenHandler;
        end

        function extraFiles=insertInstrumUtils(~,~)

            extraFiles={};
        end

        function extractCodeInformationTerminate(obj,ctx)
            obj.extractCodeInformationTerminate@codeinstrum.internal.SFcnInstrumenter(ctx);



            if sldv.code.sfcn.internal.HandwrittenInstrumenter.isDefined(ctx.feOpts,...
                'S_FUNCTION_EXPORTS_FUNCTION_CALLS')
                sldv.code.internal.throwError('sldv_sfcn:sldv_sfcn:exportsFunctionCallsNotSupported');
            end
        end

        function feOpts=getFEOptions(obj,langOrIdx)
            includeDir=fullfile(obj.WorkingDir,'include');

            feOpts=obj.getFEOptions@codeinstrum.internal.SFcnInstrumenter(langOrIdx);
            feOpts.Preprocessor.IncludeDirs=[includeDir;...
            feOpts.Preprocessor.IncludeDirs];
        end
    end

    methods(Access=private,Static=true)
        function defined=isDefined(feOpts,symbol)
            symbolEq=[symbol,'='];
            defined=any(strcmp(feOpts.Preprocessor.Defines,symbol))||...
            any(strncmp(feOpts.Preprocessor.Defines,symbolEq,numel(symbolEq)));
        end
    end

    methods(Access=private)
        function generateWrapperFiles(obj)
            includeDir=fullfile(obj.WorkingDir,'include');

            mkdir(includeDir);
            wrappedMacros=sldv.code.sfcn.internal.HandwrittenFEHandler.generateWrapperHeaders(includeDir);
            for mm=1:numel(wrappedMacros)
                macro=wrappedMacros{mm};
                for ii=1:numel(obj.BuildOptions)
                    obj.BuildOptions(ii).FcnCallToIgnore{end+1}=macro;
                end
            end
            for ii=1:numel(obj.BuildOptions)
                obj.BuildOptions(ii).DirToIgnore{end+1}=fullfile(includeDir,'*');
            end
        end
    end
end


