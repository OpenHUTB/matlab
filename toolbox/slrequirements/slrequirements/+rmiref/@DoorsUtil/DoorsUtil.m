

classdef DoorsUtil<handle

    properties
sID
sName
sProject
modifiedOn
labels
locations
parentIdx
depths
summary
selected
    end

    methods(Access=private)

        function moduleData=DoorsUtil(moduleId)
            moduleData.sID=moduleId;
            moduleData.sName=rmidoors.getModuleAttribute(moduleId,'Name');
            moduleData.sProject='';
            doorsLinkType=rmi.linktype_mgr('resolveByRegName','linktype_rmi_doors');
            [moduleData.labels,~,moduleData.locations]=feval(doorsLinkType.ContentsFcn,moduleId);
            moduleData.parentIdx=rmiref.DoorsUtil.buildParentIdx(moduleId,moduleData.locations);
            moduleData.depths=rmiref.DoorsUtil.computeDepths(moduleData.parentIdx);
            moduleData.summary=rmiref.DoorsUtil.compileSummary(moduleData.depths);
            moduleData.modifiedOn=rmidoors.getModuleAttribute(moduleId,'Last Modified On');
            moduleData.selected=[];
        end

    end

    methods

        function fullName=sFile(this)
            fullName=[this.sID,' (',this.sProject,'/',this.sName,')'];
        end

        function itemSummary=makeSummary(this,itemId)
            if isstruct(itemId)
                itemId=itemId.id;
            end
            itemSummary=rmidoors.getObjAttribute(this.sID,itemId,'Object Heading');
            if isempty(itemSummary)
                itemSummary=rmidoors.getObjAttribute(this.sID,itemId,'Object Text');
            end
        end

    end

    methods(Static,Access=private)

        function parentIdx=buildParentIdx(moduleId,locations)
            parentIdx=zeros(size(locations));
            numbers=zeros(size(locations));

            modulePrefix=rmidoors.getModuleAttribute(moduleId,'Prefix');
            for i=1:length(locations)
                location=locations{i};
                if location(1)=='#'
                    location(1)=[];
                end
                if~isempty(modulePrefix)
                    location=strrep(location,modulePrefix,'');
                end
                numbers(i)=str2num(location);%#ok<ST2NM>
            end

            for i=1:length(numbers)
                number=numbers(i);
                childIds=rmidoors.getObjAttribute(moduleId,number,'childIds');
                if~isempty(childIds)
                    for j=1:length(childIds)
                        childId=childIds{j};
                        if length(childId)>1
                            for m=1:size(childId,1)
                                for n=1:size(childId,2)
                                    childNumber=childId(m,n);
                                    childIndex=(numbers==childNumber);
                                    parentIdx(childIndex)=i;
                                end
                            end
                        else
                            childIndex=(numbers==childId);
                            parentIdx(childIndex)=i;
                        end
                    end
                end
            end















        end

        function depths=computeDepths(parentIdx)
            depths=zeros(size(parentIdx));
            for i=1:length(parentIdx)
                if parentIdx(i)==0
                    depths(i)=1;
                else
                    depths(i)=depths(parentIdx(i))+1;
                end
            end
        end

        function summary=compileSummary(depths)
            summary=cell(0,2);
            depth=1;
            total=length(depths);
            summary(end+1,1:2)={'All items',total};
            while true
                count=sum(depths==depth);
                if count==0
                    break;
                else
                    summary(end+1,1:2)={sprintf('Level %d items',depth),count};%#ok<AGROW>
                    depth=depth+1;
                end
            end
        end

    end

    methods(Static)

        function docUtilObj=get(moduleId)

            persistent docUtilObjects
            if isempty(docUtilObjects)
                docUtilObjects=containers.Map('KeyType','char','ValueType','any');
            end
            if strcmp(moduleId,'clearAll')
                docUtilObjects=containers.Map('KeyType','char','ValueType','any');
                return;
            end

            if isKey(docUtilObjects,moduleId)
                docUtilObj=docUtilObjects(moduleId);
            else
                docUtilObj=rmiref.DoorsUtil(moduleId);
                docUtilObjects(moduleId)=docUtilObj;
            end
        end

        function filePathName=htmlFileName(moduleId,itemID)
            baseName=rmiref.DoorsUtil.cacheFileBaseName(moduleId,itemID);
            filePathName=[baseName,'.htm'];
        end

        MODULE_ID=findModule(DOC)
        MDL=fixDoorsModel(DOC,ITEM,ARGS)
        FIXED=fixDoorsObject(DOC,ITEM,ARGS)
        [docTxt,anchorId]=getAnchorInfo(doc,id,label)
        hDoors=getApplication(use_current)
        doorsModule=getCurrentDoc()
        [depths,items]=getObjAttributes(module,objid)


        [html,cachedHtmlFile]=itemToHtml(module,object,varargin)
        html=itemToHtmlDefault(moduleId,item,varargin)
        html=childItemsToHtml(moduleId,itemId,headerLevel)
        html=itemToHtmlCustom(moduleId,item,cols)
        html=pictureObjToHtml(moduleId,item)
        data=doorsTableIdsToStrings(module,ids)
        fPathName=cacheFileBaseName(module,objId)
        yesno=isUpToDate(cachedHtmlFile,moduleId,item)

    end

end

