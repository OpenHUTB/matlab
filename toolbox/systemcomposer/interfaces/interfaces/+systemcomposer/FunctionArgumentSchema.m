classdef FunctionArgumentSchema<systemcomposer.InterfaceElementSchema




    properties(SetAccess=private)
fe
    end

    methods
        function this=FunctionArgumentSchema(fa,si,mf0Model)
            this@systemcomposer.InterfaceElementSchema(fa,si,mf0Model);
            this.fe=fa.getFunctionElement();
        end

        function name=getObjectType(this)
            name=['Element : ',this.fe.getName(),' | Argument : ',this.pie.getName()];
        end

        function subprops=subProperties(this,prop)
            subprops={};
            if isempty(prop)
                subprops{end+1}='Sysarch:Port:Interface:Element';
            end
            if(strcmp(prop,'Sysarch:Port:Interface:Element'))
                assert(isa(this.pie,'systemcomposer.architecture.model.swarch.FunctionArgument'));
                subprops{end+1}='Sysarch:Port:Interface:Type';
                subprops{end+1}='Sysarch:Port:Interface:Dimensions';
                subprops{end+1}='Sysarch:Port:Interface:Units';
                subprops{end+1}='Sysarch:Port:Interface:Complex';
                subprops{end+1}='Sysarch:Port:Interface:Minimum';
                subprops{end+1}='Sysarch:Port:Interface:Maximum';
                subprops{end+1}='Sysarch:Port:Interface:Description';
            end
        end


    end
end
