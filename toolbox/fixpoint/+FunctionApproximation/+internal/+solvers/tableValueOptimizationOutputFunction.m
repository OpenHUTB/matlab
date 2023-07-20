function stop=tableValueOptimizationOutputFunction(~,optimValues,state,varargin)








    optargs={...
    struct('advance',true),...
    struct('Display',true),...
    struct('MaxIter',10),...
    };
    optargs(1:numel(varargin))=varargin;
    [constraintTracker,options,optimset]=optargs{:};

    stop=false;
    needsClearing=false;
    if options.Display
        nDigits=floor(log10(optimset.MaxIter))+1;
        prefix=[message('SimulinkFixedPoint:functionApproximation:iterationPrefix').getString(),': '];
        prefixLength=numel(prefix);
        formatSpec=[prefix,'%',num2str(nDigits),'g/%',num2str(nDigits),'g'];
        totalLength=prefixLength+(2*nDigits)+1;
        clearString=repmat('\b',1,totalLength);
        switch state
        case 'init'

            fprintf(repmat(' ',1,totalLength));
            needsClearing=true;
        case 'iter'

            fprintf(clearString);
            fprintf(formatSpec,optimValues.iteration,optimset.MaxIter);
            needsClearing=true;
        case 'done'

            fprintf(clearString);
            needsClearing=false;
        otherwise
        end
    end

    if~constraintTracker.advance()

        stop=true;
        if options.Display&&needsClearing

            fprintf(clearString);
        end
    end
end


