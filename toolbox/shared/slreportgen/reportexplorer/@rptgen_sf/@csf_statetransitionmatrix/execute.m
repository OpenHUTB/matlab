function out=execute(this,d,varargin)






    out=d.createDocumentFragment();




    if(~isempty(this.RunTimeSTTUtils))
        for STTUtilMan=this.RunTimeSTTUtils(:)'




            out.appendChild(STTUtilMan.generateSTMDocBook(d,this));
        end
        this.RunTimeSTTUtils=[];
    else
        sttHandles=rptgen_sf.csf_statetransitionmatrix.findSTTs;
        for i=1:length(sttHandles)
            STT=sttHandles(i);
            STTUtilMan=Stateflow.STTUtils.STTUtilMan.getManager(STT);
            if(STTUtilMan.isValid())
                out.appendChild(STTUtilMan.generateSTMDocBook(d,this));
            end
        end

    end
