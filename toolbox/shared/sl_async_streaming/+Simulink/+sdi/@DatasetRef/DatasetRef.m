classdef DatasetRef<handle
























    properties(Dependent=true,GetAccess='public',SetAccess='immutable')
Name
Run
numElements
    end


    methods


        function obj=DatasetRef(varargin)




            bFirstArgStr=false;
            if nargin>0
                bFirstArgStr=ischar(varargin{1})||isstring(varargin{1});
            end
            if nargin<1||...
                (nargin==1&&bFirstArgStr)
                obj=Simulink.sdi.DatasetRef.empty();
                runIDs=Simulink.sdi.getAllRunIDs();
                for idx=1:length(runIDs)
                    obj(idx)=Simulink.sdi.DatasetRef(runIDs(idx),varargin{:});
                end
                return
            end


            validateattributes(varargin{1},...
            {'numeric'},...
            {'integer','scalar','positive'},...
            '','runID',1);
            obj.RunID=varargin{1};


            if nargin>1&&(ischar(varargin{2})||~isempty(varargin{2}))
                validateattributes(varargin{2},{'char','string'},{},'','domain',2);

                obj.Domain=char(varargin{2});
                if strcmpi(obj.Domain,'signal')||strcmpi(obj.Domain,'signals')
                    obj.Domain='';
                elseif strcmpi(obj.Domain,'outports')
                    obj.Domain='outport';
                end
            else
                obj.Domain=[];
            end


            obj.IncludeHidden=false;
            if nargin<3
                obj.Repo=sdi.Repository(1);
            elseif isa(varargin{3},'sdi.Repository')
                obj.Repo=varargin{3};
            elseif isobject(varargin{3})&&isprop(varargin{3},'sigRepository')
                obj.Repo=varargin{3}.sigRepository;
            elseif islogical(varargin{3})&&isscalar(varargin{3})
                obj.IncludeHidden=varargin{3};
                obj.Repo=sdi.Repository(1);
            else
                validateattributes(varargin{3},{'char','string'},{},'','filepath',2);
                obj.Repo=sdi.Repository(char(varargin{3}));
            end


            obj.FileLocation=getSource(obj.Repo);


            obj.LogIntervals=[];
            obj.LoggingOverride=[];







            obj.SortStatesForLegacyFormats=false;
        end


        function ret=get.Name(this)
            ret=getRunName(this.Repo,this.RunID);
        end


        function ret=get.Run(this)
            ret=Simulink.sdi.Run(this.Repo,this.RunID);
        end


        function ret=get.numElements(this)
            sigIDs=getSortedSignalIDs(this);
            ret=numel(sigIDs);
        end


        ret=getElementNames(this)
        [elementDatastore,name,retIdx]=getAsDatastore(this,arg1)
        [elementVal,name,retIdx]=get(this,varargin)
        [elementVal,name,retIdx]=getElement(this,arg1)
        sig=getSignal(this,arg1)
        plot(this,varargin)
        [equal,mismatches,drr]=compare(this,other,varargin)
    end


    methods(Hidden=true)
        ret=getLength(this)
        ret=getElementByIndex(this,idx)
        ids=getSortedSignalIDs(this)
        setIntervalsAndOverride(this,intervals,dlo)
        ret=fullExport(this)
        ret=validateOverride(this)
    end

    methods(Static=true,Hidden=true)
        ret=getDatastoreForSignal(sigID,repo)
        obj=loadobj(var)
    end


    properties(Hidden)
SortStatesForLegacyFormats
    end


    properties(Access=private)
RunID
FileLocation
Domain
IncludeHidden
LogIntervals
LoggingOverride
    end

    properties(Transient=true,Access=private)
Repo
SignalIDs
    end
end
