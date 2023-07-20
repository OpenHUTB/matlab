function writeSimDoFile(this,varargin)


    if nargin==3
        epl=varargin{1};
        epl_out_ref=varargin{2};
    else
        [epl,epl_out_ref]=this.getPortList;
    end

    if this.GenerateTBCompileDoFile
        topname=this.TestBenchName;
    else
        topname=hdlentitytop;
    end

    fname=fullfile(this.CodeGenDirectory,[topname,this.SimDoFilePostFix]);
    fid=fopen(fname,'w');
    if fid==-1
        error(message('HDLShared:hdlshared:simopenfile'));
    end
    fprintf(fid,this.HdlSimInit);

    simCmd=this.HdlSimCmd;

    simCmd=this.getTargetSpecificSimCmd(simCmd);

    if hdlgetparameter('isvhdl')
        libname=hdlgetparameter('vhdl_library_name');
    else
        libname='work';
    end
    fprintf(fid,simCmd,libname,topname);

    tbname=this.TestBenchName;

    inst_prefix=hdlgetparameter('instance_prefix');
    inst_name=this.TopLevelName;
    inst_postfix=hdlgetparameter('instance_postfix');
    tbref_postfix=hdlgetparameter('testbenchreferencepostfix');
    for n=1:length(epl)
        fprintf(fid,this.HdlSimViewWaveCmd,...
        sprintf('/%s/%s/%s',tbname,hdllegalname([inst_prefix,char(inst_name),inst_postfix]),epl{n}));
        if~isempty(epl_out_ref{n})
            fprintf(fid,this.HdlSimViewWaveCmd,...
            sprintf('/%s/%s',tbname,hdllegalname([epl{n},tbref_postfix])));
        end
    end

    fprintf(fid,this.HdlSimTerm);
    fclose(fid);
end
