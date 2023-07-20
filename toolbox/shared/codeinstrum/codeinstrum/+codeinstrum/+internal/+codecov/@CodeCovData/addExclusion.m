



function addExclusion(this,funSigs)

    persistent msgExclusion;
    if isempty(msgExclusion)
        msgExclusion=getString(message('CodeInstrumentation:instrumenter:excludedInternallyHidden'));
    end

    try

        fcns=this.CodeTr.getFunctions();
        for ii=1:numel(fcns)
            fcn=fcns(ii);
            if~ismember(fcn.signature,funSigs)
                excludeFunction(fcn);
            end
        end

    catch MEx

        rethrow(MEx);
    end

    function excludeFunction(fcn)
        for instIdx=1:this.getNumInstances()
            this.CodeCovDataImpl.addFilter(instIdx,...
            internal.codecov.FilterKind.FUNCTION,...
            internal.codecov.FilterSource.INTERNAL,...
            internal.codecov.FilterMode.EXCLUDED,msgExclusion,fcn);
        end
    end
end
