



classdef SupportedSubsystemBlockConstraint<slci.compatibility.Constraint

    methods


        function out=getDescription(aObj)%#ok
            out='Subsystems are not configurable or not supported type.';
        end


        function obj=SupportedSubsystemBlockConstraint()
            obj.setEnum('SupportedSubsystemBlock');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function[SubTitle,Information,StatusText,RecAction]=...
            getSpecificMAStrings(aObj,varargin)
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


        function out=check(aObj)
            out=[];
            if~aObj.isCompatible()
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SupportedSubsystemBlock',...
                aObj.ParentBlock().getName());
            end
        end

    end

    methods(Access=protected)

        function acceptable=isCompatible(aObj)

            blkSID=aObj.ParentBlock().getSID();
            acceptable=true;
            if~isempty(get_param(blkSID,'TemplateBlock'))
                acceptable=false;
            elseif any(strcmpi(slci.internal.getSubsystemType(...
                get_param(blkSID,'Object')),...
                {'Iterator'}))
                acceptable=false;
            end
        end

    end


end


