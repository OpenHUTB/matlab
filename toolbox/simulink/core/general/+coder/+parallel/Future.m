classdef Future<coder.parallel.interfaces.IFuture




    properties(GetAccess=private,SetAccess=immutable)
PCTFuture
    end

    methods



        function this=Future(pctFuture)
            this.PCTFuture=pctFuture;
        end
    end

    methods(Sealed)



        function varargout=fetchNext(objOrObjs)
            pctFutures=[objOrObjs.PCTFuture];




            [idx,varargout{2:nargout}]=fetchNext(pctFutures);
            varargout{1}=pctFutures(idx).Diary;
        end




        function cancel(objOrObjs)


            pctFutures=[objOrObjs.PCTFuture];
            cancel(pctFutures);
        end
    end
end

