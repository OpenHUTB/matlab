function output=solver(input)





















































































































































    persistent optsolvers internal_caller

    output=struct('message','Input OK','messageID','','id','','retcode',0);

    if~isstruct(input)
        output.messageID='globaloptim:bmo:mustBeStructInput';
        output.message=getString(message(output.messageID));
        return
    end



    if isfield(input,'clearall')
        optsolvers=[];
        return;
    end

    if isfield(input,'getall')
        output=optsolvers;
        return
    end





    if isempty(internal_caller)
        internal_caller=internalCaller();
    end


    if~isfield(input,'id')

        index=length(optsolvers)+1;
    else

        [index,output]=getSolverIndex(input.id,{optsolvers.id},output);


        if isempty(index)
            index=length(optsolvers)+1;
        end
    end





    if isfield(input,'clear')&&...
        index<=length(optsolvers)&&...
        ~isempty(optsolvers)
        optsolvers(index)=[];

        if isempty(optsolvers)
munlock
        end

        return;
    end


    if~internal_caller
        try
            run();
        catch ME

            output.messageID=ME.identifier;
            output.message=ME.message;
            output.retcode=-100;
        end
    else
        run();
    end


    if~isempty(optsolvers)&&~mislocked
mlock
    end

    function run()
        if isfield(input,'setup')
            if index>length(optsolvers)&&~isempty(optsolvers)

                [optsolvers(index),output]=solverFactory(input,output);

            elseif isempty(optsolvers)
                [optsolvers,output]=solverFactory(input,output);

            else
                output=processSetup(optsolvers(index),input,output);
            end
        end

        if isfield(input,'request')

            output=processRequest(optsolvers(index),input);

        elseif isfield(input,'update')

            output=processUpdates(optsolvers(index),input);

        end

    end

end


function output=processSetup(solver,input,output)


    output=solver.setup(input,output);
    output.message=sprintf('%s\nSetup OK',output.message);
end


function output=processRequest(solver,input)

    if isfield(input,'trial')
        output=solver.getTrial(input);
        assert(isfield(output,'X'))
    end

    if isfield(input,'metrics')||isfield(input,'results')
        output=solver.getMetrics(input);
    end

    if isfield(input,'save')
        output=solver.saveState();
    elseif isfield(input,'load')
        output=solver.restoreState(input);
    end

    output.message=sprintf('Request OK');
end


function output=processUpdates(solver,input)

    output=solver.updateResponse(input);
    output.message=sprintf('Update OK');
end


function[solver,output]=solverFactory(input,output)

    solver=[];
    if~isfield(input,'setup')
        output.message='Expected ''setup'' field in input structure for optimization setup.';
        return
    end

    if~isfield(input,'id')

        [solver,output]=createSolverInstance(input,output);
    else
        output.id=input.id;

        if~isfield(input,'saveloc')
            output.message='saveloc is expected when restoring/discarding. ';
        end


        file_loc=savedSolverLocation(input);
        if isfield(input,'restore')
            [solver,output]=restoreSolverFromFile(file_loc,output);

        elseif isfield(input,'discard')
            output=discardSavedSolver(file_loc,output);
            return
        end
    end
end


function[solver,output]=createSolverInstance(input,output)

    if~isfield(input,'solver')||strcmpi(input.solver,'surrogate-single-obj')
        solver=globaloptim.bmo.SurrogateSolver(input);
    else
        error('Expected ''solver'' field in the input structure.');
    end

    output.retcode=solver.state.retcode;
    output.message=sprintf('%s\n%s',output.message,solver.state.msg);
    output.id=solver.id;
    output.clocktime=clock;
end


function[index,output]=getSolverIndex(id,allIds,output)
    index=find(strcmp(id,allIds),1,'first');
    if isempty(index)
        output.message=sprintf('%s\n''%s'' does not exist in memory; will try to load.',...
        output.message,char(id));
    end
end

function TF=internalCaller()

    if ispc
        start='\\';
    else
        start='/';
    end
    location=fullfile(start,'mathworks','devel','src','mathdepot','optim');
    TF=isfolder(location);
end
