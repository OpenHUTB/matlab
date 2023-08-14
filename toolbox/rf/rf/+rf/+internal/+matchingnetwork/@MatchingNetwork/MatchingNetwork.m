classdef MatchingNetwork<handle





    properties(Access=public,Dependent)
        SourceImpedance;
        LoadImpedance;
        CenterFrequency;
        Bandwidth;
        Components;
        LoadedQ;
    end

    properties(SetAccess=protected)
Circuit
    end


    properties(Access=protected)
        SourceImpedanceData;SourceDataType;SourceMetadata;
        LoadImpedanceData;LoadDataType;LoadMetadata;
        MatchCenterFrequency;
        MatchBandwidth;
        NumComponents;
    end


    properties(Access=protected)
        EvaluationParameters;
        PerformanceScores;
        PerformancePassed;
        PerformanceTestsFailed;
    end


    properties(Access=protected)
        AutoupdateEnabled=0;
        AutoGenerateEnabled=1;
        AutosortEnabled=1;
Nets
Values

AutoCkts
UserCkts
SortedCkts
AutoCktsNames
UserCktsNames
SortedCktsNames
    end


    properties(Access=protected,Constant)
        AutoCktNamePrefix='auto_';
        UserCktNamePrefix='user_';
        AllSourceLoadTypes={'Constant','FunctionHandle','AnalyzeCapableCircuitObject','CircuitObject','AntennaObject','RFDataObject','SParamObject','AnalyzeCapableDataObject'};
        LegalTopologySpecifications={'L','Pi','Tee'};
        LegalCircuitOutputFormats={'rfckt','circuit'};
        LegalEvaluationParameters={'gammain','Gt'};
    end


    methods

        function obj=MatchingNetwork(varargin)
            if(nargin>0)
                [varargin{:}]=convertStringsToChars(varargin{:});
            end
            p=obj.makeConstructorInputParser();
            parse(p,varargin{:});
            obj.SourceImpedance=p.Results.SourceImpedance;
            obj.LoadImpedance=p.Results.LoadImpedance;
            obj.CenterFrequency=p.Results.CenterFrequency;

            if(~isempty(p.Results.Bandwidth))
                obj.Bandwidth=p.Results.Bandwidth;
            else
                obj.LoadedQ=p.Results.LoadedQ;
            end

            if(~isempty(p.Results.Components))
                if(isnumeric(p.Results.Components))
                    validateattributes(p.Results.Components,...
                    {'numeric'},{'scalar','real','positive','>',1,'<=',3});
                    obj.NumComponents=p.Results.Components;

                elseif(ischar(p.Results.Components)||isstring(p.Results.Components))
                    val=validatestring(p.Results.Components,...
                    obj.LegalTopologySpecifications);
                    obj.NumComponents=val;
                end
            end


            obj.EvaluationParameters=rf.internal.matchingnetwork.MatchingNetworkEvaluationParameters();
            obj.EvaluationParameters=obj.EvaluationParameters.addEvaluationParameter({'Gt','>',-3,obj.FrequencyBand,1,'Automatic'});


            obj.AutoupdateEnabled=1;
            obj=obj.autoupdate();
        end


        function cktsOut=exportCircuits(obj,indexList,format)
            if(nargin<3||isempty(format))
                format='circuit';
            else
                format=validatestring(format,{'circuit','rfckt'},...
                'matchingnetwork','Format');
            end
            format=convertStringsToChars(format);

            if nargin<2
                indexList=1;
            elseif isempty(indexList)||...
                (~iscell(indexList)&&strcmpi(convertStringsToChars(indexList),'all'))
                indexList=1:length(obj.SortedCkts);
            elseif(isnumeric(indexList))
                validateattributes(indexList,{'numeric'},...
                {'nonempty','real','positive'},...
                mfilename,'Index list');
            else
                indexList=convertStringsToChars(indexList);
                validateattributes(indexList,{'cell','char'},{'vector'});
                if(ischar(indexList))
                    indexList={indexList};
                end
            end


            if(~isnumeric(indexList))
                [~,~,indexList]=obj.cktNamesToIndices(indexList);
            end

            if(strcmp(format,'rfckt'))











                cktsOut=topologyToRfckt(obj.Nets,obj.Values);
                cktsOut=cktsOut(indexList);
            elseif(strcmp(format,'circuit'))








                cktsOut=arrayfun(@clone,obj.SortedCkts(indexList));
                for k=1:numel(cktsOut)
                    cktsOut(k).Name=obj.SortedCktsNames{k};
                end
            end
        end


        function cktsOut=richards(obj,OpFreq,indexList)
            if nargin<3
                indexList=1;
                cktsOut=richards(exportCircuits(obj,indexList,'circuit'),OpFreq);
            else
                lumpedCkts=exportCircuits(obj,indexList,'circuit');
                cktsOut=arrayfun(@(x)richards(x,OpFreq),lumpedCkts);
            end
        end


        function[circuitData,performanceSummary]=circuitDescriptions(obj)
            dt={'string','double'};
            numComponents=length(obj.Nets(1,:));












            datatypes=[{'string'},repmat(dt,1,numComponents)];

            circuitData=table('Size',[length(obj.SortedCkts),1+2*numComponents],'VariableTypes',datatypes);

            varnames(1)={'circuitName'};
            varnames((1:numComponents).*2+1)=arrayfun(@(k)(['component',num2str(k),'Value']),1:numComponents,'UniformOutput',0);
            varnames((1:numComponents).*2-1+1)=arrayfun(@(k)(['component',num2str(k),'Type']),1:numComponents,'UniformOutput',0);

            rownames=arrayfun(@(k)(['Circuit ',num2str(k)]),1:length(obj.SortedCkts),'UniformOutput',0);

            circuitData.Properties.RowNames=rownames;
            circuitData.Properties.VariableNames=varnames;


            circuitData(1:length(obj.SortedCkts),1)=obj.SortedCktsNames;

            componentTypeMap={"Series C","Series L","Shunt C","Shunt L","Series R","Shunt R"};


            for(j=1:length(obj.SortedCkts))
                for(k=1:length(obj.Nets(1,:)))
                    curnet=obj.Nets(j,k);
                    if(curnet==0)
                        circuitData(j,k*2-1+1)={"--------"};
                        circuitData{j,k*2+1}=0;
                    else
                        circuitData(j,k*2-1+1)=componentTypeMap(curnet);
                        circuitData{j,k*2+1}=obj.Values(j,k);
                    end
                end
            end




































            u(1)={''};
            u((1:numComponents).*2+1)=repmat({'F or H'},1,numComponents);
            u((1:numComponents).*2-1+1)=repmat({''},1,numComponents);
            circuitData.Properties.VariableUnits=u;


            pass=cell(length(obj.PerformancePassed),1);
            pass(:)=repmat({"No"},length(obj.PerformancePassed),1);
            pass(find(obj.PerformancePassed))={"Yes"};%#ok<FNDSB> %Warning suppressed because attempted solution did not have the same behavior
            performanceSummary=table(convertCharsToStrings(obj.SortedCktsNames),pass,obj.PerformanceTestsFailed',num2cell(obj.PerformanceScores'));
            performanceSummary.Properties.VariableNames={'circuitName','evaluationPassed','testsFailed','performanceScore'};

            performanceSummary.Properties.RowNames=rownames;
        end


        function varargout=rfplot(obj,frequencyList,circuitIndices)

            if(nargin<3)
                circuitIndices=1:length(obj.SortedCkts);
            elseif(~isnumeric(circuitIndices))
                circuitIndices=convertStringsToChars(circuitIndices);
                validateattributes(circuitIndices,{'cell','char'},{'vector'});
                if(ischar(circuitIndices))
                    circuitIndices={circuitIndices};
                end
            end


            if(~isnumeric(circuitIndices))
                [~,~,circuitIndices]=obj.cktNamesToIndices(circuitIndices);
            end

            if(nargin<2||isempty(frequencyList))
                [frequencyList]=obj.constructFrequencyList();
            end
            validateattributes(circuitIndices,{'numeric'},{'real','finite','nonnan','nonnegative','<=',length(obj.SortedCkts)});
            validateattributes(frequencyList,{'numeric'},{'vector','real','finite','nonnan','positive','nondecreasing'});


            if(isempty(frequencyList))

                error(message('rf:matchingnetwork:NonIntersectSrcLoad'))
            end


            [scaledFrequencyList,frequencyScaleFactor,freqPrefix]=engunits(frequencyList);


            [~,srcZ]=obj.interpretImpedanceData(obj.SourceImpedanceData,obj.SourceDataType,frequencyList);
            [~,loadZ]=obj.interpretImpedanceData(obj.LoadImpedanceData,obj.LoadDataType,frequencyList);


            ckts=obj.exportCircuits(circuitIndices);


            h=gobjects(2,1);
            [hline{1:length(ckts)}]=deal(h);

            for k=1:length(circuitIndices)
                [gamma,gain]=obj.calcS11S21_circuitobj(srcZ,ckts(k),loadZ,frequencyList);
                gammadB=20*log10(abs(gamma));
                gaindB=10*log10(abs(gain));


                figure('Name',['Circuit ',num2str(circuitIndices(k))],'NumberTitle','off');
                hold on;


                hline{k}(1)=plot(scaledFrequencyList,gammadB,'b-');
                hline{k}(2)=plot(scaledFrequencyList,gaindB,'b--');


                evalparams=obj.getEvaluationParameters();
                for m=1:length(evalparams.Parameter)
                    x=evalparams.Band{m}(1);
                    w=evalparams.Band{m}(2)-evalparams.Band{m}(1);
                    if(strcmp(evalparams.Comparison{m},'>'))
                        h=1000;
                        y=evalparams.Goal{m}-h;
                    else
                        y=evalparams.Goal{m};
                        h=1000;
                    end
                    if(strcmp(evalparams.Parameter{m},'gammain'))
                        if(any(obj.PerformanceTestsFailed{circuitIndices(k)}==m))
                            color=[1,0,0,0.5];
                        else
                            color=[0,1,1,0.5];
                        end
                    else
                        if(any(obj.PerformanceTestsFailed{circuitIndices(k)}==m))
                            color=[1,0.65,0,0.5];
                        else
                            color=[0,1,0,0.5];
                        end
                    end
                    r=rectangle('Position',[x*frequencyScaleFactor,y,w*frequencyScaleFactor,h]);
                    r.FaceColor=color;
                end


                grid on;
                if(obj.PerformancePassed(circuitIndices(k)))
                    passedString=' (Passed)';
                else
                    passedString=' (Failed)';
                end

                title(['Performance for Circuit ',num2str(circuitIndices(k)),' (''',obj.SortedCktsNames{circuitIndices(k)},''') ',passedString],'Interpreter','none');
                xlabel(['Frequency (',freqPrefix,'Hz)']);
                ylabel('Magnitude (dB)');
                ylim([-20,0]);
                legend({['Circuit ',num2str(circuitIndices(k)),': |gammain|, dB'],['Circuit ',num2str(circuitIndices(k)),': |Gt|, dB']});
                hold off;

            end
            if(nargout>0)
                varargout{:}=hline;
            end
        end
    end

    methods

        h=toleranceAnalysis(obj,tolerances,frequencyList,indices);
    end


    methods(Access=public)
        function disp(obj)
            propertyNames=fields(obj);
            if~isscalar(obj)
                [M,N]=size(obj);
                if feature('hotlinks')
                    fprintf('  %dx%d <a href="matlab:helpPopup matchingnetwork">matchingnetwork</a> array with properties:\n\n',...
                    M,N);
                else
                    fprintf('  %dx%d matchingnetwork array with properties:\n\n',...
                    M,N);
                end
                cellfun(@(s)fprintf('    %s\n',s),propertyNames)
            else
                if feature('hotlinks')
                    fprintf('  <a href="matlab:helpPopup matchingnetwork">matchingnetwork</a> with properties:\n\n')
                else
                    fprintf('  matchingnetwork with properties:\n\n')
                end

                fprintf('%22s: ',propertyNames{1});
                if(isa(obj.SourceImpedance,'double'))
                    if(isscalar(obj.SourceImpedance))
                        [o,~,units]=engunits(obj.SourceImpedance);
                        fprintf('%d ',real(o));
                        if(~isreal(o))
                            fprintf('%+dj ',imag(o));
                        end
                        fprintf('%sOhms\n',units);
                    else
                        dims=size(obj.SourceImpedance);
                        fprintf('[%dx%d double]\n',dims(1),dims(2));
                    end
                elseif(isa(obj.SourceImpedance,'char'))
                    fprintf('''%s''\n',obj.SourceImpedance);
                else
                    fprintf('[1x1 %s]\n',class(obj.SourceImpedance));
                end


                fprintf('%22s: ',propertyNames{2});
                if(isa(obj.LoadImpedance,'double'))
                    if(isscalar(obj.LoadImpedance))
                        [o,~,units]=engunits(obj.LoadImpedance);
                        fprintf('%d ',real(o));
                        if(~isreal(o))
                            fprintf('%+dj ',imag(o));
                        end
                        fprintf('%sOhms\n',units);
                    else
                        dims=size(obj.LoadImpedance);
                        fprintf('[%dx%d double]\n',dims(1),dims(2));
                    end
                elseif(isa(obj.LoadImpedance,'char'))
                    fprintf('''%s''\n',obj.LoadImpedance);
                else
                    fprintf('[1x1 %s]\n',class(obj.LoadImpedance));
                end


                [fc,~,units]=engunits(obj.CenterFrequency);
                fprintf('%22s: %.5g %sHz\n',propertyNames{3},fc,units);


                if((isnumeric(obj.Components)&&obj.Components>2)||(ischar(obj.Components)&&~strcmp(obj.Components,'L')))
                    [bw,~,units]=engunits(obj.Bandwidth);
                    fprintf('%22s: %.5g %sHz\n',propertyNames{4},bw,units);
                end


                fprintf('%22s: ',propertyNames{5});
                if(isa(obj.Components,'char'))
                    fprintf('''%s''\n',obj.Components);
                else
                    fprintf('%d\n',obj.Components);
                end


                if((isnumeric(obj.Components)&&obj.Components>2)||(ischar(obj.Components)&&~strcmp(obj.Components,'L')))
                    fprintf('%22s: %.5g\n',propertyNames{6},obj.LoadedQ);
                end


                fprintf('%22s: [1x%d %s]\n',propertyNames{7},...
                numel(obj.Circuit),class(obj.Circuit))
            end
        end


        function s=sparameters(obj,freq,Z0,circuitIndices)

            if(nargin>1&&~isempty(freq))
                frequencyList=freq;
            else
                [frequencyList]=obj.constructFrequencyList();
            end

            if(nargin<3||isempty(Z0))
                Z0=50;
            end

            if(nargin<4||isempty(circuitIndices))
                circuitIndices=1;
            end


            if(~isnumeric(circuitIndices))
                circuitIndices=convertStringsToChars(circuitIndices);
                validateattributes(circuitIndices,{'cell','char'},{'vector'});
                if(ischar(circuitIndices))
                    circuitIndices={circuitIndices};
                end
            end


            testCircuits=obj.exportCircuits(circuitIndices,'circuit');
            s=arrayfun(@(ckt)(sparameters(ckt,frequencyList,Z0)),testCircuits);
        end






























        function varargout=smithplot(obj,varargin)
            if nargin>0
                [varargin{:}]=convertStringsToChars(varargin{:});
            end
            updatedargin=varargin;

            ind=find(strcmpi(varargin,'circuitIndex'));
            if(~isempty(ind))
                if(isnumeric(varargin{ind(1)+1}))
                    validateattributes(varargin{ind(1)+1},{'numeric'},...
                    {'nonempty','real','positive','scalar','<=',...
                    length(obj.SortedCkts),'size',[1,1],'nonnan','nonzero'},...
                    mfilename,'Index list');
                    circuitIndices=varargin{ind(1)+1};
                else
                    indexList=convertStringsToChars(varargin{ind(1)+1});
                    validateattributes(indexList,{'char'},{'nonempty','scalartext'});
                    if(ischar(indexList))
                        indexList={indexList};
                    end
                    [~,~,circuitIndices]=obj.cktNamesToIndices(indexList);
                end
                updatedargin(ind(1):ind(1)+1)=[];
            else
                circuitIndices=1;
            end
            ind=find(strcmpi(updatedargin,'Z0'));
            if(~isempty(ind))
                validateattributes(updatedargin{ind(1)+1},{'numeric'},...
                {'nonempty','real','positive','scalar','size',[1,1],...
                'nonnan','nonzero'},...
                mfilename,'Characteristic Impedance');
                Z0=updatedargin{ind(1)+1};
                updatedargin(ind(1):ind(1)+1)=[];
            else
                Z0=50;
            end
            varargout{:}=smithp(obj,circuitIndices,Z0,updatedargin{:});
        end

        function out=copy(obj)
            out=matchingnetwork;
            out.AutoupdateEnabled=false;

            out.SourceImpedance=obj.SourceImpedance;
            out.LoadImpedance=obj.LoadImpedance;
            out.CenterFrequency=obj.CenterFrequency;
            out.Bandwidth=obj.Bandwidth;
            out.LoadedQ=obj.LoadedQ;
            out.Components=obj.Components;


            out.Circuit=arrayfun(@(x)clone(x),obj.Circuit);

            out.EvaluationParameters=obj.EvaluationParameters;
            out.PerformanceScores=obj.PerformanceScores;
            out.PerformancePassed=obj.PerformancePassed;
            out.PerformanceTestsFailed=obj.PerformanceTestsFailed;

            out.AutoCkts=arrayfun(@(x)clone(x),obj.AutoCkts);
            out.UserCkts=arrayfun(@(x)clone(x),obj.UserCkts);
            out.SortedCkts=arrayfun(@(x)clone(x),obj.SortedCkts);
            out.AutoCktsNames=obj.AutoCktsNames;
            out.UserCktsNames=obj.UserCktsNames;
            out.SortedCktsNames=obj.SortedCktsNames;

            out.Nets=obj.Nets;
            out.Values=obj.Values;
            out.AutoGenerateEnabled=obj.AutoGenerateEnabled;
            out.AutosortEnabled=obj.AutosortEnabled;
            out.AutoupdateEnabled=obj.AutoupdateEnabled;
        end
    end


    methods(Access=public)




        function obj=addNetwork(obj,userCircuits,userCircuitNames)
            if(nargin<3)
                userCircuitNames={};
            end


            validateattributes(userCircuits,{'circuit','rfckt'},{'vector'});
            for j=1:length(userCircuits)

                if length(userCircuits(j).Ports)~=2
                    error(message('rf:matchingnetwork:IncorrectSetPorts',...
                    num2str(length(userCircuits(j).Ports))))
                end
            end
            temp=arrayfun(@obj.parseCircuitObject,userCircuits,'UniformOutput',false);
            userCircuits=arrayfun(@clone,userCircuits);
            userCircuits=reshape(userCircuits,[length(userCircuits),1]);


            if(~isempty(userCircuitNames))
                validateattributes(userCircuitNames,{'cell','char','string'},{});
                if(iscell(userCircuitNames))
                    validateattributes(userCircuitNames,{'cell'},{'vector'});
                else
                    if(isstring(userCircuitNames))
                        validateattributes(userCircuitNames,{'string'},{'vector'});
                    end
                    userCircuitNames=cellstr(userCircuitNames);
                end
                userCircuitNames=reshape(userCircuitNames,[length(userCircuitNames),1]);
            end


            obj.UserCkts=[obj.UserCkts;userCircuits];


            obj.UserCktsNames=[obj.UserCktsNames;userCircuitNames];


            if(length(obj.UserCktsNames)>length(obj.UserCkts))
                obj.UserCktsNames(length(obj.UserCkts)+1:end)=[];
            else
                for j=length(obj.UserCktsNames)+1:length(obj.UserCkts)
                    obj.UserCktsNames{j,1}=[obj.UserCktNamePrefix,num2str(j)];
                end
            end

            obj.autoupdate();

        end





        function obj=deleteNetwork(obj,circuitsToDelete)

            if(isnumeric(circuitsToDelete))
                validateattributes(circuitsToDelete,{'numeric'},{'nonempty','real','positive','<=',length(obj.SortedCkts)});
            else
                circuitsToDelete=convertStringsToChars(circuitsToDelete);
                validateattributes(circuitsToDelete,{'cell','char'},{'vector'});
                if(ischar(circuitsToDelete))
                    circuitsToDelete={circuitsToDelete};
                end
            end


            if(isnumeric(circuitsToDelete))
                cktnames=obj.SortedCktsNames(circuitsToDelete);
            else
                cktnames=circuitsToDelete;
            end


            [autoIndices,userIndices,sortedIndices]=obj.cktNamesToIndices(cktnames);


            obj.AutoCkts(autoIndices)=[];
            obj.AutoCktsNames(autoIndices)=[];
            obj.UserCkts(userIndices)=[];
            obj.UserCktsNames(userIndices)=[];
            obj.SortedCkts(sortedIndices)=[];
            obj.SortedCktsNames(sortedIndices)=[];

            obj.autoupdate();
        end


        function disableAutomaticNetworks(obj)
            obj.AutoGenerateEnabled=0;
            tempCkts=obj.exportCircuits(obj.AutoCktsNames);
            obj.deleteNetwork(obj.AutoCktsNames);
            obj.addNetwork(tempCkts);
        end

        function enableAutomaticNetworks(obj)
            obj.AutoGenerateEnabled=1;
            obj.autoupdate();
        end
    end




    methods(Access=public)
        function obj=addEvaluationParameter(obj,parameter,comparison,targetdB,band,weight,desiredIndex)
            if(nargin<7)
                desiredIndex=inf;
            end
            [parameter,comparison]=convertStringsToChars(parameter,comparison);
            validateattributes(parameter,{'char'},{'nonempty','scalartext'});
            validatestring(parameter,obj.LegalEvaluationParameters);

            validateattributes(comparison,{'char'},{'scalar'});
            validatestring(comparison,{'<','>'});

            validateattributes(targetdB,{'numeric'},{'scalar','real','finite','nonnan'});
            validateattributes(band,{'numeric'},{'vector','real','finite','nonnan','positive','nondecreasing'});
            validateattributes(weight,{'numeric'},{'scalar','real','finite','nonnan','positive'});

            validateattributes(desiredIndex,{'numeric'},{'scalar','real','nonnan','positive'});


            obj.EvaluationParameters=obj.EvaluationParameters.addEvaluationParameter({parameter,comparison,targetdB,band,weight,'User-specified'},desiredIndex);
            obj=obj.autoupdate();
        end

        function c=getEvaluationParameters(obj)
            c=obj.EvaluationParameters.getEvaluationParameters();
        end

        function obj=clearEvaluationParameter(obj,indices)
            obj.EvaluationParameters=obj.EvaluationParameters.clearEvaluationParameter(indices);
            obj=obj.autoupdate();
        end

    end



    methods(Access=protected)
        function obj=autoupdate(obj)
            if(obj.AutoupdateEnabled)
                obj.Nets=0;
                obj.Values=0;
                if(obj.AutoGenerateEnabled)

                    [~,srcZ]=obj.interpretImpedanceData(obj.SourceImpedanceData,obj.SourceDataType,obj.MatchCenterFrequency);
                    [~,loadZ]=obj.interpretImpedanceData(obj.LoadImpedanceData,obj.LoadDataType,obj.MatchCenterFrequency);


                    if(isnan(srcZ)||isnan(loadZ))
                        error(message('rf:matchingnetwork:CantEvalSrcZLoadZ'));
                    end

                    if(~isstring(obj.NumComponents)&&~ischar(obj.NumComponents))
                        if(obj.NumComponents==2)
                            [obj.AutoCkts,obj.Nets,obj.Values]=generateLMatchingNetworks(srcZ,loadZ,obj.MatchCenterFrequency);
                        elseif(obj.NumComponents==3)
                            [obj.AutoCkts,obj.Nets,obj.Values]=generatePiTMatchingNetworks(srcZ,loadZ,obj.MatchCenterFrequency,obj.LoadedQ,'both');
                        else

                        end

                    elseif(strcmp(obj.NumComponents,'L'))
                        [obj.AutoCkts,obj.Nets,obj.Values]=generateLMatchingNetworks(srcZ,loadZ,obj.MatchCenterFrequency);
                    elseif(strcmp(obj.NumComponents,'Pi')||strcmp(obj.NumComponents,'Tee'))
                        [obj.AutoCkts,obj.Nets,obj.Values]=generatePiTMatchingNetworks(srcZ,loadZ,obj.MatchCenterFrequency,obj.LoadedQ,obj.NumComponents);
                    else
                        [obj.AutoCkts,obj.Nets,obj.Values]=generatePiTMatchingNetworks(srcZ,loadZ,obj.MatchCenterFrequency,obj.LoadedQ,'both');
                    end


                    obj.AutoCktsNames=cell([length(obj.AutoCkts),1]);
                    for j=1:length(obj.AutoCkts)
                        obj.AutoCktsNames{j}=[obj.AutoCktNamePrefix,num2str(j)];
                    end
                end


                obj.SortedCkts=[];
                obj.SortedCktsNames={};
                if(~isempty(obj.AutoCkts))
                    obj.SortedCkts=arrayfun(@clone,obj.AutoCkts);
                    obj.SortedCktsNames=obj.AutoCktsNames;
                end
                if(~isempty(obj.UserCkts))
                    obj.SortedCkts=[obj.SortedCkts;arrayfun(@clone,obj.UserCkts)];
                    obj.SortedCktsNames=[obj.SortedCktsNames;obj.UserCktsNames];
                end



                e=obj.getEvaluationParameters();
                sources=e.Source;
                autoindex=find(strcmp(sources,'Automatic'),1);
                if(~isempty(autoindex))
                    obj.EvaluationParameters=obj.EvaluationParameters.clearEvaluationParameter(autoindex);
                    obj.EvaluationParameters=obj.EvaluationParameters.addEvaluationParameter({'Gt','>',-3,obj.FrequencyBand,1,'Automatic'},autoindex);
                end




                obj=obj.autosort();
            end
        end


        function obj=autosort(obj)
            if(~obj.AutosortEnabled)
                return;
            end

            freqList=obj.constructFrequencyList();


            [~,srcZ]=obj.interpretImpedanceData(obj.SourceImpedanceData,obj.SourceDataType,freqList);
            [~,loadZ]=obj.interpretImpedanceData(obj.LoadImpedanceData,obj.LoadDataType,freqList);




            circuitPerformance=zeros(1,length(obj.SortedCkts));

            c=obj.exportCircuits('all');
            passed=zeros(1,length(c));
            testsFailed=cell(1,length(c));

            for k=1:length(obj.SortedCkts)
                [gamma,gain]=obj.calcS11S21_circuitobj(srcZ,c(k),loadZ,freqList);
                [circuitPerformance(k),passed(k),testsFailed{k}]=obj.EvaluationParameters.evaluatePerformance(20*log10(abs(gamma)),10*log10(abs(gain)),freqList);
            end



            [obj.PerformanceScores,sortedIndices]=sort(circuitPerformance,'descend');
            obj.PerformancePassed=passed(sortedIndices);
            obj.PerformanceTestsFailed=testsFailed(sortedIndices);


            obj.SortedCkts=obj.SortedCkts(sortedIndices);
            obj.SortedCktsNames=obj.SortedCktsNames(sortedIndices);


            userCktNets=zeros([length(obj.UserCkts),1]);
            userCktValues=userCktNets;
            for(j=1:length(obj.UserCkts))
                [tempnet,tempval,flag]=obj.parseCircuitObject(obj.UserCkts(j),false);

                if(flag~=0)
                    tempnet=[];
                    tempval=[];

                end

                if(length(tempnet)<length(userCktNets(1,:)))

                    tempnet(1,end+1:length(userCktNets(1,:)))=0;
                    tempval(1,end+1:length(userCktNets(1,:)))=0;
                elseif(length(tempnet)>length(userCktNets(1,:)))

                    userCktNets(:,end+1:length(tempnet))=0;
                    userCktValues(:,end+1:length(tempnet))=0;
                end
                userCktNets(j,:)=tempnet;
                userCktValues(j,:)=tempval;
            end


            if(~isempty(userCktNets))
                if(length(userCktNets(1,:))<length(obj.Nets(1,:)))

                    userCktNets(:,end+1:length(obj.Nets(1,:)))=0;
                    userCktValues(:,end+1:length(obj.Nets(1,:)))=0;
                elseif(length(userCktNets(1,:))>length(obj.Nets(1,:)))

                    obj.Nets(:,end+1:length(userCktNets(1,:)))=0;
                    obj.Values(:,end+1:length(userCktNets(1,:)))=0;
                end

                if(isempty(obj.AutoCkts)&&~isempty(obj.UserCkts)&&~any(obj.Nets))
                    obj.Nets=zeros(0,length(userCktNets(1,:)));
                    obj.Values=zeros(0,length(userCktNets(1,:)));
                end
                obj.Nets=[obj.Nets;userCktNets];
                obj.Values=[obj.Values;userCktValues];
            end




            obj.Nets=obj.Nets(sortedIndices,:);
            obj.Values=obj.Values(sortedIndices,:);

        end


        function[frequencyList]=constructFrequencyList(obj)
            srcFreq=obj.interpretImpedanceData(obj.SourceImpedanceData,obj.SourceDataType,[]);
            loadFreq=obj.interpretImpedanceData(obj.LoadImpedanceData,obj.LoadDataType,[]);

            frequencyList=[];

            if(~isequal(srcFreq,[0,inf]))
                frequencyList=srcFreq;
            end
            if(~isequal(loadFreq,[0,inf]))
                frequencyList=union(frequencyList,loadFreq);
            end




            if(~isempty(frequencyList))
                frequencyList=union(obj.EvaluationParameters.getEvaluationBand(),frequencyList);
            else
                frequencyList=union(obj.EvaluationParameters.getEvaluationBand(),obj.FrequencyBand);
                frequencyList=union(frequencyList,linspace(frequencyList(1),frequencyList(end),1000));
            end




            frequencyList(frequencyList>srcFreq(end))=[];
            frequencyList(frequencyList<srcFreq(1))=[];
            frequencyList(frequencyList>loadFreq(end))=[];
            frequencyList(frequencyList<loadFreq(1))=[];
            frequencyList(frequencyList==0)=[];
        end



        function[autoIndices,userIndices,sortedIndices]=cktNamesToIndices(obj,names)



            try
                tempIndices=arrayfun(@(n)(find(strcmp(n,obj.AutoCktsNames))),names,'UniformOutput',false);
                autoIndices=[tempIndices{cellfun(@(k)(~isempty(k)),tempIndices)}];
            catch
                autoIndices=[];
            end

            try
                tempIndices=arrayfun(@(n)(find(strcmp(n,obj.UserCktsNames))),names,'UniformOutput',false);
                userIndices=[tempIndices{cellfun(@(k)(~isempty(k)),tempIndices)}];
            catch
                userIndices=[];
            end

            try
                tempIndices=arrayfun(@(n)(find(strcmp(n,obj.SortedCktsNames))),names,'UniformOutput',false);
                sortedIndices=[tempIndices{cellfun(@(k)(~isempty(k)),tempIndices)}];
            catch
                userIndices=[];
            end






        end
    end

    methods

        function set.SourceImpedance(obj,z)
            [obj.SourceImpedanceData,obj.SourceDataType,obj.SourceMetadata]=assignImpedanceData(z);
            obj.autoupdate();
        end


        function set.LoadImpedance(obj,z)
            [obj.LoadImpedanceData,obj.LoadDataType,obj.LoadMetadata]=assignImpedanceData(z);
            obj.autoupdate();
        end


        function set.CenterFrequency(obj,f)
            validateattributes(f,{'numeric'},{'scalar','real','finite','positive'});
            obj.MatchCenterFrequency=f;
            obj.autoupdate();
        end


        function set.Bandwidth(obj,bw)
            bw_old=obj.MatchBandwidth;
            validateattributes(bw,{'numeric'},{'scalar','real','finite','nonnan','positive'});
            try
                obj.MatchBandwidth=bw;
                obj.autoupdate();
            catch ME
                obj.MatchBandwidth=bw_old;
                rethrow(ME)
            end
        end


        function set.Components(obj,n)
            n=convertStringsToChars(n);
            validateattributes(n,{'numeric','string','char'},{});
            if(isnumeric(n))
                validateattributes(n,{'numeric'},...
                {'scalar','real','positive','>',1,'<=',3});
                obj.NumComponents=n;
            else
                n=validatestring(n,obj.LegalTopologySpecifications);
                obj.NumComponents=n;
            end
            obj.autoupdate();
        end



        function set.LoadedQ(obj,q)
            validateattributes(q,{'numeric'},{'scalar','real','finite','positive'});
            obj.Bandwidth=obj.MatchCenterFrequency/q;
        end

    end


    methods
        function z=get.SourceImpedance(obj)
            z=obj.SourceMetadata;
        end

        function z=get.LoadImpedance(obj)
            z=obj.LoadMetadata;
        end

        function fc=get.CenterFrequency(obj)
            fc=obj.MatchCenterFrequency;
        end

        function bw=get.Bandwidth(obj)
            bw=obj.MatchBandwidth;
        end

        function n=get.Components(obj)
            n=obj.NumComponents;
        end

        function q=get.LoadedQ(obj)
            q=obj.MatchCenterFrequency/obj.MatchBandwidth;
        end

        function c=get.Circuit(obj)
            c=exportCircuits(obj,'all');
        end
    end


    methods(Access=protected)
        function fb=FrequencyBand(obj)
            fb=[obj.MatchCenterFrequency-obj.MatchBandwidth/2,obj.MatchCenterFrequency+obj.MatchBandwidth/2];

        end
    end

    methods(Access=protected,Static)
        function p=makeConstructorInputParser()
            p=inputParser;
            p.CaseSensitive=false;
            addParameter(p,'SourceImpedance',50);
            addParameter(p,'LoadImpedance',50);
            addParameter(p,'CenterFrequency',1e9);
            addParameter(p,'Bandwidth',[]);
            addParameter(p,'Components',2);
            addParameter(p,'LoadedQ',10);
        end
    end


    methods(Access=protected)

        [z,datatype,metadata]=assignImpedanceData(zData);


        z=calcImpedance(componentType,value,frequency);
        [type,value]=calcComponent(reactance,frequency);
        X=calculateMatchImpedancesShuntSeries(sourceImpedance,loadImpedance);
        [ckts,net,values]=generateLMatchingNetworks(sourceImpedance,loadImpedance,targetFrequency);
        [net,comp]=makeLNet(reactancesShuntSeries,frequency);
        X=oneElemenetMatch(sourceImpedance,loadImpedance);
        ckt=topologyToRfckt(net,values);


        virtualResistances=calculateVirtualResistancesPi(srcZ,loadZ,targetQ);
        virtualResistances=calculateVirtualResistancesT(srcZ,loadZ,targetQ);
        [net,values]=makeUnmergedLNetSeries(allExtImpedances,targetFrequency);
        [netsOut,valuesOut]=simplifyNets(netsIn,valuesIn,centerFrequency,combineOppositeImpedances);
        [ckts,net,values]=generatePiTMatchingNetworks(sourceImpedance,loadImpedance,targetFrequency,targetQ,type);








    end


    methods(Access=protected)
        [frequencyData,zData]=interpretImpedanceData(this,dataobj,dataObjType,freq);
        [gamma,efficiency]=calcS11S21_circuitobj(obj,srcZ,matchCkt,loadZ,band);

        [Net,Values,errorflag]=parseCircuitObject(obj,c,verbose);
        varargout=smithp(obj,circuitIndices,Z0,varargin);
    end







end

