%#codegen
function[innerReg_en,innerRegCtrol_en,outBypass_en,tapDelay_en,varargout]=hdleml_deserializer1DContl(ratio,idleCycles,hasStartInSignal,hasValidInSignal,hasValidOutSignal,varargin)


    coder.allowpcode('plain')%#ok<EMXTR>
    eml_prefer_const(ratio,idleCycles,hasStartInSignal,hasValidInSignal,hasValidOutSignal);

    if hasStartInSignal
        startIn=varargin{1};
        if hasValidInSignal
            validIn=varargin{2};
        end
    else
        if hasValidInSignal
            validIn=varargin{1};
        end
    end

    if~hasValidInSignal
        cntLength=ratio+idleCycles;
    else
        cntLength=ratio;
    end

    F=hdlfimath();
    cnt_bitwidth=ceil(log2(cntLength+1));
    T_CNT=numerictype(0,cnt_bitwidth,0);

    persistent cnt;
    if isempty(cnt)
        cnt=fi(0,T_CNT,F);
    end

    cntGlobal_bitwidth=ceil(log2(ratio+idleCycles+1));
    T_CNTGLOBAL=numerictype(0,cntGlobal_bitwidth,0);
    persistent cntGlobal;
    if isempty(cntGlobal)
        cntGlobal=fi(0,T_CNTGLOBAL,F);
    end

    T_CNTINNERREGCTROL=T_CNTGLOBAL;
    persistent cntInnerRegCtrol;
    if isempty(cntInnerRegCtrol)
        cntInnerRegCtrol=fi(ratio+idleCycles,T_CNTINNERREGCTROL,F);
    end

    persistent startsCollect;
    if isempty(startsCollect)
        startsCollect=false;
    end

    if hasStartInSignal
        if startIn
            startsCollect=true;
        end
    end


    if~hasValidInSignal
        if hasStartInSignal
            if startIn||cnt<(ratio-1)
                tapDelay_en=true;
            else
                tapDelay_en=false;
            end
        else
            if cnt<(ratio-1)
                tapDelay_en=true;
            else
                tapDelay_en=false;
            end
        end
    else
        if validIn
            tapDelay_en=true;
        else
            tapDelay_en=false;
        end
    end

    validOut=false;
    innerReg_en=false;
    innerRegCtrol_en=false;

    if hasStartInSignal&&(ratio==1)
        if hasValidInSignal
            if validIn&&startIn
                validOut=true;
                innerReg_en=true;
                innerRegCtrol_en=true;
                cntInnerRegCtrol=cntGlobal;
            end
        else
            if startIn
                validOut=true;
                innerReg_en=true;
                innerRegCtrol_en=true;
                cntInnerRegCtrol=cntGlobal;
            end
        end
    else
        validOutput=false;
        if hasValidInSignal
            if validIn&&cnt==(ratio-1)
                validOutput=true;
            end
        else
            if cnt==(ratio-1)
                validOutput=true;
            end
        end

        if validOutput
            if~hasStartInSignal
                validOut=true;
                innerReg_en=true;
                innerRegCtrol_en=true;
                if hasValidInSignal
                    cntInnerRegCtrol=cntGlobal;
                end
            else
                if startIn
                else
                    validOut=true;
                    innerReg_en=true;
                    innerRegCtrol_en=true;
                    cntInnerRegCtrol=cntGlobal;
                end
            end
        end
    end

    if hasStartInSignal||hasValidInSignal
        if~innerReg_en&&(cntGlobal==cntInnerRegCtrol);
            innerRegCtrol_en=true;
            cntInnerRegCtrol=fi(ratio+idleCycles,T_CNTINNERREGCTROL,F);
        end
    end


    if hasValidOutSignal
        varargout{1}=validOut;
    end


    if~hasValidInSignal&&~hasStartInSignal
        if cnt==(cntLength-1)
            cnt=fi(0,T_CNT,F);
        else
            cnt(:)=cnt+fi(1,T_CNT,F);
        end
    elseif~hasValidInSignal&&hasStartInSignal
        if startIn
            cnt=fi(1,T_CNT,F);
        elseif cnt==cntLength
            cnt=cnt;%#ok<ASGSL> %counter saturate
        elseif startsCollect
            cnt(:)=cnt+fi(1,T_CNT,F);
        end
    elseif hasValidInSignal&&~hasStartInSignal

        if validIn
            if cnt==(ratio-1)
                cnt=fi(0,T_CNT,F);
            else
                cnt(:)=cnt+fi(1,T_CNT,F);
            end
        end
    elseif hasValidInSignal&&hasStartInSignal
        if startIn&&validIn
            cnt=fi(1,T_CNT,F);
        elseif cnt==ratio
            cnt=cnt;%#ok<ASGSL> %counter saturate
        elseif validIn&&startsCollect
            cnt(:)=cnt+fi(1,T_CNT,F);
        end
    end


    if~hasStartInSignal&&~hasValidInSignal&&(idleCycles==0)
        outBypass_en=true;
    else
        if~hasStartInSignal&&~hasValidInSignal
            outBypass_en=(cntGlobal==ratio+idleCycles-1);
        else
            outBypass_en=(cntGlobal==0);
        end

        if cntGlobal==ratio+idleCycles-1
            cntGlobal=fi(0,T_CNTGLOBAL,F);
        else
            cntGlobal(:)=cntGlobal+fi(1,T_CNTGLOBAL,F);
        end
    end
end

