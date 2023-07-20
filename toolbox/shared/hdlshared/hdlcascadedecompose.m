function decomp=hdlcascadedecompose(in,mode,latency,NumberOfOperators)









    decomp=[];

    if(nargin<=2)
        latency=-1;
        NumberOfOperators=-1;
    end


    in=prod(in);


    if in==1
        decomp=[];
    elseif mode==0||in<4
        decomp=validate(in);
    elseif mode==1
        if latency==-1&&NumberOfOperators==-1
            [AllSolutions,decomp]=OptimizeLatency4MuxSize(in,mode,0);
        elseif latency==0||NumberOfOperators==0
            decomp=[];
        elseif latency==1
            if in==1
                decomp=validate(in);
            else
                decomp=[];
            end
        elseif NumberOfOperators==1
            decomp=validate(in);
        elseif latency>1&&NumberOfOperators==-1

            intmp=in-latency+1;
            [AllSolutions,Optdecomp]=OptimizeLatency4MuxSize(intmp,mode,0);
            if~isempty(Optdecomp)
                decomp=validate([latency,Optdecomp]);
            end
        elseif NumberOfOperators>1&&latency==-1
            [AllSolutions,Optdecomp]=OptimizeLatency4MuxSize(in,mode,0);
            if NumberOfOperators==length(Optdecomp)

                decomp=validate(Optdecomp);
            elseif NumberOfOperators>length(Optdecomp)

                decomp=[];
            else
                decomp=validate(FindOperatorBasedSolution(in,NumberOfOperators));
            end
        elseif latency>1&&NumberOfOperators>1
            intmp=in-latency+1;
            [AllSolutions,Optdecomp]=OptimizeLatency4MuxSize(intmp,mode,0);
            if~isempty(Optdecomp)
                tmp=[latency,Optdecomp];
                if length(tmp)==NumberOfOperators
                    decomp=validate(tmp);
                end
                decomp=[];
            end

            if isempty(decomp)
                tmp=FindOperatorBasedSolution(in,NumberOfOperators);
                if tmp(1)==latency
                    decomp=validate(tmp);
                end
            end
        else
            decomp=[];
        end
    elseif mode==2
        if latency==-1&&NumberOfOperators==-1
            [AllSolutions,decomp]=OptimizeLatency4Operator(in,-1);
        elseif latency==0||NumberOfOperators==0
            decomp=[];
        elseif latency==1
            if in==1
                decomp=[in];
            else
                decomp=[];
            end
        elseif NumberOfOperators==1
            if latency==in
                decomp=[in];
            else
                decomp=[];
            end
        elseif latency>1&&NumberOfOperators==-1

            [AllSolutions,Optdecomp]=OptimizeLatency4Operator(in,latency);
            decomp=validate(Optdecomp);
        elseif NumberOfOperators>1&&latency==-1
            [AllSolutions,Optdecomp]=OptimizeLatency4Operator(in,-1);
            if NumberOfOperators==length(Optdecomp)

                decomp=validate(Optdecomp);
            elseif NumberOfOperators>length(Optdecomp)

                decomp=[];
            else
                decomp=validate(FindOperatorBasedSolution(in,NumberOfOperators));
            end
        elseif latency>1&&NumberOfOperators>1
            [AllSolutions,Optdecomp]=OptimizeLatency4Operator(in,latency);
            for ii=1:length(AllSolutions)
                tmp=AllSolutions{1,ii};
                if tmp(1)==latency
                    if length(tmp)==NumberOfOperators
                        decomp=validate(tmp);
                    end
                end
            end
            if isempty(decomp)
                tmp=FindOperatorBasedSolution(in,NumberOfOperators);
                if tmp(1)==latency
                    decomp=validate(tmp);
                end
            end
        else
            decomp=[];
        end
    end


    function exists=IsSolutionExists(in,first_entry)
        sumIn=0;
        correction=0;
        for i=2:first_entry
            sumIn=sumIn+i;
            correction=i-2;
        end
        if sumIn>=in+correction
            exists=1;
        else
            exists=0;
        end


        function[allSolutions,OptimalSolution]=OptimizeLatency4MuxSize(in,mode,option)
            OptimalSolution=[in];
            allSolutions={};

            tmp_decomp=[];
            min_decomp=3;


            if in==1
                OptimalSolution=[];
            elseif(in<=min_decomp|mode==0)
                tmp_decomp=[tmp_decomp,in];
                OptimalSolution=tmp_decomp;
            else
                if option==0




                    first_entry=in;
                    while IsSolutionExists(in,first_entry)
                        first_entry=first_entry-1;
                    end
                    first_entry=first_entry+1;
                    remainder=in-first_entry+1;
                    tmp_decomp=[tmp_decomp,first_entry];
                    [tmp,newSolution]=OptimizeLatency4MuxSize(remainder,1,option);
                    tmp_decomp=[tmp_decomp,newSolution];
                    OptimalSolution=tmp_decomp;
                elseif option==1




                    first_entry=in-1;
                    remainder=in-first_entry+1;
                    tmp_decomp=[tmp_decomp,first_entry];


                    while IsSolutionExists(in,first_entry)
                        [tmp,newSolution]=OptimizeLatency4MuxSize(remainder,1,option);
                        tmp_decomp=[tmp_decomp,newSolution];
                        allSolutions{end+1}=tmp_decomp;
                        if max(tmp_decomp)<=max(OptimalSolution)
                            OptimalSolution=tmp_decomp;
                            tmp_decomp=[];
                        end
                        first_entry=first_entry-1;
                        remainder=in-first_entry+1;
                        tmp_decomp=[tmp_decomp,first_entry];
                    end

                else
                    msg('Not Valid Option')
                end
            end


            function[allSolutions,OptimalSolution]=OptimizeLatency4Operator(in,first_entry)
                OptimalSolution=[in];
                allSolutions={};

                if first_entry==-1
                    first_entry=in;
                    while IsSolutionExists(in,first_entry)
                        first_entry=first_entry-1;
                    end
                    first_entry=first_entry+1;
                else
                    if~IsSolutionExists(in,first_entry)
                        first_entry=-1;
                        OptimalSolution=[];
                    end
                end

                if first_entry>0
                    decomp=[first_entry];
                    sumDecomp=sum(decomp)-length(decomp)+1;
                    while sumDecomp<in
                        decomp=[decomp,(decomp(end)-1)];
                        sumDecomp=sum(decomp)-length(decomp)+1;
                    end
                    if sumDecomp>in
                        decomp(end)=decomp(end)-(sumDecomp-in);
                    end
                    OptimalSolution=decomp;
                end


                function[decomp]=FindOperatorBasedSolution(in,NumberOfOperators)
                    decomp=[];
                    NumberOfInputs=(in+NumberOfOperators-1);
                    tmp=floor((NumberOfInputs/NumberOfOperators));
                    first_entry=tmp+NumberOfOperators;
                    last_entry=-1;
                    while last_entry<=1
                        first_entry=first_entry-1;
                        decomp=[first_entry];
                        for ii=1:NumberOfOperators-2
                            decomp=[decomp,(first_entry-ii)];
                        end
                        last_entry=NumberOfInputs-sum(decomp);
                    end
                    decomp=[decomp,last_entry];


                    function[out]=validate(in)
                        out=[in];
                        for i=1:length(in)-1
                            if in(i)<=in(i+1)
                                out=[];
                            end
                        end
