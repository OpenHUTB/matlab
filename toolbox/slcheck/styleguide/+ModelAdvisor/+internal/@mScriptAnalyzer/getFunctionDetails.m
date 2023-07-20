function[result,visitedFiles]=getFunctionDetails(this,visitedFiles)






    result=ModelAdvisor.internal.mFunctionDetails(this.name);

    if isempty(visitedFiles)||~ismember({this.name},visitedFiles)
        visitedFiles=[visitedFiles,{this.name}];
    else
        result=ModelAdvisor.internal.mFunctionDetails([this.name,'(',DAStudio.message('ModelAdvisor:engine:PossibleRecursion'),')']);
        return;
    end

    if isempty(this.mtreeObject);return;end


    if this.mtreeObject.anykind('CLASSDEF');return;end

    this.visitedFcns={};

    [bValid,error]=Advisor.Utils.isValidMtree(this.mtreeObject);
    if~bValid
        result=ModelAdvisor.internal.mFunctionDetails([this.name,'(',error.message,')']);
        return;
    end


    fcnDefs=this.mtreeObject.mtfind('Kind','FUNCTION').Fname.strings;

    if isempty(fcnDefs);return;end

    this.fmain=fcnDefs(1);
    this.fdefs=fcnDefs(:,2:end);

    result=this.getCallsInFunction(this.fmain{1},visitedFiles);

end
