



classdef SFAstExplicitEvent<slci.ast.SFAst

    properties
        fPortNum=-1;
    end

    methods

        function aObj=SFAstExplicitEvent(aAstObj,aParent)
            aObj=aObj@slci.ast.SFAst(aAstObj,aParent);
            id=aObj.resolveObjectId(aAstObj,aParent);
            eventObj=idToHandle(sfroot,id);
            if isfinite(eventObj.Port)
                aObj.fPortNum=eventObj.Port-1;
            end
        end

        function out=getPortNum(aObj)
            out=aObj.fPortNum;
        end


        function ComputeDataDim(aObj)


            assert(~aObj.fComputedDataDim);
        end


        function ComputeDataType(aObj)


            assert(~aObj.fComputedDataType);
        end

    end

    methods(Access=private)


        function id=resolveObjectId(aObj,aAstObj,aParent)
            assert(isa(aParent,'slci.ast.SFAst'));
            owner=aParent.getRootAstOwner;
            if isa(owner,'slci.stateflow.Transition')...
                ||isa(owner,'slci.stateflow.SFState')
                chart=owner.ParentChart;
                assert(isa(chart,'slci.stateflow.Chart'));
                if strcmpi(chart.getActionLanguage,'MATLAB')
                    assert(isa(aAstObj,'mtree'))
                    event=chart.getEventByName(aAstObj.string);
                    assert(isa(event,'slci.stateflow.SFEvent'));
                    id=event.getUDDObject.Id;
                else
                    id=aAstObj.id;
                end
            end
        end

    end

end
