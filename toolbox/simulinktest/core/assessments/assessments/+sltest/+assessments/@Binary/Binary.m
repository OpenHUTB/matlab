


classdef(Abstract,...
    AllowedSubclasses={
    ?sltest.assessments.BinaryDuration
    ?sltest.assessments.BinaryInterval
    ?sltest.assessments.BinaryNumeric
    ?sltest.assessments.And
    ?sltest.assessments.Or
    ?sltest.assessments.Implies
    ?sltest.assessments.IfThen
    ?sltest.assessments.IfThenAtRisingEdge
    })Binary<sltest.assessments.Expression
    properties(SetAccess=immutable)
left
right
    end

    methods
        function res=children(self)
            res={self.left,self.right};
        end

        function visit(self,functionHandle)
            functionHandle(self);
            self.left.visit(functionHandle);
            self.right.visit(functionHandle);
        end

        function res=transform(self,functionHandle)
            res=functionHandle(self,[]);
            res.children={self.left.transform(functionHandle),self.right.transform(functionHandle)};
        end
    end

    methods(Access=protected,Hidden)
        function self=Binary(left,right)
            self.left=left;
            self.right=right;
        end
    end
end
