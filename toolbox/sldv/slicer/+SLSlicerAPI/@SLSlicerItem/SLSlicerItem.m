classdef SLSlicerItem




    properties
        SeedType='StartingPoint';
        SID='';
        DataPorts=[];


        CovConstraintStruct=[];

        BusElementPath=[];
    end
    properties(Dependent)
Type
    end
    properties(Hidden=true,Constant=true)
        SeedTypeList={'StartingPoint','ExclusionPoint','Constraint','SliceSubSystem'};
    end
    methods
        function obj=SLSlicerItem(type,SID,Dataports,varargin)
            if nargin==0
                return;
            end
            obj.SeedType=type;
            obj.SID=SID;
            obj.DataPorts=Dataports;

            if nargin>3
                obj.CovConstraintStruct=varargin{1};
            end
        end

        function obj=set.SeedType(obj,t)
            if any(strcmp(obj.SeedTypeList,t))
                obj.SeedType=t;
            else
                error('ModelSlicer:API:InvalidSeedType',getString(message('Sldv:ModelSlicer:SLSlicerAPI:InvalidTypeIsSpecified')));
            end
        end
        function obj=set.SID(obj,s)
            if~isempty(s)&&ischar(s)&&contains(s,':')
                obj.SID=s;
            else
                error('ModelSlicer:API:InvalidSID',getString(message('Sldv:ModelSlicer:SLSlicerAPI:InvalidSIDIsSpecified')));
            end
        end
        function obj=set.DataPorts(obj,d)
            if isnumeric(d)
                obj.DataPorts=d;
            else
                error('ModelSlicer:API:InvalidDataPort',getString(message('Sldv:ModelSlicer:SLSlicerAPI:InvalidDataPortsIsSpecified')));
            end
        end
        function t=get.Type(obj)
            if isempty(obj.DataPorts)
                if isSf(obj.SID)
                    t='state';
                else
                    t='block';
                end
            else
                t='signal';
            end
        end
        function out=getReturn(obj,seedType,mdl)
            nObj=numel(obj);
            hasPort=false;
            switch seedType
            case{'StartingPoint','Constraint'}
                out=struct('SID',cell(1,nObj),'Path','','Handle',[],'Port',[]);
                hasPort=true;
            case{'ExclusionPoint','SliceSubSystem'}
                out=struct('SID',cell(1,nObj),'Path','','Handle',[]);
            end
            if isempty(mdl)
                mdlName='';
                hasModel=false;
            else
                mdlName=get_param(mdl,'Name');
                hasModel=true;
            end
            for n=1:nObj
                tok=strfind(obj(n).SID,':');
                if~isempty(tok)&&tok(1)==1
                    sid=[mdlName,obj(n).SID];
                else
                    sid=obj(n).SID;
                end
                out(n).SID=sid;
                if hasPort
                    out(n).Port=obj(n).DataPorts;
                end
                if~isempty(obj(n).BusElementPath)
                    out(n).BusElementPath=obj(n).BusElementPath;
                end
                if hasModel

                    try
                        out(n).Path=Simulink.ID.getFullName(sid);
                        blkH=Simulink.ID.getHandle(sid);
                        if strcmp(obj(n).Type,'block')||...
                            strcmp(obj(n).Type,'state')
                            out(n).Handle=blkH;
                        else
                            ph=get_param(blkH,'PortHandles');
                            out(n).Handle=ph.Outport(obj(n).DataPorts);
                        end
                    catch

                    end
                end
            end
        end
        function invalidIdx=validateSeeds(obj,modelName,msObj,slcri)


            invalidIdx=[];
            if nargin<4
                slcri=[];
            else
                slcri.clearAllStartingPoints();
            end
            for m=1:length(obj)
                valid=true;
                showwarning=false;
                blockPath=obj(m).SID;
                blockPort=obj(m).DataPorts;
                busElemPath=obj(m).BusElementPath;
                try
                    tok=strfind(obj(m).SID,':');
                    if~isempty(tok)&&tok(1)==1

                        sid=[modelName,obj(m).SID];
                    else
                        sid=obj(m).SID;
                    end
                    bh=Simulink.ID.getHandle(sid);

                    switch obj(m).SeedType
                    case 'StartingPoint'
                        if~isempty(blockPort)
                            lh=get(bh,'PortHandles');
                            if isempty(busElemPath)
                                bh=get(lh.Outport(blockPort),'Line');
                            else
                                bh=lh.Outport(blockPort);
                            end
                        end


                        [yesno,msg]=slcri.addStart(bh,busElemPath);
                        if~yesno
                            valid=false;
                            if~ismember(msg,'StartAddedAlready')



                                showwarning=true;
                            end
                        end
                    case 'ExclusionPoint'
                        if~msObj.isBlockValidTarget(bh)
                            valid=false;
                            showwarning=true;
                        end
                    case 'Constraint'
                        if~isSf(sid)
                            if~any(strcmp(get_param(bh,'BlockType'),{'Switch','MultiportSwitch'}))
                                valid=false;
                            end
                        else
                            valid=isa(bh,'Stateflow.State')||...
                            isa(bh,'Stateflow.AtomicSubChart')||...
                            isa(bh,'Stateflow.Transition');
                        end
                        showwarning=~valid;
                    case 'SliceSubSystem'
                        try
                            Transform.SubsystemSliceUtils.checkCompatibility(bh);
                        catch
                            valid=false;
                            showwarning=true;
                        end
                    end
                    if~isa(bh,'Stateflow.Object')
                        blockPath=getfullname(bh);
                    else
                        blockPath=Simulink.ID.getFullName(sid);
                    end
                catch Mex %#ok<NASGU>
                    valid=false;
                end
                if~valid
                    invalidIdx(end+1)=m;%#ok<AGROW>
                end
                if showwarning
                    warning('ModelSlicer:API:InvalidSeedFoundWhenActivatedSeeds',...
                    getString(message('Sldv:ModelSlicer:SLSlicerAPI:InvalidSeedFoundWhenActivated',blockPath,obj(m).SeedType)));
                end
            end
        end

    end
    methods(Static,Hidden)
        function elem=SLSlicerItem2SliceCriterionElem(seedType,sp,sc)
            if~isa(sp,'SLSlicerAPI.SLSlicerItem')
                error('ModelSlicer:API:InvalidClass',getString(message('Sldv:ModelSlicer:SLSlicerAPI:InvalidClassIsSpecified')));
            end
            elem=[];
            switch seedType

            case 'StartingPoint'
                spelements=slslicer.internal.convertAPIStartsToSLMSStarts(sp);
                sc.updateUserStartsFromStruct(spelements);
            case 'ExclusionPoint'
                exclusion=slslicer.internal.convertAPIExclusionToSLMSExclusion(sp);
                sc.updateUserExclusionsFromStruct(exclusion);

            case 'Constraint'
                elem=containers.Map('KeyType','char','ValueType','any');
                for ii=1:length(sp)
                    if isfield(sp(ii),'DataPorts')&&...
                        ~isempty(sp(ii).DataPorts)
                        if Simulink.ID.isValid(sp(ii).SID)
                            ph=get_param(Simulink.ID.getHandle(sp(ii).SID),'PortHandles');
                            tp=length(ph.Inport);
                        else



                            tp=[];
                        end
                        elem(sp(ii).SID)=struct('PortNumbers',sp(ii).DataPorts,'TotalPorts',tp);
                    end
                end
            case 'CovConstraint'


                elem=containers.Map('KeyType','char','ValueType','any');
                for ii=1:length(sp)
                    if isfield(sp(ii),'CovConstraintStruct')&&...
                        ~isempty(sp(ii).CovConstraintStruct)&&...
                        Simulink.ID.isValid(sp(ii).SID)
                        elem(sp(ii).SID)=sp(ii).CovConstraintStruct;
                    end
                end
            case 'SliceSubSystem'
                if~isempty(sp)
                    elem=Simulink.ID.getHandle(sp.SID);
                end
            end
        end
        function item=SliceCriterionElem2SLSlicerItem(seedType,elem)
            item=SLSlicerAPI.SLSlicerItem.empty();
            switch seedType
            case 'StartingPoint'
                for i=1:length(elem)
                    if isfield(elem(i),'SID')&&~isempty(elem(i).SID)
                        SID=elem(i).SID;
                    else
                        SID=Simulink.ID.getSID(elem(i).Handle);
                    end
                    item(i)=SLSlicerAPI.SLSlicerItem(seedType,SID,elem(i).PortNumber);
                end
            case 'ExclusionPoint'
                for i=1:length(elem)
                    if isfield(elem(i),'SID')&&~isempty(elem(i).SID)
                        SID=elem(i).SID;
                    else
                        SID=Simulink.ID.getSID(elem(i).Handle);
                    end
                    item(i)=SLSlicerAPI.SLSlicerItem(seedType,SID,[]);
                end
            case 'Constraint'
                SIDs=elem.keys;
                values=elem.values;
                for i=1:length(SIDs)
                    if isfield(values{i},'PortNumbers')

                        item(i)=SLSlicerAPI.SLSlicerItem(seedType,SIDs{i},values{i}.PortNumbers);
                    else

                        item(i)=SLSlicerAPI.SLSlicerItem(seedType,SIDs{i},[],values{i});
                    end
                end
            case 'SliceSubSystem'
                if~isempty(elem)
                    if~ischar(elem)&&numel(elem)~=1
                        error('ModelSlicer:API:MultipleSubSystem',getString(message('Sldv:ModelSlicer:SLSlicerAPI:SliceSubSystemASingleSystem')));
                    end
                    if ischar(elem)&&contains(elem,':')
                        SID=elem;
                    else
                        SID=Simulink.ID.getSID(elem);
                    end
                    item=SLSlicerAPI.SLSlicerItem(seedType,SID,[]);
                end
            end
        end
    end
end

function yesno=isSf(sid)
    try
        h=Simulink.ID.getHandle(sid);
        yesno=isa(h,'Stateflow.Object');
    catch
        yesno=false;
    end
end
