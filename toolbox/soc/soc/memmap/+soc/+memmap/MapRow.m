classdef MapRow<handle




    properties
source
isFixedMemMap
    end
    methods
        function this=MapRow(data,isFixedMemMap)
            this.source=data;
            this.isFixedMemMap=isFixedMemMap;
        end
        function label=getDisplayLabel(obj)
            label='objectname';
        end
        function iconFile=getDisplayIcon(~)
            iconFile='';
        end
        function propValue=getPropValue(obj,propName)
            switch propName
            case soc.memmap.MemUtil.strDevType
                propValue=obj.source.type;
            case soc.memmap.MemUtil.strDevName
                propValue=obj.source.name;
            case soc.memmap.MemUtil.strDevBase
                propValue=obj.source.baseAddr;
            case soc.memmap.MemUtil.strDevRange
                propValue=sprintf('%s %sB',obj.source.range{:});
            otherwise
                propValue='';
            end
        end
        function isHyperlink=propertyHyperlink(obj,propName,clicked)
            isHyperlink=false;
            if strcmp(propName,soc.memmap.MemUtil.strDevName)&&...
                any(strcmp(obj.source.type,{soc.memmap.MemUtil.strDevPSMemory,...
                soc.memmap.MemUtil.strDevPLMemory,soc.memmap.MemUtil.strDevUser,...
                soc.memmap.MemUtil.strDevCustom}))
                isHyperlink=true;
            end
            if clicked



                hilited=find_system(gcs,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BackgroundColor','yellow');
                hilite_system(hilited,'off');
                hilite_system(obj.source.path);
            end
        end
        function isValid=isValidProperty(~,propName)
            switch propName
            case soc.memmap.MemUtil.strDevType
                isValid=true;
            case soc.memmap.MemUtil.strDevName
                isValid=true;
            case soc.memmap.MemUtil.strDevBase
                isValid=true;
            case soc.memmap.MemUtil.strDevRange
                isValid=true;
            otherwise
                isValid=false;
            end
        end
        function isReadOnly=isReadonlyProperty(rowobj,propName)
            switch propName
            case soc.memmap.MemUtil.strDevType
                isReadOnly=true;
            case soc.memmap.MemUtil.strDevName
                isReadOnly=true;
            case soc.memmap.MemUtil.strDevBase
                if strcmp(rowobj.source.name,'VDMA Frame Buffer Read')
                    isReadOnly=true;
                elseif rowobj.isFixedMemMap
                    isReadOnly=true;
                else
                    isReadOnly=false;
                end
            case soc.memmap.MemUtil.strDevRange
                isReadOnly=true;
            otherwise
                isReadOnly=false;
            end
        end
        function getPropertyStyle(this,propName,propertyStyle)
            if~strcmp(propName,soc.memmap.MemUtil.strDevBase)

            end
            if strcmp(propName,soc.memmap.MemUtil.strDevType)
                if strcmp(this.source.type,soc.memmap.MemUtil.strDevUser)
                    propertyStyle.Tooltip="Click to view register info";
                elseif strcmp(this.source.type,soc.memmap.MemUtil.strDevImplicit)
                    propertyStyle.Tooltip="Register info not available";
                end
            end
        end
    end
end
