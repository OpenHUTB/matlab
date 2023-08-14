classdef AssessmentsException<MException




    methods
        function obj=AssessmentsException(m)


            if isa(m,'MException')
                mException=m;
            else
                assert(isa(m,'message'));
                mException=MException(m);
            end



            obj@MException(mException.identifier,'%s',mException.message);

            for i=1:length(mException.cause)
                obj=addCause(obj,sltest.assessments.internal.AssessmentsException(mException.cause{i}));
            end
        end
    end

    methods(Access=protected)
        function stack=getStack(obj)






            stack=[];
        end
    end
end


