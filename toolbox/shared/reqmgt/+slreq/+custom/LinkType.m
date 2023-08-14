classdef LinkType




    enumeration
        Implement;
        Verify;
        Confirm;
        Relate;
        Derive;
        Refine;
    end

    methods
        function str=forwardName(this)
            switch this
            case 'Relate'
                str='Slvnv:slreq:RelatedTo';
            case 'Implement'
                str='Slvnv:slreq:Implements';
            case 'Verify'
                str='Slvnv:slreq:Verifies';
            case 'Confirm'

                str='Slvnv:slreq:ConfirmedBy';
            case 'Derive'
                str='Slvnv:slreq:Derives';
            case 'Refine'
                str='Slvnv:slreq:Refines';
            otherwise
                error(message('Slvnv:slreq:UnexpectedEnumType'));
            end
        end

        function str=backwardName(this)
            switch this
            case 'Relate'
                str='Slvnv:slreq:RelatedTo';
            case 'Implement'
                str='Slvnv:slreq:ImplementedBy';
            case 'Verify'
                str='Slvnv:slreq:VerifiedBy';
            case 'Confirm'

                str='Slvnv:slreq:Confirms';
            case 'Derive'
                str='Slvnv:slreq:DerivedFrom';
            case 'Refine'
                str='Slvnv:slreq:RefinedBy';
            otherwise
                error(message('Slvnv:slreq:UnexpectedEnumType'));
            end
        end

        function str=getTypeName(this)
            str=char(this);
        end

        function rollupType=getRollupType(this)
            switch this
            case 'Verify'
                rollupType='verification';
            case 'Confirm'
                rollupType='verification';
            case 'Implement'
                rollupType='implementation';
            otherwise
                rollupType='none';
            end
        end
    end
    methods(Static)
        function val=DefaultValue()
            val=slreq.custom.LinkType.Relate;
        end
        function linkType=getLinkTypeByName(typeName)
            switch typeName
            case 'Relate'
                linkType=slreq.custom.LinkType.Relate;
            case 'Implement'
                linkType=slreq.custom.LinkType.Implement;
            case 'Verify'
                linkType=slreq.custom.LinkType.Verify;
            case 'Confirm'

                linkType=slreq.custom.LinkType.Confirm;
            case 'Derive'
                linkType=slreq.custom.LinkType.Derive;
            case 'Refine'
                linkType=slreq.custom.LinkType.Refine;
            otherwise
                error(message('Slvnv:slreq:UnexpectedEnumType'));
            end
        end
    end
end
