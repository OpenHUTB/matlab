



classdef HiddenBusConversionConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='No automatic insertion of hidden bus conversion blocks at root inports or outports, or reference model block ports';
        end

        function obj=HiddenBusConversionConstraint()
            obj.setEnum('HiddenBusConversion');
            obj.setCompileNeeded(1);
            obj.addPreRequisiteConstraint(...
            slci.compatibility.StrictBusMsgConstraint);
        end

        function out=check(aObj)
            info=slInternal('busDiagnostics',...
            'signalConversionBlocksInsertedForBusConversion',...
            aObj.ParentModel().getName());
            out=[];
            if~isempty(info)

                set=slci.compatibility.UniqueBlockSet;
                for i=1:numel(info)
                    srcBlkHdl=info(i).SourceBlockHandle;
                    if slcifeature('VirtualBusSupport')==1
                        if~aObj.isSupportedBlock(srcBlkHdl)
                            set.AddBlock(info(i).SourceBlockHandle);
                        end
                    else
                        set.AddBlock(info(i).SourceBlockHandle);
                    end
                end
                if slcifeature('VirtualBusSupport')==1
                    if set.GetLength()>0
                        out=slci.compatibility.Incompatibility(...
                        aObj,'HiddenBusConversion',set.GetBlockStr());
                        out.setObjectsInvolved(set.GetBlockCell());
                    end
                else
                    out=slci.compatibility.Incompatibility(...
                    aObj,'HiddenBusConversion',set.GetBlockStr());
                    out.setObjectsInvolved(set.GetBlockCell());
                end
            end
        end

    end
    methods(Access=private)

        function out=isSupportedBlock(~,blkHdl)



            blkObj=get_param(blkHdl,"Object");
            out=(slci.internal.isMatlabFunctionBlock(blkObj)||...
            slci.internal.isStateflowBasedBlock(blkHdl))&&...
            slci.internal.isSubsystemInlined(blkHdl);
        end
    end
end
