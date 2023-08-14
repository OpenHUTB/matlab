function result=preview(obj)


    dm=obj.dataProvider.dataModel;
    top=obj.topModel;
    node=dm.getNode(top);
    visited=containers.Map;
    result=loc_apply(dm,node,visited,{});


    function result=loc_apply(dm,node,visited,result)
        mdl=node.name;

        if visited.isKey(mdl)
            return;
        end

        id=node.id;
        [role,rootNode]=dm.getRole(id);

        if role==0
            cgb='None';
            dp='None';
        elseif role==1
            cgb='Default';
            dp=node.DeploymentType;
        elseif role==2
            cgb='Default';
            dp=2;
        end
        ecd=rootNode.CoderDictionary;
        pf=rootNode.Platform;

        visited(mdl)=true;
        result(end+1,:)={mdl,role,cgb,ecd,pf,dp};

        refs=node.refMdls;
        for i=1:length(refs)
            ref=refs{i};
            refNode=dm.getNode([id,'/',ref]);
            result=loc_apply(dm,refNode,visited,result);
        end




