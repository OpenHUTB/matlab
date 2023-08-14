function this=TLMTestbench(subsysPath,subsysName)





    this=tlmg.TLMTestbench;

    sc=tlmg.SimulinkConnection(subsysPath,subsysName);
    sc.initModel();
    sc.termModel();

    this.initParams(sc);












    bp=regexprep(sc.System,['^',sc.ModelName,'[/]{0,1}'],'');

    if(isempty(bp))

        this.SllogBasePath=this.OrigSllogName;

    else


        bp=regexprep(bp,'//','__xxxx__');


        bps=regexp(bp,'/','split');



        bpsp=cellfun(@(x)(sprintf('(''%s'')',x)),bps,'UniformOutput',false);


        bpsp=regexprep(bpsp,'__xxxx__','/');


        bp=sprintf('%s.',bpsp{:});


        this.SllogBasePath=[this.OrigSllogName,'.',bp(1:end-1)];
    end

