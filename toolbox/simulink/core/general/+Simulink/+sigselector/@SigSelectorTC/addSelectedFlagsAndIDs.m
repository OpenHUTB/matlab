function outsigs=addSelectedFlagsAndIDs(~,insigs)










    outsigs=insigs;
    id=1;


    filename_buselement=Simulink.sigselector.getSigSelectorResourceFile('buselement.gif');
    filename_bus=Simulink.sigselector.getSigSelectorResourceFile('bus.gif');

    for ct=1:numel(outsigs)

        if isa(outsigs{ct},'Simulink.sigselector.SignalItem')

            outsigs{ct}.TreeID=id;id=id+1;
        elseif isa(outsigs{ct},'Simulink.sigselector.BusItem')


            hier=outsigs{ct}.Hierarchy;
            for ctc=1:numel(hier)
                uphier(ctc).SignalName=hier(ctc).SignalName;
                uphier(ctc).BusObject=hier(ctc).BusObject;

                if~isfield(hier(ctc),'Selected')
                    uphier(ctc).Selected=false;
                else
                    uphier(ctc).Selected=hier(ctc).Selected;
                end

                uphier(ctc).TreeID=id;id=id+1;

                if~isfield(hier(ctc),'Icon')
                    if isempty(hier(ctc).Children)
                        uphier(ctc).Icon=filename_buselement;
                    else
                        uphier(ctc).Icon=filename_bus;
                    end
                else
                    uphier(ctc).Icon=hier(ctc).Icon;
                end

                [uphier(ctc).Children,id]=LocalBus(hier(ctc).Children,id,...
                filename_buselement,filename_bus);
            end

            outsigs{ct}.Hierarchy=uphier;
        else

            DAStudio.error('Simulink:sigselector:TCInvalidSignals');
        end
    end
    function[out,id]=LocalBus(input,id,filename_buselement,filename_bus)
        out=[];
        for ct=1:numel(input)
            out(ct).SignalName=input(ct).SignalName;
            out(ct).BusObject=input(ct).BusObject;

            if isfield(input(ct),'Selected')
                out(ct).Selected=input(ct).Selected;
            else
                out(ct).Selected=false;
            end

            out(ct).TreeID=id;id=id+1;

            if isfield(input(ct),'Icon')
                out(ct).Icon=input(ct).Icon;
            else
                if isempty(input(ct).Children)
                    out(ct).Icon=filename_buselement;
                else
                    out(ct).Icon=filename_bus;
                end
            end
            if isempty(input(ct).Children)
                out(ct).Children=[];
            else
                [out(ct).Children,id]=LocalBus(input(ct).Children,id,...
                filename_buselement,filename_bus);
            end
        end


