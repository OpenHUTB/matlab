
function[baseRateFactor,baseRateScaling]=hdlEmitOversampleMessage(p)





    baseRate=p.getOrigDutBaseRate;
    baseRateScaling=1;

    baseRateFactor=p.getDutBaseRateScalingFactor;

    maxOversampling=hdlgetparameter('maxoversampling');
    if~isempty(maxOversampling)&&...
        maxOversampling>0&&...
        maxOversampling~=inf
        msgobj=message('hdlcoder:makehdl:DeprecateMaxOverSampling');
        warning(msgobj);
        hdlsetparameter('maxoversampling',inf);
    end

    overSample=hdlgetparameter('oversampling');
    if isempty(overSample)
        overSample=1;
    end






    if baseRateFactor>1||overSample>1

        emitWarning=false;
        if baseRateFactor>1

            if(overSample>1)&&((overSample<baseRateFactor)||(mod(overSample,baseRateFactor)~=0))
                emitWarning=true;
            end
        end

        if emitWarning

            msgObj=message('hdlcoder:hdldisp:OversampleIgnored',...
            sprintf('%d',baseRateFactor),sprintf('%g',baseRate),...
            sprintf('%d',overSample));
            hdldisp(msgObj);
        else
            baseRateScaling=max([overSample,baseRateFactor]);
            msgObj=message('hdlcoder:hdldisp:OversampleMessage',...
            sprintf('%d',baseRateScaling),sprintf('%g',baseRate));
            hdldisp(msgObj);
        end
        if p.isMATLABCoderBased
            emlhdlcoder.EmlChecker.CheckRepository.addCgirCheck(msgObj.getString,...
            msgObj.Identifier,'Message','',1,1);
        else
            currentDriver=hdlcurrentdriver;
            currentDriver.addCheck(currentDriver.ModelName,'Message',msgObj);
        end
    end

    currentDriver=hdlcurrentdriver;
    if~isempty(currentDriver)
        currentDriver.cgInfo.baseRate=baseRate;
        currentDriver.cgInfo.baseRateScaling=baseRateScaling;
    end
end
