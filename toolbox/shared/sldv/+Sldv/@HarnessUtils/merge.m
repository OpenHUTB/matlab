function status=merge(destModelH,modelHs,initCmds,isNew,caller)





    if strcmp(caller,'slvnvmergeharness')
        invalid=~SlCov.CoverageAPI.checkCvLicense();
        if invalid
            error('Sldv:SLVNVMERGEHARNESS',getString(message('Sldv:MAKEHARNESS:DisabledCoverageLic')));
        end
    else
        invalid=builtin('_license_checkout','Simulink_Design_Verifier','quiet');
        if invalid
            error('Sldv:SLVNVMERGEHARNESS',getString(message('Sldv:MAKEHARNESS:DisabledSldvLic')));
        end
    end


    status=true;

    modelNameHarnessGenerated='';
    for idx=1:length(modelHs)
        srcModelH=modelHs(idx);
        anymakeharnessgen=Sldv.HarnessUtils.isSldvGenHarness(srcModelH);
        if anymakeharnessgen
            modelNameHarnessGenerated=...
            Sldv.HarnessUtils.getGeneratedModel(srcModelH);
            break;
        end
    end

    if~anymakeharnessgen
        error(message('Sldv:SldvMergeHarness:IncorrectHarnessModels'));
    end



    [destHarnessObj,errstr]=Sldv.harnesssource.Source.getSource(destModelH);
    if~isempty(errstr)
        if isNew
            save_system(destModelH,get(destModelH,'Filename'));
            open_system(destModelH);
        end
        error('Sldv:SldvMergeHarness:IncorrectSignalBuilder',errstr);
    end

    requireSldvTestCaseParameterValues=hasSldvTestCaseParameterValues([destModelH,modelHs]);
    tcCnt=destHarnessObj.getNumberOfTestcases;

    orgiMdlIdx=find(destModelH==modelHs);
    if isempty(orgiMdlIdx)
        orgiMdlIdx=-1;
        if requireSldvTestCaseParameterValues
            allParams(tcCnt).parameters=[];
        else
            allParams=[];
        end
        maxStopTime='0';
    else
        allParams=getMdlWSParams(destModelH,tcCnt);
        maxStopTime=get_param(destModelH,'StopTime');
    end


    if orgiMdlIdx~=-1&&~has_init_cmds(destModelH)
        grpcnt=destHarnessObj.getNumberOfTestcases;
        append_init_commands(destModelH,grpcnt,initCmds(orgiMdlIdx));

        docStr=get_docblock_str(destModelH);
        if~isempty(docStr)
            docStr=prepend_init_cmd(docStr,initCmds{orgiMdlIdx});
            set_docblock_str(destModelH,docStr);
        end
    end

    for idx=1:length(modelHs)
        srcModelH=modelHs(idx);
        if(srcModelH~=destModelH)&&idx~=orgiMdlIdx
            [srcHarnessObj,errstr]=Sldv.harnesssource.Source.getSource(srcModelH);


            srcStopTime=get_param(srcModelH,'StopTime');
            if str2double(srcStopTime)>str2double(maxStopTime)
                maxStopTime=srcStopTime;
            end
            if~isempty(errstr)
                status=false;%#ok<NASGU>
                error('Sldv:SldvMergeHarness:IncorrectSignalBuilder',errstr);
            else
                [errstr,destStartGrpCnt,srcGrpCnt]=merge(srcHarnessObj,destHarnessObj);
                if requireSldvTestCaseParameterValues
                    thisMdlParams=getMdlWSParams(srcModelH,srcGrpCnt);
                    allParams=[allParams,thisMdlParams];
                end

                if~isempty(errstr)
                    status=false;%#ok<NASGU>
                    error('Sldv:SldvMergeHarness:Merging',errstr);
                else
                    append_init_commands(destModelH,srcGrpCnt,initCmds(idx));


                    srcDocStr=get_docblock_str(srcModelH);
                    if~isempty(srcDocStr)
                        srcDocStr=increment_test_case_numbers(srcDocStr,destStartGrpCnt);
                        srcDocStr=prepend_init_cmd(srcDocStr,initCmds{idx});
                        destDocStr=get_docblock_str(destModelH);
                        set_docblock_str(destModelH,[destDocStr,newline,srcDocStr]);
                    end
                end
            end
        end
    end

    set_param(destModelH,'StopTime',maxStopTime);

    if requireSldvTestCaseParameterValues
        setMdlWSParams(destModelH,allParams);
        append_parameter_initialization(destModelH);
    end

    addTestUnitParameter(destModelH,modelNameHarnessGenerated);
    harnessFilePath=get(destModelH,'Filename');
    save_system(destModelH,harnessFilePath);

    currentPostLoadFcn=get_param(destModelH,'PostLoadFcn');





    if Sldv.HarnessUtils.isMultiSimDesignStudyExist(destModelH)||...
        contains(currentPostLoadFcn,'Sldv.HarnessUtils.openMultiSimulationDesignStudy;')
        open_system(destModelH);
        Sldv.HarnessUtils.setupMultiSimDesignStudy(harnessFilePath,destHarnessObj);
    end
end

function addTestUnitParameter(modelH,modelNameHarnessGenerated)
    try
        get_param(modelH,'SldvGeneratedHarnessModel');
    catch Mex %#ok<NASGU>
        add_param(modelH,'SldvGeneratedHarnessModel','');
    end
    param1Name='TestUnitModel';
    param1Value=modelNameHarnessGenerated;
    modelParam=sprintf('%s=%s|',param1Name,param1Value);
    set_param(modelH,'SldvGeneratedHarnessModel',modelParam);
end

function docBlkH=get_docblock(modelH)
    docBlkH=find_system(modelH,...
    'SearchDepth',1,...
    'LoadFullyIfNeeded','off',...
    'FollowLinks','off',...
    'LookUnderMasks','all',...
    'BlockType','SubSystem',...
    'MaskType','DocBlock');
end

function docStr=get_docblock_str(modelH)
    docStr='';
    docBlkH=get_docblock(modelH);

    if~isempty(docBlkH)
        docInfo=get_param(docBlkH,'UserData');
        if isstruct(docInfo)
            docStr=docInfo.content;
        else
            docStr=docInfo;
        end
    end
end

function set_docblock_str(modelH,docStr)
    docBlkH=get_docblock(modelH);
    if~isempty(docBlkH)
        set_param(docBlkH,'UserData',docStr);
    end
end

function docStr=prepend_init_cmd(str,initCmdStr)
    tail=sprintf(' ==\n\n%s',str);
    docStr=['\n==',getString(message('Sldv:HarnessUtils:MakeSystemTestHarness:UsingInitCmd',initCmdStr)),tail];
end

function out=has_init_cmds(modelH)
    out=false;
    initFcnStr=get_param(modelH,'InitFcn');

    if isempty(initFcnStr)
        out=contains(initFcnStr,'sldvharnessinit(');
    end
end


function out=escape_command_string(in)
    out=strrep(in,'''','''''');
    out=strrep(out,newline,' ');
end

function append_init_commands(modelH,cnts,cmds)
    initFcnStr=get_param(modelH,'InitFcn');

    if isempty(initFcnStr)
        initFcnStr='sldvharnessinit(';
    else
        insertIdx=find_insert_point(initFcnStr);
        if isempty(insertIdx)
            initFcnStr=[initFcnStr,';  sldvharnessinit('];
        else
            initFcnStr=[initFcnStr(1:(insertIdx-1)),','];
        end
    end

    for idx=1:length(cnts)
        initFcnStr=[initFcnStr,num2str(cnts(idx)),', '];
        initFcnStr=[initFcnStr,'''',escape_command_string(cmds{idx}),''''];
        if idx<length(cnts)
            initFcnStr=[initFcnStr,', '];
        end
        initFcnStr=[initFcnStr,'); '];
    end
    set_param(modelH,'InitFcn',initFcnStr);
end

function append_parameter_initialization(modelH)

    initFcnStr=get_param(modelH,'InitFcn');

    if~contains(initFcnStr,'sldvshareprivate(''parameters'',''init''')
        initFcnStr=[initFcnStr,newline,'sldvshareprivate(''parameters'',''init'',[],0);'];
        set_param(modelH,'InitFcn',initFcnStr);
    end
end

function p=getMdlWSParams(modelH,tcCnt)
    hws=get_param(modelH,'modelworkspace');

    try
        p=hws.evalin('SldvTestCaseParameterValues');
    catch Mex %#ok<NASGU>
        p(tcCnt).parameters=[];
    end
end

function setMdlWSParams(modelH,p)
    hws=get_param(modelH,'modelworkspace');
    hws.assignin('SldvTestCaseParameterValues',p);
end

function out=hasSldvTestCaseParameterValues(modelH)
    out=false;
    for idx=1:length(modelH)
        hws=get_param(modelH(idx),'modelworkspace');
        if hws.hasVariable('SldvTestCaseParameterValues')
            out=true;
        end
    end
end


function out=increment_test_case_numbers(str,inc)
    tstCaseStr=getString(message('Sldv:HarnessUtils:MakeSystemTestHarness:TestCase_1'));
    tstCaseStr=[tstCaseStr,' '];

    eol=newline;
    str=[eol,str];
    idcs=strfind(str,[eol,tstCaseStr]);

    if isempty(idcs)
        out=str;
        return;
    end

    numIdx=idcs+length([eol,tstCaseStr]);

    cnt=length(numIdx);
    nums=zeros(1,cnt);
    for idx=1:cnt
        nums(idx)=str2double(strtok(str((numIdx(idx)):end),' '));
    end

    out=str(2:(numIdx(1)-1));

    for idx=1:cnt
        newNum=nums(idx)+inc;
        numStr=num2str(newNum);
        digitCnt=ceil(log10(nums(idx)+1));
        out=[out,numStr];

        if idx==cnt
            out=[out,str((numIdx(idx)+digitCnt):end)];%#ok<*AGROW>
        else
            out=[out,str((numIdx(idx)+digitCnt):(numIdx(idx+1)-1))];
        end
    end
end


function out=find_insert_point(s)

    out=[];

    startParseStr='sldvharnessinit(';
    charOffset=length(startParseStr);
    startpos=strfind(s,startParseStr);

    if isempty(startpos)
        return;
    end

    idx=startpos(1)+charOffset-2;
    c=consume_char();

    if isempty(c)
        out=length(s);
    else
        out=idx-1;
    end


    function c=consume_char()
        idx=idx+1;
        if idx>length(s)
            c='';
            return;
        end

        switch(s(idx))
        case '('
            c=consume_paren();
        case '{'
            c=consume_curly_brace();
        case '['
            c=consume_brace();
        case ''''
            if any(s(idx-1)==sprintf('\n\t, ''{(['))
                c=consume_single_quote();
            else
                c=consume_char();
            end
        otherwise
            c=s(idx);
        end
    end


    function c=consume_paren()
        stop=false;
        while(~stop)
            c=consume_char();
            if isempty(c)
                return;
            end
            stop=(c==')');
        end
        idx=idx+1;
        c=s(idx);
    end

    function c=consume_curly_brace()
        stop=false;
        while(~stop)
            c=consume_char();
            if isempty(c)
                return;
            end
            stop=(c=='}');
        end
        idx=idx+1;
        c=s(idx);
    end

    function c=consume_brace()
        stop=false;
        while(~stop)
            c=consume_char();
            if isempty(c)
                return;
            end
            stop=(c==']');
        end
        idx=idx+1;
        c=s(idx);
    end

    function c=consume_single_quote()
        idx=idx+1;
        while(s(idx)~='''')
            idx=idx+1;
        end
        c=consume_char();
    end
end


