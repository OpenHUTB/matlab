


classdef BlockNameConstraint<slci.compatibility.Constraint
    methods

        function out=getDescription(aObj)%#ok
            out='Block names must not contain ''/*'', ''*/'', or end with the character ''*''.';
        end


        function obj=BlockNameConstraint(varargin)
            obj.setEnum('BlockName');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];

            blkObj=aObj.ParentBlock().getParam('Object');
            blkRTWName=slci.internal.getRTWName(blkObj);
            if(blkRTWName(end)=='*')...
                ||~isempty(strfind(blkRTWName,'/*'))...
                ||~isempty(strfind(blkRTWName,'*/'))
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum(),...
                blkRTWName);
            end
        end
    end
end
