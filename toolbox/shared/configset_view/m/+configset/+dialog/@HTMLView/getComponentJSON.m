function[json,layoutFeatures]=getComponentJSON(obj,cc,pid,lazy)





    [json,layoutFeatures]=obj.getCurrentComponentJSON(cc,pid,lazy);


    subcc=cc.Components;
    n=length(subcc);
    if strcmp(pid,'Simulink.RTWCC')
        cid=pid;
    else
        cid=obj.getCID(cc);
    end
    for i=1:n
        c=subcc(i);
        [subJSON,subLF]=obj.getComponentJSON(c,cid,lazy);
        if~isempty(subJSON)
            json=[json,',',subJSON];%#ok
            layoutFeatures=configset.dialog.HTMLView.mergeStructs(layoutFeatures,subLF);
        end
    end


    cid='Simulink.RTWCC';
    if isa(cc,cid)
        adp=obj.Source;
        tlc=adp.tlcCategory;
        if~isempty(tlc)
            n=length(tlc);
            tlcData=cell(n,1);
            for i=1:n
                tlcOpt=tlc{i};
                if isstruct(tlcOpt)

                    if isempty(tlcOpt.tooltip)
                        tlcOpt.tooltip='';
                    end
                    enable=tlcOpt.enable;
                    if isempty(enable)
                        enable=~cc.isObjectLocked;
                    elseif ischar(enable)
                        if strcmpi(enable,'on')
                            enable=true;
                        elseif strcmp(enable,'off')
                            enable=false;
                        end
                    end
                    tlcOpt.enable=enable;
                    tlcData{i}=tlcOpt;
                else
                    tlcData{i}=obj.getData(tlcOpt);
                end
            end
            s=[];
            s.cid='tlc';
            s.pid=cid;
            s.params=tlcData;
            tgt=cc.getComponent('Target');
            if isa(tgt,'Simulink.STFCustomTargetCC')
                s.forcedBaseTarget=tgt.ForcedBaseTarget;
            else
                s.forcedBaseTarget='off';
            end

            mcs=configset.internal.getConfigSetStaticData;
            mcc=mcs.ComponentMap('Simulink.TargetCC');
            if isempty(mcc.Dependency)
                s.status=0;
            else
                cs=cc.getConfigSet;
                s.status=mcc.Dependency.getStatus(cs,'');
            end
            json=[json,',',jsonencode(s)];
        end
    end
