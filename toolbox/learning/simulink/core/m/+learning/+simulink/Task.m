classdef Task<handle




    properties
question
courseObject
modelName
conceptSequence
    end

    methods(Access=public)
        function obj=Task(question,courseObject,modelName,conceptSequence)






            obj.question=question;
            obj.courseObject=courseObject;
            obj.modelName=modelName;
            obj.conceptSequence=conceptSequence;
        end

        function courseObject=getCourseObject(obj)


            courseObject=obj.courseObject;
        end

        function conceptSequence=getConceptSequence(obj)


            conceptSequence=obj.conceptSequence;
        end
    end

end
