function targetCodeGenStatusCheck(p,varargin)




    if nargin>=2
        simulinkFlow=varargin{1};
    else
        simulinkFlow=true;
    end

    hDrv=hdlcurrentdriver;

    targetCodeGenMode=targetcodegen.targetCodeGenerationUtils.isFloatingPointMode();
    if~targetCodeGenMode
        return;
    end
    nfp_mode=targetcodegen.targetCodeGenerationUtils.isNFPMode();
    dbMessageThrown=false;
    for i=1:length(p.Networks)
        n=p.Networks(i);
        offendingComps=n.getTargetCodeGenOffendingCompList;
        switch n.getTargetCodeGenMsgID
        case{0}
            continue;
        case{1}
            if(~iscell(offendingComps))
                offendingComps={offendingComps};
            end
            msg='';
            for j=1:length(offendingComps)
                remain=offendingComps{j};
                assert(~isempty(remain));
                while(~isequal(remain,';'))
                    [offComp,remain]=strtok(remain,'=');%#ok<STTOK>
                    [requiredDelay,remain]=strtok(remain(2:end),';');
                    if(offComp(1)==';')
                        offComp=offComp(2:end);
                    end
                    if nfp_mode
                        msgID='hdlcommon:nativefloatingpoint:TargetCodeGenFailure2';
                    else
                        msgID='hdlcoder:validate:TargetCodeGenFailure2';
                    end
                    errObj=message(msgID,requiredDelay);
                    if simulinkFlow
                        hDrv.addCheck(hDrv.ModelName,'Error',errObj,'block',offComp);
                    else
                        numbersInMessage=extract(offComp,digitsPattern);
                        lineNum=numbersInMessage(length(numbersInMessage)-1);
                        colNum=numbersInMessage(length(numbersInMessage));
                        emlhdlcoder.EmlChecker.CheckRepository.addCgirCheck(errObj,msgID,'Error','',str2double(lineNum),str2double(colNum));
                    end
                    msg=errObj.getString();
                end
                if nfp_mode
                    msgID='hdlcommon:nativefloatingpoint:TargetCodeGenFailure';
                else
                    msgID='hdlcoder:validate:TargetCodeGenFailure';
                end
            end
            dbMessageThrown=true;
        case{2,4}
            if nfp_mode
                msgID='hdlcommon:nativefloatingpoint:TargetCodeGenFailure';
            else
                msgID='hdlcoder:validate:TargetCodeGenFailure';
            end

            error(message(msgID,[n.Name,' ',offendingComps]));
        case{3}
            if nfp_mode
                msgID='hdlcommon:nativefloatingpoint:TargetCodeGenFailure';
            else
                msgID='hdlcoder:validate:TargetCodeGenFailure';
            end
            error(message(msgID,message('hdlcoder:validate:TargetCodeGenFailure4')));
        case{5}
            error(message('hdlcoder:validate:TargetCodeGenFailure5',n.Name));
        end
    end
    if dbMessageThrown




        if simulinkFlow
            hDrv.addCheck(hDrv.ModelName,'Error',message(msgID,msg));
        else
            emlhdlcoder.EmlChecker.CheckRepository.addCgirCheck(message(msgID,msg),msgID,'Error','',0,0);
        end
    end
end
