classdef VRedRefBlockInfo<handle




    methods(Hidden,Access={?Simulink.variant.reducer.types.VRedRefBlocksInfo})
        function obj=VRedRefBlockInfo()
            obj.init();
        end
        function init(obj)
            obj.ParentRefBlock='';
            obj.ParentBDType=Simulink.variant.reducer.enums.BDType.INVALID;
            obj.ReferredFrom='';
            obj.ReferredFromFilePath='';
            obj.BlockInstance='';
            obj.RefersTo='';
            obj.RefersToFilePath='';
            obj.RefersToBDType=Simulink.variant.reducer.enums.BDType.INVALID;
            obj.Level=0;
            obj.BDName='';
        end
        function delete(obj)
            obj.init();
        end
        function assignFromStruct(obj,refBlkInfoStruct)
            obj.ParentRefBlock=obj.getBlockInstanceName(refBlkInfoStruct.ParentRefBlock);
            obj.ParentBDType=refBlkInfoStruct.ParentBDType;
            obj.ReferredFrom=refBlkInfoStruct.ReferredFrom;
            obj.ReferredFromFilePath=refBlkInfoStruct.ReferredFromFilePath;
            obj.BlockInstance=obj.getBlockInstanceName(refBlkInfoStruct.BlockInstance);
            obj.RefersTo=refBlkInfoStruct.RefersTo;
            obj.RefersToFilePath=refBlkInfoStruct.RefersToFilePath;
            obj.RefersToBDType=refBlkInfoStruct.RefersToBDType;
            obj.Level=refBlkInfoStruct.Level;
            obj.BDName=refBlkInfoStruct.BDName;
        end
        function print(obj)
            data=[' ParentRefBlock: ',obj.ParentRefBlock,...
            ' ParentBDType: ',char(obj.ParentBDType),...
            ' ReferredFrom: ',obj.ReferredFrom,...
            ' ReferredFromFilePath: ',obj.ReferredFromFilePath,...
            ' BlockInstance: ',obj.BlockInstance,...
            ' RefersTo: ',obj.RefersTo,...
            ' RefersToFilePath: ',obj.RefersToFilePath,...
            ' RefersToBDType: ',char(obj.RefersToBDType),...
            ' Level: ',char(obj.Level),...
            ' BDName: ',obj.BDName,...
            ];
            disp(data);
        end
    end
    methods(Static)
        function name=getBlockInstanceName(bh)
            if isequal(bh,-1.0)
                name='null';
            else


                name=Simulink.variant.reducer.utils.getBlockPathWithoutNewLines(bh);
            end
        end
    end
    properties
        ParentRefBlock(1,:)char;
        ParentBDType(1,1)Simulink.variant.reducer.enums.BDType;
        ReferredFrom(1,:)char;
        ReferredFromFilePath(1,:)char;
        BlockInstance(1,:)char;
        RefersTo(1,:)char;
        RefersToFilePath(1,:)char;
        RefersToBDType(1,1)Simulink.variant.reducer.enums.BDType;
        Level(1,1)uint32;
        BDName(1,:)char;
    end
end
