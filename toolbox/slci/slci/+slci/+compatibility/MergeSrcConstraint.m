

classdef MergeSrcConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='The sources of a Merge block should not be a multi-condition action subsystem';
        end

        function obj=MergeSrcConstraint()
            obj.setEnum('MergeSrc');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)

            out=[];

            isSupported=~aObj.isSrcMultiCondActionSubsystem;

            if~isSupported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum(),...
                aObj.ParentBlock().getName());
            end
        end

    end

    methods(Access=private)


        function out=isSrcMultiCondActionSubsystem(aObj)
            out=false;


            pH=aObj.ParentBlock().getParam('PortHandles');

            for pIdx=1:numel(pH.Inport)

                pObj=get_param(pH.Inport(pIdx),'Object');
                pSrc=pObj.getCondSrc;
                for srcIdx=1:size(pSrc,1)
                    srcPortObj=pSrc(srcIdx,1);
                    srcBlk=get_param(srcPortObj,'ParentHandle');
                    if aObj.isActionSubsystem(srcBlk)

                        ph=get_param(srcBlk,'PortHandles');


                        actObj=get_param(ph.Ifaction,'Object');
                        actSrc=actObj.getActualSrc;
                        assert(size(actSrc,1)==1);
                        actSrcBlk=get_param(actSrc(1,1),'ParentHandle');


                        if strcmpi(get_param(actSrcBlk,'BlockType'),'SwitchCase')

                            conditionsArr=slci.internal.parseSwitchCaseConditions(actSrcBlk);
                            if~isempty(conditionsArr)

                                portNum=get_param(actSrc(1,1),'PortNumber');

                                if(numel(conditionsArr)>=portNum)
                                    if numel(conditionsArr{portNum})>1
                                        out=true;
                                        return;
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end


        function out=isActionSubsystem(~,blk)
            out=false;
            srcBlkType=get_param(blk,'BlockType');
            if strcmpi(srcBlkType,'Subsystem')
                ssType=slci.internal.getSubsystemType(get_param(blk,'Object'));
                out=strcmpi(ssType,'Action');
            end
        end
    end
end

