classdef ExperimentException<MException




    properties(Access=private)
OriginalException
    end

    methods
        function self=ExperimentException(me)
            if isa(me,'message')
                me=MException(me);
            end
            assert(isa(me,'MException'),'me must be an MException or a message');

            self@MException(me.identifier,'%s',me.message);
            if isa(me,'experiments.internal.ExperimentException')


                self=me;
                return;
            end

            self.OriginalException=me;
            self.type=me.type;
            for i=1:length(me.cause)
                self=addCause(self,experiments.internal.ExperimentException(me.cause{i}));
            end
        end
    end

    properties(Constant,Access=private)
        InternalPath=fileparts(mfilename('fullpath'))
    end

    methods(Access=protected)
        function stack=getStack(self)

            for k=1:length(self.OriginalException.stack)
                if startsWith(self.OriginalException.stack(k).file,self.InternalPath)
                    k=k-1;%#ok<FXSET>
                    break;
                end
            end
            stack=self.OriginalException.stack(1:k);
        end
    end
end
