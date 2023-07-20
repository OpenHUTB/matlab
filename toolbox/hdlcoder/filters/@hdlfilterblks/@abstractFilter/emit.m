function hdlcode=emit(this,hC)


    hDrv=hdlcurrentdriver;
    codegendir=hDrv.hdlGetCodegendir;

    displayProgressMsg(hC,codegendir);
    if isfield(hC.HDLUserData,'FilterObject')
        hF=hC.HDLUserData.FilterObject;
        fp=[hC.Owner.Name];
        slname=hC.Name;
        block_desc='';
        block_parent='';
        block_name=hC.Name;
    else
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        hF=this.createHDLFilterObj(hC);
        fp=get(get_param(bfp,'Handle'),'Path');
        slname=get_param(bfp,'Name');
        block_desc=get_param(bfp,'Description');
        block_parent=block.parent;
        block_name=block.Name;
    end
    if hC.SimulinkHandle==-1
        hF.CodeGenMode='matlabcoder';
    end

    if~isempty(hF)















        vhdlpkgreqd=hdlgetparameter('vhdl_package_required');


        oldcgmode=hdlcodegenmode;
        hdlcodegenmode('filtercoder');

        old_props=localCopyParamsToGlobalPool(hF);

        if hC.SimulinkHandle==-1
            hF.setHDLParameter('TargetDirectory',codegendir);
            hF.setHDLParameter('TargetLanguage',hdlgetparameter('target_language'));
        end


        hdlentitysignalsinit;





        oldPVs=this.setupParamsForFilterCodeGen(hC,hF);
        s=this.applyFilterImplParams(hF,hC);
        appliedPVs=s.pcache;
        hF.setimplementation;

        customHeaderComment=hdlgetparameter('CustomFileHeaderComment');
        customFooterComment=hdlgetparameter('CustomFileFooterComment');

        dfname=hC.Name;
        ip=hdlgetparameter('instance_prefix');
        dfname=regexprep(dfname,['^',ip],'');




        if isempty(customHeaderComment)
            if hdlgetparameter('datecomment')==1
                createdate=['Created: ',datestr(now,31),'\n'];
            else
                createdate='';
            end
            filename=fullfile(codegendir,dfname);
            cchar=hdlgetparameter('comment_char');
            genby=hdlgetparameter('tool_file_comment');
            genby(1:length(cchar)+1)='';
            usercomment=hdlgetparameter('rcs_cvs_tag');

            usercomment=regexprep(usercomment,['^',cchar,' '],'');
            usercomment=regexprep(usercomment,['\n',cchar,' '],'\n');
            comments=...
            [repmat('-',1,60),'\n',...
            '\n',...
            'File Name: ',filename,'\n',...
            createdate,...
            genby,...
            usercomment,...
            '\n',...
            repmat('-',1,60),'\n',...
            '\n',...
            '\n',...
            repmat('-',1,60),'\n',...
            '\n',...
            'Module: ',dfname,'\n',...
            'Source Path: ',block_parent,'/',block_name,'\n',...
            '\n',...
            repmat('-',1,60),'\n'];
            if~isempty(block_desc)
                comments=[comments,...
                '\n',...
                '\n',...
                repmat('-',1,60),'\n\n',...
                'Block Comments: \n\n',...
                block_desc,'\n\n',...
                repmat('-',1,60),'\n'];
            end
            comments=hdlformatcomment(comments);


            impstr=hF.getImplementationStr;
            impstr=strrep(impstr,'\n',char(10));

            comments=[comments,impstr];

            hF.Comment=strrep(comments,'\','\\');
        else


            commentStart=[hdlgetparameter('comment_char'),' '];
            comment=strrep([commentStart,customHeaderComment],'\','\\');
            comment=strrep(comment,char(10),[char(10),commentStart]);
            hF.Comment=[comment,'\n\n'];
        end


        if isempty(customFooterComment)
            hF.FooterComment=[];
        else
            commentStart=[hdlgetparameter('comment_char'),' '];
            comment=strrep([commentStart,customFooterComment],'\','\\');
            comment=strrep(comment,char(10),[char(10),commentStart]);
            hF.FooterComment=['\n',comment];
        end


        if hdlconnectivity.genConnectivity
            hCD=hdlconnectivity.getConnectivityDirector;

            ntwkpath=hCD.getNetworkHDLPath(hC.Owner);
            hCD.setCurrentHDLPath(ntwkpath);


        end




        hF.emit;


        if~isa(hC,'hdlcoder.sysobj_comp')


            [~,~,lat]=hF.latency;
            fprintf('%s\n',getString(message('hdlcoder:hdldisp:filterlatency',lat)));


            filterarch=hF.Implementation;
            mip=this.getImplParams('MultiplierInputPipeline');
            mop=this.getImplParams('MultiplierOutputPipeline');
            if isempty(mip)
                mip=0;
            end
            if isempty(mop)
                mop=0;
            end
            isFirtdecimPipelined=isa(hF,'hdlfilter.firtdecim')&&mip>0&&mop>0;
            isdecimMultiClock=(isa(hF,'hdlfilter.firdecim')||isa(hF,'hdlfilter.firtdecim')||...
            isa(hF,'hdlfilter.cicdecim'))...
            &&(hdlgetparameter('clockinputs')>1);
            isChannelShared=hF.HDLParameters.INI.getProp('filter_generate_multichannel')>1;
            if any(strcmpi(filterarch,{'serial','serialcascade','distributedarithmetic'}))||...
                isFirtdecimPipelined||...
                isdecimMultiClock||...
isChannelShared
                fprintf('%s\n',getString(message('hdlcoder:hdldisp:filtersynclatency')));

            end

        end



        if hdlconnectivity.genConnectivity,
            hCD=hdlconnectivity.getConnectivityDirector;
            hCD.setCurrentAdapter('String');



            compinfo=hF.componentConnectivity;
            if~isempty(compinfo),
                filtpath=compinfo.path;


                for pp=1:numel(filtpath),
                    hCD.addRelativeClockEnable(hdlgetparameter('clockenablename'),hC.PirInputSignals(2).Name,0,1,...
                    'newEnbPath',filtpath{pp},'relEnbPath',ntwkpath{pp});
                end

                insigs=compinfo.inputs;
                outsigs=compinfo.outputs;

                for ii=1:numel(filtpath),

                    num_in=numel(insigs);
                    for kk=4:num_in,

                        hCD.addDriverReceiverPair(hC.PIRinputSignals(kk).Name,insigs{kk},'driverPath',ntwkpath{ii},'receiverPath',filtpath{ii});
                    end




                    for kk=1:numel(hC.PIRoutputSignals),
                        hCD.addDriverReceiverPair(outsigs{kk},hC.PIRoutputSignals(kk).Name,'driverPath',filtpath{ii},'receiverPath',ntwkpath{ii});
                    end




                end
            end
        end




        this.unApplyParams(appliedPVs);
        this.unApplyParams(oldPVs);


        PersistentHDLPropSet(old_props);
        hdlcodegenmode(oldcgmode);






        hdlsetparameter('vhdl_package_required',vhdlpkgreqd);


        hdladdtoentitylist([fp,'/',slname],dfname,'','');

    end






    hdlcode.entity_name=hC.Name;
    hdlcode.arch_name=hdlgetparameter('vhdl_architecture_name');
    hdlcode.library_name=hdlgetparameter('vhdl_library_name');
    hdlcode.component_name=hC.Name;


    function displayProgressMsg(hC,codegendir)

        if hC.SimulinkHandle>0
            fullpathname=getfullname(hC.SimulinkHandle);
        else
            fullpathname=[hC.Owner.Name,'/',hC.Name];
        end

        fullpathname=strrep(fullpathname,char(10),' ');
        fullpathname=strrep(fullpathname,char(13),' ');
        nameforuser=[hC.Name,hdlgetparameter('filename_suffix')];
        fullfilename=fullfile(codegendir,nameforuser);
        hdldisp(message('hdlcoder:hdldisp:WorkingOnBlock',fullpathname,hdlgetfilelink(fullfilename)));


        function old_props=localCopyParamsToGlobalPool(hF)





            hDriver=hdlcurrentdriver;
            slpropval=hDriver.getCPObj;
            old_props=PersistentHDLPropSet;
            PersistentHDLPropSet(copyobj(slpropval));
            hF.HDLParameters=PersistentHDLPropSet;
            hdlsetparameter('entitynamelist',[]);
            hdlsetparameter('entitypathlist',[]);
            hdlsetparameter('entityportlist',[]);
            hdlsetparameter('entityarchlist',[]);

            hdlsetparameter('lasttopleveltargetlang','');
            hdlsetparameter('lasttoplevelname','');
            hdlsetparameter('lasttoplevelports','');
            hdlsetparameter('lasttoplevelportnames','');
            hdlsetparameter('lasttopleveldecls','');
            hdlsetparameter('lasttoplevelinstance','');
            hdlsetparameter('lasttopleveltimestamp','');

            hdlsetparameter('vhdl_package_required',false);









