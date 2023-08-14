classdef(Sealed,Hidden)CompileManager<handle












    properties(Constant)
        pInstance=Simulink.variant.reducer.CompileManager;
    end

    properties(Access={?VRedUnitTest})

        TopModel='';


        Models={};


        Blocks={};


        ModelName2ModelBlocksMap=containers.Map('keyType','char','valueType','any');




        VariantBlockActiveChoiceStruct=i_newEmptyVariantBlockInfoStruct();







        ModifiedSpecialGraphicalBlocks(:,1)Simulink.variant.reducer.types.VRedCompiledSpecialBlockInfo;





        InactiveAZVCOffIVBlockToActivePortMap=containers.Map('keyType','char','valueType','any');




        CompiledPortAttributesMap=containers.Map('keyType','char','valueType','any');




        CompiledBusStructPortAttribsMap=containers.Map('keyType','char','valueType','any');


        ValidateSignalsFlag(1,1)logical=true;


        CompileCalledForValidation(1,1)logical=false;



        SLCompEvent(1,1)=Simulink.variant.reducer.EngineCompileEvent.UNKNOWN;

        RefBlocksInfo=[];
    end

    methods(Access=private)
        function obj=CompileManager
        end



        function compile(obj,compileForCodegen)
            if compileForCodegen
                feval(obj.TopModel,[],[],[],'compileForCodegen');
                feval(obj.TopModel,[],[],[],'term');
            else
                set_param(obj.TopModel,'SimulationCommand','update');
            end
        end
    end

    methods(Static)
        function obj=getInstance
            obj=Simulink.variant.reducer.CompileManager.pInstance;
        end

        function callSetBlocks(modelName,blocks)
            Simulink.variant.reducer.CompileManager.pInstance.setSLCompEvent(Simulink.variant.reducer.EngineCompileEvent.PRE_INACTIVE_VARIANT_REMOVAL);
            Simulink.variant.reducer.CompileManager.pInstance.setModels(modelName);
            Simulink.variant.reducer.CompileManager.pInstance.setBlocks(modelName,unique(blocks));
        end

        function callSetActiveVariantBlockInfo(varBlockActiveChoiceStruct)
            Simulink.variant.reducer.CompileManager.pInstance.setVariantBlockActiveChoice(varBlockActiveChoiceStruct);
        end

        function callSetInactiveVariantBlockInfo(varBlockInactiveAZVCInfo)
            Simulink.variant.reducer.CompileManager.pInstance.setInactiveAZVCOffIVBlockToActivePortMap(varBlockInactiveAZVCInfo);
        end


        function callSetCompiledPortInfo()
            Simulink.variant.reducer.CompileManager.pInstance.setCompiledPortAttributeMap('CompiledPortAttributesMap');
        end


        function callSetBusStructPortAttribsMap(blks)
            Simulink.variant.reducer.CompileManager.pInstance.setCompiledPortAttributeMap('CompiledBusStructPortAttribsMap',blks);
        end

        function callSetPostCompileInfo()

            Simulink.variant.reducer.CompileManager.pInstance.setSLCompEvent(Simulink.variant.reducer.EngineCompileEvent.COMP_PASSED_EVENT);
            Simulink.variant.reducer.CompileManager.pInstance.setCompiledPortAttributeMap('CompiledPortAttributesMap');
        end

        function callSetSpecialBlockInfo(modifiedSpecialGraphicalBlocks)
            splBlk=Simulink.variant.reducer.types.VRedCompiledSpecialBlockInfo.empty;

            if isempty(modifiedSpecialGraphicalBlocks)
                Simulink.variant.reducer.CompileManager.pInstance.setModifiedSpecialGraphicalBlocks(splBlk);
                return;
            end

            numOfBlks=length(modifiedSpecialGraphicalBlocks);
            splBlk(numOfBlks,1)=Simulink.variant.reducer.types.VRedCompiledSpecialBlockInfo;
            for idx=1:numOfBlks
                splBlk(idx).BlockPath=modifiedSpecialGraphicalBlocks(idx).BlockPath;
                splBlk(idx).ActiveInputPortNumbers=modifiedSpecialGraphicalBlocks(idx).ActiveInputPortNumbers;
                splBlk(idx).ActiveOutputPortNumbers=modifiedSpecialGraphicalBlocks(idx).ActiveOutputPortNumbers;
                splBlk(idx).Operation=modifiedSpecialGraphicalBlocks(idx).Operation;
                splBlk(idx).ReplacedBlock=modifiedSpecialGraphicalBlocks(idx).ReplacedBlock;
            end

            Simulink.variant.reducer.CompileManager.pInstance.setModifiedSpecialGraphicalBlocks(splBlk);
        end

        function callSetRefBlocksInfo(refBlocksInfo)
            if~isempty(refBlocksInfo)
                Simulink.variant.reducer.CompileManager.pInstance.setRefBlocksInfo(refBlocksInfo);
            end
        end

        function tf=CallIsCompileCalledForValidation()
            tf=Simulink.variant.reducer.CompileManager.pInstance.isCompileCalledForValidation();
        end

        function topModel=CallGetTopModel()
            topModel=Simulink.variant.reducer.CompileManager.pInstance.getTopModel();
        end
    end

    methods
        function setTopModel(obj,val)
            obj.TopModel=val;
            obj.setModels(val);
        end

        function topModel=getTopModel(obj)
            topModel=obj.TopModel;
        end



        function setValidateSignalsFlag(obj,flag)
            obj.ValidateSignalsFlag=flag;
        end

        function setSLCompEvent(obj,flag)
            obj.SLCompEvent=flag;
        end


        function callInitialCompile(obj,compileForCodegen)
            obj.CompileCalledForValidation=false;
            obj.compile(compileForCodegen);
        end


        function callValidationCompile(obj,compileForCodegen)
            obj.CompileCalledForValidation=true;
            obj.compile(compileForCodegen);
        end

        function[models,blocks]=getModelInfo(obj)
            models=obj.Models;
            blocks=obj.Blocks;
        end

        function modelBlocksMap=getModelName2ModelBlocksMap(obj)
            modelBlocksMap=obj.ModelName2ModelBlocksMap;
        end

        function varBlkChoiceInfo=getVariantBlockActiveChoiceStruct(obj)
            varBlkChoiceInfo=obj.VariantBlockActiveChoiceStruct;
        end

        function inactiveAZVCOffIVBlockToActivePortMap=getInactiveAZVCOffIVBlockToActivePortMap(obj)
            inactiveAZVCOffIVBlockToActivePortMap=obj.InactiveAZVCOffIVBlockToActivePortMap;
        end

        function compAttrMap=getCompiledPortAttributeMap(obj)
            compAttrMap=obj.CompiledPortAttributesMap;
        end

        function compAttrMap=getCompiledBusSrcPortAttributeMap(obj)
            compAttrMap=obj.CompiledBusStructPortAttribsMap;
        end

        function modBlockInfo=getSpecialBlockInfo(obj)
            modBlockInfo=obj.ModifiedSpecialGraphicalBlocks;
        end

        function setRefBlocksInfo(obj,refBlocksInfo)
            obj.RefBlocksInfo=refBlocksInfo;
        end

        function refBlocksInfo=getRefBlocksInfo(obj)
            refBlocksInfo=obj.RefBlocksInfo;
        end

        function tf=isCompileCalledForValidation(obj)
            tf=obj.CompileCalledForValidation;
        end

        function clean(obj)
            obj.TopModel='';
            obj.Models={};
            obj.Blocks={};
            obj.ModelName2ModelBlocksMap=containers.Map('keyType','char','valueType','any');
            obj.VariantBlockActiveChoiceStruct=i_newEmptyVariantBlockInfoStruct();
            obj.CompiledPortAttributesMap=containers.Map('keyType','char','valueType','any');
            obj.ModifiedSpecialGraphicalBlocks=Simulink.variant.reducer.types.VRedCompiledSpecialBlockInfo.empty;
            obj.InactiveAZVCOffIVBlockToActivePortMap=containers.Map('keyType','char','valueType','any');
            obj.CompiledBusStructPortAttribsMap=containers.Map('keyType','char','valueType','any');
            obj.ValidateSignalsFlag=true;
            obj.CompileCalledForValidation=false;
            obj.SLCompEvent=Simulink.variant.reducer.EngineCompileEvent.UNKNOWN;
            obj.RefBlocksInfo=[];
        end
    end

    methods(Access=private)

        setVariantBlockActiveChoice(obj,val)


        setCompiledPortAttributeMap(obj,prop,val)

        setModels(obj,val)

        setBlocks(obj,modelName,blocks)

        setSpecialBlockInfo(obj,val)

    end

end





function varBlkStruct=i_newEmptyVariantBlockInfoStruct(createZeroSizeStruct)
    if nargin==0
        createZeroSizeStruct=true;
    end
    varBlkStruct=struct(...
    'VariantBlock','',...
    'CompiledActiveChoice','',...
    'isAZVCActivated',[]);
    if createZeroSizeStruct
        varBlkStruct(end)=[];
    end
end








