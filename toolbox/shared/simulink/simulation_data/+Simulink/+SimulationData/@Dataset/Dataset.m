classdef Dataset<Simulink.SimulationData.Element















































    properties(Constant,Access=protected,Transient)
        CurrentVersion_=3;
    end

    properties(Access=protected,Hidden=true)







        Version_=Simulink.SimulationData.Dataset.CurrentVersion_;
    end

    properties(Access=protected,Hidden,Transient)



        Storage_=[];
    end

    properties(Access=protected,Hidden=true)

Elements
    end

    properties(Dependent,Hidden)
        ReturnAsDatastoreForDatasetRef=false
    end

    properties(Transient,Hidden)

        ExportToPrev_=false;
    end


    methods(Access=private)

        this=copyStorageIfNeededBeforeWrite(this)

        function verifyDatasetIsScalar(this)
            if~isscalar(this)
                Simulink.SimulationData.utError('InvalidDatasetArray');
            end
        end
    end

    methods

        function this=Dataset(varargin)
























            [varargin{:}]=convertStringsToChars(varargin{:});


            if nargin==1&&isa(varargin{1},'Simulink.sdi.internal.DatasetStorage')
                this.Storage_=varargin{1};
                return
            end

            this.Storage_=Simulink.SimulationData.Storage.RamDatasetStorage;

            if nargin>0
                try


                    vars=locGetCellOfVars(varargin{:});




                    if isequal(length(vars),1)
                        this.Name=inputname(1);
                    else
                        Simulink.SimulationData.utError(...
                        'DatasetConstructorMoreThanOneVariable');
                    end


                    this=this.convertToDataset(...
                    vars,varargin{length(vars)+1:end});

                catch me
                    throw(me);
                end

            end
        end

        function this=set.ReturnAsDatastoreForDatasetRef(this,newVal)
            this.Storage_.ReturnAsDatastore=newVal;
        end
        function ret=get.ReturnAsDatastoreForDatasetRef(this)
            if isa(this.Storage_,...
                'Simulink.SimulationData.Storage.MatFileDatasetStorage')
                ret=this.Storage_.ReturnAsDatastore;
            else
                ret=false;
            end
        end

        function ret=get.Elements(this)




            ret={};
            if this.ExportToPrev_
                numEl=this.numElements;
                ret=cell(1,numEl);
                for idx=1:numEl
                    ret{idx}=this.get(idx);
                end
            end
        end

        function this=set.Elements(this,val)


            if~isempty(val)
                this=this.utSetElements(val);
            end
        end


        this=addElement(this,varargin);
        tt=extractTimetable(ds,varargin);
        [elementVal,name,retIdx]=get(this,searchArg,varargin);
        [elementVal,name,retIdx]=getElement(this,searchArg,varargin);
        elemNames=getElementNames(this);
        [dsout,retIndex]=find(this,searchArg,varargin);
        nelem=numElements(this);
        varargout=plot(this,varargin);
        this=setElement(this,idx,element,name);
        this=removeElement(this,idx);
        this=concat(this,val);
        exportToPreviousRelease(this,matFileName,varName,varargin);


        function out=copy(this)


            n=numel(this);
            out=this;
            if n>1
                for idx=1:n
                    tmpThis=this(idx);
                    tmpOut=tmpThis;
                    nEl=tmpThis.numElements;
                    elements=tmpThis.Storage_.utGetElements();
                    for elIdx=1:nEl
                        tmpOut=tmpOut.setElement(...
                        elIdx,Simulink.SimulationData.utCopyRecurse(elements{elIdx}));
                    end
                    out(idx)=tmpOut;
                end
            elseif n==1
                nEl=this.numElements;
                elements=this.Storage_.utGetElements();
                for elIdx=1:nEl
                    out=out.setElement(elIdx,Simulink.SimulationData.utCopyRecurse(elements{elIdx}));
                end
            end
        end
    end


    methods(Hidden=true)


        disp(this);
        displayElements(this);
        [equal,mismatches]=compare(this,other,varargin);
        this=convertToDataset(this,vars,varargin);
        [ret,name,retIdx,found,searchOpts,elementCache]=...
        locGet(this,elementCache,searchArg,varargin);
        [ret,name,retIdx,elementCache]=...
        locGetWrapperWithNotFoundWarning(this,elementCache,searchArg,varargin);
        this=addElementWithoutChecking(this,varargin);
        ret=isequal(this,rhs);
        ret=isequaln(this,rhs);

        function storage=getStorage(this,varargin)
            if isempty(varargin)
                bRetMemResident=true;
            else
                bRetMemResident=varargin{1};
            end

            if bRetMemResident&&isa(this.Storage_,'Simulink.sdi.internal.DatasetStorage')
                storage=getMemoryResidentStorage(this.Storage_);
            else
                storage=this.Storage_;
            end
        end


        function nelem=getLength(this)






            this.verifyDatasetIsScalar;
            nelem=this.Storage_.numElements();
        end


        function elementVal=getElementByIndex(this,idx)


            this.verifyDatasetIsScalar;



            elementVal=this.Storage_.getElements(idx);
            if isa(elementVal,'Simulink.SimulationData.TransparentElement')
                elementVal=elementVal.Values;
            end

        end


        function metaVal=getElementMetaDataByIndex(this,idx,prop)


            this.verifyDatasetIsScalar;
            try
                metaVal=this.Storage_.getMetaData(idx,prop);
            catch me
                throwAsCaller(me);
            end
        end


        function version=getVersion(this)
            version=this.Version_;
        end



        function this=sortElements(this)
            this=copyStorageIfNeededBeforeWrite(this);
            this.Storage_=this.Storage_.sortElements();
        end


        function this=add(this,varargin)

            this=this.addElement(varargin{:});
            if nargout<1
                msg=message(...
                'SimulationData:Objects:DatasetUpdateNoLHS',...
                'addElement');
                warning(msg);
            end
        end



        function this=remove(this,idx)

            narginchk(2,2);
            this=this.removeElement(idx);
            if nargout<1
                msg=message(...
                'SimulationData:Objects:DatasetUpdateNoLHS',...
                'removeElement');
                warning(msg);
            end
        end


        function this=utfillfromstruct(this,datasetStruct)
            if~isempty(datasetStruct)
                assert(this.Storage_.numElements()==0);
                if strcmp(...
                    datasetStruct.DatasetStorageType,...
'RamDatasetStorage'...
                    )
                    this.Storage_=...
                    Simulink.SimulationData.Storage.RamDatasetStorage;
                else
                    assert(...
                    strcmp(...
                    datasetStruct.DatasetStorageType,...
'MatFileDatasetStorage'...
                    )...
                    );
                    this.Storage_=...
                    Simulink.SimulationData.Storage.MatFileDatasetStorage;
                end
                this.Storage_=...
                this.Storage_.utfillfromstruct(datasetStruct.Dataset);
                this.Name=datasetStruct.Dataset.Name;
            end
        end


        function this=utSetElements(this,elements)



            this.Storage_=this.Storage_.utSetElements(elements);
        end


        function out=toStructForSimState(this,varargin)
            out=[];
            try
                for eIdx=1:this.numElements()
                    eVal=this.Storage_.getElements(eIdx);
                    validateattributes(eVal,...
                    {'Simulink.SimulationData.State'},{'scalar'});
                    out=[out,eVal.toStructForSimState(varargin{:})];%#ok<AGROW>
                end
            catch ex
                throwAsCaller(ex)
            end
        end


        function ret=saveobj(this)
            if this.ExportToPrev_
                ret=this;
            else
                ret.Name=this.Name;
                ret.Version=this.Version_;


                if isa(this.Storage_,'Simulink.sdi.internal.DatasetStorage')
                    this.Storage_=getMemoryResidentStorage(this.Storage_);
                end

                if isa(...
                    this.Storage_,...
'Simulink.SimulationData.Storage.RamDatasetStorage'...
                    )&&...
                    sigstream_mapi('getDatasetSaveR2')&&...
                    sigstream_mapi('isSavingToV73')
                    fileName=sigstream_mapi('getSavingToV73FileName');
                    ret.Storage=...
                    Simulink.SimulationData.Storage.MatFileDatasetStorage.createFromRamDatasetStorage(...
                    this.Storage_,...
fileName...
                    );
                else
                    ret.Storage=this.Storage_;
                end
            end
        end


        function answer=isRilDsDstCapable(this)
            answer=...
            isscalar(this)&&...
            isa(...
            this.Storage_,...
'Simulink.SimulationData.Storage.RamDatasetStorage'...
            )&&...
            this.Storage_.isRilDsDstCapable;
        end

        function this=convertTStoTTatLeaf(this)
            this=copyStorageIfNeededBeforeWrite(this);
            this.Storage_=this.Storage_.convertTStoTTatLeaf();
        end


        n=numArgumentsFromSubscript(obj,s,context);
        varargout=subsref(obj,s);
        A=subsasgn(A,s,varargin);


        function ind=end(obj,k,n)
            if numel(obj)==1
                numElements=obj.numElements;
            else
                numElements=-1;
            end
            szd=size(obj);
            if k<n
                nObj=szd(k);
            else
                nObj=prod(szd(k:end));
            end
            if numElements~=-1
                ind=Simulink.SimulationData.DatasetEndIndex(nObj,numElements);
            else
                ind=nObj;
            end
        end


        function idx=utGetIndexFromSubs(obj,s,isGet)
            if numel(obj)~=1
                Simulink.SimulationData.utError('InvalidDatasetArray');
            end

            isValidIndex=false;
            idx=0;
            len=obj.numElements();
            if iscell(s(1).subs)
                s(1).subs=obj.utReplaceBDatasetEndIndex(s(1).subs);
                if isscalar(s(1).subs)
                    idx=s(1).subs{1};
                    if isnumeric(idx)&&isscalar(idx)&&...
                        idx<=len+1&&idx>0
                        isValidIndex=true;
                    end
                end
            end
            if~isValidIndex
                if~isGet
                    Simulink.SimulationData.utError('InvalidDatasetSetIndex',len+1);
                else
                    Simulink.SimulationData.utError('InvalidDatasetGetIndex',len);
                end
            end
        end


    end


    methods(Static=true,Hidden=true)









        function obj=loadobj(var)
            if isstruct(var)
                obj=Simulink.SimulationData.Dataset;
                assert(isfield(var,'Name'));
                obj.Name=var.Name;
                if~isfield(var,'Version')
                    assert(isfield(var,'Elements'));
                    obj.Version_=3;
                    if~isempty(var.Elements)
                        obj.Storage_=obj.Storage_.utSetElements(var.Elements);
                    end
                else
                    assert(var.Version~=1);
                    assert(isfield(var,'Storage'));
                    if var.Version>Simulink.SimulationData.Dataset.CurrentVersion_
                        Simulink.SimulationData.utError('LoadingNewerVersionNotAllowed',...
                        'Simulink.SimulationData.Dataset');
                    end
                    obj.Version_=3;
                    if isa(var.Storage,...
                        'Simulink.SimulationData.Storage.MatFileDatasetStorage')&&...
                        sigstream_mapi('getFullLoadRecord')
                        for eIdx=1:var.Storage.numElements
                            obj=obj.addElement(var.Storage.getElements(eIdx));
                        end
                    else
                        obj.Storage_=var.Storage;
                    end
                end
            else
                assert(isa(var,'Simulink.SimulationData.Dataset'));
                if var.Version_>Simulink.SimulationData.Dataset.CurrentVersion_
                    Simulink.SimulationData.utError('LoadingNewerVersionNotAllowed',...
                    'Simulink.SimulationData.Dataset');
                end
                if isa(var.getStorage(false),...
                    'Simulink.SimulationData.Storage.MatFileDatasetStorage')&&...
                    sigstream_mapi('getFullLoadRecord')
                    obj=Simulink.SimulationData.Dataset;
                    obj.Name=var.Name;
                    for eIdx=1:var.getLength
                        obj=obj.addElement(var.getElement(eIdx));
                    end
                else
                    obj=var;
                end
            end
        end


        function this=utcreatefromstruct(datasetStruct)
            this=Simulink.SimulationData.Dataset;
            this=this.utfillfromstruct(datasetStruct);
        end


        function subs=utReplacePDatasetEndIndex(subs)
            n=numel(subs);
            for idx=1:n
                if isa(subs{idx},'Simulink.SimulationData.DatasetEndIndex')
                    subs{idx}=subs{idx}.pEnd;
                end
            end
        end


        function subs=utReplaceBDatasetEndIndex(subs)
            n=numel(subs);
            for idx=1:n
                if isa(subs{idx},'Simulink.SimulationData.DatasetEndIndex')
                    subs{idx}=subs{idx}.bEnd;
                end
            end
        end

        function isValid=isDatatypeAllowedInDataset(var)





            isValid=...
            ((isa(var,'Simulink.SimulationData.Element')||...
            isa(var,'timeseries')||...
            isa(var,'matlab.io.datastore.SimulationDatastore'))&&...
            isscalar(var))||...
            isa(var,'timetable')||...
            isa(var,'Simulink.Timeseries');

            if isValid
                return;
            end



            isValid=isequal(var,[])||...
            (isa(var,'double')&&ismatrix(var));
            if isValid
                return;
            end


            isValid=isequal(class(var),'struct');
        end

        function el=convertToTransparentElementIfNeeded(element,opt_name)


            try
                if Simulink.SimulationData.Dataset.utNeedsTransparentElement(element)
                    el=Simulink.SimulationData.TransparentElement;
                    el.Values=element;
                    if isempty(opt_name)
                        Simulink.SimulationData.utError('DatasetAddMissingName');
                    end
                else
                    el=element;
                end
                if~isempty(opt_name)
                    el.Name=opt_name{1};
                end
            catch me
                throwAsCaller(me);
            end
        end
    end

    methods(Static=true,Hidden=true,Access=private)

        function val=utNeedsTransparentElement(element)
            val=~isscalar(element)||(~isa(element,'Simulink.SimulationData.Element')&&...
            ~isa(element,'timeseries'))||...
            isempty(element);
        end


        function utPrivateCheck(name)





            switch name

            case 'Name'


            case{'ReturnAsDatastoreForDatasetRef',...
                'ExportToPrev_'}


            case{'Dataset',...
                'addElement',...
                'concat',...
                'exportToPreviousRelease',...
                'extractTimetable',...
                'find',...
                'get',...
                'getElement',...
                'getElementNames',...
                'numElements',...
                'plot',...
                'removeElement',...
                'setElement',...
                'copy'}



            case{'utGetIndexFromSubs',...
                'end',...
                'subsasgn',...
                'subsref',...
                'numArgumentsFromSubscript',...
                'convertTStoTTatLeaf',...
                'isRilDsDstCapable',...
                'saveobj',...
                'toStructForSimState',...
                'utSetElements',...
                'utfillfromstruct',...
                'remove',...
                'add',...
                'sortElements',...
                'getVersion',...
                'getElementMetaDataByIndex',...
                'getElementByIndex',...
                'getLength',...
                'getStorage',...
                'addElementWithoutChecking',...
                'locGet',...
                'locGetWrapperWithNotFoundWarning',...
                'convertToDataset',...
                'compare',...
                'disp',...
                'convertToTransparentElementIfNeeded',...
                'isDatatypeAllowedInDataset',...
                'utReplaceBDatasetEndIndex',...
                'utReplacePDatasetEndIndex',...
                'utcreatefromstruct',...
                'loadobj',...
                'empty'}

            otherwise
                id='MATLAB:noSuchMethodOrField';
                ME=MException(id,message(id,name,'Simulink.SimulationData.Dataset').getString);
                throw(ME);
            end
        end

    end
end




function vars=locGetCellOfVars(varargin)



    firstPrmIdx=find(cellfun(@(x)ischar(x),varargin),...
    1,'first');


    if isequal(firstPrmIdx,1)
        Simulink.SimulationData.utError(...
        'DatasetConstructorInvalidArg');
    end



    if isempty(firstPrmIdx)
        vars=varargin;
    else
        vars=varargin(1:firstPrmIdx-1);
    end
end



