classdef ConfigTestType<internal.CodeImporterUI.QuestionBase
    methods
        function obj=ConfigTestType(env)
            id='ConfigTestType';
            topic=message('Simulink:CodeImporterUI:Topic_SimulinkLib').getString;
            obj@internal.CodeImporterUI.QuestionBase(id,topic,env);
            obj.NextQuestionId='ConfigCodeImporter';
            obj.getAndAddOption(env,'ConfigTestType_UnitTest');
            obj.getAndAddOption(env,'ConfigTestType_PackageTest');
        end

        function onNext(obj)
            onNext@internal.CodeImporterUI.QuestionBase(obj);
            obj.NextQuestionId='ConfigCodeImporter';
        end
    end
end

