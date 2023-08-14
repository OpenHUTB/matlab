classdef TranslatorData<handle





    properties
Tree
MtreeAttributes
Replacements
FunctionTypeInfo
FunctionSimulationExprInfo
FunctionTypeInfoRegistry
TypeProposalSettings
FxpConversionSettings
FiOperatorMapper
AutoReplaceHndlr
StructCopyHandler
UniqueNamesService
ExpressionTypes
GlobalUniqNameMap
FimathFcnName


ForNodeIndices
    end

    methods
        function this=TranslatorData(tree,...
            mtreeAttributes,...
            replacements,...
            functionTypeInfo,...
            functionSimulationExprInfo,...
            functionTypeInfoRegistry,...
            typeProposalSettings,...
            fxpConversionSettings,...
            fiOperatorMapper,...
            autoReplaceHndlr,...
            structCopyHandler,...
            uniqueNamesService,...
            expressionTypes,...
            globalUniqNameMap,...
            fimathFcnName)

            this.Tree=tree;
            this.MtreeAttributes=mtreeAttributes;
            this.Replacements=replacements;
            this.FunctionTypeInfo=functionTypeInfo;
            this.FunctionSimulationExprInfo=functionSimulationExprInfo;
            this.FunctionTypeInfoRegistry=functionTypeInfoRegistry;
            this.TypeProposalSettings=typeProposalSettings;
            this.FxpConversionSettings=fxpConversionSettings;
            this.FiOperatorMapper=fiOperatorMapper;
            this.AutoReplaceHndlr=autoReplaceHndlr;
            this.StructCopyHandler=structCopyHandler;
            this.UniqueNamesService=uniqueNamesService;
            this.ExpressionTypes=expressionTypes;
            this.GlobalUniqNameMap=globalUniqNameMap;
            this.FimathFcnName=fimathFcnName;
        end
    end

end
