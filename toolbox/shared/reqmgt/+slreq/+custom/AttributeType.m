classdef AttributeType





    enumeration
Edit
Checkbox
Combobox
DateTime
    end


    methods(Hidden)
        function out=toInternalEnum(this)
            switch this
            case slreq.custom.AttributeType.Edit
                out=slreq.datamodel.AttributeRegType.Edit;
            case slreq.custom.AttributeType.Checkbox
                out=slreq.datamodel.AttributeRegType.Checkbox;
            case slreq.custom.AttributeType.Combobox
                out=slreq.datamodel.AttributeRegType.Combobox;
            case slreq.custom.AttributeType.DateTime
                out=slreq.datamodel.AttributeRegType.DateTime;
            otherwise
                assert(false,'Internal error: given custom attribute is not defined');
            end
        end
    end

    methods(Static)
        function out=nameToEnum(name)
            switch lower(name)
            case 'edit'
                out=slreq.custom.AttributeType.Edit;
            case 'checkbox'
                out=slreq.custom.AttributeType.Checkbox;
            case 'combobox'
                out=slreq.custom.AttributeType.Combobox;
            case 'datetime'
                out=slreq.custom.AttributeType.DateTime;
            otherwise
                error(message('Slvnv:slreq:InvalidAttributeType',name));
            end
        end
    end
end