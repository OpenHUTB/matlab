classdef(Sealed,SupportExtensionMethods=true)Registry<dependencies.internal.GenericRegistry




    properties(Constant)
        Instance=dependencies.internal.attribute.Registry;
    end

    properties(GetAccess=public,SetAccess=private)
        AttributeAnalyzers=dependencies.internal.attribute.AttributeAnalyzer.empty;
    end

    methods(Access=private)
        function this=Registry
        end
    end

    methods
        function analyzers=get.AttributeAnalyzers(this)
            if isempty(this.AttributeAnalyzers)
                this.AttributeAnalyzers=this.register('AttributeAnalyzers');
            end
            analyzers=this.AttributeAnalyzers;
        end
    end

end
