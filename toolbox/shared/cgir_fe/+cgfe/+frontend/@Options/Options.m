

classdef Options<cgfe.util.BaseClass

    properties(Constant,GetAccess=public)
        PLATFORMS={'none','windows','linux','mac'};
    end

    properties
        Target=cgfe.frontend.Target;
        Language=cgfe.frontend.Language;
        Preprocessor=cgfe.frontend.Preprocessor;
        KeepErrorOutput=false;
        ErrorOutput='';
        MaxErrors=50;
        DoPreprocessOnly=false;
        PreprocOutput='';
        DoXref=false;
        XrefOutput='';
        DoDisplayIl=false;
        DisplayIlOutput='';
        DoIlLowering=false;
        RemoveUnneededEntities=false;
        KeepRedundantCasts=false;
        ExtraSources={};
        ExtractDependenciesOnly=false;
        KeepCommentsPosition=false;
        KeepCommentsText=false;
        Platform='none';
        Verbose=uint32(0);
        RethrowException=false;
    end

    methods
        function this=Options(varargin)
            for ii=1:numel(varargin)
                arg=varargin{ii};
                if isa(arg,'cgfe.HwInfo')
                    this.Target=arg;
                elseif isa(arg,'cgfe.frontend.Language')
                    this.Language=arg;
                elseif isa(arg,'cgfe.frontend.Preprocessor')
                    this.Preprocessor=arg;
                end
            end
        end

        function this=set.Platform(this,aValue)
            cgfe.util.verifyStringValue('Platform',aValue);
            this.Platform=cgfe.util.verifyEnumValue('Platform',...
            cgfe.frontend.Options.PLATFORMS,lower(aValue));
        end

        function this=set.Target(this,aValue)
            this.Target=cgfe.util.verifyClassValue('Target',...
            'cgfe.HwInfo',aValue);
        end

        function this=set.Language(this,aValue)
            this.Language=cgfe.util.verifyClassValue('Target',...
            'cgfe.frontend.Language',aValue);
        end

        function this=set.Preprocessor(this,aValue)
            this.Preprocessor=cgfe.util.verifyClassValue('Target',...
            'cgfe.frontend.Preprocessor',aValue);
        end

        function this=set.KeepErrorOutput(this,aValue)
            this.KeepErrorOutput=cgfe.util.verifyLogicalValue('KeepErrorOutput',aValue);
        end

        function this=set.RethrowException(this,aValue)
            this.RethrowException=cgfe.util.verifyLogicalValue('RethrowException',aValue);
        end

        function this=set.Verbose(this,aValue)
            this.Verbose=cgfe.util.verifyUint32Value('Verbose',aValue);
        end

        function this=set.ErrorOutput(this,aValue)
            this.ErrorOutput=cgfe.util.verifyStringValue('ErrorOutput',aValue);
        end

        function this=set.MaxErrors(this,aValue)
            this.MaxErrors=cgfe.util.verifyInt32Value('MaxErrors',aValue);
        end

        function this=set.DoPreprocessOnly(this,aValue)
            this.DoPreprocessOnly=cgfe.util.verifyLogicalValue('DoPreprocessOnly',aValue);
        end

        function this=set.PreprocOutput(this,aValue)
            this.PreprocOutput=cgfe.util.verifyStringValue('PreprocOutput',aValue);
        end

        function this=set.DoXref(this,aValue)
            this.DoXref=cgfe.util.verifyLogicalValue('DoXref',aValue);
        end

        function this=set.XrefOutput(this,aValue)
            this.XrefOutput=cgfe.util.verifyStringValue('XrefOutput',aValue);
        end

        function this=set.DoDisplayIl(this,aValue)
            this.DoDisplayIl=cgfe.util.verifyLogicalValue('DoDisplayIl',aValue);
        end

        function this=set.DisplayIlOutput(this,aValue)
            this.DisplayIlOutput=cgfe.util.verifyStringValue('DisplayIlOutput',aValue);
        end

        function this=set.DoIlLowering(this,aValue)
            this.DoIlLowering=cgfe.util.verifyLogicalValue('DoIlLowering',aValue);
        end

        function this=set.RemoveUnneededEntities(this,aValue)
            this.RemoveUnneededEntities=cgfe.util.verifyLogicalValue('RemoveUnneededEntities',aValue);
        end

        function this=set.KeepRedundantCasts(this,aValue)
            this.KeepRedundantCasts=cgfe.util.verifyLogicalValue('KeepRedundantCasts',aValue);
        end

        function this=set.ExtraSources(this,aValue)
            this.ExtraSources=cgfe.util.verifyCellOfStrings('ExtraSources',aValue);
        end

        function this=set.ExtractDependenciesOnly(this,aValue)
            this.ExtractDependenciesOnly=cgfe.util.verifyLogicalValue('ExtractDependenciesOnly',aValue);
        end

        function this=set.KeepCommentsPosition(this,aValue)
            this.KeepCommentsPosition=cgfe.util.verifyLogicalValue('KeepCommentsPosition',aValue);
        end

        function this=set.KeepCommentsText(this,aValue)
            this.KeepCommentsText=cgfe.util.verifyLogicalValue('KeepCommentsText',aValue);
        end

    end

end


