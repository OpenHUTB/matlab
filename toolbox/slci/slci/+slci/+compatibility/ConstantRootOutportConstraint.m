








classdef ConstantRootOutportConstraint<slci.compatibility.Constraint

    methods

        function obj=ConstantRootOutportConstraint()
            obj.setEnum('ConstantRootOutport');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=getDescription(aObj)%#ok
            out='A root outport cannot have a constant or parameter sample time';
        end

        function out=check(aObj)
            out=[];
            set=slci.compatibility.UniqueBlockSet;
            mdlHdl=get_param(aObj.ParentModel().getHandle(),'Handle');
            outBlks=find_system(mdlHdl,'SearchDepth',1,'BlockType','Outport');
            for i=1:numel(outBlks)
                outBlk=outBlks(i);
                compiledSampleTime=get_param(outBlk,'CompiledSampleTime');
                if aObj.isConstantOrParameter(compiledSampleTime)
                    set.AddBlock(outBlk);
                end
            end
            if set.GetLength()>0
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'ConstantRootOutport',...
                set.GetBlockStr());
                out.setObjectsInvolved(set.GetBlockCell());
            end
        end

        function out=hasAutoFix(~)
            out=true;
        end

        function out=fix(~,aIncompatibility)
            try
                blks=aIncompatibility.getObjectsInvolved();
                sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
                for i=1:numul(blks)
                    blk=blks{i};
                    pHArray=get_param(blk,'PortHandles');
                    pH=pHArray.Inport(1);
                    inObj=get_param(pH,'Object');
                    asObj=inObj.getActualSrc;
                    numSrcs=size(asObj,1);
                    if numSrcs==1
                        srcPortHdl=asObj(1,1);
                        srcBlk=get_param(srcPortHdl,'Parent');
                        if strcmp(get_param(srcBlk,'BlockType'),'Constant')
                            set_param(srcBlk,'SampleTime','-1');
                        end
                    end
                end
                delete(sess);
                out=true;
            catch
                out=false;
            end
        end

    end
    methods(Access=private)
        function out=isConstantOrParameter(aObj,compiledSampleTime)







            [row,~]=size(compiledSampleTime);
            for i=1:row



                if iscell(compiledSampleTime)
                    s=slci.internal.SampleTime(compiledSampleTime{i,:});
                else
                    s=slci.internal.SampleTime(compiledSampleTime(i,:));
                end
                if(~s.isConstant()&&~s.isParameter())
                    out=false;
                    return;
                end
            end
            out=true;
        end
    end
end


