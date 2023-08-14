function slvrJacobianPattern=getSlvrJacobianPattern(mdlH)
























    needToThrowError=false;
    caughtError='';

    try
        if(~strcmp(get_param(mdlH,'Type'),'block_diagram'))

            needToThrowError=true;
        end
    catch caughtError
        needToThrowError=true;
    end

    if(needToThrowError)
        identifier='Simulink:utility:getSlvrJacobianPatternNeedsBlockDiagram';
        message=DAStudio.message(identifier);
        me=MException(identifier,'%s',message);
        if(~isempty(caughtError))
            me=addCause(me,caughtError);
        end
        throw(me);
    end

    try
        slvrJacobianPattern=slprivate('slGetSlvrJacobianPattern',...
        get_param(mdlH,'Name'));
    catch e
        identifier='Simulink:utility:SolverGetSlvrJacobianPatternFailed';
        message=DAStudio.message(identifier,get_param(mdlH,'Name'));
        me=MException(identifier,'%s',message);
        me=addCause(me,e);
        throw(me);

    end
