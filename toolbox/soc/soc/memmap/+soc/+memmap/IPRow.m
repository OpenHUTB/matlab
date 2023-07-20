
classdef IPRow<handle
    properties
source
regAttributes
    end

    methods
        function this=IPRow(data)
            this.source=data;

        end
        function label=getDisplayLabel(obj)
            label='objectname';
        end
        function iconFile=getDisplayIcon(~)
            iconFile='toolbox/shared/dastudio/resources/info.png';
        end
        function propValue=getPropValue(obj,propName)
            switch propName
            case soc.memmap.MemUtil.strRegName
                propValue=obj.source.register;
            case soc.memmap.MemUtil.strRegOffset
                propValue=obj.source.offset;
            case soc.memmap.MemUtil.strRegVL
                propValue=obj.source.vectorlength;
            case soc.memmap.MemUtil.strRegType
                propValue=obj.source.type;
            otherwise
                propValue='';
            end
        end

        function isHyperlink=propertyHyperlink(~,propName,clicked)
            isHyperlink=false;
            if strcmp(propName,'<hyperlink-column-name>')
                isHyperlink=true;
            end
            if clicked

            end
        end
        function isValid=isValidProperty(~,propName)
            switch propName
            case soc.memmap.MemUtil.strRegName
                isValid=true;
            case soc.memmap.MemUtil.strRegOffset
                isValid=true;
            case soc.memmap.MemUtil.strRegVL
                isValid=true;
            case soc.memmap.MemUtil.strRegType
                isValid=true;
            otherwise
                isValid=false;
            end
        end
        function isReadOnly=isReadonlyProperty(this,propName)
            switch propName
            case soc.memmap.MemUtil.strRegName
                isReadOnly=true;
            case soc.memmap.MemUtil.strRegOffset
                if~strcmp(this.source.type,soc.memmap.MemUtil.strRegReserved)
                    isReadOnly=false;
                else
                    isReadOnly=true;
                end
            case soc.memmap.MemUtil.strRegVL
                isReadOnly=true;
            case soc.memmap.MemUtil.strRegType
                isReadOnly=true;
            otherwise
                isReadOnly=false;
            end
        end
        function getPropertyStyle(this,propName,propertyStyle)
            if~strcmp(propName,soc.memmap.MemUtil.strRegOffset)

            end
            if this.source.reserved
                propertyStyle.ForegroundColor=[1,0,0,1];

            end
            if strcmp(propName,soc.memmap.MemUtil.strRegOffset)
                propertyStyle.Tooltip="Offset format should be 0xXXXX";
            end
        end
    end
end