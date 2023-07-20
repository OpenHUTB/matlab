





classdef(Abstract)BaseItem<matlab.mixin.Heterogeneous&handle





    properties(Transient=true,Access=protected)
dataObject
    end

    properties(Dependent)
IndexEnabled
IndexNumber
    end

    properties(Dependent,GetAccess=public,SetAccess=private)
SID
FileRevision
ModifiedOn
Dirty
Comments
Index
    end

    properties(Hidden,Constant)

        READONLY_PROPERTIES={'createdon','createdby','modifiedon','modifiedby',...
        'sid','filerevision','dirty'};
    end

    methods(Hidden,Access=?slreq.data.ReqData)
        function d=getDataObj(this)
            d=this.dataObject;
        end
    end

    methods(Static,Hidden)
        function obj=loadobj(s)
            obj=s;
            rmiut.warnNoBacktrace('Slvnv:slreq:illegalDataForMATFile',class(obj));
        end
    end
    methods(Hidden)
        function sobj=saveobj(obj)
            rmiut.warnNoBacktrace('Slvnv:slreq:illegalDataForMATFile',class(obj));
            sobj=obj;
        end
    end

    methods(Access=protected)
        function this=BaseItem(dataObject)
            this.dataObject=dataObject;
        end
    end

    methods
        function index=get.Index(this)
            index=this.dataObject.index;
        end

        function sid=get.SID(this)
            sid=this.dataObject.sid;
        end

        function value=get.ModifiedOn(this)
            value=this.dataObject.modifiedOn;
        end

        function value=get.FileRevision(this)
            value=this.dataObject.revision;
        end

        function value=get.Dirty(this)
            value=this.dataObject.dirty;
        end

        function parentApi=parent(this)
            this.errorIfVectorOperation();
            parentObj=this.dataObject.parent;
            if isempty(parentObj)
                parentApi=this.reqSet;
            else
                parentApi=slreq.utils.dataToApiObject(parentObj);
            end
        end

        function childrenApi=children(this)
            this.errorIfVectorOperation();
            childObjs=this.dataObject.children;
            if isempty(childObjs)
                childrenApi=[];
            else
                childrenApi=slreq.utils.wrapDataObjects(childObjs);
            end
        end

        function thisComment=addComment(this,text)
            this.errorIfVectorOperation();
            if~(ischar(text)||isstring(text))
                error(message('Slvnv:slreq:InvalidInputType'));
            end
            comment=this.dataObject.addComment();
            comment.Text=text;
            thisComment=this.Comments(end);
        end

        function value=get.Comments(this)

            value=struct('CommentedBy',{},'CommentedOn',{},'CommentedRevision',{},'Text',{});
            comments=this.dataObject.comments;
            for n=1:length(comments)
                comment=comments(n);
                value(n)=struct('CommentedBy',comment.CommentedBy,...
                'CommentedOn',comment.Date,'CommentedRevision',...
                comment.CommentedRevision,'Text',comment.Text);
            end
        end

        function reqSet=reqSet(this)
            this.errorIfVectorOperation();
            reqSetDataObj=slreq.data.ReqData.getInstance.getParentReqSet(this.dataObject);
            reqSet=slreq.utils.dataToApiObject(reqSetDataObj);
        end

        function links=inLinks(this)
            this.errorIfVectorOperation();
            links=slreq.Link.empty();
            linkData=this.dataObject.getLinks();
            for i=1:numel(linkData)
                links(end+1)=slreq.utils.dataToApiObject(linkData(i));%#ok<AGROW>
            end
        end

        function links=outLinks(this)
            this.errorIfVectorOperation();
            links=slreq.Link.empty();
            linkData=this.dataObject.getOutgoingLinks();
            for i=1:numel(linkData)
                links(end+1)=slreq.utils.dataToApiObject(linkData(i));%#ok<AGROW>
            end
        end

        function result=find(this,varargin)
            this.errorIfVectorOperation();
            [varargin{:}]=convertStringsToChars(varargin{:});
            allChildren=this.contents();
            if isempty(varargin)
                result=allChildren;
            else
                result=slreq.utils.filterByProperties(allChildren,varargin{:});
            end
        end

        function value=getAttribute(this,name)
            this.errorIfVectorOperation();
            name=convertStringsToChars(name);
            if strcmp(name,'dataObject')

                error(message('Slvnv:slreq:NoSuchAttribute'));
            elseif this.dataObject.hasRegisteredAttribute(name)


                try
                    value=this.dataObject.getAttribute(name,true);
                catch ex

                    throwAsCaller(ex)
                end
            elseif this.dataObject.hasStereotypeAttribute(name)
                try
                    value=this.dataObject.getStereotypeAttr(name,true);
                catch ex

                    error(message('Slvnv:slreq:NoSuchAttribute'));
                end
            elseif any(strcmp(name,{'Id','Summary','Keywords','Description','Rationale','Type'}))


                value=this.(name);
            else
                error(message('Slvnv:slreq:NoSuchAttribute'));
            end
        end

        function setAttribute(this,name,value)
            this.errorIfVectorOperation();
            name=convertStringsToChars(name);
            value=convertStringsToChars(value);
            if strcmp(name,'dataObject')

                error(message('Slvnv:slreq:NoSuchAttribute'));
            elseif this.dataObject.hasRegisteredAttribute(name)


                try
                    this.dataObject.setAttributeWithTypeCheck(name,value);
                catch ex

                    throwAsCaller(ex)
                end
            elseif this.dataObject.hasStereotypeAttribute(name)
                try
                    this.dataObject.setStereotypeAttr(name,value);
                catch ex

                    throwAsCaller(ex)
                end
            elseif any(strcmp(name,{'Id','Summary','Keywords','Description','Rationale','Type'}))
                this.(name)=value;
            else
                error(message('Slvnv:slreq:NoSuchAttribute'));
            end
        end

        function count=remove(this,varargin)
            this.errorIfVectorOperation();

            if~isempty(this.reqSet.getParentModel())
                error(message('Slvnv:slreq:SFTableNotAllowed','remove',this.reqSet.getParentModel));
            end

            if~isempty(varargin)
                [varargin{:}]=convertStringsToChars(varargin{:});

                count=0;
                matchedItems=this.find(varargin{:});
                for i=length(matchedItems):-1:1
                    count=count+matchedItems(i).remove();
                end
            else

                try
                    reqSet=this.dataObject.getReqSet();
                    [~,count]=reqSet.removeRequirement(this.dataObject);
                catch ex
                    rmiut.warnNoBacktrace(ex.message);
                    count=0;
                end
            end
        end

        function success=moveUp(this)
            this.errorIfVectorOperation();
            if~isempty(this.reqSet.getParentModel)
                error(message('Slvnv:slreq:SFTableNotAllowed','moveUp',this.reqSet.getParentModel));
            end
            try
                success=this.dataObject.moveUp();
            catch ex
                throwAsCaller(ex);
            end
        end

        function success=moveDown(this)
            this.errorIfVectorOperation();
            if~isempty(this.reqSet.getParentModel)
                error(message('Slvnv:slreq:SFTableNotAllowed','moveDown',this.reqSet.getParentModel));
            end
            try
                success=this.dataObject.moveDown();
            catch ex
                throwAsCaller(ex);
            end
        end


        function result=get.IndexEnabled(this)
            result=this.dataObject.hIdxEnabled;
        end

        function result=get.IndexNumber(this)
            fixedNumber=this.dataObject.fixedHIdx;
            if fixedNumber<0
                result=[];
            else
                result=fixedNumber;
            end
        end

        function set.IndexEnabled(this,state)
            this.errorIfVectorOperation();
            assert(islogical(state),message('Slvnv:rmipref:InvalidArgument',class(state)));
            this.dataObject.enableHIdx(state);
        end

        function set.IndexNumber(this,number)
            this.errorIfVectorOperation();
            if isempty(number)
                this.dataObject.setHIdx(-1);
            else
                if~isnumeric(number)
                    fromUser=number;
                    number=str2num(number);%#ok<ST2NM> 
                    assert(~isempty(number),message('Slvnv:rmipref:InvalidArgument',fromUser));
                end
                assert(number>0,message('Slvnv:rmipref:InvalidArgument',num2str(number)));
                assert(floor(number)==number,message('Slvnv:rmipref:InvalidArgument',num2str(number)));
                this.dataObject.setHIdx(number);
            end
        end

        function tf=isFilteredIn(this)
            tf=false(0,length(this));
            for i=1:length(this)
                tf(i)=this(i).dataObject.isFilteredIn;
            end
        end

    end

    methods(Access=protected)
        function errorIfVectorOperation(this)
            if numel(this)>1
                error(message('Slvnv:slreq:MethodOnlyForScalar'));
            end
        end
    end

    methods(Hidden)

        function generateTraceDiagram(this)
            this.errorIfVectorOperation();
            slreq.internal.tracediagram.utils.generateTraceDiagram(this.dataObject);
        end

        function[result,depths]=contents(this,depth)
            this.errorIfVectorOperation();
            if nargin<2
                depth=0;
            end

            result=this;
            depths=depth;

            myChildren=this.children;
            for i=1:numel(myChildren)
                [resultFromChild,depthsFromChild]=myChildren(i).contents(depth+1);
                if~isempty(resultFromChild)
                    result=[result,resultFromChild];%#ok<AGROW>
                    depths=[depths,depthsFromChild];%#ok<AGROW>
                end
            end
            if depth==0

                result(1)=[];
                depths(1)=[];
            end
        end

        function firstChild=getFirstChild(this)
            this.errorIfVectorOperation();
            dataChild=this.dataObject.getFirstChild();
            if isempty(dataChild)
                firstChild=[];
            else
                firstChild=slreq.utils.dataToApiObject(dataChild);
            end
        end


        function propValue=getInternalAttribute(this,propName)
            propValue=this.dataObject.getProperty(propName);
        end
        function setInternalAttribute(this,propName,propValue)




            this.dataObject.setProperty(propName,propValue)
        end

        function propsStruct=toStruct(this)
            this.errorIfVectorOperation();
            propsStruct=this.dataObject.toStruct();
        end
    end

    methods(Static,Hidden)
        function ensureWriteableProps(reqInfo)


            if isempty(reqInfo)
                return;
            end
            fields=fieldnames(reqInfo);
            for n=1:length(fields)
                fieldName=fields{n};
                if any(strcmpi(fieldName,slreq.BaseItem.READONLY_PROPERTIES))
                    error(message('Slvnv:slreq:SettingReadOnlyProperty',fieldName));
                end
            end
        end
    end
end
