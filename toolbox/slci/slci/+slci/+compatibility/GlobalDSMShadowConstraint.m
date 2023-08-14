


classdef GlobalDSMShadowConstraint<slci.compatibility.Constraint


    methods

        function out=getDescription(aObj)%#ok
            out='Global data store memory blocks may not be used if local DSM shadows the global DSM';
        end

        function obj=GlobalDSMShadowConstraint(varargin)
            obj.setEnum('GlobalDSMShadow');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end




        function out=check(aObj)
            out=[];
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            try

                obj=get_param(aObj.ParentModel().getHandle(),'Object');
                blks=obj.SortedList;

                all_local_dsms={};
                all_global_dsms={};
                for i=1:numel(blks)
                    blk=blks(i);
                    blkObj=get_param(blk,'Object');
                    if strcmp(get_param(blk,'BlockType'),'DataStoreMemory')
                        dsName=get_param(blk,'DataStoreName');
                        if blkObj.isSynthesized
                            all_global_dsms=[all_global_dsms,dsName];%#ok
                        else
                            all_local_dsms=[all_local_dsms,dsName];%#ok
                        end
                    end
                end

                dsms=intersect(all_global_dsms,all_local_dsms);

                if~isempty(dsms)&&~aObj.ParentModel().getCheckAsRefModel()
                    dsmStr=strjoin(dsms,', ');
                    out=slci.compatibility.Incompatibility(...
                    aObj,'GlobalDSMShadow',aObj.ParentModel().getName(),dsmStr);
                    out.setObjectsInvolved(dsms);
                end
            catch

            end

        end
    end
end

