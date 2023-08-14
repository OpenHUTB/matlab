classdef TextItem<slreq.data.DataModelObj




    properties(Dependent,GetAccess=public,SetAccess=private)
id
    end

    properties(Dependent)
content
    end

    methods(Access=?slreq.data.ReqData)



        function this=TextItem(modelObject)
            this.modelObject=modelObject;
        end
    end

    methods

        function name=get.id(this)
            name=this.modelObject.id;
        end

        function name=get.content(this)
            name=this.modelObject.content;
        end

        function set.content(this,value)
            this.modelObject.content=value;

            linkSet=this.getLinkSet();
            if~isempty(linkSet)
                linkSet.setDirty(true);
            end
        end

        function editorId=getEditorId(this)
            linkSet=this.getLinkSet();
            myId=this.modelObject.id;
            if isempty(myId)

                editorId=linkSet.artifact;
            else



                [~,artifactName]=fileparts(linkSet.artifact);
                editorId=[artifactName,myId];
            end
        end

        function linkSet=getLinkSet(this)
            linkSet=slreq.data.ReqData.getWrappedObj(this.modelObject.artifact);
        end

        function textRange=addTextRange(this,varargin)
            if ischar(varargin{1})
                newId=varargin{1};
                range=varargin{2};
            else
                newId=this.getNextId();
                range=varargin{1};
            end
            textRange=slreq.data.ReqData.getInstance.addTextRange(this,newId,range);
        end

        function ranges=getRanges(this)
            ranges=slreq.data.TextRange.empty();
            textRanges=this.modelObject.textRanges.toArray();
            for i=1:numel(textRanges)
                ranges(i)=slreq.data.ReqData.getWrappedObj(textRanges(i));
            end
        end

        function yesno=hasOutgoingLinks(this)
            yesno=false;
            ranges=this.getRanges();
            for i=1:numel(ranges)
                if ranges(i).numberOfLinks()>0
                    yesno=true;
                    return;
                end
            end
        end

        function[range,numMatchedRanges]=getRange(this,id)
            range=slreq.data.TextRange.empty();
            textRanges=this.modelObject.textRanges.toArray();
            numMatchedRanges=0;

            if ischar(id)






                for i=1:numel(textRanges)
                    textRange=textRanges(i);
                    longId=slreq.utils.getLongIdFromShortId(this.id,id);
                    if strcmp(textRange.id,longId)
                        range=slreq.data.ReqData.getWrappedObj(textRange);
                        numMatchedRanges=1;
                        return;
                    end
                end

            elseif isnumeric(id)








                for i=1:numel(textRanges)
                    textRange=textRanges(i);
                    rangeChars=textRange.start:textRange.end;
                    givenRange=int32(id(1):id(end));
                    if any(ismember(givenRange,rangeChars))
                        if numMatchedRanges==0
                            range=slreq.data.ReqData.getWrappedObj(textRange);
                            numMatchedRanges=1;
                        else
                            numMatchedRanges=numMatchedRanges+1;
                        end
                    end
                end
            end
        end

        function success=removeTextRange(this,id)
            success=slreq.data.ReqData.getInstance.removeTextRange(this,id);
        end

        function nextId=getNextId(this)
            today=floor(now);
            if ispc
                userNum=mod(sum(getenv('USERNAME')),1000);
            else
                userNum=mod(sum(getenv('USER')),1000);
            end
            baseId=slreq.utils.getLongIdFromShortId(this.id,sprintf('%d.%d',today,userNum));
            prefixLen=length(baseId);
            textRanges=this.modelObject.textRanges.toArray();
            lastNum=0;
            for i=1:numel(textRanges)
                myId=textRanges(i).id;
                if strncmp(myId,baseId,prefixLen)
                    myNum=str2num(myId(prefixLen+2:end));%#ok<ST2NM>
                    if myNum>lastNum
                        lastNum=myNum;
                    end
                end
            end
            nextId=sprintf('%s.%d',baseId,lastNum+1);
        end
    end

end

