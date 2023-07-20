classdef ExcitationVec<matlab.mixin.SetGet

    properties
Vec
N
NExVecs
NFreqVecs
PartsMap
EMSol
    end

    methods

        function obj=ExcitationVec(solObj)
            obj.EMSol=solObj;
            obj.N=0;
            obj.NExVecs=1;
            obj.NFreqVecs=1;
            obj.Vec=zeros(obj.N,obj.NExVecs,obj.NFreqVecs);
            obj.PartsMap=repmat(struct('Part',[],'Indices',[]),0,1);
        end

        function enteries=AddTermination(obj,termination)

            obj.PartsMap(end+1).Part=termination;
            if termination.Side==0


                termSegInd=find(ismember([obj.PartsMap(:).Part],...
                termination.NextParts),1);
                obj.PartsMap(end).Indices=...
                obj.PartsMap(termSegInd).Indices(1)-1;
            else


                termSegInd=find(ismember([obj.PartsMap(:).Part],...
                termination.PrevParts),1);
                obj.PartsMap(end).Indices=...
                obj.PartsMap(termSegInd).Indices(end)+1;
            end


            enteries=em.wire.solver.ExcitationVec.CreateEnteriesStruct;
            PartsMapVal=obj.PartsMap(end);
            enteries(1).Indices=PartsMapVal.Indices;
            enteries(1).Vals=[];
        end

        function enteries=GetTerminationEnteries(obj,termination)
            termInd=find(ismember([obj.PartsMap(:).Part],termination),1);

            enteries=em.wire.solver.ExcitationVec.CreateEnteriesStruct;
            PartsMapVal=obj.PartsMap(termInd);
            enteries(1).Indices=PartsMapVal.Indices;
            enteries(1).Vals=[];
        end

        function enteries=AddConnection(obj,connection,varargin)

            obj.PartsMap(end+1).Part=connection;
            connPrevInd=find(ismember([obj.PartsMap(:).Part],...
            connection.PrevParts),1);
            connNextInd=find(ismember([obj.PartsMap(:).Part],...
            connection.NextParts));
            if connection.PrevSegSides==0
                obj.PartsMap(end).Indices=...
                obj.PartsMap(connPrevInd).Indices(1)-1;
            else
                obj.PartsMap(end).Indices=...
                obj.PartsMap(connPrevInd).Indices(end)+1;
            end
            NextSegNum=length(connNextInd);
            for connNextIndInd=1:NextSegNum
                if connection.NextSegSides(connNextIndInd)==0
                    obj.PartsMap(end).Indices=[obj.PartsMap(end).Indices...
                    ,obj.PartsMap(connNextInd(connNextIndInd)).Indices(1)-1];
                else
                    obj.PartsMap(end).Indices=[obj.PartsMap(end).Indices...
                    ,obj.PartsMap(connNextInd(connNextIndInd)).Indices(end)+1];
                end
            end

            enteries=em.wire.solver.ExcitationVec.CreateEnteriesStruct;
            PartsMapVal=obj.PartsMap(end);
            enteries(1).Indices=PartsMapVal.Indices(2:NextSegNum+1);
            enteries(1).Vals=zeros(0,obj.NExVecs,length(varargin{1}));



            if obj.PartsMap(end).Part.AffectingOtherPartsEx
                PartsMapVal=obj.PartsMap(connPrevInd);
                enteries(2).Indices=PartsMapVal.Indices;
                enteries(2).Vals=obj.Vec(enteries(2).Indices,:,...
                varargin{1});
                PartsMapVal=obj.PartsMap(connNextInd);
                enteries(3).Indices=PartsMapVal.Indices;
                enteries(3).Vals=obj.Vec(enteries(3).Indices,:,...
                varargin{1});
            end
        end

        function enteries=GetConnectionEnteries(obj,connection,varargin)
            connInd=find(ismember([obj.PartsMap(:).Part],connection),1);
            connPrevInd=find(ismember([obj.PartsMap(:).Part],...
            connection.PrevParts),1);
            connNextInd=find(ismember([obj.PartsMap(:).Part],...
            connection.NextParts));
            NextSegNum=length(connNextInd);

            enteries=em.wire.solver.ExcitationVec.CreateEnteriesStruct;
            PartsMapVal=obj.PartsMap(connInd);
            enteries(1).Indices=PartsMapVal.Indices(2:NextSegNum+1);
            enteries(1).Vals=zeros(0,obj.NExVecs,sum(varargin{1}));



            if obj.PartsMap(connInd).Part.AffectingOtherPartsEx
                PartsMapVal=obj.PartsMap(connPrevInd);
                enteries(2).Indices=PartsMapVal.Indices;
                enteries(2).Vals=obj.Vec(enteries(2).Indices,:,...
                varargin{1});
                PartsMapVal=obj.PartsMap(connNextInd);
                enteries(3).Indices=PartsMapVal.Indices;
                enteries(3).Vals=obj.Vec(enteries(3).Indices,:,...
                varargin{1});
            end
        end

        function enteries=AddSegment(obj,segment)

            addedElems=segment.PolyDegree+1;
            if isempty(obj.Vec)
                obj.Vec=zeros(addedElems,obj.NExVecs,obj.NFreqVecs);
            else
                obj.Vec=[obj.Vec;zeros(addedElems,obj.NExVecs,obj.NFreqVecs)];
            end
            obj.PartsMap(end+1).Part=segment;
            obj.PartsMap(end).Indices=obj.N+1+1:obj.N+addedElems-1;
            obj.N=obj.N+addedElems;


            enteries=em.wire.solver.ExcitationVec.CreateEnteriesStruct;
            enteries(1).Indices=obj.PartsMap(end).Indices;
            enteries(1).Vals=[];
        end

        function enteries=GetSegmentEnteries(obj,segment)
            segInd=find(ismember([obj.PartsMap(:).Part],segment),1);

            enteries=em.wire.solver.ExcitationVec.CreateEnteriesStruct;
            enteries(1).Indices=obj.PartsMap(segInd).Indices;
            enteries(1).Vals=[];
        end

        function Fill(obj,enteries,varargin)

            if((~isstruct(enteries))||...
                (~all(cellfun(@(x,y)strcmp(x,y),...
                fieldnames(enteries),{'Indices';'Vals'}))))
                error(['Fill expects a structure with '...
                ,'fields: ''Indices'',''Vals''']);
            end
            if nargin==2||isempty(varargin{1})
                for partInd=1:length(enteries)
                    obj.Vec(enteries(partInd).Indices,:,:)=...
                    enteries(partInd).Vals;
                end
            else
                for partInd=1:length(enteries)
                    obj.Vec(enteries(partInd).Indices,:,varargin{1})=...
                    enteries(partInd).Vals;
                end
            end
        end

        function vec=FillReplica(obj,enteries,varargin)

            if((~isstruct(enteries))||...
                (~all(cellfun(@(x,y)strcmp(x,y),...
                fieldnames(enteries),{'Indices';'Vals'}))))
                error(['Fill expects a structure with '...
                ,'fields: ''Indices'',''Vals''']);
            end
            if nargin==4
                vec=varargin{2};
            else
                vec=obj.Vec;
            end
            if nargin==2||isempty(varargin{1})
                for partInd=1:length(enteries)
                    vec(enteries(partInd).Indices,:,:)=...
                    enteries(partInd).Vals;
                end
            else
                for partInd=1:length(enteries)
                    vec(enteries(partInd).Indices,:,varargin{1})=...
                    enteries(partInd).Vals;
                end
            end
        end

        function enteries=GetEnteries(obj,part)
            partInd=find(obj.PartsMap==part,1);
            enteries=em.wire.solver.ExcitationVec.CreateEnteriesStruct;
            if~isempty(partInd)
                enteries(1).Indices=obj.PartsMap(partInd).Indices;
                enteries(1).Vals=obj.Vec(enteries(1).Indices);
            end
        end

    end

    methods(Access=private,Static)


        function enteries=CreateEnteriesStruct
            enteries=struct('Indices',[],'Vals',[]);
        end

    end

end