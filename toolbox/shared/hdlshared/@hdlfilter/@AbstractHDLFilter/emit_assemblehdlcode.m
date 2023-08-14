function emit_assemblehdlcode(this,hdl_arch)









    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if emitMode
        nname=hdlgetparameter('filter_name');
        if isempty(nname)
            nname='filter';
        end



        if isempty(hdlgetparameter('CustomFileHeaderComment'))
            getPostEmitMultiplierComment(this);
        end

        hdl_entity_comment=this.Comment;

        [hdl_entity_ports,hdl_entity_portdecls]=hdlentityports;

        hdladdtoentitylist('filter',nname,hdl_entity_ports,hdlentityportnames);

        if hdlgetparameter('isverilog')
            hdl_entity_library='';
            hdl_entity_package=hdlverilogtimescale;
            hdl_entity_decl=['module ',nname,''];
            hdl_entity_end='';

        elseif hdlgetparameter('isvhdl')
            [hdl_entity_library,...
            hdl_entity_package,...
            hdl_entity_decl,...
            hdl_entity_end]=vhdlentityinit(nname);
        end


        hdl_entity=struct('comment',hdl_entity_comment,...
        'library',hdl_entity_library,...
        'package',hdl_entity_package,...
        'decl',hdl_entity_decl,...
        'ports',hdl_entity_ports,...
        'portdecls',hdl_entity_portdecls,...
        'end',hdl_entity_end);


        if hdlgetparameter('vhdl_package_required')==1
            hdl_entity.library=[hdl_entity.library,'USE work.',hdlgetparameter('vhdl_package_name'),'.ALL;\n\n'];
        else
            hdl_entity.library=[hdl_entity.library,'\n'];
        end

        codegendir=hdlGetCodegendir;
        if hdlgetparameter('split_entity_arch')==1
            entityfilename=fullfile(codegendir,[nname,...
            hdlgetparameter('split_entity_file_postfix'),...
            hdlgetparameter('filename_suffix')]);
            archfilename=fullfile(codegendir,[nname,...
            hdlgetparameter('split_arch_file_postfix'),...
            hdlgetparameter('filename_suffix')]);
            opentype='w';
        else
            if strcmp(this.CodeGenMode,'matlabcoder')


                curMode=hdlcodegenmode();
                hdlcodegenmode('slcoder');
                dirName=codegendir;
                hdlcodegenmode(curMode);
            else
                dirName=codegendir;
            end
            entityfilename=fullfile(dirName,[nname,hdlgetparameter('filename_suffix')]);
            archfilename=entityfilename;
            opentype='a';
        end

        entityfid=fopen(entityfilename,'w');

        if entityfid==-1
            error(message('HDLShared:hdlfilter:fileerror',entityfilename));
        end

        hdl_entity=[hdl_entity.comment,...
        hdl_entity.library,...
        hdl_entity.package,...
        hdl_entity.decl,...
        hdl_entity.ports,...
        hdl_entity.portdecls,...
        hdl_entity.end];
        fprintf(entityfid,hdl_entity);
        fclose(entityfid);

        archfid=fopen(archfilename,opentype);

        if archfid==-1
            error(message('HDLShared:hdlfilter:fileerror',archfilename));
        end




        if hdlgetparameter('split_entity_arch')==1
            hdl_arch.comment=this.comment;
        else
            hdl_arch.comment=hdldefarchheader(nname);
        end


        hdl_arch.end=[hdl_arch.end,this.FooterComment];

        hdl_arch_typedefs=hdlUniquifyTypeDefinitions(hdl_arch.typedefs);

        hdl_arch=[hdl_arch.comment,...
        hdl_arch.decl,...
        hdl_arch.component_decl,...
        hdl_arch.component_config,...
        hdl_arch.functions,...
        hdl_arch_typedefs,...
        hdl_arch.constants,...
        hdl_arch.signals,...
        hdl_arch.begin,...
        hdl_arch.body_component_instances,...
        hdl_arch.body_blocks,...
        hdl_arch.body_output_assignments,...
        hdl_arch.end];

        fprintf(archfid,hdl_arch);
        fclose(archfid);
        [ign,lat]=latency(this);%#ok<ASGLU>
        disp(sprintf('%s',hdlcodegenmsgs(7,ign)));%#ok<DSPS>

    end


