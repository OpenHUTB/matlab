function[x,fval,exitflag,output,lambda,slbiopts]=slbiClient(f,intcon,Ai,bi,Aeq,beq,lb,ub,x0,user_options,xparams)











    callStack=dbstack;
    caller1=[];
    if numel(callStack)>1
        [~,caller1]=fileparts(callStack(2).file);
    end

    caller='';
    doSetup=true;
    setupOnly=false;
    if strcmpi('IntlinprogBranchAndCut',caller1)
        caller='intlinprog';
    elseif strcmpi('LinprogDualSimplex',caller1)
        caller='linprog';
    end

    if~strcmpi('',caller)





        setupOnly=contains(callStack(2).name,"initialize");

        doSetup=~contains(callStack(2).name,"runNoChecks");
    end


    if nargin<11
        xparams=[];
    end

    sizes.SLBI_INF=1e25;
    sizes.SLBI_ZERO=1e-12;



    sizes.SLBI_INTMAX=2147483646;


    [f,Ai,bi,Aeq,beq,lb,ub,x0,vtype,sizes,exitflag]=...
    changeConstraintForm(f,Ai,bi,Aeq,beq,lb,ub,x0,intcon,sizes,user_options);
    if~isempty(exitflag)
        x=[];fval=[];

        [output,lambda]=formOutput(caller);
        return;
    end

    if doSetup
        try
            slbiopts=getOptions(user_options,xparams,sizes,caller);
        catch ME %#ok
            if sizes.nInteger==0
                exitflag='LP_NaN_-1000@-1002';
            else
                exitflag='IP_NaN_-1000@-1002';
            end
            x=[];fval=[];slbiopts=[];

            [output,lambda]=formOutput(caller);
            return;
        end
        if~isempty(user_options.OutputFcn)||~isempty(user_options.PlotFcns)


            user_options.OutputFcn=...
            replaceEnumStringWithFcnHdl('Intlinprog','OutputFcn',user_options.OutputFcn);
            user_options.OutputFcn=...
            createCellArrayOfFunctions(user_options.OutputFcn,'OutputFcn');
            user_options.PlotFcns=...
            replaceEnumStringWithFcnHdl('Intlinprog','PlotFcn',user_options.PlotFcns);
            user_options.PlotFcns=...
            createCellArrayOfFunctions(user_options.PlotFcns,'OutputFcn');


            stop=slbiCallback('init',struct(),user_options);
            if stop

                if sizes.nInteger==0
                    exitflag='LP_-1';
                else
                    exitflag='IP_-1';
                end
                x=[];fval=[];

                [output,lambda]=formOutput(caller);
                return;
            end
        end

        if setupOnly


            x=[];fval=[];output=[];lambda=[];
            return;
        end
    else


        slbiopts=user_options;
    end



    solStr={'xcmgap',...
    'xnints',...
    'xnodes',...
    'xipfun',...
    'xzlbnd',...
    'xzubnd',...
    'xctime',...
    'xlpfun',...
    'xlptim',...
    'xiter',...
    'xertyp'};


    try
        slbiInfo=[];
        if getenv('USE_SLBI_BUILTIN')=='1'
            slbiInfo=intlinprog_slxp(f,Ai,bi,Aeq,beq,lb,ub,x0,vtype,slbiopts,solStr);
        else
            slbiInfo=slbiMex(f,Ai,bi,Aeq,beq,lb,ub,x0,vtype,slbiopts,solStr);
        end
    catch ME
        slbiInfo=slbiErrorHandler(slbiInfo,ME);
    end

    try
        [x,fval,exitflag,output,lambda]=prepareOutput(Ai,bi,Aeq,beq,lb,ub,vtype,slbiInfo,slbiopts,sizes,caller);
    catch ME %#ok
        if sizes.nInteger==0
            exitflag='LP_NaN_-1000@-1003';
        else
            exitflag='IP_NaN_-1000@-1003';
        end
        x=[];fval=[];

        [output,lambda]=formOutput(caller);
        return
    end

    if strncmp(exitflag,'IP_-9',5)||strcmp(exitflag,'LP_-9')
        x=[];fval=[];
    end
    if doSetup&&(~isempty(user_options.OutputFcn)||~isempty(user_options.PlotFcns))

        slbiCallback('done',...
        struct('x',x,...
        'numnodes',output.numnodes,...
        'fval',fval,...
        'relativegap',output.relativegap));
    end




    function[f,A,b,Aeq,beq,lb,ub,x0,vtype,sizes,exitflag]=...
        changeConstraintForm(f,A,b,Aeq,beq,lb,ub,x0,intcon,sizes,user_options)

        nvars=length(f);

        if~isempty(intcon)

            intcon=intcon(:);

            intcon=unique(intcon);
        end


        vtype=zeros(nvars,1);
        sizes.nBinary=0;
        sizes.nInteger=length(intcon);


        exitflag='';

        [~,lb,ub,msg]=checkbounds([],full(lb),full(ub),nvars);
        if~isempty(msg)
            if sizes.nInteger==0
                exitflag='LP_-2_4';
            else
                exitflag='IP_-2_4';
            end
            return;
        end


        if isempty(A),A=sparse(zeros(0,nvars));end
        if isempty(b),b=zeros(0,1);end
        if isempty(Aeq),Aeq=sparse(zeros(0,nvars));end
        if isempty(beq),beq=zeros(0,1);end

        if~isempty(x0)&&...
            (max([0;norm(Aeq*x0-beq,inf);(lb-x0);(x0-ub);(A*x0-b)])>user_options.ConstraintTolerance||...
            (~isempty(intcon)&&max(abs(x0(intcon)-round(x0(intcon))))>user_options.IntegerTolerance))
            x0=[];
            warning(message('optim:intlinprog:IgnoreX0'));
        end

        if sizes.nInteger>0&&any(ceil(lb(intcon))>floor(ub(intcon)))

            exitflag='IP_-2_1';
            return;
        end

        if sizes.nInteger>0&&isempty(x0)&&~strcmpi('none',user_options.Heuristics)
            x0=checkForTrivialSolutions(f,intcon,A,b,Aeq,beq,lb,ub,user_options);
        end


        SLBI_INF=sizes.SLBI_INF;
        if any(abs(f)>=SLBI_INF)||...
            any(abs(b)>=SLBI_INF)||...
            any(abs(beq)>=SLBI_INF)||...
            any(abs(nonzeros(A))>=SLBI_INF)||...
            any(abs(nonzeros(Aeq))>=SLBI_INF)
            if sizes.nInteger==0
                exitflag='LP_NaN_0';
            else
                exitflag='IP_NaN_0';
            end
            return;
        end


        if any(isnan(f))||...
            any(isnan(b))||...
            any(isnan(beq))||...
            any(isnan(nonzeros(A)))||...
            any(isnan(nonzeros(Aeq)))||...
            any(isnan(lb))||...
            any(isnan(ub))
            if sizes.nInteger==0
                exitflag='LP_NaN_1';
            else
                exitflag='IP_NaN_1';
            end
            return;
        end

        index=abs(lb)>SLBI_INF;
        lb(index)=SLBI_INF.*sign(lb(index));
        sizes.nFiniteLb=nnz(~index);

        index=abs(ub)>SLBI_INF;
        ub(index)=SLBI_INF.*sign(ub(index));
        sizes.nFiniteUb=nnz(~index);


        b=full(b(:));
        beq=full(beq(:));
        f=full(f(:));

        A=sparse(A);
        Aeq=sparse(Aeq);


        nineqcstr=size(A,1);
        neqcstr=size(Aeq,1);
        numConstr=nineqcstr+neqcstr;

        sizes.nVars=nvars;
        sizes.mEq=neqcstr;
        sizes.mIneq=nineqcstr;
        sizes.mAll=numConstr;



        if sizes.nInteger>0

            vtype(intcon)=2;

            bin_ub=ones(sizes.nInteger,1);
            bin_lb=zeros(sizes.nInteger,1);
            bin_index=false(nvars,1);
            bin_index(intcon)=(ub(intcon)==bin_ub)&(lb(intcon)==bin_lb);

            vtype(bin_index)=1;
            sizes.nBinary=nnz(bin_index);
        end

        if numConstr==0

            onlyBounds=true;
            A=sparse([1,zeros(1,nvars-1)]);
            b=SLBI_INF;
        else
            onlyBounds=false;
        end

        sizes.nnz=nnz(Aeq)+nnz(A);
        sizes.onlyBounds=onlyBounds;


        function[x,fval,exitflag,output,lambda]=prepareOutput(Ai,bi,Aeq,beq,lb,ub,vtype,slbiInfo,slbiopts,sizes,caller)









            if sizes.nInteger>0
                exitflag='IP_';
                pureLP=false;
            else
                exitflag='LP_';
                pureLP=true;
            end
            x=[];fval=[];


            if~isempty(slbiInfo.errmessage)
                msg=strtrim(slbiInfo.errmessage);
                xertyp=strtok(msg);
                xertyp=str2int(xertyp);
                if isnumeric(xertyp)&&isfinite(xertyp)
                    slbiInfo.xertyp=xertyp;
                else

                    slbiInfo.xertyp=-1000;
                end
            elseif~isempty(slbiInfo.xertyp)
                slbiInfo.xertyp=str2int(slbiInfo.xertyp);
            else




                slbiInfo.xertyp=0;
            end


            if slbiInfo.errorcode_ml<100

                if ismember(slbiInfo.errorcode_ml,[-96,-98])&&ismember(slbiInfo.xertyp,[410,420])

                    exitflag=[exitflag,'NaN_0'];
                else
                    exitflag=[exitflag,'NaN_',num2str(slbiInfo.errorcode_ml),'@',num2str(slbiInfo.xertyp)];
                end
                [output,lambda]=formOutput(caller);
                return;
            end

            nVars=sizes.nVars;


            if slbiInfo.xertyp==10

                if sizes.nInteger==0
                    exitflag='LP_-1';
                else
                    exitflag='IP_-1';
                end
                if isfield(slbiInfo,'x')&&~isempty(slbiInfo.x)
                    x=slbiInfo.x(1:nVars);
                end

            elseif slbiInfo.phase==1
                switch(slbiInfo.optimstatus)
                case 0
                    exitflag=[exitflag,'1_',microCode('1',slbiInfo,slbiopts)];
                    x=slbiInfo.x(1:nVars);
                case 1
                    exitflag=[exitflag,'-2_1'];
                case 3
                    exitflag=[exitflag,'2_',microCode('2',slbiInfo,slbiopts)];
                    x=slbiInfo.x(1:nVars);
                otherwise
                    exitflag=[exitflag,'0_',microCode('0',slbiInfo,slbiopts)];
                end


            else
                switch(slbiInfo.optimstatus)
                case 0
                    exitflag=[exitflag,'1_',microCode('1',slbiInfo,slbiopts)];
                    x=slbiInfo.x(1:nVars);
                case 1
                    if~pureLP
                        exitflag=[exitflag,'-2_2'];
                    else
                        exitflag=[exitflag,'-2'];
                    end
                case 2
                    exitflag=[exitflag,'-3'];
                otherwise
                    exitflag=[exitflag,'0_',microCode('0',slbiInfo,slbiopts)];
                end
            end

            if~isempty(x)
                fval=slbiInfo.fval;
            end

            [output,lambda,relconstviolation]=formOutput(caller,x,Ai,bi,Aeq,beq,lb,ub,slbiInfo,sizes);

            if~isempty(x)


                exitflag=verifyExitflags(exitflag,x,vtype,slbiopts,output,sizes,relconstviolation);
            end



            if strcmp('IP_-9',exitflag)
                output.relativegap=[];
                output.absolutegap=[];
                output.numfeaspoints=[];
            end


            function code=microCode(flag,slbiInfo,slbiopts)


                code='0';
                switch flag
                case '1'
                    if slbiInfo.phase==0
                        code='1';
                    else
                        if isfield(slbiInfo,'xnodes')&&...
                            ~isempty(slbiInfo.xnodes)&&...
                            str2int(slbiInfo.xnodes)==0

                            code='2';
                        else

                            code='1';
                        end
                    end
                case '2'
                    if isfield(slbiInfo,'xnints')&&~isempty(slbiInfo.xnints)
                        xnints=str2int(slbiInfo.xnints);
                    else
                        xnints=0;
                    end

                    if ismember(slbiInfo.xertyp,[5,9,19,20,21,130,159,156])

                        code='3';
                    elseif slbiInfo.xertyp==6

                        code='4';
                    elseif slbiInfo.xertyp==3||slbiInfo.xertyp==2

                        code='5';
                    elseif slbiInfo.xertyp==4

                        code='6';
                    elseif xnints>=slbiopts.xmxint

                        code='7';
                    end
                case '0'
                    if slbiInfo.xertyp==1

                        code='1';
                    elseif ismember(slbiInfo.xertyp,[5,9,19,20,21,130,159,156])

                        code='3';
                    elseif slbiInfo.xertyp==6

                        code='4';
                    elseif slbiInfo.xertyp==3||slbiInfo.xertyp==2

                        code='5';
                    elseif slbiInfo.xertyp==4

                        code='6';
                    end
                end


                function out=str2int(in)
                    out=double(string(in));



                    function[output,lambda,relativeConstrViolation]=formOutput(caller,x,Ai,bi,Aeq,beq,lb,ub,slbiInfo,sizes)

                        switch caller
                        case 'intlinprog'
                            output.relativegap=[];
                            output.absolutegap=[];
                            output.numfeaspoints=[];
                            output.numnodes=[];
                            output.constrviolation=[];
                        case 'linprog'
                            output.iterations=[];
                        otherwise
                            output.relativegap=[];
                            output.absolutegap=[];
                            output.numfeaspoints=[];
                            output.numnodes=[];
                            output.constrviolation=[];
                            output.iterations=[];
                        end

                        lambda=[];
                        relativeConstrViolation=[];


                        if nargin<2,return;end

                        if sizes.nInteger>0
                            fieldExists=isfield(slbiInfo,'xnints')&&~isempty(slbiInfo.xnints);
                            if fieldExists&&~isempty(str2int(slbiInfo.xnints))
                                output.numfeaspoints=str2int(slbiInfo.xnints);
                            end

                            fieldExists=isfield(slbiInfo,'xnodes')&&~isempty(slbiInfo.xnodes);
                            if fieldExists&&~isempty(str2int(slbiInfo.xnodes))
                                output.numnodes=str2int(slbiInfo.xnodes);
                            end

                            if~isempty(output.numfeaspoints)&&output.numfeaspoints>0
                                fieldExists=isfield(slbiInfo,'xcmgap')&&~isempty(slbiInfo.xcmgap);
                                if fieldExists&&~isempty(str2double(slbiInfo.xcmgap))
                                    output.relativegap=str2double(slbiInfo.xcmgap);
                                end
                            end

                            fieldExists=isfield(slbiInfo,'xipfun')&&~isempty(slbiInfo.xipfun);
                            if fieldExists&&~isempty(str2double(slbiInfo.xipfun))&&...
                                (~isempty(output.numfeaspoints)&&output.numfeaspoints>0)
                                ubound=str2double(slbiInfo.xipfun);
                            else
                                ubound=[];
                            end

                            fieldExists=isfield(slbiInfo,'xzlbnd')&&~isempty(slbiInfo.xzlbnd);
                            if fieldExists&&~isempty(str2double(slbiInfo.xzlbnd))
                                lbound=str2double(slbiInfo.xzlbnd);
                            else
                                lbound=[];
                            end

                            if~isempty(lbound)&&~isempty(ubound)
                                output.absolutegap=abs(ubound-lbound);
                            end

                        end

                        if~strcmpi(caller,'intlinprog')
                            fieldExists=isfield(slbiInfo,'xiter')&&~isempty(slbiInfo.xiter);
                            if fieldExists&&~isempty(str2int(slbiInfo.xiter))
                                output.iterations=str2int(slbiInfo.xiter);
                            end
                        end

                        if~isempty(x)
                            if sizes.nInteger==0
                                lambdaVec=slbiInfo.lambda;
                                status=slbiInfo.status;
                                nvars=sizes.nVars;
                                mEq=sizes.mEq;
                                mIneq=sizes.mIneq;


                                lambda.lower=zeros(nvars,1);
                                lambda.upper=zeros(nvars,1);
                                for j=1:nvars
                                    if status(j,1)==2

                                        lambda.lower(j,1)=lambdaVec(j,1);
                                    elseif status(j,1)==3

                                        lambda.upper(j,1)=-lambdaVec(j,1);
                                    elseif status(j,1)==4

                                        if lambdaVec(j,1)<0
                                            lambda.upper(j,1)=-lambdaVec(j,1);
                                        elseif lambdaVec(j,1)>0
                                            lambda.lower(j,1)=lambdaVec(j,1);
                                        end
                                    end
                                end


                                if mEq>0
                                    lambda.eqlin=zeros(mEq,1);
                                    for i=1:mEq
                                        j=nvars+i;
                                        lambda.eqlin(i,1)=-lambdaVec(j,1);
                                    end
                                else
                                    lambda.eqlin=[];
                                end


                                if mIneq>0
                                    lambda.ineqlin=zeros(mIneq,1);
                                    for i=1:mIneq
                                        j=nvars+mEq+i;
                                        lambda.ineqlin(i,1)=-lambdaVec(j,1);
                                    end
                                else
                                    lambda.ineqlin=[];
                                end

                            end


                            eqResiduals=Aeq*x-beq;
                            ineqResiduals=Ai*x-bi;
                            output.constrviolation=max([0;norm(eqResiduals,inf);(lb-x);(x-ub);(ineqResiduals)]);
                            eqLargestOfRow=max(abs([Aeq,beq,ones(size(beq))]),[],2);
                            ineqLargestOfRow=max(abs([Ai,bi,ones(size(bi))]),[],2);
                            relativeConstrViolation=max([0;norm(eqResiduals./eqLargestOfRow,inf);...
                            (lb-x)./max(1,abs(lb));(x-ub)./max(1,abs(ub));...
                            ineqResiduals./ineqLargestOfRow]);
                        end


                        function exitflag=verifyExitflags(exitflag,x,vtype,slbiopts,output,sizes,relconstrviolation)




                            if strcmp(exitflag,'IP_-1')||strcmp(exitflag,'LP_-1')


                                return
                            end


                            if output.constrviolation>slbiopts.xtolx
                                if relconstrviolation<=slbiopts.xtolx
                                    if strncmp('IP_1',exitflag,4)
                                        exitflag='IP_3_1';
                                    elseif strncmp('LP_1',exitflag,4)
                                        exitflag='LP_3_1';
                                    elseif strncmp('IP_2',exitflag,4)
                                        exitflag='IP_3_2';
                                    end
                                else
                                    if sizes.nInteger>0
                                        exitflag='IP_-9';
                                    else
                                        exitflag='LP_-9';
                                    end
                                end
                                return;
                            end


                            int_index=(vtype==2)|(vtype==1);
                            integer_infeas=abs(x(int_index)-round(x(int_index)))>slbiopts.xtolin;
                            if any(integer_infeas)

                                if any(integer_infeas&(abs(x(int_index))>slbiopts.xpibnd))
                                    exitflag='IP_-2_3';
                                else
                                    exitflag='IP_NaN_-2_3';
                                end
                                return;
                            end


                            if strcmp('IP_1_1',exitflag)
                                if output.absolutegap<=slbiopts.xabgap
                                    exitflag='IP_1_1';
                                else
                                    exitflag='IP_1_2';
                                end
                            elseif strcmp('IP_1_2',exitflag)
                                if output.absolutegap<=slbiopts.xabgap
                                    exitflag='IP_1_3';
                                else
                                    exitflag='IP_1_4';
                                end
                            end


                            function slbiInfo=slbiErrorHandler(slbiInfo,~)



                                slbiInfo.errorcode_ml=-1000;
                                slbiInfo.errorcode_ext=-1001;

                                slbiInfo.errmessage='ML error';


                                function slbiopts=getOptions(options,xparams,sizes,caller)



                                    if~isempty(xparams)

                                        if isfield(xparams,'exclusivexparams')
                                            xparams_only=true;
                                            xparams=rmfield(xparams,'exclusivexparams');
                                        else
                                            xparams_only=false;
                                        end
                                    else
                                        xparams_only=false;
                                    end


                                    if xparams_only
                                        slbiopts=xparams;
                                        return;
                                    else

                                        [user_slbiopts,InternalOptions]=validateIntlinprogUserOptions(options,sizes,caller);
                                    end




                                    if~isempty(InternalOptions)||~(isstruct(InternalOptions)&&~isempty(fieldnames(InternalOptions)))
                                        user_slbiopts=addInternalOptions(user_slbiopts,InternalOptions);
                                    end



                                    fixed_slbiopts=getFixedOptions(sizes,caller);




                                    slbiopts=fixed_slbiopts;


                                    user_params=setdiff(fieldnames(user_slbiopts),fieldnames(fixed_slbiopts));
                                    for k=1:length(user_params)
                                        slbiopts.(user_params{k})=user_slbiopts.(user_params{k});
                                    end

                                    if~isempty(xparams)

                                        fnames=fieldnames(xparams);
                                        for k=1:length(fnames)
                                            slbiopts.(fnames{k})=xparams.(fnames{k});
                                        end
                                    end


                                    function fixed_slbiopts=getFixedOptions(sizes,caller)



                                        fixed_slbiopts.xoutlv=0;
                                        fixed_slbiopts.xoutsl=0;
                                        fixed_slbiopts.xctrlc=1;

                                        fixed_slbiopts.xpibnd=2100000000;

                                        fixed_slbiopts.xinf=sizes.SLBI_INF;

                                        fixed_slbiopts.xdropm=sizes.SLBI_ZERO;


                                        if sizes.nInteger>0
                                            fixed_slbiopts.xfntre=prepareTempFileName('tre');
                                        end


                                        if sizes.nInteger==0
                                            fixed_slbiopts.xlpmip=0;
                                        end


                                        if~strcmpi(caller,'intlinprog')&&sizes.nInteger==0
                                            fixed_slbiopts.xpreme=383;
                                            fixed_slbiopts.xprbnd=-1;
                                        end


                                        function tempFileName=prepareTempFileName(aSubPrefix)



                                            tempFileName=tempname;
                                            tempDirName=tempdir;
                                            tempFileName=regexprep(tempFileName,regexptranslate('escape',tempDirName),'');
                                            tempFileName=strcat(tempDirName,'intlinprog_',aSubPrefix,tempFileName);


                                            function user_slbiopts=addInternalOptions(user_slbiopts,InternalOptions)






                                                if~isstruct(InternalOptions)&&~isempty(InternalOptions)&&...
                                                    (~isnumeric(InternalOptions)||size(InternalOptions,2)~=2)

                                                    return
                                                end

                                                [params,inv_params]=xparamsList();

                                                if isa(InternalOptions,'double')

                                                    numParams=size(InternalOptions,1);
                                                    optionsAsArray=true;
                                                else
                                                    fields=fieldnames(InternalOptions);
                                                    numParams=numel(fields);
                                                    optionsAsArray=false;
                                                end
                                                for i=1:numParams
                                                    if optionsAsArray
                                                        num=InternalOptions(i,1);
                                                        name=char(inv_params(num));
                                                        value=InternalOptions(i,2);
                                                    else
                                                        name=fields{i};
                                                        value=InternalOptions.(name);
                                                    end
                                                    type=params(name).('type');
                                                    range=params(name).('range');

                                                    if type==0&&ismember(value,range)
                                                        user_slbiopts.(name)=value;
                                                    elseif type==1
                                                        value=max(value,range(1));
                                                        value=min(value,range(2));
                                                        user_slbiopts.(name)=value;
                                                    end
                                                end


                                                function[params,inv_params]=xparamsList()

















                                                    paramsCellArray={...
                                                    'xadcol',1,1,[0,1e4];...
                                                    'xadrow',2,1,[2e3,50e3];...
                                                    'xadnon',3,1,[0,2e6];...
                                                    'xbckpa',4,1,[0.0,1.0];...
                                                    'xluctr',5,1,[1.1,5.0];...
                                                    'xhtlim',6,1,[0.0,500.0];...
                                                    'xlpgap',7,1,[0,1e20];...
                                                    'xhrdlb',8,1,[0.0,1.0];...
                                                    'xhrdub',9,1,[0.0,1.0];...
                                                    'xmnheu',10,1,[10,500];...
                                                    'xtolre',11,1,[0.0,1e-7];...
                                                    'xtolx1',12,1,[1e-9,1e-3];...
                                                    'xtolx2',13,1,[1e-9,1e-3];...
                                                    'xnlbab',14,1,[0,3000];...
                                                    'xnlstr',15,1,[0,3000];...
                                                    'xmxdsk',16,1,[0,Inf];...
                                                    'xpibnd',17,1,[0,2147483647];...
                                                    'xmreal',18,1,[64,8000];...
                                                    'xtolpv',19,1,[1e-8,1e-3];...
                                                    'xdropm',20,1,[eps,1e-4];...
                                                    'xclict',21,0,[0,1,2];...
                                                    'xcored',22,0,[0,1,2];...
                                                    'xcovct',23,0,[0,1,2,3];...
                                                    'xbndrd',24,0,[0,1,2];...
                                                    'xbrheu',25,0,[0,1,2,3,5,6,7,8];...
                                                    'xdjscl',26,0,[0,1,2,3];...
                                                    'xgomct',27,0,[0,1,2,3,4];...
                                                    'xmirag',28,0,[0,1,2,3,4,5,6,7,8,9];...

                                                    'xhfinb',30,0,[0,1];...
                                                    'xflwct',31,0,[0,1,2,3,4,5,6];...
                                                    'xlifo',32,0,[0,1,2];...
                                                    'ximbnd',33,0,[0,1,2];...
                                                    'ximpli',34,0,[0,1,2];...
                                                    'xlocs',35,0,[0,1,2,3,4,5];...
                                                    'xlotst',36,0,[0,1,2,3];...
                                                    'xmirbs',37,0,[0,1];...
                                                    'xflwpa',38,0,[0,1,2];...
                                                    'xlapct',39,0,[0,1];...
                                                    'xmirct',40,0,[0,1,2,3];...
                                                    'xmirss',41,0,[0,1];...
                                                    'xmtlgo',42,0,[0,1];...
                                                    'xmtlsp',43,0,[0,1];...
                                                    'xmtlt1',44,0,[0,1];...
                                                    'xmtlt2',45,0,[0,1];...
                                                    'xmtlt3',46,0,[0,1];...
                                                    'xmtrgo',47,0,[0,1];...
                                                    'xnogap',48,0,[0,1];...
                                                    'xparct',49,0,[0,1];...
                                                    'xpr2ct',50,0,[0,1];...
                                                    'xprlev',51,0,[0,1,2];...
                                                    'xmtrsp',52,0,[0,1];...
                                                    'xmtrt1',53,0,[0,1];...
                                                    'xmtrt2',54,0,[0,1];...
                                                    'xmtrt3',55,0,[0,1];...
                                                    'xrasct',56,0,[0,1];...
                                                    'xscale',57,0,[0,1,2];...
                                                    'xscgct',58,0,[0,1];...
                                                    'xstart',59,0,[0,1];...
                                                    'xusepl',60,0,[0,1];...
                                                    'xzhcut',61,0,[0,1];...
                                                    'xoutfn',62,0,[0,1,2];...
                                                    'xtolrf',63,1,[0.0,1e-6];...
                                                    'xhroun',64,0,[-1,0,1];...
                                                    'xhrins',65,0,[-1,0,1];...
                                                    'xhrbss',66,0,[-1,0,1];...
                                                    'xhdive',67,0,[-1,0,1];...
                                                    'xhdico',68,0,[-1,0,1];...
                                                    'xhdifr',69,0,[-1,0,1];...
                                                    'xhdigu',70,0,[-1,0,1];...
                                                    'xhdipc',71,0,[-1,0,1];...
                                                    'xhdils',72,0,[-1,0,1];...

                                                    'xiidet',75,0,[0,1];...
                                                    'xcmtol',76,1,[0.0,50e3];...
                                                    'xprobn',77,0,[0,1];...
                                                    'xogcdr',78,0,[0,1];...
                                                    'xconfg',79,0,[0,1];...
                                                    'xtriv',80,0,[-1,0,1];...
                                                    'xdpone',81,0,[0,1,2];...
                                                    'xnhdpc',82,0,[-1,0,1];...
                                                    'xnhdgu',83,0,[-1,0,1];...
                                                    'xnhdco',84,0,[-1,0,1];...
                                                    'xnhdfr',85,0,[-1,0,1];...
                                                    'xnhdvl',86,0,[-1,0,1];...
                                                    'xnhdls',87,0,[-1,0,1];...
                                                    'xnhshi',88,0,[-1,0,1];...
                                                    'xnhrou',89,0,[-1,0,1];...
                                                    'xnhint',90,1,[0,10000];...
                                                    'xhshih',91,0,[-1,0,1];...
                                                    'xrseed',92,1,[-2147483648,2147483647];...
                                                    'xdeieq',93,0,[0,1];...
                                                    'xrstol',94,1,[0.0,1.0];...
                                                    'xh1opt',95,0,[-1,0,1];...
                                                    'xhzirn',96,0,[-1,0,1];...
                                                    'xh2opt',97,0,[-1,0,1];...
                                                    'xbkmit',98,1,[0,2147483647];...
                                                    'xclime',99,0,[0,1];...
                                                    };



                                                    fieldNames={'number','type','range'};
                                                    params=containers.Map(paramsCellArray(:,1)',...
                                                    num2cell(cell2struct(paramsCellArray(:,2:4),fieldNames,2)'));

                                                    inv_params=containers.Map(paramsCellArray(:,2)',...
                                                    num2cell(paramsCellArray(:,1))');


                                                    function x=checkForTrivialSolutions(f,intcon,A,b,Aeq,beq,lb,ub,options)

                                                        x=[];


                                                        xTest=zeros(numel(f),1);
                                                        if isFeasible(xTest,A,b,Aeq,beq,lb,ub,options)
                                                            x=xTest;
                                                            return
                                                        end


                                                        if~any(isinf(ub))&&~all(ub==0)
                                                            xTest=ub(:);
                                                            xTest(intcon)=max(floor(ub(intcon)),ceil(lb(intcon)));
                                                            if isFeasible(xTest,A,b,Aeq,beq,lb,ub,options)
                                                                x=xTest;
                                                                return
                                                            end
                                                        end


                                                        if~any(isinf(lb))&&~all(lb==0)
                                                            xTest=lb(:);
                                                            xTest(intcon)=min(ceil(lb(intcon)),floor(ub(intcon)));
                                                            if isFeasible(xTest,A,b,Aeq,beq,lb,ub,options)
                                                                x=xTest;
                                                                return
                                                            end
                                                        end



                                                        if~isempty(A)
                                                            upLocks=sum(A>0,1)+sum(abs(Aeq)>0,1);
                                                            downLocks=sum(A<0,1)+sum(abs(Aeq)>0,1);
                                                            LessUpLocks=upLocks<=downLocks;
                                                            xTest=lb(:);
                                                            xTest(intcon)=min(ceil(lb(intcon)),ub(intcon));
                                                            xTest(LessUpLocks)=ub(LessUpLocks);
                                                            logicalForIntegers=false(size(LessUpLocks));
                                                            logicalForIntegers(intcon)=true;
                                                            integerAndLessUpLocks=LessUpLocks&logicalForIntegers;
                                                            xTest(integerAndLessUpLocks)=max(floor(ub(integerAndLessUpLocks)),ceil(lb(integerAndLessUpLocks)));
                                                            if~any(isinf(xTest))
                                                                if isFeasible(xTest,A,b,Aeq,beq,lb,ub,options)
                                                                    x=xTest;
                                                                    return
                                                                end
                                                            end
                                                        end

                                                        function feasible=isFeasible(xTest,A,b,Aeq,beq,lb,ub,options)
                                                            feasible=max([0;norm(Aeq*xTest-beq,inf);(lb-xTest);(xTest-ub);(A*xTest-b)])<=options.ConstraintTolerance;













































































































