function entityDecl(this)







    hdlcode=this.hdlcodeinit;
    prop=properties(this);

    if~isa(this,'eda.internal.component.BlackBox')
        for i=1:length(prop)
            propName=prop{i};
            if isa(this.(propName),'eda.internal.component.Port')



                portName=hdllegalnamersvd(this.(propName).UniqueName);
                this.(propName).UniqueName=portName;
                FiType=this.(propName).FiType;
                hType=this.hdltype(FiType);
                [~,idx]=hdlnewsignal(this.(propName).UniqueName,'block',-1,0,0,hType,FiType);%#ok
                if isa(this.(propName),'eda.internal.component.Outport')
                    hdladdoutportsignal(idx);
                end

            end
        end
    end


    if hdlgetparameter('isvhdl')
        hdlcode.entity_decl=['ENTITY ',this.UniqueName,' IS \n'];
        if~isempty(this.findprop('generic'))
            hdlcode.entity_generic='GENERIC (\n';
            fieldNames=fieldnames(this.generic);
            for i=1:length(fieldNames)
                Value=this.generic.(fieldNames{i}).default_Value;
                Type=this.generic.(fieldNames{i}).Type;
                htype=this.hdltype(Type);
                hdlcode.entity_generic=[hdlcode.entity_generic,'         ',fieldNames{i},': ',htype,' := ',Value,';\n'];
            end
            hdlcode.entity_generic(end-2)='';
            hdlcode.entity_generic=[hdlcode.entity_generic,');\n\n'];
        end
        hdlcode.entity_end=['END ',this.UniqueName,';\n'];
        hdlcode.entity_portdecls=this.portDecl('');
    else
        hdlcode.entity_decl=['module ',this.UniqueName,' (\n'];
        hdlcode.entity_end='\n';
        generic_decl='';
        if~isempty(this.findprop('generic'))
            generic_decl='\n\n //Parameter definition \n\n';
            fieldNames=fieldnames(this.generic);
            for i=1:length(fieldNames)
                Value=this.generic.(fieldNames{i}).default_Value;
                generic_decl=[generic_decl,'      parameter ',fieldNames{i},' = ',Value,';\n'];%#ok<AGROW>
            end
        end
        hdlcode.entity_portdecls=this.portDecl([generic_decl,'\n\n']);
    end

    this.HDL=hdlcodeconcat([this.HDL,hdlcode]);

end




