function applyRebindingRules(this,bRemoveUnused)






    if nargin<2
        bRemoveUnused=false;
    end

    len=this.Count;
    for idx=len:-1:1

        sig=get(this,idx,true);
        origHandle=sig.CachedBlockHandle_;
        origPortIdx=sig.CachedPortIdx_;
        origSubPath=sig.SubPath_;
        origSignalName=sig.SignalName_;
        try
            sig=Simulink.HMI.SignalSpecification.bindSignal(sig);
        catch me %#ok<NASGU>
            continue
        end

        if strcmp(sig.BindingRule_,'not found')
            if bRemoveUnused
                remove(this,idx);
            else
                sigObj=Simulink.HMI.SignalSpecification(sig);
                sigObj.BindingRule_=sig.BindingRule_;
                set(this,idx,sigObj);
            end


        elseif~isequal(sig.CachedBlockHandle_,origHandle)||...
            origPortIdx~=sig.CachedPortIdx_||...
            ~strcmp(sig.SubPath_,origSubPath)||...
            ~strcmp(sig.SignalName_,origSignalName)
            sigObj=Simulink.HMI.SignalSpecification(sig);
            sigObj.CachedBlockHandle_=sig.CachedBlockHandle_;
            sigObj.CachedPortIdx_=sig.CachedPortIdx_;
            sigObj.SubPath_=sig.SubPath_;
            sigObj.SignalName_=sig.SignalName_;
            sigObj.BindingRule_=sig.BindingRule_;
            set(this,idx,sigObj);
        end
    end

    if bRemoveUnused
        locRemoveDuplicates(this);
    end
end


function locRemoveDuplicates(this)


    ports=Simulink.sdi.Map(0,?double);
    idxToRemove=[];


    len=this.Count;
    for idx=1:len
        sig=get(this,idx,true);

        if sig.CachedPortIdx_>0

            if isKey(ports,sig.CachedBlockHandle_)
                portProps=ports.getDataByKey(sig.CachedBlockHandle_);
            else
                try
                    ph=get_param(sig.CachedBlockHandle_,'PortHandles');
                catch me %#ok<NASGU>

                    continue;
                end
                portProps=zeros(size(ph.Outport));
            end


            if sig.CachedPortIdx_<=numel(portProps)&&portProps(sig.CachedPortIdx_)
                idxToRemove(end+1)=idx;%#ok<AGROW>
            else
                portProps(sig.CachedPortIdx_)=1;
                ports.insert(sig.CachedBlockHandle_,portProps);
            end
        end
    end


    len=numel(idxToRemove);
    for idx=len:-1:1
        toRemove=idxToRemove(idx);
        remove(this,toRemove);
    end
end