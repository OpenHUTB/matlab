function hdlwritescripts





    if hdlgetparameter('gen_eda_scripts'),
        if hdlgetparameter('hdlcompilescript')
            writecompiledofile;
        end

        if hdlgetparameter('hdlsimscript')
            writesimdofile;
        end

        if hdlgetparameter('hdlsimprojectscript')
            writesimprojectdofile;
        end

        if hdlgetparameter('hdlsynthscript')
            writesynthfile;
        end

        if hdlgetparameter('hdlmapfile')
            writemapfile;
        end
    end




    function writecompiledofile
        if hdlgetparameter('hdlcompiletb')
            topname=hdlgetparameter('tb_name');
        else
            topname=hdlentitytop;
        end

        fname=fullfile(hdlGetCodegendir,...
        [hdlgetparameter('module_prefix'),topname,hdlgetparameter('hdlcompilefilepostfix')]);
        fid=fopen(fname,'w');
        if fid==-1
            error(message('HDLShared:directemit:compileopenfile'));
        end

        tlang=hdlgetparameter('lasttopleveltargetlang');
        if isempty(tlang)
            tlang=hdlgetparameter('target_language');
        end

        if strcmpi(tlang,'vhdl')
            simcompilecmd=hdlgetparameter('hdlcompilevhdlcmd');
            libname=hdlgetparameter('vhdl_library_name');
        else
            simcompilecmd=hdlgetparameter('hdlcompileverilogcmd');
            libname='work';
        end
        fprintf(fid,hdlgetparameter('hdlcompileinit'),libname);

        hdlnames=hdlentityfilenames;
        simflags=hdlgetparameter('simulator_flags');
        for n=1:length(hdlnames)
            fprintf(fid,simcompilecmd,simflags,hdlnames{n});
        end


        if hdlgetparameter('hdlcompiletb')
            if hdlgetparameter('isvhdl')
                simcompilecmd=hdlgetparameter('hdlcompilevhdlcmd');
            else
                simcompilecmd=hdlgetparameter('hdlcompileverilogcmd');
            end
            fprintf(fid,simcompilecmd,simflags,...
            [hdlgetparameter('tb_name'),hdlgetparameter('filename_suffix')]);
        end

        fprintf(fid,hdlgetparameter('hdlcompileterm'));
        fclose(fid);


        function writesimdofile
            if hdlgetparameter('hdlcompiletb')
                topname=hdlgetparameter('tb_name');
            else
                topname=hdlentitytop;
            end

            fname=fullfile(hdlGetCodegendir,...
            [hdlgetparameter('module_prefix'),topname,hdlgetparameter('hdlsimfilepostfix')]);
            fid=fopen(fname,'w');
            if fid==-1
                error(message('HDLShared:directemit:simopenfile'));
            end

            fprintf(fid,hdlgetparameter('hdlsiminit'));
            if hdlgetparameter('isvhdl')
                libname=hdlgetparameter('vhdl_library_name');
            else
                libname='work';
            end
            fprintf(fid,hdlgetparameter('hdlsimcmd'),libname,topname);

            tbname=hdlgetparameter('tb_name');
            epl=hdlgetparameter('lasttoplevelportnames');
            inst_prefix=hdlgetparameter('instance_prefix');
            enl=hdlgetparameter('entitynamelist');
            inst_postfix=hdlgetparameter('instance_postfix');
            viewwavecmd=hdlgetparameter('hdlsimviewwavecmd');
            outname=hdlgetparameter('filter_output_name');
            tbpostfix=hdlgetparameter('testbenchreferencepostfix');
            tbref=hdlgetparameter('tbrefsignals');
            for n=1:length(epl)
                fprintf(fid,viewwavecmd,...
                sprintf('/%s/%s%s%s/%s',tbname,inst_prefix,char(enl{end}),inst_postfix,epl{n}));
                idx=hdlsignalfindname(epl{n});
                if tbref&&(hdlisoutportsignal(idx)||strcmp(hdlsignalname(idx),outname))
                    fprintf(fid,viewwavecmd,sprintf('/%s/%s%s',tbname,epl{n},tbpostfix));
                end
            end

            fprintf(fid,hdlgetparameter('hdlsimterm'));
            fclose(fid);


            function writesimprojectdofile
                topname=hdlentitytop;
                hdlnames=hdlentityfilenames;

                fname=fullfile(hdlGetCodegendir,...
                [hdlgetparameter('module_prefix'),topname,hdlgetparameter('hdlsimprojectfilepostfix')]);
                fid=fopen(fname,'w');

                if fid==-1
                    error(message('HDLShared:directemit:simprojectopenfile'));
                end
                fprintf(fid,hdlgetparameter('hdlsimprojectinit'),topname);

                for n=1:length(hdlnames)
                    fprintf(fid,hdlgetparameter('hdlsimprojectcmd'),...
                    hdlnames{n});
                end

                fprintf(fid,hdlgetparameter('hdlsimprojectterm'));
                fclose(fid);


                function writesynthfile
                    topname=hdlentitytop;
                    hdlnames=hdlentityfilenames;
                    tlang=hdlgetparameter('lasttopleveltargetlang');

                    fname=fullfile(hdlGetCodegendir,...
                    [hdlgetparameter('module_prefix'),topname,hdlgetparameter('hdlsynthfilepostfix')]);
                    fid=fopen(fname,'w');

                    if fid==-1
                        error(message('HDLShared:directemit:synthopenfile'));
                    end

                    if strcmpi(hdlgetparameter('HDLSynthTool'),'libero')
                        fprintf(fid,hdlgetparameter('hdlsynthinit'),topname,tlang);
                    else
                        fprintf(fid,hdlgetparameter('hdlsynthinit'),topname);
                    end

                    for n=1:length(hdlnames)
                        if strcmpi(hdlgetparameter('HDLSynthTool'),'quartus')
                            fprintf(fid,hdlgetparameter('hdlsynthcmd'),...
                            tlang,hdlnames{n});
                        else
                            fprintf(fid,hdlgetparameter('hdlsynthcmd'),...
                            hdlnames{n});
                        end
                    end

                    fprintf(fid,hdlgetparameter('hdlsynthterm'));
                    fclose(fid);


                    function writemapfile
                        topname=hdlentitytop;

                        fname=fullfile(hdlGetCodegendir,...
                        [hdlgetparameter('module_prefix'),topname,hdlgetparameter('hdlmapfilepostfix')]);

                        fid=fopen(fname,'w');

                        if fid==-1
                            error(message('HDLShared:directemit:mapopenfile'));
                        end

                        enames=hdlentitynames;

                        pathlist=strrep(hdlgetparameter('entitypathlist'),char(10),' ');

                        if hdlgetparameter('vhdl_package_required')&&isempty(pathlist{1})
                            pathlist{1}='<NONE>';
                        elseif isempty(pathlist{1})
                            pathlist=pathlist(2:end);
                        end

                        if length(pathlist)~=length(enames)
                            error(message('HDLShared:directemit:internalmaperror',length(pathlist),length(enames)));
                        end

                        map=strcat(pathlist,...
                        {[' ',hdlgetparameter('hdlmaparrow'),' ']},...
                        enames,'\n');
                        fprintf(fid,[map{:}]);
                        fclose(fid);
