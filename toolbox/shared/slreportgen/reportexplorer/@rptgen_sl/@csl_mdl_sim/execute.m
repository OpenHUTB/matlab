function out=execute(c,d,varargin)




    out='';

    adSL=rptgen_sl.appdata_sl;
    mdlName=get(adSL,'CurrentModel');

    if isempty(mdlName)
        c.status(getString(message('RptgenSL:rsl_csl_mdl_sim:noModelFound')),2);
        return;
    end
    rptgen_sl.uncompileModel(mdlName);


    if c.useMDLioparam
        outStr='';
    else
        if(isempty(c.timeOut)||...
            isempty(c.statesOut)||...
            isempty(c.matrixOut))
            c.status(getString(message('RptgenSL:rsl_csl_mdl_sim:ioParamEmptyLabel')),2);
            outStr='';
        else
            outStr='SimOut=';
        end
    end


    if c.useMDLtimespan
        try
            tStart=get_param(mdlName,'StartTime');
        catch ME %#ok
            tStart='0';
        end
        try
            tEnd=get_param(mdlName,'StopTime');
        catch ME %#ok
            tEnd='10';
        end
    else
        tStart=c.startTime;
        tEnd=c.endTime;
    end

    if strcmpi(tEnd,'inf')
        tEnd='10';
        c.status(sprintf(getString(message('RptgenSL:rsl_csl_mdl_sim:stopTimeCannotBeInfiniteLabel')),tEnd));
    end

    timeStr=['''StartTime''',',','''',tStart,'''',',','''StopTime''',',','''',tEnd,''''];



    stateString=[];
    outPutString=[];
    timeVectorString=[];

    if~c.useMDLioparam
        stateString=['''SaveState''',','];
        if c.statesOut
            stateString=[stateString,'''on''',',','''StateSaveName''',',','''xout''',','];
        else
            stateString=[stateString,'''off''',','];
        end

        outPutString=['''SaveOutput''',','];
        if c.matrixOut
            outPutString=[outPutString,'''on''',',','''OutputSaveName''',',','''yout''',','];
        else
            outPutString=[outPutString,'''off''',','];
        end

        timeVectorString=['''SaveTime''',','];
        if c.timeOut
            timeVectorString=[timeVectorString,'''on''',',','''TimeSaveName''',',','''tout''',','];
        else
            timeVectorString=[timeVectorString,'''off''',','];
        end
    end

    simParamString=[];

    if~isempty(c.simparam)
        simParamString=['''',c.simParam{1},'''',',','''',c.simParam{2},'''',','];
    end

    postString=');';

    if c.CompileModel


        fid=get_rtw_fid(adSL,mdlName);
        if fid>0

            fclose(fid);
        end
    end


    try
        machineID=rptgen_sf.model2machine(mdlName);
    catch ME %#ok
        machineID=[];
    end

    if~isempty(machineID)
        oldAnimation=machineID.debug.animation.enabled;
        machineID.debug.animation.enabled=0;
    else
        oldAnimation=0;
    end




    evalStr=sprintf('%ssim(''%s'', %s%s%s%s%s%s%s',...
    outStr,...
    mdlName,...
    simParamString,...
    stateString,...
    outPutString,...
    timeVectorString,...
    timeStr,...
    postString);
    c.status(evalStr,6);

    try
        oldState=c.preSimulateAction(mdlName);
    catch ME
        c.status(getString(message('RptgenSL:rsl_csl_mdl_sim:couldNotPrepareModel')),2);
        c.status(ME.message,5);
    end

    if strcmp(c.MessageDisplay,'screen')
        try
            evalin('base',evalStr);
        catch ME
            c.status(getString(message('RptgenSL:rsl_csl_mdl_sim:cannotSimulateLabel',strrep(ME.message,newline,' '))),2);
        end
    else
        evalStr=['evalc(''',strrep(evalStr,'''',''''''),''');'];
        try
            evalResult=evalin('base',evalStr);
            msgLevel=3;
        catch ME
            msgLevel=2;
            evalResult=ME.message;

        end
        if isempty(evalResult)

        elseif strcmp(c.MessageDisplay,'report')


            if rptgen.use_java
                out=com.mathworks.toolbox.rptgencore.docbook.StringImporter.importHonorLineBreaks(java(d),evalResult);
            else
                out=mlreportgen.re.internal.db.StringImporter.importHonorLineBreaks(d.Document,evalResult);
            end
        else

            c.status(evalResult,msgLevel,...
            false);
        end
    end

    try
        c.postSimulateAction(mdlName,oldState);
    catch ME
        c.status(getString(message('RptgenSL:rsl_csl_mdl_sim:couldNotCleanUp')),2);
        c.status(ME.message,5);
    end


    if oldAnimation
        machineID.debug.animation.enabled=oldAnimation;
    end

    if(~isempty(c.statesOut)&&isvarname(c.statesOut)&&~c.UseMdlIOParam)
        evalin('base',[c.statesOut,'=','SimOut.xout;']);
    end

    if(~isempty(c.timeOut)&&isvarname(c.timeOut)&&~c.UseMdlIOParam)
        evalin('base',[c.timeOut,'=','SimOut.tout;']);
    end

    if(~isempty(c.matrixOut)&&isvarname(c.matrixOut)&&~c.UseMdlIOParam)
        evalin('base',[c.matrixOut,'=','SimOut.yout;']);
    end


    function un=LocUniqName()


        basevars=evalin('base','whos');
        basevars={basevars.name};

        un='TEMP_RPTGEN_SIMPARAMS';

        while ismember(un,basevars)
            un=[un,'x'];%#ok
        end
