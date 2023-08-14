classdef Markup<slreq.data.AttributeOwner









    properties(Dependent,GetAccess=public,SetAccess=public)
linkSet
        position;
        size;
        sourceObjId;
        viewOwnerId;
        connectors;
        visibleDetail;
    end

    properties(GetAccess=private,SetAccess=private)
        reqData;
    end

    methods(Access=?slreq.data.ReqData)



        function this=Markup(modelObject)
            this.modelObject=modelObject;
            this.reqData=slreq.data.ReqData.getInstance;
        end
    end

    methods
        function set.position(this,pos)
            if this.modelObject.posx~=int32(pos(1))||this.modelObject.posy~=int32(pos(2))
                this.modelObject.posx=int32(pos(1));
                this.modelObject.posy=int32(pos(2));
                if~this.modelObject.linkSet.dirty

                    this.linkSet.setDirty(true);
                end
            end
        end

        function pos=get.position(this)
            pos=double([this.modelObject.posx,this.modelObject.posy]);
        end

        function set.size(this,size)
            if this.modelObject.height~=int32(size(1))||this.modelObject.width~=int32(size(2))
                this.modelObject.height=int32(size(1));
                this.modelObject.width=int32(size(2));
                if~this.modelObject.linkSet.dirty

                    this.linkSet.setDirty(true);
                end
            end
        end

        function size=get.size(this)
            size=double([this.modelObject.height,this.modelObject.width]);
        end

        function set.viewOwnerId(this,ownerId)
            if~strcmp(this.modelObject.viewOwnerId,ownerId)
                this.modelObject.viewOwnerId=ownerId;
                if~this.modelObject.linkSet.dirty

                    this.linkSet.setDirty(true);
                end
            end
        end

        function ownerId=get.viewOwnerId(this)
            ownerId=this.modelObject.viewOwnerId;
        end

        function ownerId=get.sourceObjId(this)
            ownerId=this.modelObject.sourceObjId;
        end

        function set.sourceObjId(this,val)


            if~strcmp(this.modelObject.sourceObjId,val)
                this.modelObject.sourceObjId=val;
                if~this.modelObject.linkSet.dirty

                    this.linkSet.setDirty(true);
                end
            end
        end

        function conns=get.connectors(this)
            conns=slreq.data.Connector.empty;
            modelConns=this.modelObject.connectors.toArray;
            for n=1:length(modelConns)
                conns(end+1)=this.reqData.findObject(modelConns(n).UUID);%#ok<AGROW>
            end
        end

        function linkSet=get.linkSet(this)
            linkSet=this.reqData.findObject(this.modelObject.linkSet.UUID);
        end

        function set.visibleDetail(this,value)
            if this.modelObject.visibleDetail~=value
                this.modelObject.visibleDetail=value;

                this.linkSet.setDirty(true);
            end
        end

        function value=get.visibleDetail(this)
            value=this.modelObject.visibleDetail;
        end

        function link=getLink(this)
            link=this.reqData.findObject(this.ownerId);
        end
    end
end
