function outfileName=utilDrawPIR(pirInstance,globalContext)

    globalContext.doDeadLogicElimination(true);
    pirInstance.doPreModelgenTasks;

    topNtwk=pirInstance.getTopNetwork;
    topNtwk.renderCodegenPir(true);

    infile='';
    verbose=false;
    openoutfile='no';

    outfile=topNtwk.Name;
    outfileprefix='gm_';
    autoroute='yes';
    autoplace='yes';
    hiliteparents='yes';
    color='cyan';
    showCGPIR='on';
    useArrangeSystem='yes';

    hb=slhdlcoder.SimulinkBackEnd(pirInstance,...
    'InModelFile',infile,...
    'OutModelFile',outfile,...
    'DUTMdlRefHandle',-1,...
    'ShowModel',openoutfile,...
    'OutModelFilePrefix',outfileprefix,...
    'ShowCodeGenPIR',showCGPIR,...
    'AutoRoute',autoroute,...
    'AutoPlace',autoplace,...
    'HiliteAncestors',hiliteparents,...
    'HiliteColor',color,...
    'Verbose',verbose,...
    'MLMode',true,...
    'UseArrangeSystem',useArrangeSystem);

    hb.generateModel;
    outfileName=[outfileprefix,outfile];
end