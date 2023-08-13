classdef ScenesMapping

    properties(Constant=true)
        SuburbanScene=struct('MapName','Suburban scene','PakFile','pakchunk66-WindowsNoEditor.pak');
        LargeParkingLot=struct('MapName','Large parking lot','PakFile','pakchunk7-WindowsNoEditor.pak');
        HwStrght=struct('MapName','Straight road','PakFile','pakchunk6-WindowsNoEditor.pak');
        HwCurve=struct('MapName','Curved road','PakFile','pakchunk5-WindowsNoEditor.pak');
        SimpleLot=struct('MapName','Parking lot','PakFile','pakchunk8-WindowsNoEditor.pak');
        DblLnChng=struct('MapName','Double lane change','PakFile','pakchunk3-WindowsNoEditor.pak');
        BlackLake=struct('MapName','Open surface','PakFile','pakchunk2-WindowsNoEditor.pak');
        USCityBlock=struct('MapName','US city block','PakFile','pakchunk9-WindowsNoEditor.pak');
        USHighway=struct('MapName','US highway','PakFile','pakchunk10-WindowsNoEditor.pak');
        EmptyScene=struct('MapName','Empty scene','PakFile','pakchunk55-WindowsNoEditor.pak');
    end
    methods(Static=true,Hidden=true)
        function pakFile=getPakFile(map)
            mapList=sim3d.utils.internal.ScenesMapping.getMapList;
            mapIndex=find(strcmp(mapList,map),1);
            pakList=sim3d.utils.internal.ScenesMapping.getPakList;
            pakFile=pakList(mapIndex);
        end
        function mapName=getMapName(pakFile)
            pakList=sim3d.utils.internal.ScenesMapping.getPakList;
            pakIndex=find(strcmp(pakList,pakFile),1);
            mapList=sim3d.utils.internal.ScenesMapping.getMapList;
            mapName=mapList(pakIndex);
        end
        function mapList=getMapList
            props=properties(sim3d.utils.internal.ScenesMapping);
            mapList=[];
            for i=1:length(props)
                mapList=[mapList;string(sim3d.utils.internal.ScenesMapping.(props{i}).MapName)];
            end
        end
        function pakList=getPakList
            props=properties(sim3d.utils.internal.ScenesMapping);
            pakList=[];
            for i=1:length(props)
                pakList=[pakList;string(sim3d.utils.internal.ScenesMapping.(props{i}).PakFile)];
            end
        end
    end
end

