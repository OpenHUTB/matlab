classdef AppModel<handle




















    properties(Access='public')

Model



DefinitionFileName


SupportedPeripheralInfo
    end

    properties(Access='private')

ModelName
    end

    methods(Access='public')
        function obj=AppModel(hObj,defFile)



            if isa(hObj,'Simulink.ConfigSet')||...
                isa(hObj,'Simulink.ConfigSetRef')
                obj.Model=hObj;
                obj.ModelName=get_param(hObj.getModel(),'Name');
            else

                obj.Model=getActiveConfigSet(hObj);
                obj.ModelName=get_param(hObj,'Name');
            end

            if nargin==2&&exist(defFile,'file')==2
                obj.SupportedPeripheralInfo=codertarget.peripherals.PeripheralInfo(defFile);
                obj.DefinitionFileName=defFile;
            end
        end

        function[info,type]=getPeripheralInfoForBlock(obj,blkH)



            info=[];
            type=[];
            id=obj.getBlockSID(blkH);
            pInfo=obj.getPeripheralInfoForModel(bdroot(id));

            if~isempty(pInfo)
                types=fieldnames(pInfo);
                for i=1:numel(types)
                    idx=find(strcmp({pInfo.(types{i}).Block.ID},id));
                    if~isempty(idx)
                        info=pInfo.(types{i}).Block(idx);
                        type=types{i};
                        break;
                    end
                end
            end
        end

        function info=getPeripheralInfoForModel(obj,modelInfo)




            if nargin==2
                validateattributes(modelInfo,{'char','Simulink.ConfigSet','Simulink.ConfigSetRef'},{});

                if isa(modelInfo,'Simulink.ConfigSet')||...
                    isa(modelInfo,'Simulink.ConfigSetRef')
                    hCS=modelInfo;
                else

                    hCS=getActiveConfigSet(modelInfo);
                end
            else

                hCS=obj.Model;
            end
            info=codertarget.data.getPeripheralInfo(hCS);
        end

        function mdlRefs=getRefModels(obj,throwError)


            if nargin<2
                throwError=false;
            end

            try



                mdlRefs=find_mdlrefs(obj.ModelName,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'ReturnTopModelAsLastElement',false)';
                if isempty(mdlRefs)
                    mdlRefs={obj.ModelName};
                end
            catch exc





                if logical(throwError)
                    throwAsCaller(exc);
                else
                    mdlRefs={obj.ModelName};
                end
            end
        end

        function[mdlRefs,info]=getPeripheralInfoForRefModels(obj)




            info=[];
            mdlRefs=getRefModels(obj,false);

            for i=1:numel(mdlRefs)
                if~bdIsLoaded(mdlRefs{i})
                    load_system(mdlRefs{i});
                end

                if~codertarget.peripherals.AppModel.isProcessorModel(mdlRefs{i});continue;end



                if strcmp(obj.ModelName,mdlRefs{i})
                    mdlRef=obj.Model;
                else
                    mdlRef=mdlRefs{i};
                end
                pInfo=codertarget.data.getPeripheralInfo(mdlRef);
                if~isempty(pInfo)
                    types=fieldnames(pInfo);
                    for j=1:numel(types)
                        if~isfield(info,types{j})
                            info.(types{j})=pInfo.(types{j});
                        else
                            blockInfo=pInfo.(types{j}).Block;
                            for k=1:numel(blockInfo)
                                info.(types{j}).Block(end+1)=blockInfo(k);
                            end
                        end
                    end
                end
            end
        end

        function addDefaultPeripheralInfo(obj,blkH,peripheralType)



            if~codertarget.peripherals.AppModel.isProcessorModel(obj.Model);return;end




            if~isempty(obj.SupportedPeripheralInfo)&&...
                ismember(peripheralType,obj.SupportedPeripheralInfo.getListOfPeripherals())
                block.ID=obj.getBlockSID(blkH);

                info=codertarget.data.getPeripheralInfo(obj.Model);



                if~isfield(info,peripheralType)
                    info.(peripheralType)=struct();
                end


                blockParams=obj.SupportedPeripheralInfo.getBlockParameters(peripheralType);
                for i=1:numel(blockParams)
                    block.(blockParams(i).Storage)=blockParams(i).Value;
                end

                if~isfield(info.(peripheralType),'Block')
                    info.(peripheralType).Block=block;
                else
                    info.(peripheralType).Block(end+1)=block;
                end



                groupParams=obj.SupportedPeripheralInfo.getGroupParameters(peripheralType);
                if~isempty(groupParams)

                    if~isfield(info.(peripheralType),'Group')
                        for i=1:numel(groupParams)
                            group.(groupParams(i).Storage)=groupParams(i).Value;
                        end
                        info.(peripheralType).Group=group;
                    end
                end

                codertarget.data.setPeripheralInfo(obj.Model,info);
            end
        end

        function copyPeripheralInfo(obj,blkH,peripheralType)



            if~codertarget.peripherals.AppModel.isProcessorModel(obj.Model);return;end

            if~isempty(obj.SupportedPeripheralInfo)&&...
                ismember(peripheralType,obj.SupportedPeripheralInfo.getListOfPeripherals())


                sourceBlkID=get_param(blkH,'BlockSID');
                sourceBlkH=get_param(sourceBlkID,'Handle');
                params=obj.getPeripheralInfoForBlock(sourceBlkH);
                paramFieldNames=fieldnames(params);

                for i=1:numel(paramFieldNames)
                    idx=paramFieldNames(i);
                    block.(idx{1})=params.(idx{1});
                end



                block.ID=obj.getBlockSID(blkH);

                info=codertarget.data.getPeripheralInfo(obj.Model);



                if~isfield(info,peripheralType)
                    info.(peripheralType)=struct();
                end


                if~isfield(info.(peripheralType),'Block')
                    info.(peripheralType).Block=block;
                else
                    info.(peripheralType).Block(end+1)=block;
                end


                if~isfield(info.(peripheralType),'Group')

                    groupParams=obj.SupportedPeripheralInfo.getGroupParameters(peripheralType);
                    if~isempty(groupParams)
                        for i=1:numel(groupParams)
                            group.(groupParams(i).Storage)=groupParams(i).Value;
                        end
                        info.(peripheralType).Group=group;
                    end
                end

                codertarget.data.setPeripheralInfo(obj.Model,info);
            end
        end

        function removePeripheralInfoFromModel(obj,blkH,type)



            if~codertarget.peripherals.AppModel.isProcessorModel(obj.Model);return;end

            id=obj.getBlockSID(blkH);
            data=codertarget.data.getPeripheralInfo(obj.Model);

            if~isempty(data)&&isfield(data,type)
                idx=find(strcmp({data.(type).Block.ID},id));
                if~isempty(idx)
                    data.(type).Block(idx)=[];

                    if isempty(data.(type).Block)
                        data=rmfield(data,type);
                    end
                end
                if isempty(fieldnames(data));data=[];end
                codertarget.data.setPeripheralInfo(obj.Model,data);
            end
        end

        function initOnHardwareSelect(obj)




            if~codertarget.peripherals.AppModel.isProcessorModel(obj.Model);return;end

            peripheralTypes=obj.SupportedPeripheralInfo.getListOfPeripherals();

            codertarget.data.setPeripheralInfo(obj.Model,[]);
            for i=1:numel(peripheralTypes)

                peripheralType=peripheralTypes{i};
                maskType=...
                obj.SupportedPeripheralInfo.getMaskTypeForPeripheral(peripheralType);


                blks=find_system(obj.ModelName,'IncludeCommented','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'MaskType',maskType);
                if~isempty(blks)
                    for j=1:numel(blks)
                        obj.addDefaultPeripheralInfo(blks{j},peripheralType);
                    end
                end
            end
        end

        function ret=arePeripheralBlocksInRefModels(obj)



            ret=false;
            mdlRefs=getRefModels(obj,false);

            for i=1:numel(mdlRefs)
                if~bdIsLoaded(mdlRefs{i})
                    load_system(mdlRefs{i});
                end
            end
            peripheralTypes=obj.SupportedPeripheralInfo.getListOfPeripherals();
            for i=1:numel(peripheralTypes)
                peripheralType=peripheralTypes{i};
                maskType=...
                obj.SupportedPeripheralInfo.getMaskTypeForPeripheral(peripheralType);


                blks=find_system(mdlRefs,'IncludeCommented','on',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'MaskType',maskType);
                if~isempty(blks)
                    ret=true;
                    return;
                end
            end
        end

        function out=isPeripheralInfoValid(obj)







            out=true;

            [~,savedInfo]=obj.getPeripheralInfoForRefModels;


            if isempty(savedInfo)
                out=false;
            end

        end

        function updatePeripheralBlockSID(obj,type,blkH)






            if~codertarget.peripherals.AppModel.isProcessorModel(obj.Model);return;end
            peripheralInfo=obj.getPeripheralInfoForModel();

            if~isempty(peripheralInfo)

                idx=endsWith({peripheralInfo.(type).Block.ID},...
                [':',get_param(blkH,'SID')]);
                if any(idx)

                    if~matches(peripheralInfo.(type).Block(idx).ID,Simulink.ID.getSID(blkH))
                        peripheralInfo.(type).Block(idx).ID=Simulink.ID.getSID(blkH);
                        codertarget.data.setPeripheralInfo(obj.Model,peripheralInfo);

                        set_param(blkH,'BlockSID',Simulink.ID.getSID(blkH));
                    end
                end
            end
        end

        function[status,msg]=applyPeripheralMappingInfo(obj,peripheralInfo)



            status=true;
            msg='';
            cachedInfo=peripheralInfo.Model;
            types=fieldnames(cachedInfo);
            models=peripheralInfo.ModelRefs;


            onPeripheralMappingApplyHook=obj.SupportedPeripheralInfo.getOnPeripheralMappingApplyHook();
            if~isempty(onPeripheralMappingApplyHook)


                try
                    [status,msg,outInfo]=feval(onPeripheralMappingApplyHook,cachedInfo);
                    if~isempty(outInfo)
                        cachedInfo=outInfo;
                    end
                catch ex
                    status=false;
                    msg=ex.message;
                end
                if~status,return;end
            end


            for i=1:numel(models)
                if~codertarget.peripherals.AppModel.isProcessorModel(models{i});continue;end
                data=[];

                mdlInfo=codertarget.data.getPeripheralInfo(models{i});

                for j=1:numel(types)

                    idx=find(strcmp(extractBefore({cachedInfo.(types{j}).Block.ID},':'),models{i}));

                    if~isempty(idx)&&isfield(mdlInfo,(types{j}))
                        blockInfoInCache=cachedInfo.(types{j}).Block(idx);




                        blockIndex=matches({blockInfoInCache.ID},{mdlInfo.(types{j}).Block.ID});
                        data.(types{j}).Block=blockInfoInCache(blockIndex);
                        if isfield(cachedInfo.(types{j}),'Group')
                            data.(types{j}).Group=cachedInfo.(types{j}).Group;
                        end
                    end
                end
                codertarget.data.setPeripheralInfo(models{i},data);
            end
        end

        function applyTaskMappingInfo(~,taskInfo)
            codertarget.internal.taskmapper.applyMappingData(...
            taskInfo.ModelName,taskInfo.MappingData,...
            taskInfo.EventNames);
        end
    end

    methods(Static)
        function isProc=isProcessorModel(model)



            isProc=codertarget.target.isCoderTarget(model);
        end
    end

    methods(Access=private)
        function id=getBlockSID(~,blkH)


            id=Simulink.ID.getSID(blkH);
        end
    end
end







