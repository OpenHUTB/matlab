



classdef EnabledConditionallyExecuteInputsConstraint<slci.compatibility.Constraint

    methods


        function obj=EnabledConditionallyExecuteInputsConstraint(varargin)
            obj.setEnum('EnabledConditionallyExecuteInputs');
            obj.setCompileNeeded(true);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];

            cs=getActiveConfigSet(aObj.ParentModel().getHandle());
            if strcmpi(get_param(cs,'ConditionallyExecuteInputs'),'off')
                return;
            end


            nonInlinedSS=[];

            cecInputTree=aObj.getConditionalInputTree(aObj.ParentModel().getHandle());

            for i=1:numel(cecInputTree)
                ownerBlk=get_param(cecInputTree(i).owner,'Object');


                if strcmpi(ownerBlk.BlockType,'MultiPortSwitch')


                    inBlks=[cecInputTree(i).blocksMovedToCECInputSide];


                    ssInBlks=inBlks(arrayfun(@(x)...
                    strcmpi(get_param(x,'BlockType'),'SubSystem'),inBlks));

                    nonInlinedSS=[nonInlinedSS,...
                    ssInBlks(~(arrayfun(@(x)slci.internal.isSubsystemInlined(x),...
                    ssInBlks)))];
                end
            end

            if~isempty(nonInlinedSS)
                out=slci.compatibility.Incompatibility(aObj,aObj.getEnum(),aObj.ParentModel().getName());
                out.setObjectsInvolved(nonInlinedSS);
            end
        end
    end


    methods(Access=private)




        function out=getConditionalInputTree(aObj,mdlHandle)
            mdlObj=get_param(mdlHandle,'Object');
            cecInputTree=mdlObj.getCondInputTree;
            out=cecInputTree;
        end

    end
end
