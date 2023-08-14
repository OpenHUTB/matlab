classdef CustomBoard<eda.board.FPGABoard




    properties
        PinMap;
        IOMap;
    end


    methods


        function this=CustomBoard(Name,Component)
            this.Name=Name;
            this.Component=Component;
            this.PinMap=containers.Map;
            this.IOMap=containers.Map;
        end
        function addPinMap(this,pinName,pinAssign,ioStandard)
            this.PinMap(pinName)=pinAssign;
            if nargin==3
                ioStandard='';
            end
            this.IOMap(pinName)=ioStandard;
        end

        function iostandard=getIOStandard(this,pinName)
            if this.IOMap.isKey(pinName)
                iostandard=this.IOMap(pinName);
            else
                iostandard='';
            end
        end

        function setPIN(this,CompIndex)
            keys=this.PinMap.keys;
            for m=1:numel(keys);
                this.Component(CompIndex).PINOUT.(keys{m})=this.PinMap(keys{m});
            end
        end
    end
end
