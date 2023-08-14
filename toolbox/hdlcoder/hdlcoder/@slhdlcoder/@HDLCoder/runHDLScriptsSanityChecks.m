


function runHDLScriptsSanityChecks(this,modelName)
    function reportCheck(msgData)



        this.addCheck(this.ModelName,'Warning',msgData,'model',modelName)
    end

    function nFmtCheck(paramName,cliName,nfmt)
        paramVal=this.getParameter(paramName);

        if(numel(strfind(paramVal,'%s'))~=nfmt)
            reportCheck(message('hdlcoder:validate:ScriptParamError',cliName,nfmt))
        end
    end


    synthtool=this.getParameter('hdlsynthtool');
    if strcmpi(synthtool,'None')
        return;
    end


    nFmtCheck('hdlcompileinit','HDLCompileInit',1);


    nFmtCheck('hdlsimcmd','HDLSimCmd',2);


    nFmtCheck('hdlsimviewwavecmd','HDLSimViewWaveCmd',1);


    tgtLang=this.getParameter('target_language');
    if(strncmpi('VHDL',tgtLang,length(tgtLang)))
        nFmtCheck('hdlcompilevhdlcmd','HDLCompileVHDLCmd',2);
    else
        nFmtCheck('hdlcompileverilogcmd','HDLCompileVerilogCmd',2);
    end


    if(strcmpi(synthtool,'Libero'))
        nFmtCheck('hdlsynthinit','HDLSynthInit',2);
    else

        nFmtCheck('hdlsynthinit','HDLSynthInit',1);
    end

    return
end
