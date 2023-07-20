


classdef PathException<MException



    properties(Hidden)
        arrayInd;
        errPath;
    end

    methods(Hidden)
        function obj=PathException(ex,ind,path)
            assert(nargin==3);

            msg=message('Coder:common:PathException');
            obj@MException(msg.Identifier,msg.getString());
            obj=obj.addCause(coderprivate.makeCause(ex));

            obj.arrayInd=ind;
            obj.errPath=path;
        end



        function me=exportError(obj)
            assert(numel(obj.cause)==1);
            me=obj.cause{1};
        end


        function path=exportErrorPath(obj)
            if strcmp(obj.errPath,'')
                path=[];
            else
                path=obj.errPath;
            end
        end
    end
end
