classdef TreeArch<hdlimplbase.EmlImplBase



    methods
        function this=TreeArch(block)
            supportedBlocks={'none'};

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);

        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        needDetailedElab=needDetailedElaboration(this,hN,hInSignals,dspMode)
    end


    methods(Hidden)
        compName=getCompName(this,hC,opName)
        hNewC=getTreeArchitecture(this,hN,oldhN,hDTCSignals,hInPorts,hOutPorts,opName,rndMode,satMode,compName,inputNeedDTC,aggType,dspMode,nfpOptions)
        out=needTreeArch(this,hC,hSignalsIn,hSignalsOut)
    end

end

