classdef HDLRecurseIntoSubsystem<hdlimplbase.HDLDirectCodeGen





























    properties(SetObservable)

        SuppressValidation=false;
    end


    methods
        function this=HDLRecurseIntoSubsystem
        end

    end

    methods
        function set.SuppressValidation(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','SuppressValidation')
            value=logical(value);
            obj.SuppressValidation=value;
        end

    end

    methods

        function refRate=getReferenceRateForConstantBlocks(this,hN,hC)%#ok<INUSL>



            refRate=Inf;



            if~isempty(hN.PirInputSignals)
                for inSig=1:length(hN.PirInputSignals)
                    rate=hN.PirInputSignals(inSig).SimulinkRate;
                    if(~isinf(rate)&&rate)
                        refRate=rate;
                        return;
                    end
                end
            end

            if~isempty(hN.PirOutputSignals)
                for outSig=1:length(hN.PirOutputSignals)
                    rate=hN.PirOutputSignals(outSig).SimulinkRate;
                    if(~isinf(rate)&&rate)
                        refRate=rate;
                        return;
                    end
                end
            end

            return

        end






        function propagateSuppressValidationForNetworks(impl,hChildNetwork,blockPath)

            if(~impl.SuppressValidation)
                return;
            end


            hChildNetwork.setSuppressValidation(blockPath);


            vComps=hChildNetwork.Components;
            for jitr=1:length(vComps)
                hC=vComps(jitr);
                if~hC.isNetworkInstance()
                    continue;
                end
                hC.ReferenceNetwork.setSuppressValidation(blockPath);
            end

        end









        function updateInfRatesOnConstantComps(impl,hThisNetwork)

            hOrigThisNetwork=hThisNetwork;
            visitedNW={};
            nwQueue={hThisNetwork};
            while(~isempty(nwQueue))

                hThisNetwork=nwQueue{end};
                nwQueue(end)=[];
                visitedNW{end+1}=hThisNetwork;%#ok<*AGROW>

                vComps=hThisNetwork.Components;
                for jitr=1:length(vComps)
                    hC=vComps(jitr);
                    if hC.isNetworkInstance()
                        if~any(visitedNW==hC.ReferenceNetwork)

                            nwQueue={hC.ReferenceNetwork,nwQueue{:}};%#ok<CCAT>
                        end
                        continue;
                    end

                    if~isprop(hC,'BlockTag')||~strcmpi(hC.BlockTag,'built-in/Constant')
                        continue;
                    end


                    if isinf(hC.PirOutputSignal(1).SimulinkRate)||~any(hC.PirOutputSignals(1).SimulinkRate)

                        ref_rate=impl.getReferenceRateForConstantBlocks(hOrigThisNetwork,hC);
                        hC.PirOutputSignal(1).SimulinkRate=ref_rate;
                    end
                end
            end
        end

    end


    methods(Hidden)

        function v=recurseIntoSubSystem(~)
            v=true;
        end













        function validateNetworkPostConstruction(this,hChildNetwork,hNICComp,hdlDriver)%#ok<*INUSD>

        end

    end
end
