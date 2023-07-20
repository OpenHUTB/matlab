


classdef OutportTerminatorConstraint<slci.compatibility.Constraint
    properties(Access=private)
        fPortNumber=0;
    end

    methods(Access=private)

        function out=isDstTerminated(~,pHandle)
            pObj=get_param(pHandle,'Object');
            grpDst=pObj.getActualDst;
            out=isempty(grpDst);
        end

    end

    methods

        function out=getDescription(aObj)%#ok
            out='Model reference block outport must not be connected to a terminator block.';
        end


        function obj=OutportTerminatorConstraint()
            obj.setEnum('OutportTerminator');
            obj.setCompileNeeded(1);
            obj.setFatal(false);

            obj.addPreRequisiteConstraint(slci.compatibility.BusExpansionConstraint);
        end

        function out=check(aObj)
            out=[];

            mdlBlkHdls=slInternal('searchModelBlocksWithNoDestinationInCompile',aObj.ParentModel().getSID());

            if~isempty(mdlBlkHdls)
                badBlkStr={};
                badBlks={};
                for blkIdx=1:numel(mdlBlkHdls)
                    blkName={getfullname(mdlBlkHdls(blkIdx))};
                    slciBlkName=slci.compatibility.getFullBlockName(blkName);
                    if~isempty(badBlkStr)
                        badBlkStr=[badBlkStr,', '];%#ok
                    end
                    badBlkStr=[badBlkStr,slciBlkName];%#ok
                    badBlks(end+1)=blkName;%#ok
                end
                out=slci.compatibility.Incompatibility(...
                aObj,...
                'OutportTerminator',...
                aObj.ParentModel().getName(),cell2mat(badBlkStr));
                out.setObjectsInvolved(badBlks);
            end

        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)%#ok
            status=varargin{1};
            if status
                status='Pass';
            else
                status='Warn';
            end
            SubTitle=DAStudio.message('Slci:compatibility:OutportTerminatorConstraintSubTitle');
            Information=DAStudio.message('Slci:compatibility:OutportTerminatorConstraintInfo');
            StatusText=DAStudio.message(['Slci:compatibility:OutportTerminatorConstraint',status]);
            RecAction=DAStudio.message('Slci:compatibility:OutportTerminatorConstraintRecAction');
        end

    end
end
