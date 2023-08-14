classdef Sadea<handle

    properties
        hasObj;
        perf_best;
        iter;
        tr;
        Realbestmem;
        logDims;
        MeanStd;
        bound_v;
        w;
    end

    properties(Access=private)
        VTR=1.e-6;
        D;
        XVmin;
        XVmax;
        N;
        NP2;
        F;
        ns;
        type;
        refresh;
        nfeval;
        nfevalmax;
        ISS;
        parfor_o;
        ncores;
        popA;
        valA;
        CRm;
        CRs;
        CR_memory;
        LP;
        Realbestval;
        Realbestmemit;
        Realbestvalit;
        pop2;
        val2;
        pm12;
        pm22;
        ui2;
        rotd;
        rt2;
        rtd;
        a12;
        a22;
        ind;
        rot2;
        popold2;
        a32;
        pm32;
        bm;
        CR;
        opts;
        perf;
        modifiedPerf;
        prevNeg;
        autoPen;
        consLog;
        prevConsNeg;
        logObj;
        prevObjNegative;
        modifiedValA;
    end

    methods
        function obj=Sadea(AlgSettings)
            obj.D=length(AlgSettings.ListOfParameters);
            obj.XVmin=zeros(1,length(AlgSettings.ListOfParameters));
            obj.XVmax=zeros(1,length(AlgSettings.ListOfParameters));


            for i=1:length(AlgSettings.ListOfParameters)
                obj.XVmin(i)=str2double(AlgSettings.ListOfParameters{i}...
                .Lower);
                obj.XVmax(i)=str2double(AlgSettings.ListOfParameters{i}...
                .Upper);
            end

            obj.N=AlgSettings.SelectedSettings.Samples;
            obj.NP2=AlgSettings.SelectedSettings.PopulationSize;
            obj.F=AlgSettings.SelectedSettings.ScalingFactor;
            obj.ns=AlgSettings.SelectedSettings.NumPoints;
            obj.type=AlgSettings.SelectedSettings.Type;
            obj.opts.type=obj.type;
            obj.refresh=1;
            obj.nfeval=0;
            obj.nfevalmax=AlgSettings.SelectedSettings.MaxEvals;
            obj.ISS=AlgSettings.SelectedSettings.ISS;
            obj.parfor_o=AlgSettings.SelectedSettings.Parallel;
            obj.ncores=AlgSettings.SelectedSettings.NumCores;

            obj.popA=[];
            obj.valA=[];

            obj.CRm(1,:)=0.8;
            obj.CRs=0.1;
            obj.CR_memory=[];
            obj.LP=50;
            obj.autoPen=AlgSettings.AutoPenalties;
            if~isempty(AlgSettings.ListOfConstraints)
                for i=1:length(AlgSettings.ListOfConstraints)
                    obj.w(i)=AlgSettings.ListOfConstraints{i}.Penalty;
                end
            end
        end





        function AlgSettings=initSMAS(obj,AlgSettings)

            lhsnum=lhsamp(obj.N,obj.D);
            for i=1:obj.N
                obj.popA(i,:)=obj.XVmin+lhsnum(i,:).*...
                (obj.XVmax-obj.XVmin);
            end


            if~isempty(obj.bound_v)
                for i=1:obj.N

                    tempMember=obj.popA(i,:);

                    for j=1:length(obj.logDims)
                        tempMember(obj.logDims(j))=...
                        exp(tempMember(obj.logDims(j)))-obj.prevNeg(j);
                    end

                    tempMember=obj.bound_v(tempMember);

                    for j=1:length(obj.logDims)
                        tempMember(obj.logDims(j))=...
                        log(tempMember(obj.logDims(j))+obj.prevNeg(j));
                    end
                    obj.popA(i,:)=tempMember;
                end
            end

            population=obj.popA;
            popLogDimensions=obj.logDims;
            logPrevNegative=obj.prevNeg;
            objectiveValues=obj.valA;
            performances=obj.perf;
            numFunEvals=obj.nfeval;
            if obj.parfor_o==1
                parfor i=1:obj.N

                    tempMember=population(i,:);
                    for j=1:length(popLogDimensions)
                        tempMember(popLogDimensions(j))=...
                        exp(tempMember(popLogDimensions(j)))-logPrevNegative(j);
                    end

                    y_temp=Evaluator.Evaluate(AlgSettings,tempMember);
                    objectiveValues(i,:)=y_temp(1);
                    if length(y_temp)>1
                        performances(i,:)=y_temp(2:end);
                    end
                    numFunEvals=numFunEvals+1;
                end
            elseif obj.parfor_o==0
                for i=1:obj.N

                    tempMember=population(i,:);
                    for j=1:length(popLogDimensions)
                        tempMember(popLogDimensions(j))=...
                        exp(tempMember(popLogDimensions(j)))-logPrevNegative(j);
                    end

                    y_temp=Evaluator.Evaluate(AlgSettings,tempMember);
                    objectiveValues(i,:)=y_temp(1);
                    if length(y_temp)>1
                        performances(i,:)=y_temp(2:end);
                    end
                    numFunEvals=numFunEvals+1;
                end
            end

            obj.valA=objectiveValues;
            obj.perf=performances;
            obj.nfeval=numFunEvals;


            if~isempty(obj.perf)
                obj.logConstraints();
                if obj.autoPen
                    AlgSettings=obj.autoPenalties(AlgSettings);
                end
                obj.recalculateFunctionValues();
            else
                obj.logObjectiveValue();
            end

            [obj.Realbestval,numi]=min(obj.valA);
            obj.Realbestmem=obj.popA(numi,:);


            obj.Realbestmemit=obj.Realbestmem;

            obj.Realbestvalit=obj.Realbestval;

            if~isempty(obj.perf)
                obj.perf_best=obj.perf(numi,:);
            end

            [temp,numind]=sort(obj.valA);
            obj.pop2=obj.popA(numind(1:obj.NP2),:);
            obj.val2=obj.valA(numind(1:obj.NP2),:);

            obj.iter=1;
            obj.tr(obj.iter)=obj.Realbestval;
            obj.MeanStd(obj.iter)=mean(std(obj.popA));
            obj.iter=obj.iter+1;






            obj.pm12=zeros(obj.NP2,obj.D);
            obj.pm22=zeros(obj.NP2,obj.D);
            obj.ui2=zeros(obj.NP2,obj.D);
            obj.rotd=(0:1:obj.D-1);
            obj.rt2=zeros(obj.NP2);
            obj.rtd=zeros(obj.D);
            obj.a12=zeros(obj.NP2);
            obj.a22=zeros(obj.NP2);
            obj.ind=zeros(4);
            obj.rot2=(0:1:obj.NP2-1);
        end




        function obj=Run(obj,AlgSettings)

            obj.popold2=obj.pop2;
            ind2=randperm(4);

            obj.a12=randperm(obj.NP2);
            obj.rt2=rem(obj.rot2+ind2(1),obj.NP2);
            obj.a22=obj.a12(obj.rt2+1);
            obj.rt2=rem(obj.rot2+ind2(2),obj.NP2);
            obj.a32=obj.a22(obj.rt2+1);

            obj.pm12=obj.popold2(obj.a12,:);
            obj.pm22=obj.popold2(obj.a22,:);
            obj.pm32=obj.popold2(obj.a32,:);

            for j=1:obj.NP2
                obj.bm(j,:)=obj.Realbestmemit;
            end

            if obj.iter>obj.LP
                CR_memory_st=ext_CR(obj.CR_memory,obj.iter,obj.LP);
                CR_temp=median(CR_memory_st);
                if CR_temp<0.1
                    obj.CRm(obj.iter,:)=0.1;
                elseif CR_temp>1
                    obj.CRm(obj.iter,:)=1;
                else
                    obj.CRm(obj.iter,:)=CR_temp;
                end
            else
                obj.CRm(obj.iter,:)=obj.CRm(1,:);
            end


            for j=1:obj.NP2
                obj.ui2(j,:)=obj.popold2(j,:)+obj.F*(obj.bm(j,:)...
                -obj.popold2(j,:))+obj.F*(obj.pm12(j,:)...
                -obj.pm22(j,:));

                obj.CR(j,:)=gen_CR(obj.CRm(obj.iter,:),obj.CRs);
                mui=rand(1,obj.D)<obj.CR(j,:);

                uv=randperm(obj.D);
                mui(uv(1))=1;
                mpo=mui<0.5;
                obj.ui2(j,:)=obj.popold2(j,:).*mpo+obj.ui2(j,:).*mui;
            end

            [pp,kk]=size(obj.ui2);
            for ri=1:pp
                for ji=1:kk
                    if obj.ui2(ri,ji)<obj.XVmin(ji)
                        obj.ui2(ri,ji)=randvar(obj.XVmin(ji),obj.XVmax(ji));
                    elseif obj.ui2(ri,ji)>obj.XVmax(ji)
                        obj.ui2(ri,ji)=randvar(obj.XVmin(ji),obj.XVmax(ji));
                    end
                end
            end


            if~isempty(obj.bound_v)
                for i=1:obj.N

                    tempMember=obj.ui2(i,:);

                    for j=1:length(obj.logDims)
                        tempMember(obj.logDims(j))=...
                        exp(tempMember(obj.logDims(j)))-obj.prevNeg(j);
                    end

                    tempMember=obj.bound_v(tempMember);

                    for j=1:length(obj.logDims)
                        tempMember(obj.logDims(j))=...
                        log(tempMember(obj.logDims(j))+obj.prevNeg(j));
                    end
                    obj.ui2(i,:)=tempMember;
                end
            end

            [obj.ui2,uiy2]=obj.predict();

            [~,prenum]=sort(uiy2);

            ui_sel_temp=obj.ui2(prenum(1),:);

            tempMember=ui_sel_temp;
            for i=1:length(obj.logDims)
                tempMember(obj.logDims(i))=...
                exp(tempMember(obj.logDims(i)))-obj.prevNeg(i);
            end
            y_temp=Evaluator.Evaluate(AlgSettings,tempMember);

            if length(y_temp)>1
                obj.morphPerf(y_temp);
            else
                obj.morphVal(y_temp);
            end

            obj.nfeval=obj.nfeval+1;

            obj.popA=[obj.popA;ui_sel_temp];

            obj.CR_memory=[obj.CR_memory;[obj.iter,obj.CR(prenum(1),:)]];


            [~,numind]=sort(obj.valA);

            obj.pop2=obj.popA(numind(1:obj.NP2),:);
            obj.val2=obj.valA(numind(1:obj.NP2),:);

            obj.Realbestval=obj.valA(numind(1),:);
            obj.Realbestmem=obj.popA(numind(1),:);
            if~isempty(obj.perf)
                obj.perf_best=obj.perf(numind(1),:);
            end

            obj.Realbestmemit=obj.Realbestmem;

            obj.tr(obj.iter)=min(obj.valA);
            obj.MeanStd(obj.iter)=mean(std(obj.popA));
            obj.iter=obj.iter+1;
        end

        function[ui2,uiy2]=predict(obj)
            if obj.D<10
                ADM=10*obj.D;
            elseif obj.D>=10&&obj.D<20
                ADM=100;
            else
                ADM=150;
            end

            if isempty(obj.w)

                if size(obj.popA,1)<=ADM

                    [ui2,uiy2]=predict_WF_log(obj.popA,obj.valA,obj.opts,obj.ui2,obj.logObj,obj.prevObjNegative);

                elseif obj.ISS==1

                    if obj.parfor_o==1

                        [ui2,uiy2]=predict_WF_ISS_parfor_log(obj.popA,...
                        obj.valA,obj.opts,obj.ui2,obj.D,obj.ns,obj.ncores,obj.logObj,obj.prevObjNegative);

                    elseif obj.parfor_o==0

                        [ui2,uiy2]=predict_WF_ISS_log(obj.popA,obj.valA,...
                        obj.opts,obj.ui2,obj.D,obj.ns,obj.logObj,obj.prevObjNegative);

                    end
                elseif obj.ISS==0

                    [ui2,uiy2]=predict_WF_PAS_log(obj.popA,obj.valA,...
                    obj.opts,obj.ui2,obj.D,obj.ns,obj.logObj,obj.prevObjNegative);

                end
            else

                if size(obj.popA,1)<=ADM

                    [ui2,uiy2]=predict_WF_cons_log...
                    (obj.popA,obj.perf,obj.opts,obj.ui2,obj.w,obj.hasObj,obj.consLog,obj.prevConsNeg);

                elseif obj.ISS==1

                    if obj.parfor_o==1

                        [ui2,uiy2]=predict_WF_cons_ISS_parfor_log...
                        (obj.popA,obj.perf,obj.opts,obj.ui2,obj.D,obj.ns,obj.ncores,obj.w,obj.hasObj,obj.consLog,obj.prevConsNeg);

                    elseif obj.parfor_o==0

                        [ui2,uiy2]=predict_WF_cons_ISS_log...
                        (obj.popA,obj.perf,obj.opts,obj.ui2,obj.D,obj.ns,obj.w,obj.hasObj,obj.consLog,obj.prevConsNeg);

                    end
                elseif obj.ISS==0

                    [ui2,uiy2]=predict_WF_cons_PAS_log...
                    (obj.popA,obj.perf,obj.opts,obj.ui2,obj.D,obj.w,obj.ns,obj.hasObj,obj.consLog,obj.prevConsNeg);

                end
            end
        end




        function obj=logConstraints(obj)
            [~,n]=size(obj.perf);
            obj.modifiedPerf=obj.perf;
            for i=1:n
                obj.consLog(i)=0;
                obj.prevConsNeg(i)=0;
            end
        end

        function AlgSettings=autoPenalties(obj,AlgSettings)
            [m,n]=size(obj.perf);
            for i=1:m
                for j=2:n
                    if obj.prevConsNeg(j)>0
                        P(i,j)=max([obj.modifiedPerf(i,j)-log(obj.prevConsNeg(j)),0]);
                    else
                        P(i,j)=max([obj.modifiedPerf(i,j),0]);
                    end
                end
            end
            P=[obj.modifiedPerf(:,1),P];

            PM=median(P);
            if obj.hasObj
                for i=2:n
                    if PM(i)==0
                        obj.w(i-1)=50;
                    else
                        obj.w(i-1)=PM(1)/PM(i)*50;
                    end
                end
            else
                for i=1:n
                    if PM(i)==0
                        obj.w(i)=1;
                    else
                        obj.w(i)=max(PM)/PM(i);
                    end
                end
            end
            for i=1:length(obj.w)
                AlgSettings.ListOfConstraints{i}.Penalty=obj.w(i);
            end
        end

        function obj=recalculateFunctionValues(obj)
            [m,n]=size(obj.perf);
            if obj.hasObj
                for j=1:m
                    for k=1:length(obj.w)
                        if(obj.prevConsNeg(k+1)==0)
                            penalty(k)=obj.w(k)*max([obj.modifiedPerf(j,k+1),0]);
                        else
                            penalty(k)=obj.w(k)*max([obj.modifiedPerf(j,k+1)-log(obj.prevConsNeg(k+1)),0]);
                        end
                    end
                    obj.valA(j,:)=obj.modifiedPerf(j,1)+sum(penalty);
                end
            else
                for j=1:m
                    for k=1:length(obj.w)
                        if(obj.prevConsNeg(k)==0)
                            penalty(k)=obj.w(k)*max([obj.modifiedPerf(j,k),0]);
                        else
                            penalty(k)=obj.w(k)*max([obj.modifiedPerf(j,k)-log(obj.prevConsNeg(k)),0]);
                        end
                    end
                    obj.valA(j,:)=sum(penalty);
                end
            end
        end

        function[obj,y]=morphPerf(obj,y_temp)

            perf_n=y_temp(2:end);

            obj.perf=[obj.perf;perf_n];
            obj.logConstraints();
            obj.recalculateFunctionValues();
            yval=obj.valA(end,:);
            y=[yval,perf_n];
        end

        function[obj,y]=morphVal(obj,y_temp)

            obj.valA(end+1)=y_temp;
            obj.logObjectiveValue();
            y=obj.valA(end);
        end


        function obj=logObjectiveValue(obj)
            obj.modifiedValA=obj.valA;
            obj.logObj=0;
        end

    end

end