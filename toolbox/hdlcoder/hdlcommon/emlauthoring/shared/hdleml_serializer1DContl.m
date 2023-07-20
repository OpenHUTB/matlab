%#codegen
function varargout=hdleml_serializer1DContl(ratio,idleCycles,hasValidInSignal,hasStartOutSignal,hasValidOutSignal,varargin)




    coder.allowpcode('plain')%#ok<EMXTR>
    eml_prefer_const(ratio,idleCycles,hasValidInSignal,hasStartOutSignal,hasValidOutSignal);

    if hasValidInSignal
        validIn=varargin{1};
    else
        validIn=true;
    end

    cntLength=ratio+idleCycles;
    F=hdlfimath();
    cnt_bitwidth=ceil(log2(cntLength));
    T_CNT=numerictype(0,cnt_bitwidth,0);

    persistent cnt;
    if isempty(cnt)
        cnt=fi(0,T_CNT,F);
    end

    in_vld=(cnt==0);
    startOut=(in_vld&&validIn);
    validOut=(cnt<ratio)&&validIn;

    varargout{1}=in_vld;

    if hasStartOutSignal
        varargout{2}=startOut;
        if hasValidOutSignal
            varargout{3}=validOut;
        end
    else
        if hasValidOutSignal
            varargout{2}=validOut;
        end
    end

    if cnt==cntLength-1
        cnt=fi(0,T_CNT,F);
    else
        cnt(:)=cnt+fi(1,T_CNT,F);
    end

end

