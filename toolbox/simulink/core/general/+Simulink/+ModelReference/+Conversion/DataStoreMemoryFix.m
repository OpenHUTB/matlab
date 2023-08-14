
















classdef DataStoreMemoryFix<Simulink.ModelReference.Conversion.AutoFix
    properties(SetAccess=private,GetAccess=private)
DSMBlocks
DSRWBlocks
ConversionData
DataAccessor

        SignalNames={}
ExcludedNames
        Results={}


PortInfos
InitValues
    end


    methods(Access=public)
        function this=DataStoreMemoryFix(dsmBlocks,rwBlocks,excludedNames,conversionData)
            this.DSMBlocks=dsmBlocks;
            this.DSRWBlocks=rwBlocks;
            this.ConversionData=conversionData;
            this.DataAccessor=conversionData.DataAccessor;



            modelName=get_param(conversionData.ConversionParameters.Model,'Name');
            this.ExcludedNames=union({modelName},excludedNames);


            numberOfDSMBlocks=numel(this.DSMBlocks);
            for blkIdx=1:numberOfDSMBlocks
                rwBlocks=this.DSRWBlocks{blkIdx};
                this.PortInfos{end+1}=this.getCompilePortInfoObject(rwBlocks(1));
            end


            this.InitValues=arrayfun(@(dsmBlock)get_param(dsmBlock,'InitialValue'),this.DSMBlocks,'UniformOutput',false);
        end


        function fix(this)
            numberOfDSMBlocks=numel(this.DSMBlocks);
            for blkIdx=1:numberOfDSMBlocks
                dsmBlock=this.DSMBlocks(blkIdx);
                rwBlocks=this.DSRWBlocks{blkIdx};
                varName=this.createSimulinkSignalObject(dsmBlock,this.PortInfos{blkIdx},this.InitValues{blkIdx});

                arrayfun(@(blk)set_param(blk,'DataStoreName',varName),rwBlocks);


                this.Results{end+1}=message('Simulink:modelReferenceAdvisor:UpdateDataStoreName',...
                Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(dsmBlock),dsmBlock),...
                varName);
                delete_block(dsmBlock);
            end


            this.DSMBlocks=[];
            this.DSRWBlocks={};
        end


        function results=getActionDescription(this)
            results=this.Results;
        end
    end


    methods(Access=private)
        function varName=createSimulinkSignalObject(this,dsmBlock,portInfo,initValue)
            suggestedName=get_param(dsmBlock,'DataStoreName');
            varName=this.getValidVariableName(suggestedName);
            varId=this.DataAccessor.identifyByName(varName);
            if isempty(varId)
                this.DataAccessor.createVariableAsExternalData(varName,portInfo.createSignalObject(initValue));
            else
                this.DataAccessor.updateVariable(varId,portInfo.createSignalObject(initValue));
            end
            this.SignalNames{end+1}=varName;
            this.ConversionData.addVariable(varName);
        end


        function nameString=getValidVariableName(this,suggestedName)
            maxLength=namelengthmax-4;
            suggestedName=suggestedName(1:min(maxLength,length(suggestedName)));
            varName=matlab.lang.makeValidName(suggestedName);
            newName=varName;
            counter=0;
            while(any(strcmp(this.ExcludedNames,newName))||~isempty(this.DataAccessor.identifyByName(newName)))
                counter=counter+1;
                newName=sprintf('%s%d',varName,counter);
            end
            nameString=newName;
        end
    end


    methods(Static,Access=private)
        function portInfo=getCompilePortInfoObject(accessBlock)
            portHandle=get_param(accessBlock,'PortHandles');
            if~isempty(portHandle.Inport)
                ph=portHandle.Inport;
            else
                assert(~isempty(portHandle.Outport),'A given block must have a port: %s',accessBlock);
                ph=portHandle.Outport;
            end


            portInfo=Simulink.CompiledPortInfo(ph);
        end
    end
end
