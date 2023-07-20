classdef(Sealed=true,Hidden=true)ChoicesSpreadSheetSource<handle









    properties(SetAccess=private,GetAccess=public)
        fData(1,:)Simulink.variant.parameterddg.ChoiceRow;
        fDDGCreator Simulink.variant.parameterddg.VariantVariableDDGCreator;
    end

    methods

        function obj=ChoicesSpreadSheetSource(aDDGCreator)
            obj.fDDGCreator=aDDGCreator;
        end


        function children=getChildren(obj)
            obj.fData=obj.fData.empty;
            choices=obj.fDDGCreator.fVariantVariable.getChoice();
            for choiceId=1:2:numel(choices)

                obj.fData(end+1)=Simulink.variant.parameterddg.ChoiceRow...
                (choices{choiceId},choices{choiceId+1},obj.fDDGCreator);
            end
            children=obj.fData;
        end



        function children=getHierarchicalChildren(obj)
            children=obj.getChildren();
        end
    end
end


