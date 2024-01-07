
classdef Preprocessor<cgfe.util.BaseClass
    properties
        SystemIncludeDirs={};
        IncludeDirs={};
        Defines={};
        UnDefines={};
        PreIncludes={};
        PreIncludeMacros={};
        IgnoredMacros={};
        KeepComments=true;
        KeepLineDirectives=false;
    end


    methods
        function this=Preprocessor(varargin)
            if nargin==1&&isa(varargin{1},'cgfe.frontend.Preprocessor')
                this=varargin{1};
            end
        end


        function this=set.SystemIncludeDirs(this,aValue)
            this.SystemIncludeDirs=cgfe.util.verifyCellOfStrings('SystemIncludeDirs',aValue);
        end


        function this=set.IncludeDirs(this,aValue)
            this.IncludeDirs=cgfe.util.verifyCellOfStrings('IncludeDirs',aValue);
        end


        function this=set.Defines(this,aValue)
            this.Defines=cgfe.util.verifyCellOfStrings('Defines',aValue);
        end


        function this=set.UnDefines(this,aValue)
            this.UnDefines=cgfe.util.verifyCellOfStrings('UnDefines',aValue);
        end


        function this=set.PreIncludes(this,aValue)
            this.PreIncludes=cgfe.util.verifyCellOfStrings('PreIncludes',aValue);
        end


        function this=set.PreIncludeMacros(this,aValue)
            this.PreIncludeMacros=cgfe.util.verifyCellOfStrings('PreIncludeMacros',aValue);
        end


        function this=set.IgnoredMacros(this,aValue)
            this.IgnoredMacros=cgfe.util.verifyCellOfStrings('IgnoredMacros',aValue);
        end


        function this=set.KeepComments(this,aValue)
            this.KeepComments=cgfe.util.verifyLogicalValue('KeepComments',aValue);
        end


        function this=set.KeepLineDirectives(this,aValue)
            this.KeepLineDirectives=cgfe.util.verifyLogicalValue('KeepLineDirectives',aValue);
        end
    end
end

