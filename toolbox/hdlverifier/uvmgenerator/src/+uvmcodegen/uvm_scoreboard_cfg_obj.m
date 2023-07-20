classdef(Hidden)uvm_scoreboard_cfg_obj<uvmcodegen.uvm_component

    properties(GetAccess=public,SetAccess=private)

        ScrCfgObjType;
        ScrCfgObjID;
        FormatSequence={};


    end

    properties(Constant,Access=private)
        Var_suffix='_id';
        PArg_Str_suff='_pargs_str';
    end

    properties(Access=private)
        scr;
    end

    methods
        function this=uvm_scoreboard_cfg_obj(varargin)
            this=this@uvmcodegen.uvm_component(varargin{:});
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'uvmcmp_name',replace([this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.scr_suffix,this.ucfg.scr_cfg_obj_suffix],newline,''));
            addParameter(p,'uvmcmp_tmplt',sprintf('%s/%s/%s',this.pkginfo.path,this.ucfg.mwuvm_tmplt_path,this.ucfg.mwuvm_scr_cfg_obj_tmplt));
            addParameter(p,'scr',[]);
            parse(p,varargin{:});

            this.uvmcmp_name=p.Results.uvmcmp_name;
            this.uvmcmp_type='uvm_scoreboard_cfg_obj';
            this.uvmcmp_tmplt=p.Results.uvmcmp_tmplt;

            this.ScrCfgObjType=p.Results.uvmcmp_name;
            this.ScrCfgObjID=[p.Results.uvmcmp_name,this.Var_suffix];
            this.scr=p.Results.scr;
        end

        function IsPresent=IsCfgObjPresent(obj)
            IsPresent=~isempty(obj.scr.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TunablePrmFunction.FunctionName);
        end

        function str=prtuvmcmp(this)
            dpigenerator_disp(['Generating UVM scoreboard configuration object ',dpigenerator_getfilelink(this.get_uvmcmp_name_fileLoc())]);
            tpl=prtuvmcmp@uvmcodegen.uvm_component(this);
            tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_uvmcmp_name_fileLoc(),'//',this.mwpath,bdroot(this.mwcfg.sldut_path)));
            tpl=replace(tpl,'%SCRCFGNAME%',this.ScrCfgObjType);
            tpl=replace(tpl,'%TUN_PRM_VAR_DECL%',this.tunable_prm_var_decl(this.getSpaceIndentation(tpl,'%TUN_PRM_VAR_DECL%'),this.scr.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TunablePrmFunction));


            tpl=replace(tpl,'%TUN_PRM_ARRVAR_PARG_STR_DECL%',this.tun_prm_arrvar_parg_str_decl(this.getSpaceIndentation(tpl,'%TUN_PRM_ARRVAR_PARG_STR_DECL%'),this.scr.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TunablePrmFunction));
            tpl=replace(tpl,'%GET_PRM_VALS_FROM_PARGS%',this.get_prm_vals_from_pargs(this.getSpaceIndentation(tpl,'%GET_PRM_VALS_FROM_PARGS%'),this.scr.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TunablePrmFunction));
            tpl=replace(tpl,'%GET_PRM_VEC_VALS_FROM_PARGS%',this.get_prm_vec_vals_from_pargs(this.getSpaceIndentation(tpl,'%GET_PRM_VEC_VALS_FROM_PARGS%'),this.scr.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.TunablePrmFunction));
            str=tpl;
        end


        function str=get_uvmcmp_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths('scoreboard'),[obj.uvmcmp_name,'.sv']));
        end


        function str=get_uvmcmp_name_fileRelLoc(obj)
            [~,scrdir,~]=fileparts(obj.ucfg.component_paths('scoreboard'));
            str=obj.replaceBackS(fullfile('..',scrdir,[obj.uvmcmp_name,'.sv']));
        end
    end

    methods(Access=private)


        function str=tun_prm_arrvar_parg_str_decl(obj,space_ind,TunPrmStruct)

            [ind_base,~]=obj.getIndentationLevels(space_ind,0);

            if isempty(TunPrmStruct.ArgumentIdentifiers)

                str='';
                return;
            end

            TunPrmId=TunPrmStruct.ArgumentIdentifiers(:,2)';
            DecList=char(join(cellfun(@(varId)[varId,obj.PArg_Str_suff],TunPrmId(cellfun(@(x)numel(x)>1,TunPrmStruct.ArgumentValues(:,2)')),'UniformOutput',false),', '));
            if~isempty(DecList)

                str=['//String variables to receive tunable parameter vector plusargs\n',...
                ind_base,'string ',DecList,';\n'];
            else
                str='';
            end
        end


        function str=get_prm_vals_from_pargs(obj,space_ind,TunPrmStruct)

            [ind_base,ind_lvl]=obj.getIndentationLevels(space_ind,1);

            if isempty(TunPrmStruct.ArgumentIdentifiers)

                str='';
                return;
            end

            OnlyScalarLA=cellfun(@(x)numel(x)==1,TunPrmStruct.ArgumentValues(:,2)');
            TunPrmId=TunPrmStruct.ArgumentIdentifiers(:,2)';
            TunPrmVals=TunPrmStruct.ArgumentValues(:,2)';
            TunPrmTypes=TunPrmStruct.ArgumentTypes(:,2)';
            str=['//Get tunable parameter scalar values from plusargs\n',...
            char(join(cellfun(@(x,y,z)[ind_base,'if(!$value$plusargs("',y,'=%s",',y,')) begin\n',...
            ind_lvl{1},'//If no plusarg is found then revert to the Simulink default value\n',...
            ind_lvl{1},y,'=',obj.getSVDefLiteral(x,z),';\n',...
            ind_base,'end\n\n'],TunPrmTypes(OnlyScalarLA),...
            TunPrmId(OnlyScalarLA),...
            TunPrmVals(OnlyScalarLA),'UniformOutput',false),''))];




            if any(OnlyScalarLA)
                obj.ucfg.TunPrmPargsMap=[obj.ucfg.TunPrmPargsMap;containers.Map(TunPrmId(OnlyScalarLA),cellfun(@(x)num2str(x),TunPrmVals(OnlyScalarLA),'UniformOutput',false))];
            end

            obj.FormatSequence=cellfun(@(x)obj.getFormatStr(x),TunPrmTypes(OnlyScalarLA),'UniformOutput',false);
        end


        function str=get_prm_vec_vals_from_pargs(obj,space_ind,TunPrmStruct)

            [ind_base,ind_lvl]=obj.getIndentationLevels(space_ind,2);

            if isempty(TunPrmStruct.ArgumentIdentifiers)

                str='';
                return;
            end

            OnlyVecLA=cellfun(@(x)numel(x)>1,TunPrmStruct.ArgumentValues(:,2)');
            if~any(OnlyVecLA)

                str='';
                return;
            end


            All_ID=TunPrmStruct.ArgumentIdentifiers(:,2)';
            ID=All_ID(OnlyVecLA);



            ID_PARG_STR=cellfun(@(x)[x,obj.PArg_Str_suff],ID,'UniformOutput',false);




            ALL_VALS=TunPrmStruct.ArgumentValues(:,2)';
            ALL_TYPES=TunPrmStruct.ArgumentTypes(:,2)';
            PREFORMAT_SEQ=cellfun(@(val)[repmat('%s,',1,numel(val)-1),'%s'],ALL_VALS(OnlyVecLA),'UniformOutput',false);


            obj.FormatSequence=[obj.FormatSequence,...
            split(join(cellfun(@(pref_seq,dt)['%s,',replace(pref_seq,'%s',obj.getFormatStr(dt))],PREFORMAT_SEQ,ALL_TYPES(OnlyVecLA),'UniformOutput',false),','),',')'];



            SCALAR_SEQ=cellfun(@(id,val)char(join(arrayfun(@(val_arf)[id,'[',num2str(val_arf),']'],(0:numel(val)-1),'UniformOutput',false),',')),ID,ALL_VALS(OnlyVecLA),'UniformOutput',false);


            ARR_SIZE=cellfun(@(v)num2str(numel(v)),ALL_VALS(OnlyVecLA),'UniformOutput',false);





            DEF_VAL_SEQ=cellfun(@(v)char(join(arrayfun(@(v_arf)num2str(v_arf),reshape(v,1,numel(v)),'UniformOutput',false),',')),ALL_VALS(OnlyVecLA),'UniformOutput',false);


            str=['//Get tunable parameter vector values from plusargs\n',...
            char(join(cellfun(@(id,id_parg_str,preformat_seq,scalar_seq,arr_size,def_val_seq)n_get_vec_val_from_pargs(id,id_parg_str,preformat_seq,scalar_seq,arr_size,def_val_seq),...
            ID,ID_PARG_STR,PREFORMAT_SEQ,SCALAR_SEQ,ARR_SIZE,DEF_VAL_SEQ,'UniformOutput',false),''))];

            function n_str=n_get_vec_val_from_pargs(n_ID,n_ID_PARG_STR,n_PREFORMAT_SEQ,n_SCALAR_SEQ,n_ARR_SIZE,n_DEF_VAL_SEQ)
















                n_str=[ind_base,'if($value$plusargs("',n_ID,'=%s",',n_ID_PARG_STR,')) begin\n',...
                ind_lvl{1},'//Detected plusargs string\n',...
                ind_lvl{1},'if($sscanf(',n_ID_PARG_STR,',"{',n_PREFORMAT_SEQ,'}",',n_SCALAR_SEQ,')!=',n_ARR_SIZE,')begin\n',...
                ind_lvl{2},'//If the plusargs string does not match vector format then use Simulink default values\n',...
                ind_lvl{2},n_ID,'=''{',n_DEF_VAL_SEQ,'};\n',...
                ind_lvl{1},'end\n',...
                ind_base,'end\n',...
                ind_base,'else begin\n',...
                ind_lvl{1},'//If no plusarg is found then revert to the Simulink default value\n',...
                ind_lvl{1},n_ID,'=''{',n_DEF_VAL_SEQ,'};\n',...
                ind_base,'end\n\n'];


                obj.ucfg.TunPrmPargsMap(n_ID)=['{',n_DEF_VAL_SEQ,'}'];
            end
        end

        function f_str=getFormatStr(~,SVDT)

            if any(strcmp(SVDT,{'real','shortreal'}))
                f_str='%f';
            else
                f_str='%d';
            end
        end


    end
end


