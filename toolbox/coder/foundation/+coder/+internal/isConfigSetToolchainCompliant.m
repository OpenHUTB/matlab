function isCompliant=isConfigSetToolchainCompliant(lConfigSet,tcInfo)






    alwaysToolchainCompliant=i_isAlwaysToolchainInfoCompliant(tcInfo);


    lUseToolchainInfoCompliant=i_isToolchainCompliant(lConfigSet,alwaysToolchainCompliant);
    if~lUseToolchainInfoCompliant
        isCompliant=false;
        return;
    end


    lGenerateMakefile=get_param(lConfigSet,'GenerateMakefile');
    lGenerateMakefile=strcmpi(lGenerateMakefile,'on');
    if~lGenerateMakefile
        isCompliant=false;
        return;
    end


    lSTF=get_param(lConfigSet,'SystemTargetFile');
    needDefaultParameterChecks=i_needDefaultParameterChecks(lSTF);


    if needDefaultParameterChecks

        commonChecksPassed=i_runCommonParameterChecks(lConfigSet);

        if alwaysToolchainCompliant
            isCompliant=commonChecksPassed;
        else

            tmfCompatibleToolchainChecksPassed=i_runTMFCompatibleToolchainParameterChecks(lConfigSet);
            isCompliant=commonChecksPassed&&tmfCompatibleToolchainChecksPassed;
        end
    else
        isCompliant=true;
    end






    function out=i_isTornado(cfg)

        osVal=i_getRTWOption(cfg,'TargetOS','BareBoardExample');
        sfVal=i_getRTWOption(cfg,'GenerateErtSFunction',0);
        if strcmp(osVal,'VxWorksExample')&&isequal(sfVal,0)
            out=true;
        else
            out=false;
        end

        function val=i_getRTWOption(cfg,option,default)
            rtwoptions=get_param(cfg.getModel,'rtwoptions');
            str=['-a',option,'='];
            idx=strfind(rtwoptions,str);

            if isempty(idx)
                val=default;
            else
                strLen=length(str);
                startIdx=idx+strLen;
                nextChar=rtwoptions(startIdx);

                if nextChar~='"'
                    val=str2double(nextChar);
                else
                    startIdx=startIdx+1;
                    endIdx=strfind(rtwoptions(startIdx:end),'"');
                    val=rtwoptions(startIdx:startIdx+endIdx(1)-2);
                end
            end



            function runDefaultParameterChecks=i_needDefaultParameterChecks(lSTF)

                fullSTFName=which(lSTF);

                runDefaultParameterChecks=true;

                if~isempty(fullSTFName)




                    if isempty(regexp(fullSTFName,regexptranslate('escape',matlabroot),'once'))



                        runDefaultParameterChecks=false;
                    end
                end


                function checksPassed=i_runCommonParameterChecks(lConfigSet)

                    checksPassed=false;

                    tmfPath=[];
                    MakeCommand=get_param(lConfigSet,'MakeCommand');
                    TemplateMakefile=get_param(lConfigSet,'TemplateMakefile');

                    lSTF=get_param(lConfigSet,'SystemTargetFile');
                    defaultTMF=coder.make.internal.Utils.getDefaultTMF(lSTF);


                    if~any(strcmp(strtrim(MakeCommand),{'make_rtw','make_rtw_target'}))
                        return;
                    end

                    [~,fname,mext]=fileparts(TemplateMakefile);
                    if~isempty(mext)&&strcmpi(mext,'.tmf')
                        return;
                    end

                    if~strcmp(fname,defaultTMF)
                        return;
                    end

                    if(isempty(tmfPath))
                        tmfPath=which(fname);
                    end
                    if iscell(tmfPath)
                        tmfPath=tmfPath{1};
                    end
                    [mpath,~,mext]=fileparts(tmfPath);
                    if isempty(mext)||(~strcmpi(mext,'.m')&&~strcmpi(mext,'.p'))
                        return;
                    end

                    if~contains(mpath,matlabroot)
                        return;
                    end

                    if isequal(TemplateMakefile,'ert_default_tmf')&&i_isTornado(lConfigSet)
                        return
                    end


                    checksPassed=true;





                    function checksPassed=i_runTMFCompatibleToolchainParameterChecks(lConfigSet)

                        lSystemTargetFile=get_param(lConfigSet,'SystemTargetFile');

                        RTWCompilerOptimization=get_param(lConfigSet,'RTWCompilerOptimization');






                        doRTWCompilerOptimizationCheck=~any(strcmp(lSystemTargetFile,{'rsim.tlc','rtwsfcn.tlc'}));


                        if doRTWCompilerOptimizationCheck&&~strcmpi(RTWCompilerOptimization,'off')
                            checksPassed=false;
                        else
                            checksPassed=true;
                        end





                        function compliant=i_isToolchainCompliant(lConfigSet,usingMinGW)

                            lSystemTargetFile=get_param(lConfigSet,'SystemTargetFile');
                            if usingMinGW
                                minGWToolchainCompliantSTFs={'accel.tlc','modelrefsim.tlc','raccel.tlc',...
                                'rsim.tlc','rtwsfcn.tlc'};



                                mingwIgnoreUseToolchainInfoCompliant=any(strcmp(lSystemTargetFile,...
                                minGWToolchainCompliantSTFs));
                                if mingwIgnoreUseToolchainInfoCompliant
                                    compliant=true;
                                    return;
                                end
                            end


                            tmf=get_param(lConfigSet,'TemplateMakefile');
                            if isequal(tmf,'RTW.MSVCBuild')






                                compliant=false;
                            else
                                compliant=strcmp...
                                (get_param(lConfigSet,'UseToolchainInfoCompliant'),'on');
                            end



                            function alwaysToolchainCompliant=i_isAlwaysToolchainInfoCompliant(tcInfo)







                                alwaysToolchainCompliant=~isempty(tcInfo)&&isAttribute(tcInfo,'AlwaysToolchainInfoCompliant');

