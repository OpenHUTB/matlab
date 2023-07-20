classdef(Hidden)uvm_component<uvmcodegen.mw_subsystem

    properties
        uvmcmp_tmplt='';
        uvmobj_tmplt='';



        uvmcmp_input_tmplt='';
        uvmsqr_tmplt='';
        uvmcmp_name='';
        uvmcmp_type='uvm_component';
        uvmobj_name='';
        uvmobj_type='uvm_object';
        sources={};
        dests={};
        dut_handle='';
        top_handle='';
    end

    properties(GetAccess=public,SetAccess=protected)

        scr_cfg_obj;
    end

    properties(Constant,Access=private)
        TypedefSuff='_T';
        indval=3;
    end

    methods(Access=private)

        function[st,mac]=uvmobj_dec(this,IsScalarizePortsEnabled)
            [Scrportdir,ScrportsSVDT,ScrportSz,ScrportsID]=this.mwcfg.sl2uvmtopo.getScrIfInfo();

            inportLA=strcmp(Scrportdir,'input');
            inportsSVDT=ScrportsSVDT(inportLA);
            inportSz=ScrportSz(inportLA);
            inportsID=ScrportsID(inportLA);

            outportLA=strcmp(Scrportdir,'output');
            outportSVDT=ScrportsSVDT(outportLA);
            outportSz=ScrportSz(outportLA);
            outportID=ScrportsID(outportLA);

            st=sprintf('   // Scoreboard Inputs\n');
            mac=sprintf('  `uvm_object_utils_begin(%s)\n',this.uvmobj_name);
            for n=1:length(inportsSVDT)
                if any(strcmp(inportsSVDT{n},{'real','shortreal'}))
                    RandQualifier='';
                else
                    RandQualifier='rand';
                end

                curInportsID=inportsID{n};

                if inportSz{n}>1
                    if IsScalarizePortsEnabled
                        for idx_1=1:inportSz{n}
                            if iscell(curInportsID)
                                st=[st,sprintf('   %s %s %s ;\n',RandQualifier,inportsSVDT{n},curInportsID{idx_1})];%#ok<AGROW>
                                mac=this.uvmobj_macro(mac,curInportsID{idx_1},inportsSVDT{n},inportSz{n});
                            else
                                st=[st,sprintf('   %s %s %s_%d ;\n',RandQualifier,inportsSVDT{n},curInportsID,idx_1-1)];%#ok<AGROW>
                                mac=this.uvmobj_macro(mac,sprintf('%s_%d',curInportsID,idx_1-1),inportsSVDT{n},inportSz{n});
                            end
                        end
                    else
                        st=[st,sprintf('   %s %s %s [%d] ;\n',RandQualifier,inportsSVDT{n},curInportsID,inportSz{n})];%#ok<AGROW>
                        mac=this.uvmobj_macro(mac,curInportsID,inportsSVDT{n},inportSz{n});
                    end
                else
                    st=[st,sprintf('   %s %s %s;\n',RandQualifier,inportsSVDT{n},curInportsID)];%#ok<AGROW>
                    mac=this.uvmobj_macro(mac,curInportsID,inportsSVDT{n},inportSz{n});
                end
            end

            st=[st,sprintf('\n   // Scoreboard Outputs\n')];
            for n=1:length(outportSVDT)
                if any(strcmp(outportSVDT{n},{'real','shortreal'}))
                    RandQualifier='';
                else
                    RandQualifier='rand';
                end

                curOutportsID=outportID{n};
                if outportSz{n}>1
                    if IsScalarizePortsEnabled
                        for idx_2=1:outportSz{n}
                            if iscell(curOutportsID)
                                st=[st,sprintf('   %s %s %s;\n',RandQualifier,outportSVDT{n},curOutportsID{idx_2})];%#ok<AGROW>
                                mac=this.uvmobj_macro(mac,curOutportsID{idx_2},outportSVDT{n},outportSz{n});
                            else
                                st=[st,sprintf('   %s %s %s_%d;\n',RandQualifier,outportSVDT{n},curOutportsID,idx_2-1)];%#ok<AGROW>
                                mac=this.uvmobj_macro(mac,sprintf('%s_%d',curOutportsID,idx_2-1),outportSVDT{n},outportSz{n});
                            end
                        end
                    else
                        st=[st,sprintf('   %s %s %s [%d];\n',RandQualifier,outportSVDT{n},curOutportsID,outportSz{n})];%#ok<AGROW>
                        mac=this.uvmobj_macro(mac,curOutportsID,outportSVDT{n},outportSz{n});
                    end
                else
                    st=[st,sprintf('   %s %s %s;\n',RandQualifier,outportSVDT{n},curOutportsID)];%#ok<AGROW>
                    mac=this.uvmobj_macro(mac,curOutportsID,outportSVDT{n},outportSz{n});
                end
            end

            mac=[mac,'   `uvm_object_utils_end'];
        end

        function addFLBanner2DPI(obj)


            if isempty(obj.mwpath)
                return;
            end


            if obj.IsDUTBuild
                dpi_fl_list={'DPIPkg','DPIModule'};
            else
                dpi_fl_list={'DPIPkg'};
            end
            cellfun(@(x)n_AddFLBanner(x),dpi_fl_list);
            function n_AddFLBanner(fl)
                [~,fln,e]=fileparts(obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMBuildInfo.(fl));
                fl_loc=strrep(fullfile(obj.ucfg.component_paths(obj.UVMComponent),[fln,e]),'\','/');
                fid=fopen(fl_loc,'r');
                tpl=fread(fid,inf,'uint8=>char')';
                fclose(fid);
                tpl=replace(tpl,'//%FL_BANNER%',addFLBanner(fl_loc,'//',obj.mwpath,bdroot(obj.mwpath)));
                fid1=fopen(fl_loc,'w');
                fwrite(fid1,tpl,'uint8');
                fclose(fid1);
            end
        end

    end

    methods(Access=protected)

        function macro=uvmobj_macro(this,mac,id,dt,sz)









            farray='';
            ftype='';

            if(sz>1)
                farray='_sarray';
            end

            switch(dt)
            case 'byte unsigned'
                ftype='_int';
            case 'shortint unsigned'
                ftype='_int';
            case 'int unsigned'
                ftype='_int';
            case 'longint unsigned'
                ftype='_int';
            case 'byte'
                ftype='_int';
            case 'shortint'
                ftype='_int';
            case 'int'
                ftype='_int';
            case 'longint'
                ftype='_int';
            case 'shortreal'
                ftype='_real';
            case 'real'
                ftype='_real';
            otherwise
                if(~isempty(regexp(ftype,'^logic')))
                    ftype='_int';
                elseif(~isempty(regexp(ftype,'^bit')))
                    ftype='_int';
                else
                    ftype='';
                end
            end

            fmac=sprintf('     `uvm_field%s%s(%s, UVM_ALL_ON)\n',farray,ftype,id);

            switch([farray,ftype])
            case{'','_sarray','_sarray_real'}
                fmac='';
            end

            if(isempty(fmac))
                macro=mac;
            else
                macro=[mac,sprintf('%s\n',fmac)];
            end
        end

        function SpaceInd=getSpaceIndentation(~,tpl,token)



            NewL_loc=strfind(tpl,newline);
            Token_loc=strfind(tpl,token);
            if isempty(Token_loc)||isempty(NewL_loc)
                SpaceInd=0;
            else
                NewL_loc=NewL_loc(NewL_loc<Token_loc(1));
                SpaceInd=Token_loc(1)-NewL_loc(end)-1;
            end
        end


        function str=get_scr_cfg_obj_var_decl(obj,space_ind,TunPrmStruct)
            if isempty(TunPrmStruct.ArgumentIdentifiers)

                str='';
                return;
            end
            str=['//Local scoreboard configuration object\n',...
            repmat(' ',1,space_ind),obj.scr_cfg_obj.ScrCfgObjType,' ',obj.scr_cfg_obj.ScrCfgObjID,';\n\n'];
        end


        function str=tunable_prm_var_decl(obj,space_ind,TunPrmStruct)
            if isempty(TunPrmStruct.ArgumentIdentifiers)

                str='';
                return;
            end

            str=sprintf(['//Simulink tunable parameters\n',...
            repmat(' ',1,space_ind),...
            char(join(cellfun(@(x,y,z)[n_rand(x),x,' ',y,obj.getSVArraySzDec(numel(z)),';\n'],...
            TunPrmStruct.ArgumentTypes(:,2)',...
            TunPrmStruct.ArgumentIdentifiers(:,2)',...
            TunPrmStruct.ArgumentValues(:,2)',...
            'UniformOutput',false),repmat(' ',1,space_ind)))]);
            function n_str=n_rand(n_x)


                n_str='';
                if isa(obj,'uvmcodegen.uvm_sequence')&&~any(strcmp(n_x,{'shortreal','real'}))
                    n_str='rand ';
                end
            end
        end

        function str=tunable_prm_fcn_call(obj,space_ind,TunPrmStruct)
            if isempty(TunPrmStruct.ArgumentIdentifiers)

                str='';
                return;
            end


            if isa(obj,'uvmcodegen.uvm_scoreboard')
                TunPrmObj=[obj.scr_cfg_obj.ScrCfgObjID,'.'];
            else
                TunPrmObj='';
            end
            str=sprintf(['//DPI function call to set tunable parameters\n',...
            char(join(cellfun(@(x,y,z)[repmat(' ',1,space_ind),x,'(',y,',',TunPrmObj,z,');\n'],TunPrmStruct.FunctionName',TunPrmStruct.ArgumentIdentifiers(:,1)',TunPrmStruct.ArgumentIdentifiers(:,2)','UniformOutput',false),''))]);
        end



        function str=getSVArrayIdxAccessor(~,indx,arrsz)
            if arrsz<2
                str='';
            else
                str=['[',num2str(indx),']'];
            end
        end

        function str=getSVArraySzDec(~,arrsz)
            if arrsz<2
                str='';
            else
                str=['[',num2str(arrsz),']'];
            end
        end


        function str=getSVDefLiteral(~,svdt,def_value)
            DT2SZ=containers.Map({'byte','shortint','int','longint'},...
            {'8','16','32','64'});

            if any(strcmp(svdt,{'shortreal','real'}))


                str=num2str(def_value);
                return;
            end



            str='';
            s=regexp(svdt,['(',char(join([keys(DT2SZ),'bit','logic'],'|')),')\s*(signed|unsigned)?\s*(\[\d+:0\])?'],'tokens');

            assert(~isempty(s)&&numel(s{1})==3,'Incorrect SV data type');

            if DT2SZ.isKey(s{1}{1})
                str=[str,DT2SZ(s{1}{1})];
            else
                str=[str,num2str(sscanf(s{1}{3},'[%d:0]')+1)];
            end

            str=[str,''''];

            if strcmp(s{1}{2},'signed')||...
                (DT2SZ.isKey(s{1}{1})&&~strcmp(s{1}{2},'unsigned'))
                str=[str,'s'];
            end

            str=[str,'d'];

            if isa(def_value,'embedded.fi')
                if DT2SZ.isKey(s{1}{1})


                    str=[str,num2str(abs(def_value.storedInteger))];
                    if def_value<0
                        str=['-',str];
                    end
                else
                    str=[str,def_value.dec];
                end
            else
                str=[str,num2str(abs(def_value))];
                if def_value<0
                    str=['-',str];
                end
            end
        end



        function str=getCfgDBType(obj,DT,ID,VAL)
            if numel(VAL)>1
                str=[ID,obj.TypedefSuff];
            else
                str=DT;
            end
        end

        function[ind_base,ind_lvl,num_ind_lvl]=getIndentationLevels(obj,num_ind_base,max_ind_lvl)

            ind_base=repmat(' ',1,num_ind_base);
            ind_lvl=arrayfun(@(x)[ind_base,repmat(' ',1,x)],(1:max_ind_lvl)*obj.indval,'UniformOutput',false);
            num_ind_lvl=arrayfun(@(x)num_ind_base+x,(1:max_ind_lvl)*obj.indval,'UniformOutput',false);
        end



        function Delay=getClkCyclesDelay(obj)
            if isa(obj,'uvmcodegen.uvm_driver')
                if obj.DrvMode==uvmcodegen.ConvertorMode.DPISUB
                    [HighST,~,~,LowST]=n_getMaxMinPortST();
                else

                    HighST=obj.mwcfg.sl2uvmtopo.getSeqBR();
                    LowST=obj.mwcfg.sl2uvmtopo.getDutBR();
                end
            elseif isa(obj,'uvmcodegen.uvm_monitor')

                if obj.MonMode==uvmcodegen.ConvertorMode.DPISUB
                    [~,LowST,HighST,~]=n_getMaxMinPortST();
                else

                    HighST=obj.mwcfg.sl2uvmtopo.getScrBR();
                    LowST=obj.mwcfg.sl2uvmtopo.getDutBR();
                end
            else
                HighST=1;LowST=1;
            end

            Delay=num2str(uint32(HighST/LowST-1));

            function[MaxInp,MinInp,MaxOut,MinOut]=n_getMaxMinPortST()
                OutLA=strcmp('output',obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.ArgumentDirections(2:end));
                InLA=strcmp('input',obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.ArgumentDirections(2:end));
                STA=obj.mwblkUVMVCodeInfo.UVMCodeInfo.UVMCompFcnInfo.OutputFunction.ArgumentST(2:end);
                MaxInp=max(cell2mat(STA(InLA)));
                MinInp=min(cell2mat(STA(InLA)));
                MaxOut=max(cell2mat(STA(OutLA)));
                MinOut=min(cell2mat(STA(OutLA)));
            end

        end

        function tmp_f=StrFormatting(~,str)

            tmp_f=split((repmat('%s ',1,count(str,'%s'))))';
            tmp_f=tmp_f(1:end-1);
        end
    end

    methods
        function this=uvm_component(varargin)

            this=this@uvmcodegen.mw_subsystem(varargin{:});
            p=inputParser;
            p.KeepUnmatched=true;

            addParameter(p,'ucfg','');
            parse(p,varargin{:});
            this.ucfg=p.Results.ucfg;

            addParameter(p,'uvmcmp_name',[this.ucfg.prefix,this.mwblkname,this.ucfg.suffix]);
            addParameter(p,'uvmobj_name',[this.ucfg.prefix,this.mwblkname,this.ucfg.scr_suffix,this.ucfg.obj_suffix]);
            addParameter(p,'uvmobj_type','uvm_object');
            addParameter(p,'uvmcmp_tmplt',[this.pkginfo.path,'/',this.ucfg.mwuvm_tmplt_path,'/',this.ucfg.mwuvm_cmp_tmplt]);
            addParameter(p,'uvmobj_tmplt',[this.pkginfo.path,'/',this.ucfg.mwuvm_tmplt_path,'/',this.ucfg.mwuvm_obj_tmplt]);
            addParameter(p,'src','');
            addParameter(p,'scr_cfg_obj','');
            addParameter(p,'dst','');
            addParameter(p,'dut_handle','');
            addParameter(p,'top_handle','');

            parse(p,varargin{:});

            this.uvmcmp_name=p.Results.uvmcmp_name;
            this.uvmobj_name=p.Results.uvmobj_name;
            this.uvmobj_type=p.Results.uvmobj_type;
            this.uvmcmp_tmplt=p.Results.uvmcmp_tmplt;
            this.uvmobj_tmplt=p.Results.uvmobj_tmplt;
            this.top_handle=p.Results.top_handle;

            this.setDut(p.Results.dut_handle);
            this.addSrc(p.Results.src);
            this.addDst(p.Results.dst);
            this.scr_cfg_obj=p.Results.scr_cfg_obj;
        end

        function status=setDut(this,dut)

            this.dut_handle=dut;
        end

        function status=addSrc(this,h)

            if(~isempty(h))
                this.sources{end+1}=h;
            end

        end

        function status=addDst(this,h)

            if(~isempty(h))
                this.dests{end+1}=h;
            end

        end

        function string=prtuvmcmp(this,varargin)

            this.addFLBanner2DPI();
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'MonitorInput',false);
            addParameter(p,'Sequencer',false);
            parse(p,varargin{:});
            MonitorInput=p.Results.MonitorInput;
            Sequencer=p.Results.Sequencer;
            if MonitorInput
                fid=fopen(this.uvmcmp_input_tmplt,'rt');
            elseif Sequencer
                fid=fopen(this.uvmsqr_tmplt,'rt');
            else
                fid=fopen(this.uvmcmp_tmplt,'rt');
            end
            tpl=fscanf(fid,'%c');
            fclose(fid);

            tpl=mw_findreplace(tpl);
            string=tpl;
        end

        function string=prtuvmobj(this,scrBlkPath)

            dpigenerator_disp(['Generating UVM transaction object ',dpigenerator_getfilelink(this.get_uvmobj_name_fileLoc())]);
            fid=fopen(this.uvmobj_tmplt,'rt');
            tpl=fscanf(fid,'%c');
            fclose(fid);

            tpl=mw_findreplace(tpl);
            this.addFLBanner2DPI();
            IsScalarizePortsEnabled=this.mwcfg.sl2uvmtopo.IsScalarizePortsEnabled();
            [dec,mac]=this.uvmobj_dec(IsScalarizePortsEnabled);

            tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_uvmobj_name_fileLoc(),'//',scrBlkPath,bdroot(this.mwpath)));
            tpl=replace(tpl,'%IMPORT_COMMON_TYPES_PKG%','');
            tpl=replace(tpl,'%CLASSNAME%',this.uvmobj_name);
            tpl=replace(tpl,'%CLASSTYPE%',this.uvmobj_type);
            tpl=replace(tpl,'%DECLARATIONS%',dec);
            tpl=replace(tpl,'%FIELDMACROS%',mac);
            string=tpl;
        end

        function str=printUVMRunTimeReporting(this,ind)
            str='';
            if~isempty(this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMRunTimeErrFcnInfo.FunctionName)
                [ind_base,ind_lvl]=this.getIndentationLevels(ind,1);
                str=sprintf([ind_base,'//Run-time error reporting\n',ind_base,'%s = %s(%s);\n',ind_base,'if(%s.len()!=0) begin\n',ind_lvl{1},'%s\n',ind_base,'end\n'],...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMRunTimeErrFcnInfo.ReturnIdentifier,...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMRunTimeErrFcnInfo.FunctionName,...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMRunTimeErrFcnInfo.ArgumentIdentifier,...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMRunTimeErrFcnInfo.ReturnIdentifier,...
                this.mwblkUVMVCodeInfo.UVMCodeInfo.UVMRunTimeErrFcnInfo.UVMMacro);
            end
        end


        function str=get_uvmobj_name_fileLoc(obj)
            str=obj.replaceBackS(fullfile(obj.ucfg.component_paths('scoreboard'),[obj.uvmobj_name,'.sv']));
        end

        function str=get_uvmobj_name_fileRelLoc(obj)
            [~,dutdir,~]=fileparts(obj.ucfg.component_paths('scoreboard'));
            str=obj.replaceBackS(fullfile('..',dutdir,[obj.uvmobj_name,'.sv']));
        end

        function str=replaceBackS(obj,str_b)%#ok

            str=replace(str_b,'\','/');
        end

        function res=containNonFlatStructOrEnumPort(this)

            res=false;
            for idx=1:numel(this.mwcfg.sl2uvmtopo.DG.Nodes.UVMCodeInfo_Obj)

                thisPortInfo=this.mwcfg.sl2uvmtopo.DG.Nodes.UVMCodeInfo_Obj{idx}.CompPortInfo;
                if(thisPortInfo.ContainStruct&&thisPortInfo.StructEnabled)||thisPortInfo.ContainEnum
                    res=true;
                    break;
                end
            end
        end


    end
end

