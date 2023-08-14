function hdlcode=componentDecl(this,varargin)







    hdlcode=this.hdlcodeinit;

    if nargin<2
        declComp=true;
    else
        declComp=varargin{1};
    end

    if declComp

        if isempty(this.findprop('compDeclNotNeeded'))&&hdlgetparameter('isvhdl')
            this.HDL.arch_component_decl=['COMPONENT ',this.UniqueName,' IS \n'];
            if~isempty(this.findprop('generic'))
                fieldNames=fieldnames(this.generic);
                this.HDL.arch_component_decl=[this.HDL.arch_component_decl,'GENERIC ('];
                for i=1:length(fieldNames)
                    Value=this.generic.(fieldNames{i}).default_Value;
                    Type=this.generic.(fieldNames{i}).Type;
                    htype=this.hdltype(Type);
                    if isempty(Value)
                        this.HDL.arch_component_decl=[this.HDL.arch_component_decl,fieldNames{i},': ',htype,';\n'];
                    else
                        this.HDL.arch_component_decl=[this.HDL.arch_component_decl,fieldNames{i},': ',htype,' := ',Value,';\n'];
                    end
                end
                this.HDL.arch_component_decl(end-2)='';
                this.HDL.arch_component_decl=[this.HDL.arch_component_decl,');\n'];
            end

            this.HDL.arch_component_decl=[this.HDL.arch_component_decl,'PORT (\n'];


            this.HDL.arch_component_decl=[this.HDL.arch_component_decl,this.portDecl,'END COMPONENT;\n\n'];
            hdlcode.arch_component_decl=this.HDL.arch_component_decl;
        end
    else
        generic_decl='';
        this.portDecl(generic_decl);
    end

end
