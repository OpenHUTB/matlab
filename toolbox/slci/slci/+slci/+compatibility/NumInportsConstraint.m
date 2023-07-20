


classdef NumInportsConstraint<slci.compatibility.Constraint

    properties(Access=private)
        fMinSupportedNumInports=0;
        fMaxSupportedNumInports=Inf;
    end

    methods(Access=private)

        function out=getMinSupportedNumInports(aObj)
            out=aObj.fMinSupportedNumInports;
        end

        function out=getMaxSupportedNumInports(aObj)
            out=aObj.fMaxSupportedNumInports;
        end

        function setMinSupportedNumInports(aObj,aMinSupportedNumInports)
            aObj.fMinSupportedNumInports=aMinSupportedNumInports;
        end

        function setMaxSupportedNumInports(aObj,aMaxSupportedNumInports)
            aObj.fMaxSupportedNumInports=aMaxSupportedNumInports;
        end

    end

    methods

        function out=getDescription(aObj)
            if aObj.fMinSupportedNumInports==aObj.fMaxSupportedNumInports
                out=['A ',aObj.ParentBlock().getParam('BlockType')...
                ,' block must have '...
                ,num2str(aObj.fMaxSupportedNumInports),' inports.'];
            elseif(aObj.fMaxSupportedNumInports==Inf)
                out=['A ',aObj.ParentBlock().getParam('BlockType')...
                ,' block must have at least '...
                ,num2str(aObj.fMinSupportedNumInports),' inports.'];
            elseif(aObj.fMinSupportedNumInports==0)
                out=['A ',aObj.ParentBlock().getParam('BlockType')...
                ,' block must have at most '...
                ,num2str(aObj.fMaxSupportedNumInports),' inports.'];
            else
                out=['A ',aObj.ParentBlock().getParam('BlockType')...
                ,' block must have between '...
                ,num2str(aObj.fMinSupportedNumInports),' and '...
                ,num2str(aObj.fMaxSupportedNumInports),' inports.'];
            end
        end

        function obj=NumInportsConstraint(varargin)
            if nargin==1
                obj.setMinSupportedNumInports(varargin{1});
                obj.setMaxSupportedNumInports(varargin{1});
            else
                obj.setMinSupportedNumInports(varargin{1});
                obj.setMaxSupportedNumInports(varargin{2});
            end
            obj.setEnum('NumInports');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end

        function out=check(aObj)
            out=[];
            ports=aObj.ParentBlock().getParam('Ports');
            actualNumInports=ports(1);
            if aObj.fMinSupportedNumInports==aObj.fMaxSupportedNumInports
                if actualNumInports~=aObj.fMinSupportedNumInports
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'NumInportsExact',...
                    aObj.ParentBlock().getName(),...
                    num2str(aObj.fMinSupportedNumInports));
                end
            elseif(aObj.fMaxSupportedNumInports==Inf)
                if actualNumInports<aObj.fMinSupportedNumInports
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'NumInportsAtLeast',...
                    aObj.ParentBlock().getName(),...
                    num2str(aObj.fMinSupportedNumInports));
                end
            elseif(aObj.fMinSupportedNumInports==0)
                if actualNumInports>aObj.fMaxSupportedNumInports
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'NumInportsAtMost',...
                    aObj.ParentBlock().getName(),...
                    num2str(aObj.fMaxSupportedNumInports));
                end
            else
                if actualNumInports<aObj.fMinSupportedNumInports||...
                    actualNumInports>aObj.fMaxSupportedNumInports
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'NumInportsRange',...
                    aObj.ParentBlock().getName(),...
                    num2str(aObj.fMinSupportedNumInports),...
                    num2str(aObj.fMaxSupportedNumInports));
                end
            end
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            [SubTitle,Information,StatusText,~]=getSpecificMAStrings@slci.compatibility.Constraint(aObj,status);
            supportedNumberStr='';
            if aObj.fMinSupportedNumInports==aObj.fMaxSupportedNumInports
                supportedNumberStr=num2str(aObj.fMinSupportedNumInports);
            elseif(aObj.fMaxSupportedNumInports==Inf)
                supportedNumberStr=[num2str(aObj.fMinSupportedNumInports),'-',num2str(aObj.fMaxSupportedNumInports);];
            end
            RecAction=[DAStudio.message('Slci:compatibility:NumInportsConstraintRecAction'),' ',supportedNumberStr];
        end

    end
end
