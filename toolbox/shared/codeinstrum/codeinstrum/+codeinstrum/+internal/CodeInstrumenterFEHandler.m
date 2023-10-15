classdef CodeInstrumenterFEHandler < internal.cxxfe.FrontEndHandler

    properties ( GetAccess = public, Constant = true )
        CODEINSTRUM_AFTER_PREPROCESSING = 1;
        CODEINSTRUM_AFTER_PARSING = 2;
        CODEINSTRUM_PROCESSMEXEVERYCALL_ONLY = 3;
    end

    properties ( Access = public )
        XmlFilePath = [  ];
        IsForSfcn = false;
        Code2ModelRecords = [  ];
        Instrumenter = [  ]
    end

    properties ( SetAccess = private, GetAccess = public )
        AfterParsingMode = codeinstrum.internal.CodeInstrumenterFEHandler.CODEINSTRUM_AFTER_PARSING
    end

    methods ( Access = public )
        function this = CodeInstrumenterFEHandler( instrumObj, mode )
            arguments
                instrumObj
                mode = codeinstrum.internal.CodeInstrumenterFEHandler.CODEINSTRUM_AFTER_PARSING
            end
            this.Instrumenter = instrumObj;
            this.AfterParsingMode = mode;
        end

        function afterPreprocessing( this, ilPtr, ~, ~, ~ )
            trDataImpl = [  ];
            this.fillInstrumOptions(  );
            if ~isempty( this.Instrumenter.traceabilityData )
                trDataImpl = this.Instrumenter.traceabilityData;
            end
            codeinstrum_mex( codeinstrum.internal.CodeInstrumenterFEHandler.CODEINSTRUM_AFTER_PREPROCESSING,  ...
                ilPtr, this.Instrumenter.Options, trDataImpl );
        end

        function afterParsing( this, ilPtr, ~, ~, ~ )
            this.fillInstrumOptions(  );
            trDataImpl = [  ];
            if ~isempty( this.Instrumenter.traceabilityData )
                trDataImpl = this.Instrumenter.traceabilityData;
            end
            if this.AfterParsingMode == codeinstrum.internal.CodeInstrumenterFEHandler.CODEINSTRUM_AFTER_PARSING
                codeinstrum_mex( codeinstrum.internal.CodeInstrumenterFEHandler.CODEINSTRUM_AFTER_PARSING,  ...
                    ilPtr, this.Instrumenter.Options, trDataImpl, this.IsForSfcn, this.Code2ModelRecords );

            elseif this.AfterParsingMode == codeinstrum.internal.CodeInstrumenterFEHandler.CODEINSTRUM_PROCESSMEXEVERYCALL_ONLY
                codeinstrum_mex( codeinstrum.internal.CodeInstrumenterFEHandler.CODEINSTRUM_PROCESSMEXEVERYCALL_ONLY,  ...
                    ilPtr, this.Instrumenter.Options, trDataImpl );
            end
        end
    end

    methods ( Access = protected )
        function fillInstrumOptions( this )
            if ~isempty( this.XmlFilePath )
                this.Instrumenter.Options.XmlFilePath = this.XmlFilePath;
            end
            this.Instrumenter.Options.WorkingDir = pwd;
        end
    end
end


