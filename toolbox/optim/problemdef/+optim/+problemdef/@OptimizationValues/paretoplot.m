function hh=paretoplot(varargin)
























    narginchk(1,3);


    args=varargin;
    parentProvided=false;
    if isa(args{1},'matlab.graphics.Graphics')


        parentProvided=true;
        parent=args{1};
        args(1)=[];
    end


    [obj,objIndex]=iParseInputs(args);



    if parentProvided

        if isscalar(parent)&&isgraphics(parent,'axes')
            parent=newplot(parent);
        else








            error(message('optim_problemdef:OptimizationValues:paretoplot:InvalidAxes'));
        end
    else

        parent=newplot;
    end





    currentNextPlot=parent.NextPlot;
    c=onCleanup(@()set(parent,'NextPlot',currentNextPlot));
    parent.NextPlot='add';


    [xData,yData,zData,xLabel,yLabel,zLabel]=paretoplotdata(obj,objIndex);




    try
        paretoFrontTitle=getString(message('optim_problemdef:OptimizationValues:paretoplot:ParetoFrontTitle'));
        axisLabels=[xLabel,yLabel,zLabel];
        h=optim.internal.plot.scatterplot(parent,xData,yData,zData,axisLabels,paretoFrontTitle);
    catch err


        throw(err)
    end


    switch currentNextPlot
    case{'replace','replaceall'}
        grid(parent,'on');
    otherwise


    end


    if nargout>0
        hh=h;
    end

end

function[vals,objIdx]=iParseInputs(args)


    p=inputParser;
    addRequired(p,'OptimizationValues',@iValidateOptimizationValues);
    addOptional(p,'ObjectiveIndex',[],@iValidateObjectiveIndex);


    try
        parse(p,args{:});
    catch ME
        throwAsCaller(ME);
    end


    vals=p.Results.OptimizationValues;
    objIdx=p.Results.ObjectiveIndex;


    numelNamedObj=structfun(@prod,vals.ObjectiveSize);
    numObjectives=sum(numelNamedObj);


    if numObjectives<2
        error(message('optim_problemdef:OptimizationValues:paretoplot:NotEnoughObjectives'));
    end


    if iscellstr(objIdx)||isstring(objIdx)

        objNames=fieldnames(vals.ObjectiveSize);
        namesNotObjectives=setdiff(objIdx,objNames);
        if~isempty(namesNotObjectives)
            error(message('optim_problemdef:OptimizationValues:paretoplot:IndicesNotObjectiveNames',namesNotObjectives(1)));
        end
    else

        if any(objIdx<1|objIdx>numObjectives)
            rangeStr="[1, "+numObjectives+"]";
            error(message('optim_problemdef:OptimizationValues:paretoplot:IndicesOutOfRange',rangeStr));
        end
    end

end

function iValidateOptimizationValues(obj)

    if~isa(obj,'optim.problemdef.OptimizationValues')
        error(message('optim_problemdef:OptimizationValues:paretoplot:NotOptimizationValues'));
    end

end

function iValidateObjectiveIndex(x)

    if ischar(x)||iscellstr(x)%#ok
        x=string(x);
    end

    if numel(x)>3
        error(message('optim_problemdef:OptimizationValues:paretoplot:TooManyObjectives'));
    end

    if numel(x)<2
        error(message('optim_problemdef:OptimizationValues:paretoplot:TooFewObjectives'));
    end


    isValid=isstring(x)||(isnumeric(x)&&all(x>0)&&all(floor(x)==x));
    if~isValid
        error(message('optim_problemdef:OptimizationValues:paretoplot:IndicesMustBeStringOrNumeric'));
    end

end
