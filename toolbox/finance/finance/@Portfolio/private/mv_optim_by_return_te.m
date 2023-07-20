function[pwgt,status]=mv_optim_by_return_te(r,n,A,b,f0,f,H,g,d,gT0,gT,...
    solverType,solverOptions)














































    pnum=numel(r);

    pwgt=zeros(n,pnum);
    status=zeros(1,pnum);

    if isempty(solverOptions)
        solverOptions=optimset(optimset('fmincon'),'algorithm','sqp','display','off',...
        'gradobj','on','gradconstr','on','maxiter',10000,'maxfunevals',100000,...
        'tolfun',1.0e-8,'tolx',1.0e-8,'tolcon',1.0e-8);
    end

    z0=zeros(size(d));

    fhandle=@(z)local_objective(z,H,g);
    chandle=@(z)mv_tracking_error_as_constraint(z,H,gT,gT0);

    for i=1:pnum
        [z,~,status]=fmincon(fhandle,z0,[A;-f'],[b;(f0-r(i))],[],[],...
        zeros(size(d)),[],chandle,solverOptions);

        z=z+d;
        pwgt(:,i)=z(1:n);
    end



    function[fobj,df]=local_objective(z,H,g)

        fobj=0.5*(z'*H*z)+g'*z;
        df=H*z+g;
