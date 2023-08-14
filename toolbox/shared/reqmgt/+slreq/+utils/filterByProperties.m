function objs=filterByProperties(objs,varargin)




    if isempty(objs)
        return;
    end

    if isempty(varargin)
        return;
    end

    if mod(numel(varargin),2)>0
        error(message('Slvnv:reqmgt:rmi:WrongArgumentNumber'));
    end

    [filter,custAttrMap]=argsToFilterStruct(varargin,objs(1));

    props=fields(filter);
    isRemove=false(size(objs));
    for i=1:numel(objs)
        for j=1:length(props)
            prop=props{j};
            objValue=objs(i).(prop);
            wantedValue=filter.(prop);
            if ischar(objValue)
                if isempty(wantedValue)

                    if~isempty(objValue)
                        isRemove(i)=true;
                        break;
                    end
                elseif wantedValue(1)=='~'
                    if isempty(regexp(objValue,wantedValue(2:end),'once'))
                        isRemove(i)=true;
                        break;
                    end
                else
                    if~strcmpi(objValue,wantedValue)
                        isRemove(i)=true;
                        break;
                    end
                end
            elseif iscell(objValue)

                if isempty(wantedValue)

                    if~isempty(objValue)
                        isRemove(i)=true;
                        break;
                    end
                elseif~any(strcmp(objValue,wantedValue))

                    isRemove(i)=true;
                    break;
                end
            else


                if~isequal(objValue,wantedValue)
                    isRemove(i)=true;
                    break;
                end
            end
        end
        if custAttrMap.Count~=0

            keys=custAttrMap.keys;
            for j=1:length(keys)
                thisPropName=keys{j};
                wantedValue=custAttrMap(thisPropName);

                if isa(objs(i),'slreq.data.Requirement')||isa(objs(i),'slreq.data.Link')


                    objValue=objs(i).getAttribute(thisPropName,true);
                elseif isa(objs(i),'slreq.Requirement')||isa(objs(i),'slreq.Reference')||isa(objs(i),'slreq.Justification')

                    objValue=objs(i).getAttribute(thisPropName);
                else

                    isRemove(i)=true;
                    break;
                end

                if isempty(objValue)&&~isempty(wantedValue)

                    isRemove(i)=true;
                    break;
                elseif ischar(objValue)
                    if~isempty(wantedValue)&&wantedValue(1)=='~'

                        if isempty(regexpi(objValue,wantedValue(2:end),'once'))
                            isRemove(i)=true;
                            break;
                        end

                    else
                        if~isequal(objValue,wantedValue)
                            isRemove(i)=true;
                            break;
                        end
                    end
                elseif isdatetime(objValue)

                    if~isequal(wantedValue,datestr(objValue,'Local'))
                        isRemove(i)=true;
                        break;
                    end
                elseif~ischar(objValue)&&~isequal(wantedValue,objValue)

                    isRemove(i)=true;
                    break;
                end
            end
        end

    end
    objs(isRemove)=[];
end

function[filterStruct,custAttrMap]=argsToFilterStruct(filtersArray,firstObj)
    filterStruct=struct([]);
    custAttrMap=containers.Map('KeyType','char','ValueType','Any');
    commonAttributeForData={'sid','summary','description','rationale','revision',...
    'createdBy','createdOn','modifiedBy','modifiedOn','keywords'};

    dataObj=firstObj;



    switch class(firstObj)
    case 'slreq.data.Requirement'
        if firstObj.external
            builtinAttributes={'index','customId','synchronizedOn',...
            'artifactUri','artifactId','typeName'};
            propNameFiler=containers.Map(...
            {'artifact','custom id','id','filerevision','type','reqtype'},...
            {'artifactUri','customId','artifactId','revision','typeName','typeName'});
        else
            builtinAttributes={'index','customId','id','typeName'};
            propNameFiler=containers.Map(...
            {'custom id','filerevision','type','reqtype'},...
            {'customId','revision','typeName','typeName'});
        end
        builtinAttributes=[commonAttributeForData,builtinAttributes];
    case 'slreq.data.RequirementSet'
        builtinAttributes={'CustomAttributeNames','filepath','name'};
        builtinAttributes=[commonAttributeForData,builtinAttributes];
        propNameFiler=containers.Map({'filename'},{'filepath'});
    case 'slreq.data.Link'


        builtinAttributes={'type'};
        builtinAttributes=[commonAttributeForData,builtinAttributes];
        propNameFiler=containers.Map({'filename','linktype'},{'filepath','type'});
    case 'slreq.data.LinkSet'
        builtinAttributes={'artifact','domain','filepath','name'};
        builtinAttributes=[commonAttributeForData,builtinAttributes];
        propNameFiler=containers.Map({'filename'},{'filepath'});
    case{'slreq.Requirement','slreq.Justification'}


        builtinAttributes={'SID','FileRevision','CreatedOn','ModifiedOn',...
        'CreatedBy','ModifiedBy','Dirty',...
        'Id','Summary','Description','Rationale','Keywords','Type'};
        propNameFiler=containers.Map({'reqtype'},{'type'});
        dataObj=localApiToData(firstObj);
    case 'slreq.Reference'


        builtinAttributes={'SID','FileRevision','ModifiedOn',...
        'UpdatedOn','Dirty',...
        'Id','Summary','Description','Rationale','Keywords','type',...
        'Artifact','Domain'};
        propNameFiler=containers.Map({'reqtype'},{'type'});
        dataObj=localApiToData(firstObj);
    otherwise
        error('Internal error. slreq.data.* object should be given');
    end

    for i=1:2:length(filtersArray)

        paramName=filtersArray{i};
        paramValue=filtersArray{i+1};
        loweredParamName=lower(filtersArray{i});

        if isKey(propNameFiler,loweredParamName)


            paramName=propNameFiler(loweredParamName);
            loweredParamName=lower(paramName);
        end

        if strcmp(loweredParamName,'sid')
            paramValue=ensureNumeric(paramValue);
        end

        if strcmp(loweredParamName,'revision')&&ischar(paramValue)

            paramValue=str2double(paramValue);
        end

        if any(strcmp(loweredParamName,{'createdon','modifiedon','updatedon'}))

            x=datetime(paramValue,'Locale','system');%#ok<NASGU>
        end

        idx=find(strcmp(lower(builtinAttributes),loweredParamName));%#ok<STCI>
        if~isempty(idx)


            paramName=builtinAttributes{idx};
            if isempty(filterStruct)
                filterStruct=struct(paramName,paramValue);
            else
                filterStruct.(paramName)=paramValue;
            end
        else



            if~dataObj.hasRegisteredAttribute(paramName)
                error(message('Slvnv:slreq:NoSuchAttribute'));
            end



            paramValue=dataObj.validateAttributeForType(paramName,paramValue);

            custAttrMap(paramName)=paramValue;
        end
    end
end

function out=ensureNumeric(in)
    if ischar(in)&&~isempty(in)
        if in(1)=='#'
            in=in(2:end);
        end
        out=str2num(in);%#ok<ST2NM>
        if isempty(out)
            error('invalid value: %s',in);
        end
    else
        out=in;
    end
end

function dataObj=localApiToData(apiObj)
    reqSetName=apiObj.reqSet.Name;
    reqData=slreq.data.ReqData.getInstance();
    reqSet=reqData.getReqSet(reqSetName);
    dataObj=reqSet.getRequirementById(num2str(apiObj.SID));
end
