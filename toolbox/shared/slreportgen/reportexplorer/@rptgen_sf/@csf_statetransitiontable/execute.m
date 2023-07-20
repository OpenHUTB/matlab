function out=execute(this,d,varargin)






    out=d.createDocumentFragment();




    if(~isempty(this.RunTimeSTTUtils))
        for STTUtilMan=this.RunTimeSTTUtils(:)'




            out.appendChild(STTUtilMan.generateDocBook(d,this));
        end
        this.RunTimeSTTUtils=[];
    else
        [sttHandles,indxToLinkPath]=rptgen_sf.csf_statetransitiontable.findSTTs;
        for i=1:length(sttHandles)
            STT=sttHandles(i);
            STTUtilMan=Stateflow.STTUtils.STTUtilMan.getManager(STT);
            if(STTUtilMan.isValid())
                if isKey(indxToLinkPath,i)

                    linkPath=indxToLinkPath(i);
                else
                    linkPath='';
                end
                out.appendChild(STTUtilMan.generateDocBook(d,this,linkPath));
            end
        end

    end