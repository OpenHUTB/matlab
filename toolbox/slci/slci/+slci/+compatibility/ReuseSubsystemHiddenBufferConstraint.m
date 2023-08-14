





classdef ReuseSubsystemHiddenBufferConstraint<slci.compatibility.Constraint
    methods


        function out=getDescription(aObj)%#ok
            out=['Reusable subsystems inport must not have hidden buffer inserted'];
        end


        function obj=ReuseSubsystemHiddenBufferConstraint()
            obj.setEnum('ReuseSubsystemHiddenBuffer');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            sub=aObj.getOwner;
            assert(isa(sub,'slci.simulink.SubSystemBlock'));
            blkH=sub.getHandle();
            isSupportedReuseSub=...
            slci.internal.isSupportedReusableSubsystem(blkH);

            if isSupportedReuseSub
                if slcifeature('VirtualBusSupport')==1&&aObj.isAtomicSubsystem(blkH)


                    return;
                end
                portHdls=get_param(blkH,'PortHandles');

                set=slci.compatibility.UniqueBlockSet;
                inportHdls=portHdls.Inport;
                for i=1:numel(inportHdls)
                    inportH=inportHdls(i);
                    if aObj.isSrcHiddenBuffer(inportH)

                        continue;
                    end

                    pObj=get_param(inportH,'Object');
                    actSrc=pObj.getActualSrc;
                    grpSrc=pObj.getGraphicalSrc;
                    if size(actSrc,1)>1&&numel(grpSrc)==1

                        set.AddBlock(blkH);
                    end
                end

                if set.GetLength()>0
                    out=[out,slci.compatibility.Incompatibility(...
                    aObj,...
                    aObj.getEnum(),...
                    set.GetBlockStr())];
                    out.setObjectsInvolved(set.GetBlockCell());
                end
            end
        end
    end

    methods(Access=private)


        function out=isSrcHiddenBuffer(~,portH)
            out=false;
            pObj=get_param(portH,'Object');
            grpSrc=pObj.getGraphicalSrc;
            grpSrcBlk=get_param(grpSrc,'ParentHandle');
            grpSrcObj=get_param(grpSrcBlk,'Object');


            if~isempty(grpSrcObj)&&grpSrcObj.isSynthesized&&...
                strcmpi(grpSrcObj.BlockType,...
                'SignalConversion')
                out=false;
            end
        end


        function out=isAtomicSubsystem(~,blkH)
            Obj=get_param(blkH,"Object");
            subsystemType=slci.internal.getSubsystemType(Obj);
            out=strcmpi(subsystemType,'Atomic');
        end
    end

end
