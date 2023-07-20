classdef ImpedanceMatrix<matlab.mixin.SetGet

    properties
Matrix
N
NMats
PartsMap
EMSol
isNotPrealloc
    end

    methods

        function obj=ImpedanceMatrix(solObj)
            obj.EMSol=solObj;
            obj.N=0;
            obj.NMats=0;
            obj.Matrix=zeros(0,0,0);
            obj.isNotPrealloc=true;
            obj.PartsMap=repmat(...
            struct('Part',[],'Cols',[],'Rows',[]),0,1);
        end

        function enteries=AddTermination(obj,termination)

            if termination.Side==0
                termSegInd=find(ismember([obj.PartsMap(:).Part],...
                termination.NextParts),1);
            else
                termSegInd=find(ismember([obj.PartsMap(:).Part],...
                termination.PrevParts),1);
            end
            obj.PartsMap(end+1).Part=termination;
            obj.PartsMap(end).Cols=obj.PartsMap(termSegInd).Cols;
            if termination.Side==0
                obj.PartsMap(end).Rows=obj.PartsMap(termSegInd).Rows(1)-1;
            else
                obj.PartsMap(end).Rows=obj.PartsMap(termSegInd).Rows(end)+1;
            end


            enteries=em.wire.solver.ImpedanceMatrix.CreateEnteriesStruct;


            PartsMapVal=obj.PartsMap(end);
            enteries(1).Cols=PartsMapVal.Cols;
            enteries(1).Rows=PartsMapVal.Rows;
            enteries(1).OtherPart=obj.PartsMap(termSegInd);
            enteries(1).Reciprocal=false;
            enteries(1).Vals=[];
        end

        function enteries=GetTerminationEnteries(obj,termination)
            termInd=find(ismember([obj.PartsMap(:).Part],termination),1);
            if termination.Side==0
                termSegInd=find(ismember([obj.PartsMap(:).Part],...
                termination.NextParts),1);
            else
                termSegInd=find(ismember([obj.PartsMap(:).Part],...
                termination.PrevParts),1);
            end

            enteries=em.wire.solver.ImpedanceMatrix.CreateEnteriesStruct;


            PartsMapVal=obj.PartsMap(termInd);
            enteries(1).Cols=PartsMapVal.Cols;
            enteries(1).Rows=PartsMapVal.Rows;
            enteries(1).OtherPart=obj.PartsMap(termSegInd);
            enteries(1).Reciprocal=false;
            enteries(1).Vals=[];
        end

        function enteries=AddConnection(obj,connection)

            connPrevInd=find(ismember([obj.PartsMap(:).Part],...
            connection.PrevParts),1);
            connNextInd=find(ismember([obj.PartsMap(:).Part],...
            connection.NextParts));
            obj.PartsMap(end+1).Part=connection;
            obj.PartsMap(end).Cols=1:obj.N;




            if connection.PrevSegSides==0
                obj.PartsMap(end).Rows=...
                obj.PartsMap(connPrevInd).Rows(1)-1;
            else
                obj.PartsMap(end).Rows=...
                obj.PartsMap(connPrevInd).Rows(end)+1;
            end
            enteries(1).Cols=obj.PartsMap(connPrevInd).Cols;
            enteries(1).Rows=obj.PartsMap(end).Rows(1);
            enteries(1).OtherPart=obj.PartsMap(connPrevInd).Part;
            enteries(1).Reciprocal=false;
            enteries(1).Vals=[];

            NextSegNum=length(connNextInd);
            allParts=[obj.PartsMap(:).Part];
            affectedParts=find([allParts.AffectingOtherPartsZ]);
            affectedPartsNum=length(affectedParts);
            for connNextIndInd=1:NextSegNum
                if connection.NextSegSides(connNextIndInd)==0
                    obj.PartsMap(end).Rows=[obj.PartsMap(end).Rows...
                    ,obj.PartsMap(...
                    connNextInd(connNextIndInd)).Rows(1)-1];
                else
                    obj.PartsMap(end).Rows=[obj.PartsMap(end).Rows...
                    ,obj.PartsMap(...
                    connNextInd(connNextIndInd)).Rows(end)+1];
                end
                enteries(1+connNextIndInd).Cols=...
                obj.PartsMap(connNextInd(connNextIndInd)).Cols;
                enteries(1+connNextIndInd).Rows=...
                obj.PartsMap(end).Rows(1);
                enteries(1+connNextIndInd).OtherPart=...
                obj.PartsMap(connNextInd(connNextIndInd)).Part;
                enteries(1+connNextIndInd).Reciprocal=false;
                enteries(1+connNextIndInd).Vals=[];

                for PartInd=1:affectedPartsNum
                    PartsMapVal=obj.PartsMap(affectedParts(PartInd));
                    enteries(1+NextSegNum+PartInd).Cols=PartsMapVal.Cols;
                    enteries(1+NextSegNum+PartInd).Rows(connNextIndInd)=...
                    obj.PartsMap(end).Rows(1+connNextIndInd);
                    enteries(1+NextSegNum+PartInd).OtherPart=PartsMapVal.Part;
                    enteries(1+NextSegNum+PartInd).Reciprocal=false;
                    enteries(1+NextSegNum+PartInd).Vals=[];
                end
            end
        end

        function enteries=GetConnectionEnteries(obj,connection)
            connInd=find(ismember([obj.PartsMap(:).Part],connection),1);
            connPrevInd=find(ismember([obj.PartsMap(:).Part],...
            connection.PrevParts),1);
            connNextInd=find(ismember([obj.PartsMap(:).Part],...
            connection.NextParts));
            enteries(1).Cols=obj.PartsMap(connPrevInd).Cols;
            enteries(1).Rows=obj.PartsMap(connInd).Rows(1);
            enteries(1).OtherPart=obj.PartsMap(connPrevInd).Part;
            enteries(1).Reciprocal=false;
            enteries(1).Vals=[];

            NextSegNum=length(connNextInd);
            allParts=[obj.PartsMap(:).Part];
            affectedParts=find([allParts.AffectingOtherPartsZ]);
            affectedPartsNum=length(affectedParts);
            for connNextIndInd=1:NextSegNum
                enteries(1+connNextIndInd).Cols=...
                obj.PartsMap(connNextInd(connNextIndInd)).Cols;
                enteries(1+connNextIndInd).Rows=...
                obj.PartsMap(connInd).Rows(1);
                enteries(1+connNextIndInd).OtherPart=...
                obj.PartsMap(connNextInd(connNextIndInd)).Part;
                enteries(1+connNextIndInd).Reciprocal=false;
                enteries(1+connNextIndInd).Vals=[];

                for PartInd=1:affectedPartsNum
                    PartsMapVal=obj.PartsMap(affectedParts(PartInd));
                    enteries(1+NextSegNum+PartInd).Cols=PartsMapVal.Cols;
                    enteries(1+NextSegNum+PartInd).Rows(connNextIndInd)=...
                    obj.PartsMap(connInd).Rows(1+connNextIndInd);
                    enteries(1+NextSegNum+PartInd).OtherPart=PartsMapVal.Part;
                    enteries(1+NextSegNum+PartInd).Reciprocal=false;
                    enteries(1+NextSegNum+PartInd).Vals=[];
                end
            end
        end

        function enteries=AddSegment(obj,segment)

            addedElems=segment.PolyDegree+1;
            if obj.isNotPrealloc
                obj.Matrix=[obj.Matrix...
                ,zeros(obj.N,addedElems,obj.NMats);...
                zeros(addedElems,obj.N+addedElems,obj.NMats)];
            end
            obj.PartsMap(end+1).Part=segment;
            obj.PartsMap(end).Cols=obj.N+1:obj.N+addedElems;
            obj.PartsMap(end).Rows=obj.N+1+1:obj.N+addedElems-1;
            obj.N=obj.N+addedElems;


            enteries=em.wire.solver.ImpedanceMatrix.CreateEnteriesStruct;
            allParts=[obj.PartsMap(:).Part];
            affectedParts=find([allParts.AffectedByOtherPartsZ]);
            for PartInd=1:length(affectedParts)
                PartsMapVal=obj.PartsMap(affectedParts(PartInd));
                enteries(PartInd).Cols=obj.PartsMap(end).Cols;
                enteries(PartInd).Rows=PartsMapVal.Rows;
                enteries(PartInd).OtherPart=PartsMapVal.Part;
                enteries(PartInd).Reciprocal=false;
                enteries(PartInd).Vals=[];
            end
            affectingOtherParts=find([allParts.AffectingOtherPartsZ]&...
            (allParts~=segment));
            for PartInd=1:length(affectingOtherParts)
                enteryInd=length(affectedParts)+PartInd;
                PartsMapVal=obj.PartsMap(affectingOtherParts(PartInd));
                enteries(enteryInd).Cols=PartsMapVal.Cols;
                enteries(enteryInd).Rows=obj.PartsMap(end).Rows;
                enteries(enteryInd).OtherPart=PartsMapVal.Part;
                enteries(enteryInd).Reciprocal=true;
                enteries(enteryInd).Vals=[];
            end
        end

        function enteries=GetSegmentEnteries(obj,segment)
            segInd=find(ismember([obj.PartsMap(:).Part],segment),1);

            enteries=em.wire.solver.ImpedanceMatrix.CreateEnteriesStruct;
            allParts=[obj.PartsMap(:).Part];
            affectedParts=find([allParts.AffectedByOtherPartsZ]);
            for PartInd=1:length(affectedParts)
                PartsMapVal=obj.PartsMap(affectedParts(PartInd));
                enteries(PartInd).Cols=obj.PartsMap(segInd).Cols;
                enteries(PartInd).Rows=PartsMapVal.Rows;
                enteries(PartInd).OtherPart=PartsMapVal.Part;
                enteries(PartInd).Reciprocal=false;
                enteries(PartInd).Vals=[];
            end











        end

        function Fill(obj,enteries,varargin)

            if((~isstruct(enteries))||...
                (~all(cellfun(@(x,y)strcmp(x,y),...
                fieldnames(enteries),...
                {'Cols';'Rows';'OtherPart';'Reciprocal';'Vals'}))))
                error(['Z Matrix Fill expects a structure with '...
                ,'fields: ''Cols'',''Rows'',''OtherPart'','...
                ,'''Reciprocal'',''Vals''']);
            end
            if nargin==2
                for PartInd=1:length(enteries)
                    obj.Matrix(enteries(PartInd).Rows,...
                    enteries(PartInd).Cols,:)=enteries(PartInd).Vals;
                end
            else
                for PartInd=1:length(enteries)
                    obj.Matrix(enteries(PartInd).Rows,...
                    enteries(PartInd).Cols,varargin{1})=...
                    enteries(PartInd).Vals;
                end
            end
        end

    end

    methods(Access=private,Static)


        function enteries=CreateEnteriesStruct
            enteries=struct('Cols',[],'Rows',[],'OtherPart',[],...
            'Reciprocal',[],'Vals',[]);
        end

    end
end