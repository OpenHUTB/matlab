function out=getElementById(h,id)





    if isempty(id)
        out=[];
    else
        out=locGetElementById(h.XDoc,id);
    end




    function out=locGetElementById(xObj,id)


        out=[];

        if xObj.getNodeType==3||xObj.getNodeType==xObj.COMMENT_NODE
            return
        end


        nodeId=char(xObj.getAttribute('id'));
        if isempty(nodeId)
            nodeId=char(xObj.getAttribute('ID'));
        end
        if strcmp(nodeId,id)
            out=xObj;
            return
        end


        for k=0:xObj.getLength-1
            out=locGetElementById(xObj.item(k),id);
            if~isempty(out)
                return
            end
        end
