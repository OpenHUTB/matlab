classdef TestModeFuture<coder.parallel.interfaces.IFuture





    properties(GetAccess=private,SetAccess=immutable)
Result
    end

    properties(Access=private)
Read
    end

    methods



        function this=TestModeFuture(result)
            this.Result=result;
            this.Read=false;
        end
    end

    methods(Sealed)



        function varargout=fetchNext(objOrObjs)

            unreadResults=objOrObjs(~[objOrObjs.Read]);
            if~isempty(unreadResults)
                [varargout{2:nargout}]=unreadResults(1).Result{:};



                varargout{1}=[];
                unreadResults(1).Read=true;
            end
        end




        function cancel(~)



        end
    end
end

