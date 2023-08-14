


classdef DataStoreMemoryFixSimpleCase<Simulink.ModelReference.Conversion.AutoFix
    properties(SetAccess=protected,GetAccess=protected)
DSMBlocks
Systems
        Results={}
ConversionData
ConversionParameters
        NewDSMBlocks=[]
    end


    methods(Access=public)
        function this=DataStoreMemoryFixSimpleCase(params,subsys,dsmBlock)
            this.DSMBlocks=dsmBlock;
            this.Systems=subsys;
            this.ConversionData=params;
            this.ConversionParameters=params.ConversionParameters;
        end


        function fix(this)
            numberOfDSMBlocks=numel(this.DSMBlocks);
            this.NewDSMBlocks=zeros(numberOfDSMBlocks,1);
            for blkIdx=1:numberOfDSMBlocks
                dsmBlock=this.DSMBlocks(blkIdx);
                subsys=this.Systems(blkIdx);
                this.Results{end+1}=message('Simulink:modelReferenceAdvisor:FixSimpleDataStoreMemoryProblem',...
                Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(dsmBlock),dsmBlock),...
                Simulink.ModelReference.Conversion.MessageBeautifier.beautifyBlockName(getfullname(subsys),subsys));


                this.NewDSMBlocks(blkIdx)=this.addDSMBlock(subsys,dsmBlock);


                this.deleteDSMBlock(dsmBlock);

            end


            this.DSMBlocks=[];
        end

        function results=getActionDescription(this)
            results=this.Results;
        end
    end


    methods(Access=protected)
        function deleteDSMBlock(this,aBlk)
            if this.ConversionParameters.ReplaceSubsystem


                delete_block(aBlk);
            end
        end

        function newBlkName=getNewBlockName(this,subsys,dsmBlock)
            aModel=this.ConversionParameters.ModelReferenceNames{this.ConversionParameters.Systems==subsys};
            blkName=strrep(get_param(dsmBlock,'Name'),'/','//');
            newBlkName=[aModel,'/',blkName];
        end

        function blk=getParent(this,subsys)
            aModel=this.ConversionParameters.ModelReferenceNames{this.ConversionParameters.Systems==subsys};
            blk=get_param(aModel,'Handle');
        end

        function newDSMBlock=addDSMBlock(this,subsys,dsmBlock)
            allBlks=Simulink.ModelReference.Conversion.GuiUtilities.findTopLevelBlocks(this.getParent(subsys));



            allPos=get_param(allBlks,'Position');
            if iscell(allPos)
                allPos=cell2mat(allPos);
            end
            pos=get_param(dsmBlock,'Position');
            blkHeight=pos(4)-pos(2);
            blkWidth=pos(3)-pos(1);
            x=min(allPos(:,1));
            y=max(allPos(:,4));


            newBlkName=this.getNewBlockName(subsys,dsmBlock);
            newDSMBlock=add_block(dsmBlock,newBlkName,'MakeNameUnique','on');
            set_param(newDSMBlock,'Position',[x,y+blkHeight,x+blkWidth,y+2*blkHeight]);
        end
    end
end
