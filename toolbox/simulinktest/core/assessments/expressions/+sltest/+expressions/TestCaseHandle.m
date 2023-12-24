classdef TestCaseHandle<sltest.expressions.mi.TestCaseHandle

    properties(Dependent)
Assessments
    end


    methods(Access=private)
        function obj=TestCaseHandle()
            obj@sltest.expressions.mi.TestCaseHandle();
        end
    end


    methods(Static)
        function obj=makeMoveFrom(miTestCaseHandle)
            if~isa(miTestCaseHandle,"sltest.expressions.mi.TestCaseHandle")
                error("Argment must be sltest.expressions.mi.TestCaseHandle.");
            end
            obj=sltest.expressions.TestCaseHandle;
            obj.moveFrom(miTestCaseHandle);
        end


        function obj=make
            import sltest.expressions.*
            obj=TestCaseHandle.makeMoveFrom(mi.TestCaseHandle.makeImpl);
        end


        function obj=fromXml(xml)
            import sltest.expressions.*
            obj=TestCaseHandle.makeMoveFrom(mi.TestCaseHandle.fromXmlImpl(xml));
        end
    end


    methods
        function assessments=get.Assessments(self)
            import sltest.expressions.*
            assessments=arrayfun(@(as)AssessmentHandle.makeMoveFrom(self,as),self.AssessmentsImpl);
        end


        function as=makeAssessment(self)
            import sltest.expressions.*
            as=AssessmentHandle.makeMoveFrom(self,self.makeAssessmentImpl);
        end
    end
end

