classdef(Hidden)sv_interface<handle
    properties(GetAccess=public,SetAccess=private)


        mwcfg;



        ucfg;



        dut_codeinfo;



        sv_ifnam='';



        sv_inports={};



        sv_outports={};



        svinf_tmplt;



        SeqIdMap;
    end

    methods
        function this=sv_interface(varargin)


            pkginfo=what('+uvmcodegen');
            p=inputParser;
            p.KeepUnmatched=true;
            addParameter(p,'ucfg','');
            addParameter(p,'mwcfg','');
            parse(p,varargin{:});
            this.ucfg=p.Results.ucfg;
            this.mwcfg=p.Results.mwcfg;

            addParameter(p,'dut_codeinfo','');
            addParameter(p,'intf_name',[this.ucfg.prefix,this.mwcfg.sldut_name,this.ucfg.inf_suffix]);
            addParameter(p,'svinf_tmplt',sprintf('%s/%s/%s',pkginfo.path,this.ucfg.mwuvm_tmplt_path,this.ucfg.mwsv_intf_tmplt));
            parse(p,varargin{:});

            this.ucfg=p.Results.ucfg;
            this.dut_codeinfo=p.Results.dut_codeinfo;
            this.sv_ifnam=p.Results.intf_name;
            this.svinf_tmplt=p.Results.svinf_tmplt;
            this.SeqIdMap=containers.Map;
        end

        function str=prtsvinf(this)


            dpigenerator_disp(['Generating UVM interface ',dpigenerator_getfilelink(this.get_sv_ifnam_fileLoc())]);
            fid=fopen(this.svinf_tmplt,'rt');
            tpl=fscanf(fid,'%c');
            fclose(fid);
            tpl=mw_findreplace(tpl);

            [dutDir,dutSVDT,dutSize,dutIfId]=this.mwcfg.sl2uvmtopo.getDutIfInfo();
            IsScalarizePortsEnabled=this.mwcfg.sl2uvmtopo.IsScalarizePortsEnabled();

            [~,seqSVDT,seqSize,seqIfId]=this.mwcfg.sl2uvmtopo.getSeqIfInfo();
            [seqoutToPred,~,~,~]=this.mwcfg.sl2uvmtopo.getMonitorInputConnectionSigId('predictor');
            [seqoutToScr,~,~,~]=this.mwcfg.sl2uvmtopo.getMonitorInputConnectionSigId('scoreboard');
            seqout=[seqoutToPred,seqoutToScr];
            AccumSeq2ScrLA=false(1,numel(seqIfId));
            seqIfIdKey=cellfun(@(x)getFirstElementOfCell(x),seqIfId,'UniformOutput',false);
            cellfun(@(x)n_or(x),seqout);
            function n_or(id)
                id=getFirstElementOfCell(id);
                AccumSeq2ScrLA=or(AccumSeq2ScrLA,strcmp(seqIfIdKey,id));
            end














            dutIfIdKey=cellfun(@(x)getFirstElementOfCell(x),dutIfId,'UniformOutput',false);
            seq2scrIfId=seqIfId(AccumSeq2ScrLA);
            seq2scrIfIdKey=cellfun(@(x)getFirstElementOfCell(x),seq2scrIfId,'UniformOutput',false);
            function res=getFirstElementOfCell(id)
                if iscell(id)
                    res=id{1};
                else
                    res=id;
                end
            end
            vifId=[dutIfId,seq2scrIfId];
            vifIdKey=[dutIfIdKey,seq2scrIfIdKey];
            [uniqueVifIdKey,uniqueVifIdIdx,~]=unique(vifIdKey);
            uniqueVifId=vifId(uniqueVifIdIdx);
            [SeqUniqueElemKey,SeqUniqueElemIdx]=setdiff(uniqueVifIdKey,dutIfIdKey);
            SeqUniqueElem=uniqueVifId(SeqUniqueElemIdx);
            [SeqDupElemKey,SeqDupElemIdx]=setdiff(seq2scrIfIdKey,SeqUniqueElemKey);
            SeqDupElem=seq2scrIfId(SeqDupElemIdx);




            if~isempty([SeqUniqueElemKey,SeqDupElemKey])
                this.SeqIdMap=containers.Map([SeqUniqueElemKey,SeqDupElemKey],...
                [SeqUniqueElem,cellfun(@(x)modifyDupSeqId(x),SeqDupElem,'UniformOutput',false)]);
            end

            function res=modifyDupSeqId(id)
                if iscell(id)
                    res=cellfun(@(x)[x,'_seq'],id,'UniformOutput',false);
                else
                    res=[id,'_seq'];
                end
            end



            seq2scr_unique_id=cellfun(@(x)this.SeqIdMap(x),seq2scrIfIdKey,'UniformOutput',false);


            NewL_loc=strfind(tpl,newline);
            IToken_loc=strfind(tpl,'%IPORTS%');
            OToken_loc=strfind(tpl,'%OPORTS%');
            INewL_loc=NewL_loc(NewL_loc<IToken_loc);
            ONewL_loc=NewL_loc(NewL_loc<OToken_loc);
            ISpaceInd=IToken_loc-INewL_loc(end)-1;
            OSpaceInd=OToken_loc-ONewL_loc(end)-1;

            IPORTS=sprintf(char(join(cellfun(@(x,y,z)n_iodeclarations(x,y,z,repmat(' ',1,ISpaceInd)),dutSVDT(strcmp(dutDir,'input')),dutIfId(strcmp(dutDir,'input')),dutSize(strcmp(dutDir,'input')),'UniformOutput',false),'')));
            OPORTS=sprintf(char(join(cellfun(@(x,y,z)n_iodeclarations(x,y,z,repmat(' ',1,OSpaceInd)),dutSVDT(strcmp(dutDir,'output')),dutIfId(strcmp(dutDir,'output')),dutSize(strcmp(dutDir,'output')),'UniformOutput',false),'')));
            SEQOPORTS=sprintf(char(join(cellfun(@(x,y,z)n_iodeclarations(x,y,z,repmat(' ',1,OSpaceInd)),seqSVDT(AccumSeq2ScrLA),seq2scr_unique_id,seqSize(AccumSeq2ScrLA),'UniformOutput',false),'')));

            tpl=replace(tpl,'%MW_INFO%',addFLBanner(this.get_sv_ifnam_fileLoc(),'//','',bdroot(this.mwcfg.sldut_path)));
            if this.containNonFlatStructOrEnumPort()

                if~isempty(this.mwcfg.sl2uvmtopo.DG.Nodes.UVMCodeInfo_Obj{1})
                    common_dpi_pkg=this.mwcfg.sl2uvmtopo.DG.Nodes.UVMCodeInfo_Obj{1}.CompPortInfo.CommonDpiPkgName;
                    if~isempty(common_dpi_pkg)
                        ci=['import ',common_dpi_pkg,'::*;'];
                    else
                        ci='';
                    end
                end
                tpl=replace(tpl,'%IMPORT_COMMON_TYPES_PKG%',ci);
            else
                tpl=replace(tpl,'%IMPORT_COMMON_TYPES_PKG%','');
            end
            tpl=replace(tpl,'%INFNAME%',this.sv_ifnam);
            tpl=replace(tpl,'%IPORTS%',IPORTS);
            tpl=replace(tpl,'%OPORTS%',OPORTS);
            tpl=replace(tpl,'%SEQOPORTS%',SEQOPORTS);
            str=tpl;

            function n_str=n_iodeclarations(x,y,sz,SpaceInd)
                if sz>1
                    if IsScalarizePortsEnabled
                        n_str='';
                        for idx1=1:sz
                            if iscell(y)
                                n_str=sprintf('%s%s%s %s;\n',n_str,SpaceInd,x,y{idx1});
                            else
                                n_str=sprintf('%s%s%s %s_%d;\n',n_str,SpaceInd,x,y,idx1-1);
                            end
                        end
                    else
                        n_str=sprintf('%s%s %s [%d];\n',SpaceInd,x,y,sz);
                    end
                else
                    n_str=sprintf('%s%s %s;\n',SpaceInd,x,y);
                end
            end
        end


        function str=get_sv_ifnam_fileLoc(obj)
            str=replace(fullfile(obj.ucfg.component_paths('uvm_artifacts'),[obj.sv_ifnam,'.sv']),'\','/');
        end

    end
    methods(Access=private)
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
