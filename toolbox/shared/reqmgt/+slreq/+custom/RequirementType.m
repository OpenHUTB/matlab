classdef RequirementType


    enumeration

Unset
Functional
Container
Informational
    end

    methods
        function msgId=getName(this)
            switch this
            case 'Unset'
                msgId='Slvnv:slreq:Unset';
            case 'Functional'
                msgId='Slvnv:slreq:RequirementTypeFunctional';
            case 'Container'
                msgId='Slvnv:slreq:RequirementTypeContainer';
            case 'Informational'
                msgId='Slvnv:slreq:RequirementTypeInformational';
            otherwise
                error(message('Slvnv:slreq:UnexpectedEnumType'));
            end
        end

        function typeName=getTypeName(this)
            typeName=char(this);
        end
    end

    methods(Static)
        function typeNames=getBuiltinTypeNames()
            typeNames={'Functional','Informational','Container'};
        end
        function requirementType=getRequirementTypeByName(typeName)
            switch typeName
            case 'Unset'
                requirementType=slreq.custom.RequirementType.Unset;
            case 'Functional'
                requirementType=slreq.custom.RequirementType.Functional;
            case 'Container'
                requirementType=slreq.custom.RequirementType.Container;
            case 'Informational'
                requirementType=slreq.custom.RequirementType.Informational;
            otherwise
                error(message('Slvnv:slreq:UnexpectedEnumType'));
            end
        end
    end
end
