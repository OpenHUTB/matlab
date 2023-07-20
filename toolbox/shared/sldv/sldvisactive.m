function status=sldvisactive(obj)




















    if nargin>=1
        obj=convertStringsToChars(obj);
    end

    if nargin<1
        if isempty(gcb)
            obj=[];
        else
            obj=bdroot(gcb);
        end
    end

    if isempty(obj)
        error(message('Sldv:SldvIsActive:Obj'));
    end

    errStr='';
    if ischar(obj)
        try
            modelH=get_param(obj,'Handle');
        catch Mex
            errStr=Mex.message;
        end
    else
        if ishandle(obj)
            if isa(obj,'Simulink.BlockDiagram')||...
                isa(obj,'Simulink.Block')
                modelH=get(obj,'Handle');
            else
                try
                    modelH=get_param(obj,'Handle');
                catch Mex
                    errStr=Mex.message;
                end
            end
        else
            errStr=getString(message('Sldv:SldvIsActive:Obj'));
        end
    end

    if~isempty(errStr)
        error('Sldv:SldvIsActive:Obj',errStr);
    end

    if bdroot(modelH)~=modelH
        modelH=bdroot(modelH);
    end

    status=get_param(modelH,'RTWExternMdlXlate')==1;

end
