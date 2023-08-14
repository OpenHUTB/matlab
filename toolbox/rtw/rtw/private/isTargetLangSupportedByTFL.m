function[ret,langConstraintStr]=isTargetLangSupportedByTFL(tfl,targetLang,isMatlabCoder)





    ret=true;
    langConstraintStr='';
    if(isempty(tfl))
        return;
    end

    if~iscell(targetLang)
        targetLang={targetLang};
    end

    if ischar(tfl)
        libNames=coder.internal.getCrlLibraries(tfl);
        n=length(libNames);
        for i=1:n
            [ret,langConstraintStr]=loc_isTargetLangSupportedBy(libNames{i},targetLang,isMatlabCoder);
            if~ret
                return;
            end
        end
    else
        [ret,langConstraintStr]=loc_isTargetLangSupportedBy(tfl,targetLang,isMatlabCoder);
    end





    function[ret,langConstraintStr]=loc_isTargetLangSupportedBy(tfl,targetLang,isMatlabCoder)
        ret=true;
        langConstraintStr='';

        langConstraint=locGetLangConstraint(tfl,isMatlabCoder);
        if isempty(langConstraint)
            return;
        end

        langConstraintStr=strjoin(langConstraint(:)',',');

        if~iscell(targetLang)
            targetLang={targetLang};
        end

        compres=intersect(langConstraint,targetLang);

        if isempty(compres)
            ret=false;
        end


        function langConstraint=locGetLangConstraint(tfl,isMatlabCoder)



            langConstraint={};
            if(isempty(tfl))
                return;
            end

            tr=RTW.TargetRegistry.get;

            if ischar(tfl)
                tflReg=coder.internal.getTfl(tr,tfl);
                if isempty(tflReg)
                    return;
                end
            else
                tflReg=tfl;
            end

            while(isempty(langConstraint)&&~isempty(tflReg))
                langConstraint=tflReg.LanguageConstraint;
                tflReg=coder.internal.getTfl(tr,tflReg.BaseTfl);
            end





