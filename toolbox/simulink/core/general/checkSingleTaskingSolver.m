function singletasking=checkSingleTaskingSolver(models,varargin)





    if nargin==2
        isInSFun=varargin{1};
    else
        isInSFun=false;
    end

    singletasking=true;

    for ct=1:numel(models)
        modelSolver=get_param(models{ct},'Solver');

        IsFixedStep=any(strcmp(getSolversByParameter('SolverType','Fixed Step'),modelSolver));



        if IsFixedStep
            modelSolverMode=get_param(models{ct},'SolverMode');
            if strcmp(modelSolverMode,'Auto')||strcmp(modelSolverMode,'MultiTasking')
                if(isInSFun)

                    singletasking=false;
                else

                    [sys,x0,str,ts]=feval(models{ct},[],[],[],'sizes');

                    ts(ts(:,1)==0,:)=[];
                    if size(ts,1)>1
                        singletasking=false;
                    end
                end
            end
        end
    end