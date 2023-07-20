



classdef SearchSystems<handle
    properties(Access=public)
        studioTag='';
        viewMode='';
        columnNames={};
        flat='';
        systemName='';
        publishMsg=[];
        functionList={};
        OBJECT_LIST={};
        PROPERTY_LIST={};
        isTest=false;
        searchId='';
        finishedSearch=false;
        markedObjects=[];
        markedResult=[];
        findManager=[];
        searchModelRef=[];
        matchCriteria=[];
        referencedSys={};
        highlightedSys={};
        lastSelection=0.0;
        lastSelectionFcn='';
        editor=[];
        advancedDialog='';
        advancedDialogHandler=[];

        results=[];
        handleToResultIdx=[];
        parentToHierarchyType=[];
        existFieldNames={};
        firstAsyncCall=true;
    end
    methods(Access=public)
        function obj=SearchSystems()
            obj.studioTag='';
            obj.viewMode='';
            obj.columnNames={};
            obj.flat='';
            obj.systemName='';
            obj.publishMsg=[];
            obj.functionList={};
            obj.OBJECT_LIST={};
            obj.PROPERTY_LIST={};
            obj.isTest=false;
            obj.searchId='';
            obj.finishedSearch=false;
            obj.markedObjects=[];
            obj.markedResult=[];
            obj.findManager=[];
            obj.searchModelRef=[];
            obj.matchCriteria=[];
            obj.referencedSys={};
            obj.highlightedSys={};
            obj.lastSelection=0.0;
            obj.lastSelectionFcn='';
            obj.editor=[];
            obj.advancedDialog='';
            obj.advancedDialogHandler=[];

            obj.results=[];
            obj.handleToResultIdx=containers.Map('KeyType','double','ValueType','double');
            obj.parentToHierarchyType=containers.Map('KeyType','char','ValueType','char');
            obj.existFieldNames={};
        end



        function appendArrayWithoutFieldOrder(this,newStructArray)


            if isempty(newStructArray)
                return;
            end

            if(~isempty(this.results))
                newFieldNames=fieldnames(newStructArray);
                newFieldNames=sort(newFieldNames);

                if~isequal(this.existFieldNames,newFieldNames)





                    e1=numel(this.existFieldNames);
                    e2=numel(newFieldNames);
                    n1=1;
                    n2=1;
                    diffFields1=cell(1,e1);
                    diffFields2=cell(1,e2);
                    cellNum1=1;
                    cellNum2=1;
                    while n1<=e1&&n2<=e2


                        sl1=numel(this.existFieldNames{n1});
                        sl2=numel(newFieldNames{n2});
                        sLen=min(sl1,sl2);
                        cmp=0;
                        for i=1:sLen
                            ch1=this.existFieldNames{n1}(i);
                            ch2=newFieldNames{n2}(i);
                            if ch1>ch2
                                cmp=1;
                                break;
                            elseif ch1<ch2
                                cmp=-1;
                                break;
                            end
                        end
                        if cmp==0
                            cmp=sl1-sl2;
                        end


                        if cmp==0
                            n1=n1+1;
                            n2=n2+1;
                        elseif cmp>0

                            diffFields2{cellNum2}=newFieldNames{n2};
                            cellNum2=cellNum2+1;
                            n2=n2+1;
                        else

                            diffFields1{cellNum1}=this.existFieldNames{n1};
                            cellNum1=cellNum1+1;
                            n1=n1+1;
                        end
                    end

                    for i=n1:e1
                        diffFields1{cellNum1}=this.existFieldNames{n1};
                        cellNum1=cellNum1+1;
                    end
                    for i=n2:e2
                        diffFields1{cellNum2}=newFieldNames{n2};
                        cellNum2=cellNum2+1;
                    end
                    diffFields1(cellNum1:e1)=[];
                    diffFields2(cellNum2:e2)=[];

                    for i=1:length(diffFields1)
                        fieldName=diffFields1{i};


                        newArrayLength=length(newStructArray);
                        defaultValue=cell(1,newArrayLength);
                        defaultValue(:)={''};

                        [newStructArray.(fieldName)]=defaultValue{:};
                    end






                    for i=1:length(diffFields2)
                        fieldName=diffFields2{i};


                        existArrayLength=length(this.results);
                        defaultValue=cell(1,existArrayLength);
                        defaultValue(:)={''};

                        [this.results.(fieldName)]=defaultValue{:};
                    end

                    if~isempty(diffFields2)
                        this.existFieldNames=union(this.existFieldNames,diffFields2);
                    end
                end


                numOfNewResults=numel(newStructArray);
                for i=1:numOfNewResults
                    this.results(end+1)=newStructArray(i);
                end
            else
                this.results=newStructArray;
                this.existFieldNames=sort(fieldnames(newStructArray));
            end
        end

        function appendArrayWithoutFieldOrder2(this,newStructArray)
            if isempty(newStructArray)||~slfeature('FindSystemSupportForReturningPropMatches')
                return;
            end

            if~isfield(newStructArray,'propertycollection')
                defaultValue=cell(1,length(newStructArray));
                defaultValue(:)={''};
                [newStructArray.propertycollection]=defaultValue{:};
            end

            if(~isempty(this.results))
                newFieldNames=fieldnames(newStructArray);

                newFieldNames=setdiff(newFieldNames,{'propertycollection'});

                if~isequal(this.existFieldNames,newFieldNames)



                    fieldsMissingInNewResults=setdiff(this.existFieldNames,newFieldNames);
                    numOfFieldsMissingInNewResults=length(fieldsMissingInNewResults);
                    for i=1:numOfFieldsMissingInNewResults
                        fieldName=fieldsMissingInNewResults{i};


                        newArrayLength=length(newStructArray);
                        defaultValue=cell(1,newArrayLength);
                        defaultValue(:)={''};

                        [newStructArray.(fieldName)]=defaultValue{:};
                    end




                    fieldsMissingInExistingResult=setdiff(newFieldNames,this.existFieldNames);
                    numOfFieldsMissingInExistingResult=length(fieldsMissingInExistingResult);
                    for i=1:numOfFieldsMissingInExistingResult
                        fieldName=fieldsMissingInExistingResult{i};


                        existArrayLength=length(this.results);
                        defaultValue=cell(1,existArrayLength);
                        defaultValue(:)={''};

                        [this.results.(fieldName)]=defaultValue{:};
                    end

                    if~isempty(fieldsMissingInExistingResult)


                        this.existFieldNames=union(this.existFieldNames,fieldsMissingInExistingResult);
                    end
                end


                numOfNewResults=numel(newStructArray);
                for i=1:numOfNewResults
                    this.results(end+1)=newStructArray(i);
                    if~isKey(this.handleToResultIdx,newStructArray(i).Handle)
                        this.handleToResultIdx(newStructArray(i).Handle)=numel(this.results);
                    end
                end
            else
                this.results=newStructArray;
                numOfNewResults=numel(this.results);
                for i=1:numOfNewResults
                    if~isKey(this.handleToResultIdx,this.results(i).Handle)
                        this.handleToResultIdx(this.results(i).Handle)=i;
                    end
                end
                this.existFieldNames=sort(fieldnames(newStructArray));
                this.existFieldNames=setdiff(this.existFieldNames,{'propertycollection'});
            end
        end

        function parentsType=getParentsType(this,parentPath)
            parentsType='';

            if isempty(parentPath)
                return;
            end

            if isKey(this.parentToHierarchyType,parentPath)
                parentsType=this.parentToHierarchyType(parentPath);
                return;
            end

            curPath=parentPath;
            while true
                if isKey(this.parentToHierarchyType,curPath)
                    parentsType=append('/',this.parentToHierarchyType(curPath),parentsType);
                    this.parentToHierarchyType(parentPath)=parentsType;
                    break;
                else
                    curHandle=getSimulinkBlockHandle(curPath,true);
                    curElemType='Subsystem';
                    if(curHandle~=-1&&strcmp(get_param(curHandle,'blockType'),'SubSystem')...
                        &&~isempty(get_param(curHandle,'ReferencedSubsystem')))
                        curElemType='Subsystem Reference';
                    end
                    parentsType=append('/',curElemType,parentsType);

                    pos=strfind(curPath,'/');
                    if isempty(pos)
                        this.parentToHierarchyType(parentPath)=parentsType;
                        break;
                    else
                        curPath=extractBefore(curPath,pos(end));
                    end
                end
            end
        end
    end

    methods(Access=public,Static)

        function out=globalAdvancedParameter(data)
            persistent gAdvancedParameter;
            if nargin
                out=gAdvancedParameter;
                gAdvancedParameter=data;
                return;
            end
            out=gAdvancedParameter;
        end
    end
end
