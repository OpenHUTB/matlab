classdef(Sealed)BlockDataStore<handle



    properties(GetAccess=public,SetAccess=immutable)
Fields
    end

    properties(GetAccess=private,SetAccess=immutable)
dataMap
listeners
    end

    properties(Access=private)
remappableBlock
remappableData
    end

    methods
        function this=BlockDataStore(varargin)
            assert(nargin>0,'A BlockDataStore must have at least one data field');
            this.Fields=cell(numel(varargin),1);

            for i=1:numel(varargin)
                fieldName=varargin{i};
                assert(isvarname(fieldName),'Not a valid field name: %s',fieldName);
                this.Fields{i}=fieldName;
            end

            this.dataMap=coder.internal.mlfb.createBlockMap();
            this.listeners=coder.internal.mlfb.createBlockMap();
            this.remappableBlock=[];
            this.remappableData=[];
        end

        function blockData=getBlockData(this,blockId,varargin)
            sid=coder.internal.mlfb.gui.BlockDataStore.normalize(blockId);

            if this.dataMap.isKey(sid)
                blockData=this.dataMap(sid);

                if~isempty(varargin)
                    this.assertValidFields(varargin);
                    if numel(varargin)==1

                        blockData=blockData.(varargin{1});
                    else

                        blockData=rmfield(blockData,varargin);
                    end
                end
            else
                blockData=[];
            end
        end

        function setBlockData(this,blockId,varargin)
            id=coder.internal.mlfb.gui.BlockDataStore.normalize(blockId);
            dataStruct=this.overlayDataStruct(this.getBlockData(id),varargin);

            if~isempty(dataStruct)
                this.dataMap(id)=dataStruct;
                this.registerBlockListeners(id);
            else
                this.remove(id);
            end
        end

        function lastData=remove(this,blockId)
            lastData=this.doRemoveBlockData(blockId,true);
        end

        function clear(this)
            this.dataMap.remove(this.dataMap.keys());
            this.listeners.remove(this.listeners.keys());
        end

        function count=size(this)
            count=this.dataMap.length();
        end

        function contained=isKey(this,blockId)
            sid=coder.internal.mlfb.gui.BlockDataStore.normalize(blockId);
            contained=this.dataMap.isKey(sid);
        end

        function allKeys=keys(this)
            allKeys=this.dataMap.keys();
        end

        function empty=isempty(this)
            empty=this.size()==0;
        end

        function allValues=values(this)
            allValues=this.dataMap.values();
        end

        function allDrivers=getAllDrivers(this)
            allDrivers={};
            allValues=this.dataMap.values();

            for ii=1:length(allValues)
                val=allValues{ii};
                if~isempty(val.Driver)
                    allDrivers{end+1}=val.Driver;%#ok<AGROW>
                end
            end
        end
    end

    methods(Hidden)
        function beginRemapping(this,blockId)
            if this.isKey(blockId)
                this.remappableBlock=coder.internal.mlfb.gui.BlockDataStore.normalize(blockId);
                this.remappableData=this.getBlockData(blockId);
            end
        end

        function finishRemapping(this,blockId)
            if~isempty(this.remappableBlock)&&~isempty(this.remappableData)
                blockId=coder.internal.mlfb.gui.BlockDataStore.normalize(blockId);
                if this.remappableBlock==blockId
                    this.setBlockData(this.remappableBlock,this.remappableData);
                end
            end

            this.remappableBlock=[];
            this.remappableData=[];
        end
    end

    methods(Access=private)
        function registerBlockListeners(this,key)
            assert(~isempty(key));
            if~this.listeners.isKey(key)
                try
                    blockObj=get_param(key,'Object');
                    this.listeners(key)=Simulink.listener(blockObj,'ObjectBeingDestroyed',...
                    @(~,~)this.doRemoveBlockData(key,false));
                catch me %#ok<NASGU>
                end
            end
        end

        function removeBlockListeners(this,blockKey)
            assert(~isempty(blockKey));
            if this.listeners.isKey(blockKey)
                this.listeners.remove(blockKey);
            end
        end

        function lastData=doRemoveBlockData(this,blockId,validateId)
            assert(islogical(validateId));

            if validateId
                normId=coder.internal.mlfb.gui.BlockDataStore.normalize(blockId);
            else


                assert(~isempty(blockId)&&isa(blockId,'coder.internal.mlfb.BlockIdentifier'));
                normId=blockId;
            end

            if this.dataMap.isKey(normId)
                lastData=this.dataMap(normId);
                this.dataMap.remove(normId);
                this.removeBlockListeners(normId);
            else
                lastData=[];
            end
        end

        function actual=overlayDataStruct(this,old,data)
            if isempty(data)
                actual=old;
                return;
            end

            validateattributes(data,{'struct','cell'},{});

            if iscell(data)
                parser=createCellInputParser();
                parser.parse(data{:});
                actual=parser.Results;
            else
                this.assertValidFields(fieldnames(data));
                actual=data;

                if numel(fieldnames(actual))~=numel(this.Fields)
                    assert(isstruct(old));
                    actual=struct();


                    for i=1:numel(this.Fields)
                        fieldName=this.Fields{i};
                        if isfield(actual,fieldName)
                            actual.(fieldName)=actual.(fieldName);
                        elseif isfield(old,fieldName)
                            actual.(fieldName)=old.(fieldName);
                        else
                            actual.(fieldName)=[];
                        end
                    end
                end
            end

            function parser=createCellInputParser()
                parser=inputParser();
                parser.FunctionName='normalizeDataStruct';
                for j=1:numel(this.Fields)
                    fieldName=this.Fields{j};
                    if~isempty(old)&&isfield(old,fieldName)
                        defaultValue=old.(fieldName);
                    else
                        defaultValue=[];
                    end
                    parser.addParameter(this.Fields{j},defaultValue);
                end
            end
        end

        function assertValidFields(this,testFields)
            if~isempty(testFields)
                validateattributes(testFields,{'cell','char'},{});
                if ischar(testFields)
                    testFields={testFields};
                end
                assert(all(ismember(testFields,this.Fields)));
            end
        end
    end

    methods(Static,Access=private)
        function normalized=normalize(blockId)
            normalized=coder.internal.mlfb.idForBlock(blockId);
        end
    end
end