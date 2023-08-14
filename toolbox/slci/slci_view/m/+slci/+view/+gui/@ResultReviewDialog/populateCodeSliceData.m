


function populateCodeSliceData(obj)


    dm=obj.getDataManager();
    if isempty(dm)
        return;
    end


    obj.fCodeSliceData={};

    functionNames=containers.Map('KeyType','char','ValueType','any');



    funcBodyReader=dm.getReader('FUNCTIONBODY');
    funcBodyKeys=funcBodyReader.getKeys();
    for i=1:numel(funcBodyKeys)
        funcScope=funcBodyKeys(i);
        funcObj=funcBodyReader.getObjects(funcScope);
        assert(iscell(funcScope));
        assert(numel(funcObj)==1);
        assert(iscell(funcObj));
        functionNames(funcScope{1})=funcObj{1}.getName();
    end

    reviewReader=dm.getReader('CODESLICE');
    codeSliceObjKeys=reviewReader.getKeys();
    codeSliceObjects=reviewReader.getObjects(codeSliceObjKeys);

    codeReader=dm.getReader('CODE');

    parents=containers.Map('KeyType','char','ValueType','any');

    id_idx=1;
    for i=1:numel(codeSliceObjects)
        clObj=codeSliceObjects{i};
        name=clObj.getName();
        if strcmp(name,'NOT_AN_OUTPUT')
            continue;
        end
        status=clObj.getStatus();
        contributeSrc=clObj.getContributingSources();
        fscope=clObj.getFunctionScope();
        if iscell(fscope)
            fscope=fscope{1};
        end

        codelines=obj.getCodeLines(contributeSrc);


        codeObj=codeReader.getObjects(clObj.getSourceObject);
        blockTrace=obj.getBlockTrace(codeObj);

        data={};
        data.id=id_idx;
        data.name=name;

        if isKey(functionNames,fscope)
            scope=functionNames(fscope);
        else

            scope='';
        end

        data.codelines=codelines;
        data.status=status;
        data.parent=scope;
        data.scope=scope;
        data.blocktrace=blockTrace;

        id_idx=id_idx+1;

        [id_idx,data,obj.fCodeSliceData]=addParentData(obj.fCodeSliceData,data,id_idx,parents);

        obj.fCodeSliceData{end+1}=data;
    end


    codeObjKeys=codeReader.getKeys();
    codeObjects=codeReader.getObjects(codeObjKeys);
    for i=1:numel(codeObjects)
        codeObj=codeObjects{i};
        status=codeObj.getStatus();
        isWarning=isWarningStatus(status);

        isJustified=strcmpi(status,'JUSTIFIED');
        if(isWarning||isJustified)&&~isempty(codeObj.getSliceNames)
            data={};
            data.id=id_idx;
            data.name='NOT_AN_OUTPUT';
            data.status=status;
            lineTrace=strsplit(codeObj.getKey,filesep);

            data.codelines=lineTrace{end};
            fscope=codeObj.getFunctionScope();
            if iscell(fscope)
                fscope=fscope{1};
            end
            assert(isKey(functionNames,fscope));

            data.scope=functionNames(fscope);
            data.parent=functionNames(fscope);

            obj.fCodeSliceData{end+1}=data;

            id_idx=id_idx+1;
        end
    end







































    kscope=keys(functionNames);
    for i=1:numel(kscope)
        data.id=id_idx;
        ks=kscope{i};
        data.name=functionNames(ks);
        data.codelines='';
        data.status='';
        data.parent='';
        data.scope=functionNames(ks);
        data.blocktrace='';

        obj.fCodeSliceData{end+1}=data;

        id_idx=id_idx+1;
    end

end


function[id_idx,data,codeSliceData]=addParentData(codeSliceData,data,id_idx,parents)
    name=data.name;

    pos=getParentPos(name);

    if(pos>0)
        parent_name=name(1:pos-1);
        key=[data.parent,'_',parent_name];

        if isKey(parents,key)

            data.parent=parent_name;

            return;
        end


        parents(key)='';


        parent_data.id=id_idx;
        parent_data.name=parent_name;
        parent_data.codelines='';
        parent_data.status='';
        parent_data.parent=data.parent;
        parent_data.scope=data.scope;
        parent_data.blocktrace='';
        data.parent=parent_name;
        id_idx=id_idx+1;

        [id_idx,parent_data,codeSliceData]=addParentData(codeSliceData,parent_data,id_idx,parents);

        codeSliceData{end+1}=parent_data;
    end

end




function pos=getParentPos(name)


    pos1=strfind(name,'[');
    if isempty(pos1)
        brac_pos=0;
    else
        brac_pos=pos1(end);
    end


    pos2=strfind(name,'.');
    if isempty(pos2)
        field_pos=0;
    else
        field_pos=pos2(end);
    end

    pos=max(brac_pos,field_pos);
end



function out=isWarningStatus(status)
    out=strcmpi(status,'PARTIALLY_PROCESSED')...
    ||strcmpi(status,'WAW')...
    ||strcmpi(status,'MANUAL')...
    ||strcmpi(status,'UNABLE_TO_PROCESS');
end


function out=isFailedStatus(status)
    out=strcmpi(status,'FAILED_TO_VERIFY');
end