classdef db_0141_a<slcheck.subcheck
    methods
        function obj=db_0141_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='db_0141_a';
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
            data.distances=Advisor.Utils.Graph.getDistances(data.adjacency);

            badSubSys=false;

            for i=1:data.num_nodes
                blockH=data.handles(i);
                if data.in_loop(data.handles==blockH)
                    continue;
                end


                if~strcmp(get_param(blockH,'orientation'),'right')
                    badSubSys=true;
                    break;
                end


                if~checkSequentialPlacement(blockH,data,i)
                    badSubSys=true;
                    break;
                end
            end

            if badSubSys
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',canvasH);
                result=this.setResult(vObj);
            end
        end
    end
end

function bResult=checkSequentialPlacement(blockH,data,idx)
    bResult=true;
    myRank=data.ranks(idx);

    blocksToCheck=data.handles(arrayfun(@(x)data.ranks(x)<myRank&&~isinf(data.distances(x,idx)),1:data.num_nodes));

    blocksToCheck=setdiff(blocksToCheck,blockH);

    current_position=get_param(blockH,'position');


    for j=1:length(blocksToCheck)

        successor_position=get_param(blocksToCheck(j),'position');

        if successor_position(3)>current_position(1)
            bResult=false;
            return;
        end
    end

end

