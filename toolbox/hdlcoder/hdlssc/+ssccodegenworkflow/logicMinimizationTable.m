classdef logicMinimizationTable<handle









    properties
        inputVectorSet=[];
        dontCareSet=[];
        terms=[]

        inputVectorSize=0;
        numberOfVectors=0;
        numberOfDCVectors=0;



        currentTerms={};
        currentNumberOfTerms={};

        primeImplicants=[];

        minimalCover=[];

        minimized=false;

        outputVar='';

    end

    methods
        function obj=logicMinimizationTable(inputVectorSet_in,dontCareSet_in,outputVar_in)




            if nargin<2
                dontCareSet_in=[];
            end
            if nargin<3
                outputVar_in='x';
            end
            obj.inputVectorSet=inputVectorSet_in;
            obj.dontCareSet=dontCareSet_in;
            obj.outputVar=outputVar_in;
            [obj.inputVectorSize,obj.numberOfVectors]=size(inputVectorSet_in);
            [~,obj.numberOfDCVectors]=size(dontCareSet_in);





            initalTerms=arrayfun(...
            @(i)ssccodegenworkflow.logicMinimizationTerm(i,[],[],sum(obj.getInput(i,0))),...
            1:obj.numberOfVectors);

            initalDcTerms=arrayfun(...
            @(i)ssccodegenworkflow.logicMinimizationTerm([],i,[],sum(obj.getInput(i,1))),...
            1:obj.numberOfDCVectors);


            obj.currentTerms=cell(obj.inputVectorSize+1,1);

            for i=1:obj.inputVectorSize+1
                obj.currentTerms{i}=[initalTerms(arrayfun(...
                @(term)term.numberOfOnes==i-1,initalTerms));...
                initalDcTerms(arrayfun(...
                @(term)term.numberOfOnes==i-1,initalDcTerms))];
            end
            obj.currentNumberOfTerms=max(arrayfun(...
            @(term)term.numberOfOnes,initalTerms))+1;

        end

        function inputVector=getInput(obj,i,dc)

            if dc
                inputVector=obj.dontCareSet(:,i);
            else
                inputVector=obj.inputVectorSet(:,i);
            end
        end

        function obj=generateNextStage(obj)




            nextTerms=cell(obj.currentNumberOfTerms-1,1);



            matchFound=false;


            for i=1:obj.currentNumberOfTerms-1

                for j=1:numel(obj.currentTerms{i})

                    for k=1:numel(obj.currentTerms{i+1})

                        irrBit=obj.compare(obj.currentTerms{i}(j),...
                        obj.currentTerms{i+1}(k));

                        if irrBit>0



                            matchFound=true;
                            obj.currentTerms{i}(j).prime=false;
                            obj.currentTerms{i+1}(k).prime=false;
                            newTerm=obj.currentTerms{i}(j).combine(obj.currentTerms{i+1}(k),irrBit);

                            alreadyAdded=false;
                            for uniqueCheck=1:numel(nextTerms{i})
                                irrBit=obj.compare(newTerm,...
                                nextTerms{i}(uniqueCheck));

                                if~irrBit


                                    nextTerms{i}(uniqueCheck).indecies=...
                                    unique([nextTerms{i}(uniqueCheck).indecies,...
                                    newTerm.indecies]);
                                    alreadyAdded=true;
                                    break;
                                end
                            end


                            if~alreadyAdded
                                nextTerms{i}=[nextTerms{i},newTerm];
                            end
                        end
                    end



                    if obj.currentTerms{i}(j).prime
                        obj.primeImplicants=[obj.primeImplicants,obj.currentTerms{i}(j)];
                    end
                end
            end

            for j=1:numel(obj.currentTerms{obj.currentNumberOfTerms})
                if obj.currentTerms{obj.currentNumberOfTerms}(j).prime
                    obj.primeImplicants=[obj.primeImplicants,obj.currentTerms{obj.currentNumberOfTerms}(j)];
                end
            end





            obj.currentTerms=nextTerms;
            obj.currentNumberOfTerms=numel(nextTerms);

            if obj.currentNumberOfTerms==1


                obj.primeImplicants=[obj.primeImplicants,...
                obj.currentTerms{1}];

                obj.minimized=true;
            end


            if~matchFound
                obj.minimized=true;
            end
        end

        function obj=minimizeLogic(obj)

            while~obj.minimized
                obj.generateNextStage();
            end

        end

        function obj=computeMinimalCover(obj)
            inputSet=1:obj.numberOfVectors;






            coverMap=zeros(numel(obj.primeImplicants),obj.numberOfVectors);

            for i=1:numel(obj.primeImplicants)
                coverMap(i,obj.primeImplicants(i).indecies)=1;
            end






            logicalDependentInputs=(sum(coverMap,1)==1);
            logicalEPIIndex=logical(sum(coverMap(:,logicalDependentInputs),2));

            EPIs=obj.primeImplicants(logicalEPIIndex);

            coverdInputs=arrayfun(@(term)term.indecies,EPIs,'UniformOutput',false);
            coverdInputs=unique(cell2mat(coverdInputs));


            coverMap=coverMap(~logicalEPIIndex,:);


            inputsLeft=setdiff(inputSet,coverdInputs);
            coverMap=coverMap(:,inputsLeft);

            if isempty(coverMap)

                obj.minimalCover=EPIs;
                return
            end








            termNumbers=1:numel(obj.primeImplicants);


            for i=numel(inputsLeft):-1:1
                PIsForInput=arrayfun(@(term)ismember(inputsLeft(i),term.indecies),obj.primeImplicants);

                coverTerms(i)=logicMinimizationCover(termNumbers(PIsForInput));
            end

            if numel(coverTerms)>1

                runningTerm=coverTerms(1).multiply(coverTerms(2));
                for i=3:numel(coverTerms)
                    runningTerm=runningTerm.multiply(coverTerms(i));
                end
            else
                runningTerm=coverTerms;
            end



            coverIndices=runningTerm.minCover();


            obj.minimalCover=[EPIs,obj.primeImplicants(coverIndices)];

        end


        function irrBit=compare(obj,term1,term2)





















            if any(term1.irrBits~=term2.irrBits)
                irrBit=-1;
            else
                [ind1,dc1]=term1.getFirstIndex();
                [ind2,dc2]=term2.getFirstIndex();

                vec1=obj.getInput(ind1,dc1);
                vec2=obj.getInput(ind2,dc2);

                vec1(term1.irrBits)=0;
                vec2(term2.irrBits)=0;

                diffVec=abs(vec1-vec2);

                numDiff=sum(diffVec);

                if numDiff==1
                    irrBit=find(diffVec==1,1);
                elseif numDiff==0
                    irrBit=0;
                else
                    irrBit=-1;
                end
            end

        end
        function outputStr=print(obj)


            if~isempty(obj.minimalCover)
                outputTerms=obj.minimalCover;
            else
                outputTerms=obj.primeImplicants;
            end

            logicFcn=cell(numel(outputTerms),1);


            for i=1:numel(outputTerms)

                currentTerm=outputTerms(i);

                [ind,dc]=currentTerm.getFirstIndex();

                assert(~dc,'This terms got into the cover by mistake')

                inputVector=obj.getInput(ind,dc);

                inputVector(currentTerm.irrBits)=-1;

                logicTerm=cell(obj.inputVectorSize-numel(currentTerm.irrBits),1);
                place=1;



                if all(inputVector==-1)
                    logicFcn(i)={'true'};
                else
                    for j=1:obj.inputVectorSize
                        if inputVector(j)==1
                            logicTerm{place}=['m(',num2str(j),')'];
                            place=place+1;
                        elseif inputVector(j)==0
                            logicTerm{place}=['~m(',num2str(j),')'];
                            place=place+1;
                        end
                    end
                    if place>2
                        logicFcn(i)=strcat('all([',join(logicTerm,', '),'])');
                    else
                        logicFcn(i)=logicTerm(1);
                    end

                end
            end
            if all(strcmp(logicFcn,'true'))
                outputStr=strcat(obj.outputVar,{' = true;'});
            else
                if numel(outputTerms)>1
                    outputStr=strcat(obj.outputVar,' = any([',join(logicFcn,', '),']);');
                else
                    outputStr=strcat(obj.outputVar,' = ',logicFcn,';');

                end
            end
        end

    end
end

