classdef db_0146_a<slcheck.subcheck





    methods
        function obj=db_0146_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0146_a';
        end

        function result=run(this)

            result=false;

            if isempty(this.getEntity)
                return;
            end

            block=get_param(this.getEntity(),'object');


            if~ismember(block.BlockType,{'TriggerPort','EnablePort','ActionPort'})
                return;
            end

            canvasH=get_param(get_param(this.getEntity(),'parent'),'handle');
            svc=slcheck.services.PositionalMapService.instance;

            posMat=svc.getPositionalMatrixForSubsys(canvasH);

            if isempty(posMat)
                return;
            end
            fl=this.getInputParamByName('Follow links');
            lum=this.getInputParamByName('Look under masks');
            allRelevantBlocks=get_param(find_system(canvasH,'Regexp','on','SearchDepth',1,'FollowLinks',fl,...
            'LookUnderMasks',lum,'BlockType','TriggerPort|EnablePort|ActionPort'),'handle');
            if iscell(allRelevantBlocks)
                allRelevantBlocks=cell2mat(allRelevantBlocks);
            end


            remPos=posMat(~ismember(posMat(:,1),allRelevantBlocks),2:end);

            if isempty(remPos)
                return;
            end

            minVals=min(remPos,[],1);
            maxVals=max(remPos,[],1);

            bBox=[minVals(1:2),maxVals(3:4)];

            blockPos=get_param(this.getEntity(),'position');




            if blockPos(4)>=bBox(2)
                result=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(result,'SID',block.Handle);
                this.setResult(result);
            end
        end
    end
end
