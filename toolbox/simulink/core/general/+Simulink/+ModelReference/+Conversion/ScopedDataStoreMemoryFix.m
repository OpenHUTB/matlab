



classdef ScopedDataStoreMemoryFix<Simulink.ModelReference.Conversion.AutoFix
    properties(SetAccess=protected,GetAccess=protected)

        Results={}
ConversionData
ConversionParameters
        NewDSMBlocks=[]
    end


    methods(Access=public)
        function this=ScopedDataStoreMemoryFix(params)

            this.ConversionData=params;
            this.ConversionParameters=params.ConversionParameters;
        end


        function fix(this)
            this.update();
        end

        function results=getActionDescription(this)
            results=this.Results;
        end
    end


    methods(Access=protected)


        function newBlkName=getNewBlockName(~,mdlblk,dsmBlock)
            newBlkName=[get_param(mdlblk,'ModelName'),'/',get_param(dsmBlock,'Name')];
        end

        function blk=getParent(~,subsys)
            blk=subsys;
        end

        function addRefDSMBlock(this,dsmBlockInfo,blockOrder)

            subsys=dsmBlockInfo.Subsys;
            dsmBlock=dsmBlockInfo.DSM;

            allBlks=Simulink.ModelReference.Conversion.GuiUtilities.findTopLevelBlocks(this.getParent(subsys));


            subsystemIndex=this.ConversionData.ConversionParameters.Systems==subsys;
            modelBlock=this.ConversionData.ModelBlocks(subsystemIndex);
            if modelBlock==0
                return;
            end



            allPos=get_param(allBlks,'Position');
            if iscell(allPos)
                allPos=cell2mat(allPos);
            end
            pos=get_param(dsmBlock,'Position');

            blkHeight=pos(4)-pos(2);
            blkWidth=pos(3)-pos(1);
            x=min(allPos(:,1));
            y=max(allPos(:,4));


            newBlkName=this.getNewBlockName(modelBlock,dsmBlock);
            newDSMBlock=add_block(dsmBlock,newBlkName,'MakeNameUnique','on');
            set_param(newDSMBlock,'Position',[x+(2*blockOrder-1)*(blkWidth),y+blkHeight,x+(2*blockOrder)*blkWidth,y+2*blkHeight]);
            set_param(newDSMBlock,'dimensions',dsmBlockInfo.Dim);
            set_param(newDSMBlock,'OutDataTypeStr',dsmBlockInfo.DataType);
            set_param(newDSMBlock,'signaltype',dsmBlockInfo.SignalType);
            set_param(newDSMBlock,'datastorereference','on');
        end




        function update(this,~)
            scopedDSMInfo=this.ConversionData.DSMReferenceCopyInfo;
            array=[scopedDSMInfo{:}];
            [~,idx]=unique([array.dataStoreName].','rows','stable');
            array=array(idx);

            for index=1:length(array)
                this.addRefDSMBlock(array(index),index);
            end
            this.ConversionData={};
        end
    end
end
