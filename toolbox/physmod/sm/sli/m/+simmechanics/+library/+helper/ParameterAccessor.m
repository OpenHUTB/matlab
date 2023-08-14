classdef ParameterAccessor<handle





















































    properties
        Namespace='';
    end

    methods

        function set.Namespace(this,ns)
            this.Namespace=ns;
        end

        function msg=message(this,id)
            msg=pm_message([this.Namespace,':',id]);
        end

        function pname=param(this,id)
            pname=pm_message([this.Namespace,':',id,':ParamName']);
        end

        function defVal=defValue(this,id)
            defVal=pm_message([this.Namespace,':',id,':defaults:Value']);
        end

        function defVal=defComboValue(this,id)
            defIdx=str2num(pm_message([this.Namespace,':',id,':values:defaults']));
            vals=pm_message([this.Namespace,':',id,':values:Param']);
            vals=split(vals,',');
            defVal=vals{defIdx+1};
        end

        function uname=units(this,id)
            uname=pm_message([this.Namespace,':',id,':UnitsParamName']);
        end

        function defUnits=defUnits(this,id)
            defUnits=pm_message([this.Namespace,':',id,':defaults:Units']);
        end

    end
end