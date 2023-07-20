classdef VRedRefBlocksInfo<handle




    methods
        function obj=VRedRefBlocksInfo()
            obj.init();
        end
        function delete(obj)
            obj.init();
        end
        function obj=appendFromStruct(obj,refBlkInfo)
            for idx=1:numel(refBlkInfo)
                singleRefBlkInfo=Simulink.variant.reducer.types.VRedRefBlockInfo;
                singleRefBlkInfo.assignFromStruct(refBlkInfo(idx));
                appendBDToMdlRefsData(obj,singleRefBlkInfo);
                obj.RefBlkToRefBlkInfo(singleRefBlkInfo.BlockInstance)=singleRefBlkInfo;
            end
            obj.initSubDatabase();
        end
        function print(obj)
            refBlkInfos=obj.RefBlkToRefBlkInfo.values;
            fprintf('\n');
            data=['Number of RefBlocksInfo:',num2str(numel(refBlkInfos))];
            disp(data);
            for idx=1:numel(refBlkInfos)
                currRefBlockInfo=refBlkInfos{idx};
                currRefBlockInfo.print();
            end
            fprintf('\n');
        end
        function tf=isBlockInsideSubsystemReference(obj,blk)
            if~isKey(obj.RefBlkToRefBlkInfo,blk)
                tf=false;
                return;
            end
            blkInfo=obj.RefBlkToRefBlkInfo(blk);
            tf=(blkInfo.ParentBDType==Simulink.variant.reducer.enums.BDType.SUBSYSTEM_REFERENCE);
        end
        function blkInfo=getSRInsideModel(obj)
            blkInfo=obj.SRBlksInsideModel.values;
        end
        function blkInfo=getSRInsideLibrary(obj)
            blkInfo=obj.SRBlksInsideLibrary.values;
        end
        function blkInfo=getSRInsideSR(obj)
            blkInfo=obj.SRBlksInsideSR.values;
        end
        function blkInfo=getModelInsideSR(obj)
            blkInfo=obj.ModelBlksInsideSR.values;
        end
        function blkInfo=getLibraryInsideSR(obj)
            blkInfo=obj.LibraryBlksInsideSR.values;
        end
        function blkInfo=getAllRefBlks(obj)
            blkInfo=obj.RefBlkToRefBlkInfo.values;
        end
        function refBlkInfo=getLevelOrderedSRBlksInsideLibrary(obj,direction)
            refBlkInfo=obj.getLevelOrderedRefBlks(obj.SRBlksInsideLibrary.values,direction);
        end
        function tf=isSubsystemReferenceBlock(obj,blk)
            if~isKey(obj.RefBlkToRefBlkInfo,blk)
                tf=false;
                return;
            end
            blkInfo=obj.RefBlkToRefBlkInfo(blk);
            tf=(blkInfo.RefersToBDType==Simulink.variant.reducer.enums.BDType.SUBSYSTEM_REFERENCE);
        end
        function SRFileToBlks=getSRFileToBlockMap(obj)
            SRFileToBlks=obj.SRFileToBlocks;
        end
        function tf=isBlockExistInRefBlocksDB(obj,blk)
            tf=isKey(obj.RefBlkToRefBlkInfo,blk);
        end
        function activeMdlRefs=getActiveMdlRefs(obj)
            activeMdlRefs=obj.ActiveMdlRefs;
        end
        function bdToMdlRefsData=getBDToMdlRefsData(obj)
            bdToMdlRefsData=obj.BDToMdlRefsData;
        end
        function clearBDToMdlRefsData(obj)
            obj.BDToMdlRefsData=containers.Map('keyType','char','valueType','any');
        end
    end
    methods(Access=private)
        function init(obj)
            obj.RefBlkToRefBlkInfo=containers.Map('keyType','char','valueType','any');
            obj.SRBlksInsideModel=containers.Map('keyType','char','valueType','any');
            obj.SRBlksInsideLibrary=containers.Map('keyType','char','valueType','any');
            obj.SRBlksInsideSR=containers.Map('keyType','char','valueType','any');
            obj.ModelBlksInsideSR=containers.Map('keyType','char','valueType','any');
            obj.LibraryBlksInsideSR=containers.Map('keyType','char','valueType','any');
            obj.SRFileToBlocks=containers.Map('keyType','char','valueType','any');
            obj.ActiveMdlRefs={};
            obj.BDToMdlRefsData=containers.Map('keyType','char','valueType','any');
        end
        function initSubDatabase(obj)
            refBlkInfos=obj.RefBlkToRefBlkInfo.values;
            for idx=1:numel(refBlkInfos)
                blkInfo=refBlkInfos{idx};
                if obj.isSubsystemReferenceBlock(blkInfo.BlockInstance)
                    if obj.isBlockInsideModel(blkInfo.BlockInstance)
                        obj.SRBlksInsideModel(blkInfo.BlockInstance)=blkInfo;
                    elseif obj.isBlockInsideLibrary(blkInfo.BlockInstance)
                        obj.SRBlksInsideLibrary(blkInfo.BlockInstance)=blkInfo;
                    elseif obj.isBlockInsideSubsystemReference(blkInfo.BlockInstance)
                        obj.SRBlksInsideSR(blkInfo.BlockInstance)=blkInfo;
                    end
                    obj.insertToSRFileToBlocksMap(blkInfo);
                elseif obj.isModelBlock(blkInfo.BlockInstance)
                    obj.appendToActiveMdlRef(blkInfo);
                    if obj.isBlockInsideSubsystemReference(blkInfo.BlockInstance)
                        obj.ModelBlksInsideSR(blkInfo.BlockInstance)=blkInfo;
                    end
                elseif obj.isLibraryBlock(blkInfo.BlockInstance)
                    if obj.isBlockInsideSubsystemReference(blkInfo.BlockInstance)
                        obj.LibraryBlksInsideSR(blkInfo.BlockInstance)=blkInfo;
                    end
                end
            end
        end
        function appendBDToMdlRefsData(obj,blkInfo)

            blkType=get_param(blkInfo.BlockInstance,'BlockType');
            if~isequal(blkType,'ModelReference')


                return;
            end
            currMdlRefData.RootPathPrefix=blkInfo.BlockInstance;



            mdlFile=get_param(blkInfo.BlockInstance,'ModelFile');
            [~,currMdlRefData.ModelName,~]=fileparts(mdlFile);
            [currMdlRefData.IsProtected,~]=Simulink.variant.utils.getIsProtectedModelAndFullFile(mdlFile);

            if isKey(obj.BDToMdlRefsData,blkInfo.BDName)
                prevMdlRefData=obj.BDToMdlRefsData(blkInfo.BDName);
                if~contains({prevMdlRefData.RootPathPrefix},currMdlRefData.RootPathPrefix)
                    obj.BDToMdlRefsData(blkInfo.BDName)=[prevMdlRefData,currMdlRefData];
                end
            else
                obj.BDToMdlRefsData(blkInfo.BDName)=currMdlRefData;
            end
        end
        function appendToActiveMdlRef(obj,blkInfo)
            obj.ActiveMdlRefs{end+1}=blkInfo.RefersTo;
        end
        function insertToSRFileToBlocksMap(obj,blkInfo)
            SRFile=blkInfo.RefersTo;
            if isKey(obj.SRFileToBlocks,SRFile)
                currBlkInfo=obj.SRFileToBlocks(SRFile);
                currBlkInfo{end+1}=blkInfo;
                obj.SRFileToBlocks(SRFile)=currBlkInfo;
            else
                obj.SRFileToBlocks(SRFile)={blkInfo};
            end
        end
        function tf=isLibraryBlock(obj,blk)
            blkInfo=obj.RefBlkToRefBlkInfo(blk);
            tf=(blkInfo.RefersToBDType==Simulink.variant.reducer.enums.BDType.LIBRARY);
        end
        function tf=isModelBlock(obj,blk)
            blkInfo=obj.RefBlkToRefBlkInfo(blk);
            tf=(blkInfo.RefersToBDType==Simulink.variant.reducer.enums.BDType.MODEL);
        end
        function tf=isBlockInsideModel(obj,blk)
            blkInfo=obj.RefBlkToRefBlkInfo(blk);
            tf=(blkInfo.ParentBDType==Simulink.variant.reducer.enums.BDType.MODEL);
        end
        function tf=isBlockInsideLibrary(obj,blk)
            blkInfo=obj.RefBlkToRefBlkInfo(blk);
            tf=(blkInfo.ParentBDType==Simulink.variant.reducer.enums.BDType.LIBRARY);
        end
    end
    methods(Static,Access=private)
        function lvlOrderedAllRefBlks=getLevelOrderedRefBlks(allRefBlks,direction)





            lvlOrderedAllRefBlks=[];
            if isempty(allRefBlks)
                return;
            end
            allRefBlksArray=[allRefBlks{:}];
            levelsArray=[allRefBlksArray.Level];
            [~,sortedIdx]=sort(levelsArray,direction);
            lvlOrderedAllRefBlks=allRefBlksArray(sortedIdx);
        end
    end
    properties(Access=private)

        RefBlkToRefBlkInfo=containers.Map('keyType','char','valueType','any');


        SRBlksInsideModel=containers.Map('keyType','char','valueType','any');


        SRBlksInsideLibrary=containers.Map('keyType','char','valueType','any');


        SRBlksInsideSR=containers.Map('keyType','char','valueType','any');


        ModelBlksInsideSR=containers.Map('keyType','char','valueType','any');


        LibraryBlksInsideSR=containers.Map('keyType','char','valueType','any');


        SRFileToBlocks=containers.Map('keyType','char','valueType','any');

        ActiveMdlRefs={};

        BDToMdlRefsData;
    end
end
