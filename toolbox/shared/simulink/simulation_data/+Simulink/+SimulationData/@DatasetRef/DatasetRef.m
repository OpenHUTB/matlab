
classdef DatasetRef<matlab.mixin.Copyable































    properties(SetAccess=immutable)
        Identifier=' ';
        Location=' ';
    end

    properties(Access=protected,Constant,Transient)
        CurrentVersion_=2;
    end

    properties(Access=protected,Hidden=true)


        Version_=Simulink.SimulationData.DatasetRef.CurrentVersion_;
        DatastoreCache_={};
        FileSignature_=0;
    end

    properties(Access=private,Transient=true,Hidden=true)
        ResolvedLocation_=' ';
        Dataset_=[];
    end


    methods
        function obj=DatasetRef(location,identifier)







            if isstring(location)
                location=char(location);
            end
            if isstring(identifier)
                identifier=char(identifier);
            end

            try
                if isvarname(identifier)
                    obj.Identifier=identifier;
                else
                    Simulink.SimulationData.utError('InvalidDatasetRefInvalidVarName');
                end
                if ischar(location)
                    obj.Location=strtrim(location);
                    [~,~,ext]=fileparts(obj.Location);
                    if isempty(ext)
                        obj.Location=[obj.Location,'.mat'];
                    end
                    whichLoc=Simulink.SimulationData.DatasetRef.getFileLocation(obj.Location);
                    if isempty(whichLoc)
                        Simulink.SimulationData.utError('InvalidDatasetRefFileNotExist');
                    end
                    [~,info]=fileattrib(whichLoc);
                    if(info.UserRead==0)
                        Simulink.SimulationData.utError('InvalidDatasetRefFileNotReadable');
                    end
                    obj.ResolvedLocation_=info.Name;
                else
                    Simulink.SimulationData.utError('InvalidDatasetRefInvalidFileName');
                end
                obj.resolve();
            catch me
                throwAsCaller(me);
            end
        end


        function name=Name(this)
            try
                this.resolve();
                name=this.Dataset_.Name;
            catch me
                throwAsCaller(me);
            end
        end


        function nelem=numElements(this)





            try
                this.resolve();
                nelem=this.Dataset_.numElements();
            catch me
                throwAsCaller(me);
            end
        end


        function elemNames=getElementNames(this)





            try
                this.resolve();
                elemNames=this.Dataset_.getElementNames;
            catch me
                throwAsCaller(me);
            end
        end

        function[elementDatastore,name,retIdx]=getAsDatastore(this,varargin)
































            [varargin{:}]=convertStringsToChars(varargin{:});

            try
                narginchk(2,inf);
                this.resolve();
                this.setReturnAsDatastoreOnMATFileDatasetStorage(true);
                oc=onCleanup(@()this.setReturnAsDatastoreOnMATFileDatasetStorage(false));
                if nargin>=2
                    [elementDatastore,name,retIdx,this.DatastoreCache_]=...
                    this.Dataset_.locGetWrapperWithNotFoundWarning(this.DatastoreCache_,varargin{:});
                else
                    [elementDatastore,name,retIdx]=this.Dataset_.get(varargin{:});
                end
            catch me
                throwAsCaller(me);
            end
        end

        function[elementVal,name,retIdx]=get(this,varargin)










            [varargin{:}]=convertStringsToChars(varargin{:});
            try
                this.resolve();
                this.setReturnAsDatastoreOnMATFileDatasetStorage(false);
                [elementVal,name,retIdx]=this.Dataset_.get(varargin{:});
            catch me
                throwAsCaller(me);
            end
        end

        function[elementVal,name,retIdx]=getElement(this,varargin)























            [varargin{:}]=convertStringsToChars(varargin{:});
            try
                this.resolve();
                this.setReturnAsDatastoreOnMATFileDatasetStorage(false);
                [elementVal,name,retIdx]=this.Dataset_.getElement(varargin{:});
            catch me
                throwAsCaller(me);
            end
        end


        function varargout=plot(this,varargin)















            [varargin{:}]=convertStringsToChars(varargin{:});
            narginchk(1,2)
            ret=cell(1,nargout);


            dsLabel=inputname(1);


            if nargin<2
                viewer='datainspector';
            else
                if~ischar(varargin{1})
                    Simulink.SimulationData.utError('viewMustBeChar');
                end
                viewer=lower(varargin{1});
            end


            switch viewer
            case 'preview'
                Simulink.SimulationData.utPlotDataset(this,dsLabel);
            otherwise
                [ret{:}]=Simulink.SimulationData.utPlotDatasetSDI(this,dsLabel);
            end
            varargout=ret;
        end

    end


    methods(Hidden=true)


        disp(this);

        function[equal,mismatches]=compare(this,varargin)
            [varargin{:}]=convertStringsToChars(varargin{:});
            try
                this.resolve();
                [equal,mismatches]=this.Dataset_.compare(varargin{:});
            catch me
                throwAsCaller(me);
            end
        end


        function nelem=getLength(this)





            try
                this.resolve();
                nelem=this.Dataset_.getLength;
            catch me
                throwAsCaller(me);
            end
        end



        function elementVal=getElementByIndex(this,idx)

            try
                this.resolve();
                this.setReturnAsDatastoreOnMATFileDatasetStorage(false);
                elementVal=this.Dataset_.getElementByIndex(idx);
            catch me
                throwAsCaller(me);
            end
        end


        function storage=getStorage(this,varargin)
            [varargin{:}]=convertStringsToChars(varargin{:});
            storage=this.Dataset_.getStorage(varargin{:});
        end


        function version=getVersion(this)
            version=this.Version_;
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


        function signature=fileSignature(this)
            try
                this.resolve();
            catch ME %#ok<NASGU>
            end
            signature=this.FileSignature_;
        end
    end


    methods(Hidden=true,Access=private)

        function idx=utGetIndexFromSubs(obj,s,isGet)
            if numel(obj)~=1
                Simulink.SimulationData.utError('InvalidDatasetArray');
            end

            if isempty(obj.Dataset_)
                Simulink.SimulationData.utError('InvalidDatasetRefVarNotExist');
            end

            isValidIndex=false;
            idx=0;
            len=obj.Dataset_.numElements();
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

        function location=ResolvedLocation(this)
            location=this.ResolvedLocation_;
        end
        function verifyDatasetRefIsScalar(this)
            if~isscalar(this)
                Simulink.SimulationData.utError('NonScalarDatasetRef');
            end
        end
        function setReturnAsDatastoreOnMATFileDatasetStorage(this,newVal)
            this.Dataset_.ReturnAsDatastoreForDatasetRef=newVal;
        end

        function resolve(this)
            this.verifyDatasetRefIsScalar;

            fileExists=sigstream_mapi('fileExists',this.ResolvedLocation_);
            if~fileExists
                this.invalidate();
                Simulink.SimulationData.utError('InvalidDatasetRefFileNotExist');
            end
            isR2=sigstream_mapi('fileIsR2',this.ResolvedLocation_);
            if isR2
                r2=...
                sigstream_mapi(...
                'openR2',...
                this.ResolvedLocation_,...
'READ_ONLY'...
                );
                r2sig=sigstream_mapi('getR2Signature',r2);
                sigstream_mapi('closeR2',r2);
                if r2sig~=this.FileSignature_
                    this.invalidate();

                    this.reload();

                    this.FileSignature_=r2sig;
                end
            else
                this.invalidate();
                this.reload();
            end
        end


        function invalidate(this)
            this.Dataset_=[];
            this.FileSignature_=0;
            this.DatastoreCache_={};
        end


        function reload(this)


            sigstream_mapi('setFullLoadRecord',false);
            warn_status=warning('off','MATLAB:load:variableNotFound');

            varstruct=load(this.Location,'-mat',this.Identifier);
            warning(warn_status);

            sigstream_mapi('setFullLoadRecord',true);
            if~isfield(varstruct,this.Identifier)
                this.invalidate();
                Simulink.SimulationData.utError('InvalidDatasetRefVarNotExist');
            end
            this.Dataset_=varstruct.(this.Identifier);

            if~isa(this.Dataset_,'Simulink.SimulationData.Dataset')
                this.invalidate();
                Simulink.SimulationData.utError('InvalidDatasetRefVarNotDataset');
            end

            if length(this.Dataset_)~=1
                this.invalidate();
                Simulink.SimulationData.utError('InvalidDatasetRefVarNotScalar');
            end



            this.DatastoreCache_=cell(1,this.Dataset_.numElements());
        end
    end
    methods(Static=true,Hidden=true)

        function obj=loadobj(var)
            try
                obj=Simulink.SimulationData.DatasetRef(var.Location,var.Identifier);
                if obj.FileSignature_==var.FileSignature_&&var.Version_>=2
                    obj.DatastoreCache_=var.DatastoreCache_;
                end
            catch
                obj=var;
            end

            if var.Version_>Simulink.SimulationData.DatasetRef.CurrentVersion_
                Simulink.SimulationData.utError('LoadingNewerVersionNotAllowed',...
                'Simulink.SimulationData.DatasetRef');
            end
        end

        function loc=getFileLocation(location)
            loc=location;
            [pathstr,~,ext]=fileparts(loc);
            if isempty(ext)
                loc=[loc,'.mat'];
            end

            if isdeployed
                whichLoc=loc;
                if isempty(pathstr)
                    whichLoc=which(whichLoc);
                    if~isempty(whichLoc)
                        loc=whichLoc;
                    elseif exist(loc,'file')~=2
                        loc='';
                    end
                end
            else
                if isempty(pathstr)||exist(loc,'file')~=2
                    loc=which(loc);
                end
            end
        end
    end

    methods(Static=true)

        function names=getDatasetVariableNames(location)







            try
                if isstring(location)
                    location=char(location);
                end

                if ischar(location)
                    location=strtrim(location);
                    [~,~,ext]=fileparts(location);
                    if isempty(ext)
                        location=[location,'.mat'];
                    end
                    whichLoc=Simulink.SimulationData.DatasetRef.getFileLocation(location);
                    if isempty(whichLoc)
                        Simulink.SimulationData.utError('InvalidDatasetRefFileNotExist');
                    end
                    [~,info]=fileattrib(whichLoc);
                    if(info.UserRead==0)
                        Simulink.SimulationData.utError('InvalidDatasetRefFileNotReadable');
                    end
                    resolvedLocation=info.Name;
                    varInfo=sigstream_mapi('getMatFileVariableInfo',resolvedLocation);
                    names={};
                    for vi=1:length(varInfo)
                        if strcmp(varInfo(vi).className,'Simulink.SimulationData.Dataset')
                            names{end+1}=varInfo(vi).variableName;%#ok<AGROW>
                        end
                    end
                else
                    Simulink.SimulationData.utError('InvalidDatasetRefInvalidFileName');
                end
            catch me
                throwAsCaller(me);
            end
        end
    end


    methods(Static=true,Hidden=true,Access=private)

        function val=utNeedsTransparentElement(element)
            val=(~isa(element,'Simulink.SimulationData.Element')&&...
            ~isa(element,'timeseries'))||...
            isempty(element);
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


        function utPrivateCheck(name,isGet)





            switch name

            case{'DatasetRef',...
                'Name',...
                'addlistener',...
                'delete',...
                'eq',...
                'findobj',...
                'findprop',...
                'ge',...
                'get',...
                'getAsDatastore',...
                'getDatasetVariableNames',...
                'getElement',...
                'getElementNames',...
                'gt',...
                'isvalid',...
                'le',...
                'lt',...
                'ne',...
                'notify',...
                'numElements',...
                'plot',...
                'copy'}



            case{'fileSignature',...
                'end',...
                'subsasgn',...
                'subsref',...
                'numArgumentsFromSubscript',...
                'getVersion',...
                'getStorage',...
                'getElementByIndex',...
                'getLength',...
                'compare',...
                'disp',...
                'loadobj',...
                'empty'}



            case{'Identifier','Location'}
                if~isGet
                    id='MATLAB:class:SetProhibited';
                    ME=MException(id,message(id,name,...
                    'Simulink.SimulationData.DatasetRef').getString);
                    throw(ME);
                end
            otherwise
                id='MATLAB:noSuchMethodOrField';
                ME=MException(id,message(id,name,...
                'Simulink.SimulationData.DatasetRef').getString);
                throw(ME);
            end
        end

    end

    methods(Access=protected)
        function cpObj=copyElement(obj)

            cpObj=copyElement@matlab.mixin.Copyable(obj);
            nElements=numel(obj.DatastoreCache_);
            for idx=1:nElements
                cpObj.DatastoreCache_{idx}=...
                Simulink.SimulationData.utCopyRecurse(obj.DatastoreCache_{idx});
            end
        end
    end
end



