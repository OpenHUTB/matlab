function[x,fval,exitflag,output,lambda,mexoutput]=...
    iplp(f,A,b,Aeq,beq,lb,ub,options)













    if isa(options,'optim.options.Linprog')
        options=extractOptionsStructure(options);
    end





    options=rmfield(options,'Preprocess');


    options=i_unwrapInternalOptions(options);


    [x,fval,~,mexoutput,lambda]=...
    interiorPointLPmex(full(f),sparse(A),full(b),sparse(Aeq),full(beq),full(lb),full(ub),options);


    exitflag.MacroExitflag=mexoutput.MacroExitflag;
    exitflag.MicroExitflag=mexoutput.MicroExitflag;


    output=i_createOutputStructure(mexoutput);

    function output=i_createOutputStructure(mexoutput)




        output.iterations=mexoutput.iterations;
        output.message='';
        output.algorithm='interior-point-r2015b';

        function options=i_unwrapInternalOptions(options)



            if isstruct(options.InternalOptions)
                internalOptionNames=fieldnames(options.InternalOptions);
            else
                internalOptionNames={};
            end
            for i=1:length(internalOptionNames)
                options.(internalOptionNames{i})=options.InternalOptions.(internalOptionNames{i});
            end


            options=rmfield(options,'InternalOptions');
