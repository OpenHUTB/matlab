



classdef SurrogateData<APIs.DataStorage
    properties




        dataStorage;

        indepVarName;
        responseNames={};
        responseCol;
        nResponses=0;
    end
    methods


        function self=SurrogateData(indepVarName_And_size,...
            response_And_size,options)

            if nargin<3
                options=struct();
            end

            self.indepVarName=indepVarName_And_size{1};
            nvar=indepVarName_And_size{2};

            start=1;nResponses=0;
            for ii=1:2:length(response_And_size)
                self.responseNames{end+1}=response_And_size{ii};
                nResponses=nResponses+response_And_size{ii+1};

                last=start+response_And_size{ii+1}-1;
                self.responseCol.(response_And_size{ii})=[start,last];
                start=last+1;
            end

            if isfield(options,'MaxFunctionEvaluations')
                allocRows=options.MaxFunctionEvaluations;
            else
                allocRows=500;
            end

            type=zeros(allocRows,1);

            self.dataStorage=struct(self.indepVarName,nan(allocRows,nvar),...
            'response',nan(allocRows,nResponses),...
            'flag',{cell(allocRows,1)},...
            'elapsedtime',nan(allocRows,1),...
            'type',type);
            self.nResponses=nResponses;
        end

        function self=setValue(self,index,params,values)


            response_reset=false;
            for ii=1:length(params)
                param=params{ii};
                if~isempty(values)
                    value=values{ii};
                else
                    value=[];
                end

                if ismember(param,self.responseNames)

                    if~isempty(value)
                        range_=self.responseCol.(param);
                        self.dataStorage.response(index,range_(1):range_(2))=value;
                    elseif~response_reset

                        self.dataStorage.response(index,:)=[];
                        response_reset=true;
                    end

                else
                    if~isempty(value)
                        self.dataStorage.(param)(index,:)=value;
                    else
                        self.dataStorage.(param)(index,:)=[];
                    end
                end
            end
        end

        function out=getValue(self,index,param)

            if isempty(index)
                index=1:size(self.dataStorage.type,1);
            end
            if ismember(param,self.responseNames)
                range_=self.responseCol.(param);
                out=self.dataStorage.response(index,range_(1):range_(2));
            elseif isfield(self.dataStorage,param)
                out=self.dataStorage.(param)(index,:);
            else
                out=[];
            end
        end

        function[self,index]=addData(self,aStruct)
            start=self.getEvalCount()+1;
            temp=aStruct.(self.indepVarName);
            last=size(temp,1)+start-1;
            params=fieldnames(aStruct);
            values=struct2cell(aStruct);


            if~any(strcmp('type',params))
                all_responses=true;
                for ii=1:length(self.responseNames)
                    if~strcmp(self.responseNames{ii},params)
                        all_responses=false;
                        break;
                    end
                end
                if all_responses
                    params{end+1}='type';
                    values{end+1}=ones(size(temp,1),1);
                end
            end
            for ii=1:length(values)-1
                assert(size(values(ii),1)==size(values(ii+1),1))
            end

            self=self.setValue(start:last,params,values);
            index=start:last;
        end

        function self=resetData(self)
            self.dataStorage.type=0;
        end

        function evalCount=getEvalCount(self)

            evalCount=nnz(self.dataStorage.type>0);
        end

        function out=getMetaData(self,name)
            nPoints=self.getEvalCount();
            out=self.dataStorage.(name)(1:nPoints);
        end

        function y=getResponsesMat(self,names)



            if~isscalar(self)
                error('Use of nonscalar data storage access not supported.');
            end
            if nargin==2
                if~isvector(names)
                    error('Invalid data indicator. ''indicator'' must be a scalar or a character vector.');
                end
                y=self.getResponsesMat_impl(names);
            else
                y=self.getResponsesMat_impl(self.getResponseNamesImpl());
            end
        end


        function names=getResponseNamesImpl(self)
            names=self.responseNames;
        end

        function colIndex=getResponseColumns(self)
            colIndex=self.responseCol;
        end


        function x=getIndependentVariableImpl(self,varargin)
            nPoints=self.getEvalCount();
            x=self.dataStorage.(self.indepVarName)(1:nPoints,:);
        end


        function y=getResponsesImpl(self,names)

            if any(ismember(names,self.responseNames)==0)
                error("Invalid response name");
            end
            if~iscell(names)
                names={names};
            end
            y=cell(1,length(names));
            nPoints=self.getEvalCount();

            for ii=1:length(names)
                range_=self.responseCol.(names{ii});
                y{ii}=self.dataStorage.response(1:nPoints,range_(1):range_(2));

            end
            if length(names)==1

                y=y{1};
            end



        end


        function Y=getResponsesMat_impl(self,names)

            if any(ismember(names,self.responseNames)==0)
                error("Invalid response name");
            end
            if~iscell(names)
                names={names};
            end

            nPoints=self.getEvalCount();
            colIndex=[];
            for ii=1:length(names)
                range_=self.responseCol.(names{ii});
                colIndex=horzcat(colIndex,range_(1):range_(2));
            end

            Y=self.dataStorage.response(1:nPoints,colIndex);

        end

    end
end
