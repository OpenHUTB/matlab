function yesno=isPortValidTarget(ms,ph)



    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU> 
    try
        bh=get(ph,'ParentHandle');
    catch
        yesno=false;
        return;
    end

    if strcmpi(get_param(bh,'CompiledIsActive'),'off')


        yesno=false;
        return;
    end

    bt=get(bh,'BlockType');

    if strcmp(bt,'ModelReference')&&strcmp(get(bh,'SimulationMode'),...
        'Normal')

        yesno=true;
    else

        if ms.compiled

            o=get(bh,'RuntimeObject');
            yesno=~isempty(o);
        else
            yesno=~strcmp(get(bh,'Virtual'),'on');
        end
    end


end
