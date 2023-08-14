function outidx=hdlsignalimag(idx,varargin)






    hN=pirNetworkForFilterComp;
    emitMode=isempty(hN);

    if hdlispirbased||~emitMode
        if isscalar(idx)
            if(~isempty(idx)&&hdlsignaliscomplex(idx)&&...
                ~isempty(idx.Imag))
                outidx=idx.Imag;

                hdlsignalsetvtype(outidx,idx.VType);
            else
                outidx=[];
            end
        elseif isvector(idx)
            outidx=[];
            for n=1:length(idx)
                if hdlsignaliscomplex(idx(n))&&~isempty(idx(n).Imag)
                    tempidx=idx(n).Imag;
                    hdlsignalsetvtype(tempidx,idx(n).VType);
                    outidx=[outidx,tempidx];%#ok
                end
            end
        end
    else
        vectsize=1;
        if(nargin>1)
            vectsize=varargin{1};
        end

        lastsig=hdllastsignal;
        if any(idx<1)||any(idx>lastsig)
            error(message('HDLShared:directemit:internalsignalerror'))
        end

        if isscalar(idx)
            outidx=idx+vectsize;
        else
            outidx=[];
            for n=1:length(idx)
                outidx=[outidx,(idx(n)+vectsize)];%#ok
            end
        end
    end
end
