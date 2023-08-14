


classdef Incompatibility<handle

    properties(Access=private)
        fCode='';
        fText='';
        fConstraint='';
        preReqFailure=false;
        objectsInvolved={};
    end

    methods
        function obj=Incompatibility(aConstraint,aCode,varargin)
            obj.fConstraint=aConstraint;
            obj.fCode=aCode;
            cmd='obj.fText = DAStudio.message(''Slci:compatibility:';
            cmd=[cmd,aCode,''''];
            for i=1:nargin-2
                cmd=[cmd,', varargin{',num2str(i),'}'];%#ok
            end
            cmd=[cmd,');'];
            eval(cmd);
            if~isempty(aConstraint)
                parentChart=aConstraint.ParentChart;
                if isa(parentChart,'slci.stateflow.Chart')
                    if aConstraint.getFatal
                        parentChart.setHasFatalIncompatibility(true);
                    else
                        parentChart.setHasIncompatibility(true);
                    end
                end
            end

        end

        function out=getCode(aObj)
            out=aObj.fCode;
        end

        function out=getText(aObj)
            out=aObj.fText;
        end

        function out=getFatal(aObj)
            if isempty(aObj.fConstraint)
                out=true;
            else
                out=aObj.fConstraint.getFatal();
            end
        end

        function out=getSID(aObj)
            out=aObj.fConstraint.getSID();
        end

        function out=getConstraint(aObj)
            out=aObj.fConstraint;
        end

        function[subTitle,Information,WarnText,RecAction]=getMAStrings(aObj)
            [subTitle,Information,WarnText,RecAction]=aObj.getConstraint.getMAStrings(false,aObj);
        end

        function out=getObjectsInvolved(aObj)
            out=aObj.objectsInvolved;
        end

        function setObjectsInvolved(aObj,blks)
            aObj.objectsInvolved=blks;
        end

        function setpreReqFailureFlag(aObj,flag)
            aObj.preReqFailure=flag;
        end

        function out=getpreReqFailureFlag(aObj)
            out=aObj.preReqFailure;
        end
    end
end
