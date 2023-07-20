




classdef SharedSynthLocalDSMConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Unsupported hidden data store memory blocks are '+...
            'inserted to support shared local data stores';
        end


        function obj=SharedSynthLocalDSMConstraint(varargin)
            obj.setEnum('SharedSynthLocalDSM');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end


        function out=check(aObj)
            out=[];
            dsmStr='';
            dsms={};
            obj=get_param(aObj.ParentModel().getHandle(),'Object');
            blks=obj.SortedList;
            for i=1:numel(blks)
                blk=blks(i);
                if aObj.isInsertedForSharedSynthDSMFromSubmodel(blk)
                    dsmName=get_param(blk,'DataStoreName');
                    if~isempty(dsmStr)
                        dsmStr=[dsmStr,', '];%#ok<*AGROW>
                    end
                    dsmStr=[dsmStr,dsmName];
                    dsms{end+1}=dsmName;
                end
            end
            if~isempty(dsmStr)
                out=slci.compatibility.Incompatibility(...
                aObj,'SharedSynthLocalDSM',aObj.ParentModel().getName(),dsmStr);
                out.setObjectsInvolved(dsms);
            end
        end



        function out=isInsertedForSharedSynthDSMFromSubmodel(aObj,aBlk)
            obj=get_param(aBlk,'Object');
            out=strcmp(obj.BlockType,'DataStoreMemory')...
            &&obj.isSynthesized...
            &&strcmp(obj.StateMustResolveToSignalObject,'off');
        end

    end

end
