


classdef SessionOptions<cgfe.util.BaseClass

    properties
        ExtraOptions={};
        ExtraSources={};
        FullParse=true;
        DoDisplayIl=false;
        DisplayIlOutput='';
        DoIlLowering=false;
        KeepErrorOutput=false;
        ErrorOutput='';
        DoRemoveAllUnsupportedOp=true;
        DoRemoveUnsupportedOp=true;
        DoRemoveGotoLabel=true;
        DoRemoveNestedAssignment=true;
        DoRemoveConditional=true;
        DoUniquifyName=true;
        DoFlatScope=false;
        DoVarInitializationConversion=true;
        RemoveUnneededEntities=true;
    end

    methods
        function this=SessionOptions(arg)
            if nargin==1&&isa(arg,'cgfe.c.SessionOptions')
                this=arg;
            else
                if nargin<1
                    arg=false;
                end
                forGlobalSymbols=arg;
                if forGlobalSymbols
                    this.FullParse=false;
                    this.DoFlatScope=false;
                    this.DoVarInitializationConversion=false;
                    this.RemoveUnneededEntities=false;
                end
            end
        end

        function this=set.ExtraOptions(this,aValue)
            this.ExtraOptions=cgfe.util.verifyCellOfStrings('ExtraOptions',aValue);
        end

        function this=set.ExtraSources(this,aValue)
            this.ExtraSources=cgfe.util.verifyCellOfStrings('ExtraSources',aValue);
        end

        function this=set.FullParse(this,aValue)
            this.FullParse=cgfe.util.verifyLogicalValue('FullParse',aValue);
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

        function this=set.KeepErrorOutput(this,aValue)
            this.KeepErrorOutput=cgfe.util.verifyLogicalValue('KeepErrorOutput',aValue);
        end

        function this=set.ErrorOutput(this,aValue)
            this.ErrorOutput=cgfe.util.verifyStringValue('ErrorOutput',aValue);
        end

        function this=set.DoRemoveAllUnsupportedOp(this,aValue)
            this.DoRemoveAllUnsupportedOp=cgfe.util.verifyLogicalValue('DoRemoveAllUnsupportedOp',aValue);
        end

        function this=set.DoRemoveUnsupportedOp(this,aValue)
            this.DoRemoveUnsupportedOp=cgfe.util.verifyLogicalValue('DoRemoveUnsupportedOp',aValue);
        end

        function this=set.DoRemoveGotoLabel(this,aValue)
            this.DoRemoveGotoLabel=cgfe.util.verifyLogicalValue('DoRemoveGotoLabel',aValue);
        end

        function this=set.DoRemoveNestedAssignment(this,aValue)
            this.DoRemoveNestedAssignment=cgfe.util.verifyLogicalValue('DoRemoveNestedAssignment',aValue);
        end

        function this=set.DoRemoveConditional(this,aValue)
            this.DoRemoveConditional=cgfe.util.verifyLogicalValue('DoRemoveConditional',aValue);
        end

        function this=set.DoUniquifyName(this,aValue)
            this.DoUniquifyName=cgfe.util.verifyLogicalValue('DoUniquifyName',aValue);
        end

        function this=set.DoFlatScope(this,aValue)
            this.DoFlatScope=cgfe.util.verifyLogicalValue('DoFlatScope',aValue);
        end

        function this=set.DoVarInitializationConversion(this,aValue)
            this.DoVarInitializationConversion=cgfe.util.verifyLogicalValue('DoVarInitializationConversion',aValue);
        end

        function this=set.RemoveUnneededEntities(this,aValue)
            this.RemoveUnneededEntities=cgfe.util.verifyLogicalValue('RemoveUnneededEntities',aValue);
        end
    end
end


