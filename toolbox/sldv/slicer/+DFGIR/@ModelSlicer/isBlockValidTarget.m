function yesno=isBlockValidTarget(ms,bh)



    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    try
        bt=get(bh,'BlockType');
    catch
        yesno=false;
        return;
    end

    if strcmpi(get_param(bh,'CompiledIsActive'),'off')


        yesno=false;
        return;
    end

    if strcmp(bt,'SubSystem')
        yesno=true;
    elseif strcmp(bt,'ModelReference')&&strcmp(get(bh,'SimulationMode'),...
        'Normal')

        if~isempty(ms.ir)
            yesno=ms.ir.handleToDfgIdx.isKey(bh);
        else


            yesno=true;
        end
        if~yesno



            bObj=get(bh,'Object');
            if isa(bObj,'Simulink.ModelReference')...
                &&~isempty(bObj.PortHandles.Trigger)...
                &&strcmp(get(bObj.PortHandles.Trigger,'CompiledPortDataType'),'fcn_call')
                yesno=true;
            end
        end
    else

        if ms.compiled
            bObj=get_param(bh,'Object');
            if bObj.isSynthesized
                yesno=false;
            else
                if~isempty(ms.ir)
                    if strcmp(bt,'DataStoreMemory')
                        yesno=ms.ir.dsmToDfgVarIdx.isKey(bh);
                    else
                        yesno=ms.ir.handleToDfgIdx.isKey(bh);
                    end
                else

                    o=get(bh,'RuntimeObject');
                    yesno=~isempty(o);
                end
            end
        else
            yesno=~strcmp(get(bh,'Virtual'),'on');
        end
    end


end
