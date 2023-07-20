classdef TextRange<slreq.data.SourceItem




    properties(Dependent)
startPos
endPos
startLine
endLine
revision
    end

    methods(Access=?slreq.data.ReqData)



        function this=TextRange(modelObject)
            this=this@slreq.data.SourceItem(modelObject);
        end
    end

    methods












        function out=get.startPos(this)
            out=this.modelObject.start;
        end

        function set.startPos(this,value)
            this.modelObject.start=value;
        end

        function out=get.endPos(this)
            out=this.modelObject.end;
        end

        function set.endPos(this,value)
            this.modelObject.end=value;
        end

        function setRange(this,range)
            this.modelObject.start=range(1);
            this.modelObject.end=range(end);
            linkSet=this.getLinkSet();
            linkSet.setDirty(true);
        end

        function parentId=getParentId(this)

            parentId=this.getSID();
            if isempty(parentId)
                parentId=this.artifactUri;
            end
        end

        function out=get.startLine(this)
            parentId=this.getParentId();
            charPos=this.modelObject.start;
            out=slreq.mleditor.ReqPluginHelper.getInstance.charPositionToLineNumber(parentId,charPos);
        end

        function out=get.endLine(this)
            parentId=this.getParentId();
            charPos=this.modelObject.end;
            out=slreq.mleditor.ReqPluginHelper.getInstance.charPositionToLineNumber(parentId,charPos);
        end

        function out=get.revision(this)
            out=this.modelObject.revision;
        end

        function set.revision(this,newRevision)
            this.modelObject.revision=newRevision;
        end

    end

end

