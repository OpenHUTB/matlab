function yyaxis(varargin)



















    import matlab.graphics.internal.*;
    narginchk(1,2);

    if(nargin==2)
        ax=varargin{1};
        idxToActivate=varargin{2};
        if~all(isgraphics(ax,'axes'))
            error(message('MATLAB:graphics:yyaxis:NotAxesArgument'));
        end
    else
        idxToActivate=varargin{1};
        ax=gca;
        if~isa(ax,'matlab.graphics.axis.Axes')
            error(message('MATLAB:graphics:yyaxis:NotAxesGCA'));
        end
    end

    if~isCharOrString(idxToActivate)
        error(message('MATLAB:graphics:yyaxis:Invalid'));
    else
        switch(lower(char(idxToActivate)))
        case 'left'
            idxToActivate=1;
        case 'right'
            idxToActivate=2;
        otherwise
            error(message('MATLAB:axis:UnknownOption',idxToActivate));
        end
    end

    if~all(ax.View==[0,90])
        error(message('MATLAB:graphics:yyaxis:ViewNot2D'));
    end

    ax.ClippingStyle='rectangle';

    numTargets=numel(ax.TargetManager.Children);
    oldTargetIdx=ax.ActiveDataSpaceIndex;

    if(numTargets<2)
        firstTimeSetup(ax)
    end


    if idxToActivate~=oldTargetIdx
        ax.makeDataSpaceCurrent(idxToActivate)
    end

end

function firstTimeSetup(ax)


    nextSeriesIndex=ax.NextSeriesIndex;
    colorOrderIndex=ax.ColorOrderIndex;
    lineStyleOrderIndex=ax.LineStyleOrderIndex;


    children=ax.Children;
    if isempty(children)&&...
        (nextSeriesIndex==1||...
        (nextSeriesIndex==0&&colorOrderIndex==1&&lineStyleOrderIndex==1))


        [~,c1,~]=matlab.graphics.chart.internal.nextstyle(ax,true,true,false);
        leftNextSeriesIndex=nextSeriesIndex;
    else

        c1=[0,0,0];




        leftNextSeriesIndex=0;
    end


    [~,cnew,~]=matlab.graphics.chart.internal.nextstyle(ax,true,true,false);


    if leftNextSeriesIndex==0
        ax.ColorOrderIndex=1;
        ax.LineStyleOrderIndex=1;
    else
        ax.setNextSeriesIndex(1);
    end


    ax.ColorOrder=c1;



    yyaxisStyleOrder='-|--|:|-.|o-|^-|*-';
    styleOrderForNewDataspaces=yyaxisStyleOrder;
    if isscalar(ax.LineStyleOrder)&&strcmp(ax.LineStyleOrder,get(groot,'FactoryAxesLineStyleOrder'))
        ax.LineStyleOrder=styleOrderForNewDataspaces;
    else
        styleOrderForNewDataspaces=ax.LineStyleOrder;
    end



    deleteallpins(ax);



    newds=matlab.graphics.axis.dataspace.CartesianDataSpace;
    newds.Description='Axes Additional DataSpace';
    dsnum=ax.addDataSpace(newds);


    t1=ax.TargetManager.Children(1);
    tnew=ax.TargetManager.Children(dsnum);


    ax.YColorMode='manual';
    setupTarget(t1,c1,styleOrderForNewDataspaces,leftNextSeriesIndex)


    setupTarget(tnew,cnew,styleOrderForNewDataspaces,nextSeriesIndex)


    b=hggetbehavior(ax,'Rotate3d');
    b.Enable=false;

end

function setupTarget(target,co,lso,nsi)


    target.AxisB.Color=co;


    target.ColorSpace.ColorOrder_I=co;
    target.ColorSpace.LineStyleOrder_I=lso;


    target.ColorOrderIndex_I=1;
    target.LineStyleOrderIndex_I=1;


    target.NextSeriesIndex_I=sign(nsi);

end

function deleteallpins(ax)

    container=ax.Parent;
    ap=findall(container,'Type','annotationpane');
    for i=1:numel(ap)
        ch=ap(i).Children;
        for j=1:numel(ch)
            if isa(ch(j),'matlab.graphics.shape.internal.ScribeObject')&&...
                ~isempty(ch(j).Pin)&&(ch(j).Pin(1).Axes==ax)
                delete(ch(j).Pin);
            end
        end
    end

end


