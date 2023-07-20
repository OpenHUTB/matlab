classdef db_0141_b<slcheck.subcheck
    methods
        function obj=db_0141_b()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0141_b';
        end

        function result=run(this)
            result=true;
            canvasH=this.getEntity();

            if ischar(canvasH)
                canvasH=get_param(canvasH,'handle');
            end

            svc=slcheck.services.GraphService.getInstance();

            data=svc.getData(canvasH);
            if isempty(data)
                return;
            end
            data.conngrp=Advisor.Utils.Graph.getConnectedComponents(data.adjacency);

            uRanks=unique(data.ranks);

            if numel(uRanks)<3
                return;
            end

            violations=[];

            for i=2:length(uRanks)-1

                blocksToCheck=data.handles(arrayfun(@(x)data.ranks(x)==uRanks(i)&&data.conngrp(x)==data.conngrp(i),1:data.num_nodes));

                if numel(blocksToCheck)<=1
                    continue;
                end


                pos=cell2mat(get_param(blocksToCheck,'position'));

                vert_pos=sort([pos(:,2),pos(:,4)]);




                if~(all(all(vert_pos(2:end,:)-vert_pos(1:end-1,:)>0))&&...
                    all(all(vert_pos(2:end,1)-vert_pos(1:end-1,2)>0)))
                    vObj=ModelAdvisor.ResultDetail;
                    ModelAdvisor.ResultDetail.setData(vObj,'Group',blocksToCheck);
                    violations=[violations;vObj];%#ok<AGROW>
                end
            end

            if~isempty(violations)
                result=this.setResult(violations);
            end
        end
    end
end