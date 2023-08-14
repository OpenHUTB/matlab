


classdef SynthLocalDSMConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out='No usage of local data stores defined by signal objects in the model workspace';
        end

        function obj=SynthLocalDSMConstraint(varargin)
            obj.setEnum('SynthLocalDSM');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            dsmStr='';
            dsms={};
            obj=get_param(aObj.ParentModel().getHandle(),'Object');
            blks=obj.SortedList;
            vars=aObj.ParentModel().getVars();
            for i=1:numel(blks)
                blk=blks(i);
                if slci.internal.isSynthDSMFromWSVar(blk)
                    dsmName=get_param(blk,'DataStoreName');
                    dsmVars=vars(dsmName);
                    for j=1:numel(dsmVars)
                        dsmVar=dsmVars(j);
                        if strcmp(dsmVar.SourceType,'model workspace')
                            if~isempty(dsmStr)
                                dsmStr=[dsmStr,', '];%#ok
                            end
                            dsmStr=[dsmStr,dsmName];%#ok
                            dsms{end+1}=dsmName;%#ok
                            break;
                        end
                    end
                end
            end
            if~isempty(dsmStr)
                out=slci.compatibility.Incompatibility(...
                aObj,'SynthLocalDSM',aObj.ParentModel().getName(),dsmStr);
                out.setObjectsInvolved(dsms);
            end
        end

    end
end


