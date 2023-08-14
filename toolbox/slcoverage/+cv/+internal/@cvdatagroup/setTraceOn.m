function setTraceOn(this,traceOn)




    cvds=getAll(this);
    for idx=1:numel(cvds)
        ccvd=cvds{idx};

        for cidx=1:numel(ccvd)
            ccvd(cidx).traceOn=traceOn;
        end
    end
end
