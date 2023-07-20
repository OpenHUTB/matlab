function fontsize(parent,varargin)






















    narginchk(2,3);
    matlab.graphics.internal.mustBeValidGraphicsInFigure(parent);

    flag='';
    units='';
    value=[];
    scaleFactor=1.1;
    if isnumeric(varargin{1})

        value=validateValue(varargin{1},'Font size');
    else




        flag=validateFlag(varargin{1});
    end

    if strcmp(flag,'decrease')
        scaleFactor=1/scaleFactor;
    end


    if~isempty(value)&&nargin==3
        units=validateUnits(varargin{2});
    elseif~isempty(value)
        error(message('MATLAB:graphics:fontfunctions:MissingUnits'));
    end


    if~isempty(flag)
        if nargin==3
            if strcmp(flag,'scale')

                scaleFactor=validateValue(varargin{2},'Scale factor');
            else
                error(message('MATLAB:graphics:fontfunctions:FlagWithTooManyInputs',flag));
            end
        elseif strcmp(flag,'scale')

            error(message('MATLAB:graphics:fontfunctions:MissingScaleFactor'));
        end
    end

    if strcmp(flag,'default')
        units='default';
        value={'default'};
    end


    allFSObjs=findall(parent,'-property','FontSize');



    axesManagedChildren=matlab.graphics.internal.getAxesManagedTextObjects(allFSObjs);
    legCBManagedChildren=matlab.graphics.internal.getLegendColorbarManagedTextObjects(allFSObjs);
    tiledLayoutText=matlab.graphics.internal.findTiledLayoutText(parent);
    allFSObjs=unique([allFSObjs;axesManagedChildren';legCBManagedChildren';tiledLayoutText]);

    needsUnitsSet=[];
    if~isempty(units)


        needsUnitsSet=allFSObjs(isprop(allFSObjs,'FontUnits'));


        legendObjs=findobj(needsUnitsSet,'-isa','matlab.graphics.illustration.Legend');
        needsUnitsSet=setdiff(needsUnitsSet,legendObjs);
    end

    [needsFontSizeSet,newFontSizes]=getObjectsToSetFontSizeOn(allFSObjs,flag,...
    scaleFactor,value,units);

    set(needsUnitsSet,'FontUnits',units);

    if strcmp(flag,'default')




        acceptsDefaultValue=findobj(needsFontSizeSet,...
        '-isa','matlab.mixin.internal.DefaultFactoryPropHandler');
        chartCompContainers=findobj(acceptsDefaultValue,...
        '-isa','matlab.graphics.chartcontainer.ChartContainer','-or',...
        '-isa','matlab.ui.componentcontainer.ComponentContainer');
        if~isempty(chartCompContainers)

            acceptsDefaultValue=acceptsDefaultValue(~ismember(acceptsDefaultValue,chartCompContainers));
            msg=message('MATLAB:graphics:fontfunctions:DefaultNotSupported',class(chartCompContainers(1)));
            warningstatus=warning('OFF','BACKTRACE');
            warning(msg);
            warning(warningstatus);
        end
        idx=ismember(needsFontSizeSet,acceptsDefaultValue);
        needsFontSizeSet=needsFontSizeSet(idx);
        newFontSizes=newFontSizes(idx);
    end
    if isnumeric(newFontSizes)
        newFontSizes=num2cell(newFontSizes);
    end
    set(needsFontSizeSet,{'FontSize'},newFontSizes);

    if strcmp(flag,'default')


        hasFontSizeMode=allFSObjs(isprop(allFSObjs,'FontSizeMode'));
        hasFontUnitsMode=allFSObjs(isprop(allFSObjs,'FontUnitsMode'));
        set(hasFontSizeMode,'FontSizeMode','auto');
        set(hasFontUnitsMode,'FontUnitsMode','auto');
    end
end


function[objects,newFontSizes]=...
    getObjectsToSetFontSizeOn(objects,flag,scaleFactor,fontSizeValue,units)

    newFontSizes=[];
    switch flag
    case{'','default'}
        newFontSizes=repmat(fontSizeValue,size(objects));



        if~strcmp(units,'default')
            newFontSizes=handleObjectsWithNoFontUnits(objects,newFontSizes,fontSizeValue,units);
        end
    case{'increase','scale','decrease'}
        currFontSizes=get(objects,'FontSize');
        if isempty(units)
            units=getFontUnits(objects);
        end
        if iscell(currFontSizes)
            currFontSizes=[currFontSizes{:}];
        end
        newFontSizes=matlab.graphics.internal.scaleAndRoundFontSizeValues(currFontSizes,scaleFactor,units);





        managedTextObjs=matlab.graphics.internal.getAxesManagedTextObjects(objects);
        if~isempty(managedTextObjs)
            managedTextObjs=managedTextObjs(isprop(managedTextObjs,'FontSizeMode'));
            modes=get(managedTextObjs,'FontSizeMode');
            managedTextAuto=managedTextObjs(ismember(string(modes),'auto'));
            managedTextAutoIdx=ismember(objects,managedTextAuto);
            objects=objects(~managedTextAutoIdx);
            newFontSizes=newFontSizes(~managedTextAutoIdx);
        end
    end


    objects=objects(:);
    newFontSizes=newFontSizes(:);



    axesIdx=ismember(objects,findobj(objects,'-isa','matlab.graphics.axis.AbstractAxes'));
    rulerIdx=ismember(objects,findobj(objects,'-isa','matlab.graphics.axis.decorator.AxisRulerBase'));
    colorbarIdx=ismember(objects,findobj(objects,'-isa','matlab.graphics.illustration.ColorBar'));
    [~,sortInd]=sortrows([axesIdx,rulerIdx,colorbarIdx],'descend');
    objects=objects(sortInd);
    newFontSizes=newFontSizes(sortInd);
end







function fontSizes=handleObjectsWithNoFontUnits(objects,fontSizes,fontSizeValue,units)

    hasUnitsIdx=hasFontUnits(objects);
    noFontUnitsObjs=objects(~hasUnitsIdx);

    if~isempty(noFontUnitsObjs)
        fig=ancestor(noFontUnitsObjs(1),'figure');
        newUnits=getFontUnits(noFontUnitsObjs);
        for i=1:numel(noFontUnitsObjs)
            rect=hgconvertunits(fig,[0,0,fontSizeValue,fontSizeValue],units,newUnits(i),fig);

            fontSizes(ismember(objects,noFontUnitsObjs(i)))=rect(3);

        end
    end
end


function val=validateUnits(val)
    import matlab.graphics.internal.isCharOrString;
    unitsAreValid=true;
    try
        val=hgcastvalue('matlab.graphics.datatype.FontUnits',val);
    catch e
        unitsAreValid=false;
    end
    if strcmp(val,'normalized')||~unitsAreValid
        validUnits={'points','pixels','centimeters','inches'};
        msg=message('MATLAB:graphics:fontfunctions:BadUnits',strjoin(validUnits,''', '''));
        throwAsCaller(MException(msg));
    end

end


function val=validateValue(val,argumentName)
    try
        mustBePositive(val);
        mustBeFinite(val);
    catch e
        throwAsCaller(e);
    end
    if~isscalar(val)
        throwAsCaller(MException(message('MATLAB:graphics:fontfunctions:NonScalar',argumentName)));
    end
end


function val=validateFlag(val)
    try
        mustBeTextScalar(val)
    catch e
        throwAsCaller(e);
    end
    val=lower(val);
    validFlags=["increase","decrease","default","scale"];
    if~ismember(val,validFlags)
        msg=message('MATLAB:graphics:fontfunctions:InvalidFlag',strjoin(validFlags,''', '''));
        throwAsCaller(MException(msg));
    end
end


function units=getFontUnits(objects)


    units=repmat("points",size(objects));

    hasUnitsIdx=hasFontUnits(objects);


    units(hasUnitsIdx)=get(objects(hasUnitsIdx),'FontUnits');


    uicomps=findobj(objects,'-isa','matlab.ui.control.Component','-and','-not','-property','FontUnits');
    uicompsIdx=ismember(objects,uicomps);
    units(uicompsIdx)="pixels";
end

function hasUnitsIdx=hasFontUnits(objects)
    hasUnitsIdx=isprop(objects,'FontUnits');



    isLegendIdx=ismember(objects,findobj(objects,'-isa','matlab.graphics.illustration.Legend'));

    hasUnitsIdx=hasUnitsIdx&~isLegendIdx;
end