classdef SingleInputSumSaturationConstraint<slci.compatibility.Constraint

    methods

        function out=getDescription(aObj)%#ok
            out=['The single input sum block with vector input should'...
            ,'turn saturation off'];
        end

        function obj=SingleInputSumSaturationConstraint()
            obj.setEnum('SingleInputSumSaturation');
            obj.setCompileNeeded(1);
            obj.setFatal(false);
        end

        function out=check(aObj)

            out=[];
            blkSID=aObj.ParentBlock().getSID();
            portWidths=get_param(blkSID,'CompiledPortWidths');
            saturation=get_param(blkSID,'SaturateOnIntegerOverflow');
            if(portWidths.Inport~=1)&&(strcmpi(saturation,'on'))
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'SingleInputSumSaturation');
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin)
            if status
                status='Pass';
            else
                status='Warn';
            end
            enum=aObj.getEnum();
            Information=DAStudio.message(['Slci:compatibility:',enum,'ConstraintInfo']);
            SubTitle=DAStudio.message(['Slci:compatibility:',enum,'ConstraintSubTitle']);
            RecAction=DAStudio.message(['Slci:compatibility:',enum,'ConstraintRecAction']);
            StatusText=DAStudio.message(['Slci:compatibility:',enum,'Constraint',status]);
        end


        function out=hasAutoFix(~)
            out=true;
        end

        function out=fix(aObj,~)
            out=false;
            try


                aObj.ParentBlock().setParam('SaturateOnIntegerOverflow','off');
                out=true;
            catch
            end
        end
    end
end
