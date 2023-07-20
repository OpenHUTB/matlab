function[outputVec,statusFlag,targetSuccessVec,targetVec]=solve_implementation(KS,varargin)




    narginchk(1,3);
    nvarargin=numel(varargin);
    if nvarargin==0
        targetVec=zeros(0,1);
        initialGuessVec=zeros(0,1);
    elseif nvarargin==1
        targetVec=varargin{1};
        initialGuessVec=zeros(0,1);
    elseif nvarargin==2
        targetVec=varargin{1};
        initialGuessVec=varargin{2};
    end

    if~(isempty(targetVec)&&isnumeric(targetVec))
        targetVecStr=pm_message('sm:mli:kinematicsSolver:TargetVector');
        validateattributes(targetVec,{'double'},{'vector','finite'},'',targetVecStr);
    end
    if~(isempty(initialGuessVec)&&isnumeric(initialGuessVec))
        initialGuessVecStr=pm_message('sm:mli:kinematicsSolver:InitialGuessVector');
        validateattributes(initialGuessVec,{'double'},{'vector','finite'},'',initialGuessVecStr);
    end

    [outputVec,statusFlag,targetSuccessVec,targetVec]=KS.mSystem.solve(targetVec,initialGuessVec,KS.MaxIterations,psp3Fcn());
end