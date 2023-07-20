function bHasLogging=getHasLoggingSettingsHereOrBelow(h,bViewMasks,bViewLinks)










    if strcmp(h.cachedHasSignals,'unknown')

        h.cachedHasSignals='no';


        if isa(h,'SigLogSelector.MdlRefNode')||...
            isa(h,'SigLogSelector.SFChartNode')
            h.cachedHasSignals='yes';


        elseif locSystemContainsLoggedSignals(h.daobject)
            h.cachedHasSignals='yes';


        elseif~isempty(h.childNodes)
            numChildren=h.childNodes.getCount();
            for chIdx=1:numChildren
                child=h.childNodes.getDataByIndex(chIdx);
                if child.getNodeIsVisible(bViewMasks,bViewLinks,false)
                    h.cachedHasSignals='yes';
                    break;
                end
            end
        end

    end

    bHasLogging=strcmp(h.cachedHasSignals,'yes');

end


function bHasLogging=locSystemContainsLoggedSignals(hSys)



    bHasLogging=false;


    objs=hSys.find(...
    '-depth',1,...
    '-isa','Simulink.ModelReference',...
    '-or','-isa','Stateflow.Chart',...
    '-or','-isa','Stateflow.LinkChart',...
    '-or','-isa','Stateflow.TruthTableChart',...
    '-or','-isa','Stateflow.StateTransitionTableChart');
    if~isempty(objs)
        bHasLogging=true;
        return;
    end


    objs=hSys.find(...
    '-depth',1,...
    '-class','Simulink.Line',...
    '-and','DataLogging',1);
    if~isempty(objs)
        bHasLogging=true;
        return;
    end

end
