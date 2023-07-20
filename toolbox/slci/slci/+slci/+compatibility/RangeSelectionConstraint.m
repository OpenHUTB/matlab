


classdef RangeSelectionConstraint<slci.compatibility.Constraint

    properties(Access=private)

        fPortNumber=1;
        SELECTORS={'Selector',...
        'Demux'};
    end

    methods(Access=private)


        function out=getPortNumber(aObj)
            out=aObj.fPortNumber;
        end


        function setPortNumber(aObj,aPortNumber)
            aObj.fPortNumber=aPortNumber;
        end


        function out=isSelectorBlock(aObj,blkType)
            switch(blkType)
            case aObj.SELECTORS
                out=true;
            otherwise
                out=false;
            end
        end

    end

    methods

        function out=getDescription(aObj)%#ok
            out=['Range selection directly on inputs is not supported'...
            ,'for Selector, assignment, and multiport switch blocks'];
        end

        function obj=RangeSelectionConstraint(aPortNumber)
            obj.setEnum('RangeSelection');
            obj.setCompileNeeded(1);
            obj.setFatal(false);

            obj.setPortNumber(aPortNumber);
        end

        function out=check(aObj)
            out=[];









            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            pH=aObj.ParentBlock().getParam('PortHandles').Inport;
            pIdx=aObj.getPortNumber();

            assert(pIdx<=numel(pH),['The port index should be less'...
            ,' than the total number of ports']);
            pObj=get_param(pH(pIdx),'Object');
            grpSrc=pObj.getGraphicalSrc;



            if~isempty(grpSrc)
                grpSrcBlk=get_param(grpSrc,'ParentHandle');
                isVirtual=strcmpi(get_param(grpSrcBlk,'Virtual'),'on');
                grpSrcObj=get_param(grpSrcBlk,'Object');
                if isVirtual...
                    &&aObj.isSelectorBlock(grpSrcObj.BlockType)
                    out=slci.compatibility.Incompatibility(...
                    aObj,...
                    'RangeSelection',...
                    aObj.ParentBlock().getName(),...
                    aObj.getPortNumber());
                end
            end

        end

    end

end
