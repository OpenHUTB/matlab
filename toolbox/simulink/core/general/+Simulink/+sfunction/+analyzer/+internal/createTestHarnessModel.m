function[modelFile,errorstatus,output]=createTestHarnessModel(sfunName,sfunSrcBlock,targetDir)

    errorstatus=0;
    output='';
    [~,mdlName,~]=fileparts(tempname);
    mdlH=new_system(mdlName);
    load_system(mdlH);
    blkName=[mdlName,'/S-function'];
    add_block(sfunSrcBlock,blkName);
    states.a=warning('off','Simulink:Engine:OutputNotConnected');
    states.b=warning('off','Simulink:Engine:InputNotConnected');
    states.c=warning('off','Simulink:Harness:ExportDeleteHarnessFromSystemModel');
    states.d=warning('off','Simulink:Engine:MdlFileShadowing');
    finishup=onCleanup(@()exitCleanupFun(mdlH,mdlName,states));
    try
        Simulink.harness.internal.create(blkName,false,false,'Source','Constant','Name','sfun_harness');
        sfunTestMdlName=[sfunName,'_unittest'];
        Simulink.harness.internal.export(blkName,'sfun_harness',false,'Name',sfunTestMdlName);
        movefile([sfunTestMdlName,'.slx'],targetDir);
        modelFile=[sfunTestMdlName,'.slx'];
    catch me
        modelFile='';
        errorstatus=1;
        output.summaryResult=Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN;
        output.summaryNum=1;
        output.category=Simulink.sfunction.analyzer.internal.ComplianceCheck.MEX_FILE_CHECK;
        output.target=sfunName;
        output.content={};
        ss.description='HarnessCreationAborted';
        ss.result=Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN;
        msg=message('Simulink:SFunctions:ComplianceCheckTestHarnessCreateFail',sfunName);
        ss.details={MSLDiagnostic([],msg)};
        output.content=[output.content,{ss}];
    end
end
function exitCleanupFun(mdlH,mdlName,states)
    save_system(mdlH);
    close_system(mdlH,0);
    delete([mdlName,'.slx']);
    warning(states.a.state,'Simulink:Engine:OutputNotConnected');
    warning(states.b.state,'Simulink:Engine:InputNotConnected');
    warning(states.c.state,'Simulink:Harness:ExportDeleteHarnessFromSystemModel');
    warning(states.d.state,'Simulink:Engine:MdlFileShadowing');
end

