classdef FPGABoard<dynamicprops&handle




    properties(SetAccess=protected)
        Name;
        Component;
    end
    properties
        WorkflowOptions;
        ConnectionOptions;
        ProgramFPGAOptions;
    end
    methods
        function pin=getPIN(this,CompIndex,PINName)
            if isfield(this.Component(CompIndex).PINOUT,PINName)
                pin=this.Component(CompIndex).PINOUT.(PINName);
            else
                pin='';
            end
        end
        function interface=getInterface(this)
            switch(this.Component.Communication_Channel)
            case 'Altera JTAG'
                interface=eda.internal.boardmanager.AltJTAG;
            case 'Digilent JTAG'
                interface=eda.internal.boardmanager.DigilentJTAG;
            otherwise
                interface=eda.internal.boardmanager.(this.Component.Communication_Channel);
            end
        end
        function setComponent(this,Component)
            this.Component=Component;
        end
    end

    methods(Abstract)
        setPIN(this,CompIndex);
    end
end
