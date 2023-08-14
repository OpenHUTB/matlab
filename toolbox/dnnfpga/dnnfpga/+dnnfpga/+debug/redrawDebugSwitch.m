function redrawDebugSwitch(switchSysPathReq,switchSysPos,cc)
















    parentSysPath=fileparts(switchSysPathReq);


    h=add_block('built-in/SubSystem',switchSysPathReq,'MakeNameUnique','on','Position',switchSysPos,'TreatAsAtomicUnit','off');
    subBlockName=get_param(h,'name');
    switchSysPath=[parentSysPath,'/',subBlockName];


    inPortPos=[20,23,50,37];
    FromBlockPos=[20,233,50,247];
    MultiRegPos=[100,223,330,750];
    outPortPos=[430,423,460,445];
    regSpacer=45;


    if~isfield(cc,'isCNN4Debug')||~cc.isCNN4Debug

        error('this function only support beta2 processor now');
    end

    debugParams=cc.DebugParams;


    debugLength=length(debugParams);
    mutliswitchMask=debugLength+1;


    debugTags=cell(1,debugLength);
    debugIDs=cell(1,debugLength);
    for ii=1:debugLength
        debugTags{ii}=debugParams{ii}.debugTag;
        debugIDs{ii}=debugParams{ii}.debugID;
    end


    add_block('built-in/InPort',[switchSysPath,'/in1'],'Position',inPortPos);
    add_block('built-in/OutPort',[switchSysPath,'/Out'],'Position',outPortPos);


    switchBlockPath=[switchSysPath,'/MultiSwitch'];
    add_block('simulink/Signal Routing/Multiport Switch',switchBlockPath,'Position',MultiRegPos);
    set_param(switchBlockPath,'Inputs',num2str(mutliswitchMask),'DataPortOrder','Zero-based contiguous');


    add_line(switchSysPath,'in1/1','MultiSwitch/1','autorouting','on');
    add_line(switchSysPath,'MultiSwitch/1','Out/1','autorouting','on');


    for ii=1:debugLength+1

        offset=[0,ii*regSpacer,0,ii*regSpacer];

        if(ii>debugLength)


            add_block('built-in/InPort',[switchSysPath,'/in2'],'Position',FromBlockPos+offset);
            add_line(switchSysPath,'in2/1',['MultiSwitch/',num2str(ii+1)]);

        else

            add_block('built-in/From',[switchSysPath,'/From',num2str(debugIDs{ii})],'Position',FromBlockPos+offset);
            set_param([switchSysPath,'/From',num2str(debugIDs{ii})],'GotoTag',debugTags{ii});


            add_line(switchSysPath,['From',num2str(debugIDs{ii}),'/1'],['MultiSwitch/',num2str(debugIDs{ii}+2)],'autorouting','on');

        end
    end

end


