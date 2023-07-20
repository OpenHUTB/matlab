function dlgSchema=nesl_utility_createpmschema(hBlk)




    hBlk=pmsl_getdoublehandle(hBlk);
    dlgSchema=[];

    subName=get_param(hBlk,'SubClassName');
    switch(subName)
    case 'ps_input'
        dlgSchema=lGetInputBlkDlgSchema(hBlk);
    case 'ps_output'
        dlgSchema=lGetOutputBlkDlgSchema(hBlk);
    case 'solver'
        dlgSchema=lGetSolverBlkDlgSchema(hBlk);
    otherwise
    end
end


function retSchema=lGetInputBlkDlgSchema(hSlBlk)
    retSchema=[];%#ok

    descPnl=PMDialogs.PmDescriptionPanel(hSlBlk);
    convertPnl=NetworkEngine.PmNePSConvertPanel(hSlBlk,'sl2ps');
    myBlder=PMDialogs.PmDlgBuilder(hSlBlk);
    myBlder.Items=[descPnl,convertPnl];
    [status,retSchema]=myBlder.getPmSchema(retSchema);%#ok
end

function retSchema=lGetOutputBlkDlgSchema(hSlBlk)
    retSchema=[];%#ok

    descPnl=PMDialogs.PmDescriptionPanel(hSlBlk);
    convertPnl=NetworkEngine.PmNePSConvertPanel(hSlBlk,'ps2sl');
    myBlder=PMDialogs.PmDlgBuilder(hSlBlk);
    myBlder.Items=[descPnl,convertPnl];
    [status,retSchema]=myBlder.getPmSchema(retSchema);%#ok
end

function retSchema=lGetSolverBlkDlgSchema(hSlBlk)
    retSchema=[];%#ok

    solverPanel=NetworkEngine.PmNeSolverPanel(hSlBlk);
    myBlder=PMDialogs.PmDlgBuilder(hSlBlk);
    myBlder.Items=solverPanel;
    [status,retSchema]=myBlder.getPmSchema(retSchema);%#ok
end