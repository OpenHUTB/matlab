function[ret,name,retIdx,found,searchOpts,elementCache]=locGet(this,elementCache,searchArg,varargin)



    narginchk(2,inf);
    if nargin>2
        searchArg=convertStringsToChars(searchArg);
    end
    if nargin>3
        [varargin{:}]=convertStringsToChars(varargin{:});
    end


    if length(this)~=1
        Simulink.SimulationData.utError('InvalidDatasetArray');
    end

    try

        if nargin==3&&isnumeric(searchArg)
            if~isscalar(searchArg)

                Simulink.SimulationData.utError(...
                'InvalidDatasetGetIndex',this.numElements());
            else

                if this.Storage_.numElements==0
                    Simulink.SimulationData.utError('InvalidDatasetGetIndexEmpty');
                end

                this.Storage_.checkIdxRange(searchArg,this.numElements(),...
                'InvalidDatasetGetIndex');
            end


            [ret,elementCache]=locGetElements(this.Storage_,searchArg,elementCache);

            name='';
            if~isa(ret,'matlab.io.datastore.SimulationDatastore')
                if isfield(ret,'Name')||isprop(ret,'Name')
                    name=ret.Name;
                end
            else


                name=this.Storage_.getMetaData(searchArg,'Name');
            end

            if isa(ret,'Simulink.SimulationData.TransparentElement')
                ret=ret.Values;
            end
            retIdx=searchArg;

            found=true;
            searchOpts=searchArg;
            return;


        else


            ret=Simulink.SimulationData.Dataset;


            try
                searchOpts=locParseFindOptions(searchArg,varargin{:});
            catch me
                throwAsCaller(me);
            end
            nestedOpts=locGetNestedSearchOpts(varargin);


            storage=this.getStorage();
            if storage.ReturnAsDatastore
                [ret,retIdx,bRecurseFound,elementCache]=locScanStruct(storage,elementCache,...
                searchOpts,nestedOpts,ret);
            else
                [ret,retIdx,bRecurseFound]=locScanObject(storage,...
                searchOpts,nestedOpts,ret);
            end



            if bRecurseFound
                retIdx=[];
            end


            if(ret.getLength()>0)
                found=true;
            else
                found=false;
            end


            name='';
            if~strcmpi(searchOpts.returnType,'Dataset')
                if(ret.getLength()==1)
                    [ret,name]=ret.getElement(1);
                elseif(ret.getLength()==0)
                    ret=[];
                end
            end

        end
    catch me
        throwAsCaller(me);
    end
end



function ret=locParseFindOptions(searchArg,varargin)


    ret.searchArg=searchArg;
    ret.returnType='';
    ret.delimChar=[];
    ret.propName='';


    num_opts=length(varargin);
    val_processed=false;
    for idx=1:num_opts


        if val_processed
            val_processed=false;
            continue;
        end


        if strcmpi(varargin{idx},'-blockpath')
            if~isempty(ret.propName)&&~strcmp(ret.propName,'BlockPath')
                Simulink.SimulationData.utError(...
                'InvalidDatasetGetDuplicateOpt',...
                'Property');
            end
            ret.propName='BlockPath';
            continue;
        end


        val_processed=true;


        if strcmpi(varargin{idx},'Property')
            if idx==num_opts||~ischar(varargin{idx+1})
                Simulink.SimulationData.utError(...
                'InvalidDatasetFindArgsProp');
            end
            if~isempty(ret.propName)&&~strcmp(ret.propName,varargin{idx+1})
                Simulink.SimulationData.utError(...
                'InvalidDatasetGetDuplicateOpt',...
                varargin{idx});
            end
            ret.propName=varargin{idx+1};


        elseif strcmpi(varargin{idx},'Return')
            if idx==num_opts||~ischar(varargin{idx+1})||...
                ~any(strcmpi(varargin{idx+1},{'Dataset','Element'}))
                Simulink.SimulationData.utError(...
                'InvalidDatasetFindArgsReturn');
            end
            if~isempty(ret.returnType)&&~strcmp(ret.returnType,varargin{idx+1})
                Simulink.SimulationData.utError(...
                'InvalidDatasetGetDuplicateOpt',...
                varargin{idx});
            end
            ret.returnType=varargin{idx+1};


        elseif strcmpi(varargin{idx},'Delimiter')
            if idx==num_opts||~ischar(varargin{idx+1})
                Simulink.SimulationData.utError(...
                'InvalidDatasetFindArgsDelim');
            end
            if~isempty(ret.delimChar)&&~strcmp(ret.delimChar,varargin{idx+1})
                Simulink.SimulationData.utError(...
                'InvalidDatasetGetDuplicateOpt',...
                varargin{idx});
            end
            ret.delimChar=varargin{idx+1};


        else
            Simulink.SimulationData.utError(...
            'InvalidDatasetFindArgs',...
            varargin{idx});
        end
    end



    if isempty(varargin)&&iscell(ret.searchArg)&&length(ret.searchArg)==1
        ret.searchArg=ret.searchArg{1};
        ret.returnType='Dataset';
    end


    if isempty(ret.propName)&&isa(ret.searchArg,'Simulink.SimulationData.BlockPath')
        ret.propName='BlockPath';
    end


    if isempty(ret.propName)
        if~ischar(ret.searchArg)
            Simulink.SimulationData.utError('InvalidDatasetFindNameArg');
        end
        if isempty(ret.delimChar)
            ret.searchName=ret.searchArg;
            ret.remainingName='';
        else
            [ret.searchName,ret.remainingName]=...
            strtok(ret.searchArg,ret.delimChar);
        end
    elseif~isempty(ret.delimChar)
        Simulink.SimulationData.utError('InvalidDatasetFindNonNameDelim');
    else
        ret.searchName='';
        ret.remainingName='';
    end

end



function nestedOpts=locGetNestedSearchOpts(origOpts)




    nestedOpts=origOpts;


    num_opts=length(origOpts);
    val_processed=false;
    for idx=1:num_opts
        if val_processed
            val_processed=false;
            continue;
        end
        if strcmpi(origOpts{idx},'-blockpath')
            continue;
        end
        val_processed=true;
        if strcmpi(origOpts{idx},'Return')
            nestedOpts{idx+1}='Dataset';
            return;
        end
    end


    nestedOpts=[nestedOpts,{'Return','Dataset'}];
end


function bRet=locElementHasProp(el,prop,val)%#ok<INUSL,INUSD>

    try
        bRet=isequal(el.(prop),val);
    catch me %#ok<NASGU>
        bRet=false;
    end
end


function[ret,elementCache]=locGetElements(storage,index,elementCache)

    if~isempty(elementCache)
        if~isempty(elementCache{index})
            ret=elementCache{index};
        else
            ret=storage.getElements(index);
            elementCache{index}=ret;
        end
    else
        ret=storage.getElements(index);
    end
end


function[ret,retIdx,bRecurseFound,elementCache]=locScanStruct(storage,elementCache,...
    searchOpts,nestedOpts,ret)
    bRecurseFound=false;
    retIdx=[];
    elements=storage.utGetElements();
    n=numel(elements);
    for elIndx=1:n
        el=elements{elIndx};

        if isempty(searchOpts.propName)&&...
            strcmp(el.Name,searchOpts.searchName)

            if isempty(searchOpts.remainingName)
                [elVal,elementCache]=locGetElements(storage,elIndx,elementCache);
                ret=ret.add(elVal,el.Name);
                retIdx=[retIdx,elIndx];%#ok<AGROW>
            elseif strcmp(el.ElementType,'dataset')
                [elVal,elementCache]=locGetElements(storage,elIndx,elementCache);
                [nestedFind]=...
                locGet(elVal,{},searchOpts.remainingName,nestedOpts{:});
                if~isempty(nestedFind)&&nestedFind.getLength()
                    ret=ret.concat(nestedFind);
                    bRecurseFound=true;
                end
            end


        elseif isfield(el,'BlockPath')&&...
            strcmpi(searchOpts.propName,'BlockPath')

            bpath=Simulink.SimulationData.BlockPath(searchOpts.searchArg);
            if Simulink.SimulationData.BlockPath(el.BlockPath).pathIsLike(bpath);
                [elVal,elementCache]=locGetElements(storage,elIndx,elementCache);
                ret=ret.add(elVal);
                retIdx=[retIdx,elIndx];%#ok<AGROW>
            end


        elseif~isempty(searchOpts.propName)
            if strcmp(el.ElementType,'dataset')
                [elVal,elementCache]=locGetElements(storage,elIndx,elementCache);
                [nestedFind]=...
                locGet(elVal,{},searchOpts.searchArg,nestedOpts{:});
            else
                nestedFind=[];
            end
            if~isempty(nestedFind)&&nestedFind.getLength()
                ret=ret.concat(nestedFind);
                bRecurseFound=true;
            elseif locElementHasProp(el,...
                searchOpts.propName,searchOpts.searchArg)
                [elVal,elementCache]=locGetElements(storage,elIndx,elementCache);
                ret=ret.add(elVal,el.Name);
                retIdx=[retIdx,elIndx];%#ok<AGROW>
            end
        end
    end
end


function[ret,retIdx,bRecurseFound]=locScanObject(storage,...
    searchOpts,nestedOpts,ret)

    bRecurseFound=false;
    retIdx=[];
    for elIndx=1:storage.numElements
        el=storage.getElements(elIndx);
        if isa(el,'Simulink.SimulationData.TransparentElement')
            elVal=el.Values;
        else
            elVal=el;
        end


        if isempty(searchOpts.propName)&&...
            strcmp(el.Name,searchOpts.searchName)

            if isempty(searchOpts.remainingName)
                ret=ret.add(el);
                retIdx=[retIdx,elIndx];%#ok<AGROW>
            elseif isa(el,'Simulink.SimulationData.Dataset')
                [nestedFind]=...
                locGet(el,{},searchOpts.remainingName,nestedOpts{:});
                if~isempty(nestedFind)&&nestedFind.getLength()
                    ret=ret.concat(nestedFind);
                    bRecurseFound=true;
                end
            elseif isa(el,'Simulink.SimulationData.Element')
                nestedFind=el.find(searchOpts.remainingName,...
                nestedOpts{:});
                if~isempty(nestedFind)&&nestedFind.getLength()
                    ret=ret.concat(nestedFind);
                    bRecurseFound=true;
                end
            end


        elseif isa(el,'Simulink.SimulationData.BlockData')&&...
            strcmpi(searchOpts.propName,'BlockPath')

            bpath=Simulink.SimulationData.BlockPath(searchOpts.searchArg);
            if el.isFromBlock(bpath)
                ret=ret.add(el);
                retIdx=[retIdx,elIndx];%#ok<AGROW>
            end


        elseif~isempty(searchOpts.propName)
            if isa(el,'Simulink.SimulationData.Dataset')
                [nestedFind]=...
                locGet(el,{},searchOpts.searchArg,nestedOpts{:});
            elseif isa(el,'Simulink.SimulationData.Element')
                nestedFind=...
                el.find(searchOpts.searchArg,nestedOpts{:});
            else
                nestedFind=[];
            end
            if~isempty(nestedFind)&&nestedFind.getLength()
                ret=ret.concat(nestedFind);
                bRecurseFound=true;
            elseif locElementHasProp(elVal,...
                searchOpts.propName,searchOpts.searchArg)
                ret=ret.add(el);
                retIdx=[retIdx,elIndx];%#ok<AGROW>
            end
        end
    end
end

