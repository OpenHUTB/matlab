


classdef InconsistentPortNumberConstraint<slci.compatibility.Constraint

    methods(Access=protected)

        function out=isCompatible(aObj)
            out=true;
            blkName=getfullname(aObj.ParentBlock().getHandle());
            ssType=Simulink.SubsystemType(blkName);

            if strcmp(ssType.getType,'variant')
                subsystem=find_system(blkName,'SearchDepth',1,'MatchFilter',@Simulink.match.allVariants,...
                'BlockType','SubSystem');
                ports=get_param(blkName,'Ports');
                for i=1:numel(subsystem)
                    subsystemName=subsystem{i};
                    if~strcmp(blkName,subsystemName)
                        subsystemPorts=get_param(subsystemName,'Ports');
                        if~isequal(subsystemPorts,ports)
                            out=false;
                            break;
                        end
                    end
                end
            end
        end

    end

    methods

        function obj=InconsistentPortNumberConstraint()
            obj.setEnum('InconsistentPortNumber');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=getDescription(aObj)%#ok
            out='Variant subsystem must have consistent port number.';
        end

        function out=check(aObj)
            out=[];


            if~aObj.isCompatible()
                out=slci.compatibility.Incompatibility(aObj,...
                'InconsistentPortNumber');
            end
        end


        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            id=strrep(class(aObj),'slci.compatibility.','');

            if status
                StatusText=DAStudio.message(['Slci:compatibility:',id,'Pass']);
            else
                StatusText=DAStudio.message(['Slci:compatibility:',id,'Warn']);
            end
            RecAction=DAStudio.message(['Slci:compatibility:',id,'RecAction']);
            SubTitle=DAStudio.message(['Slci:compatibility:',id,'SubTitle']);
            Information=DAStudio.message(['Slci:compatibility:',id,'Info']);
        end
    end
end
