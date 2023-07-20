function datatip=getDataTip(axesId,x,y)

    hAxes=mls.internal.handleID('toHandle',axesId);
    hFigure=ancestor(hAxes,'figure');

    point=[0,0,0];
    str='';

    if~isempty(hFigure)&&~isempty(hAxes)&&ishghandle(hFigure)&&ishghandle(hAxes)&&feature('HasDisplay')
        drawnow;


        axesPos=get(hAxes,'Position');
        currUnits=get(hAxes,'Units');
        axesPosPixels=hgconvertunits(hFigure,axesPos,currUnits,'pixels',hFigure);



        selPointFigPixels(1)=axesPosPixels(1)-.5+x*axesPosPixels(3);
        selPointFigPixels(2)=axesPosPixels(2)-.5+y*axesPosPixels(4);
        selPointFigPixels(3:4)=0;


        figUnits=get(hFigure,'Units');
        selPointFigCurrUnits=hgconvertunits(hFigure,selPointFigPixels,'pixels',figUnits,hFigure);


        set(hFigure,'CurrentPoint',selPointFigCurrUnits(1:2));
        drawnow;

        [point,str]=getPointInfo(hFigure,selPointFigPixels(1),selPointFigPixels(2));
    end

    datatip.axesId=axesId;
    datatip.dataX=point(1);
    datatip.dataY=point(2);
    if numel(point)>2
        datatip.dataZ=point(3);
    else
        datatip.dataZ=0;
    end

    if iscell(str)
        datatip.text=strjoin(str,'\n');
    elseif~ischar(str)
        datatip.text='';
    elseif size(str,1)>1
        datatip.text=strjoin(cellstr(str)','\n');
    else
        datatip.text=str;
    end

end


function[point,str]=getPointInfo(hFigure,x,y)

    canvas=hFigure.getCanvas();

    pos=get(hFigure,'Position');
    target=canvas.hittest(floor(x),floor(pos(4)-y));
    hTarget=localGetTarget(target);

    if~isempty(hTarget)

        hCursor=matlab.graphics.shape.internal.PointDataCursor(hTarget);
        hCursor.Interpolate='on';
        hCursor.moveTo([x,y]);


        point=hCursor.Position;






        dd=hCursor.getDataDescriptors();
        str=localDescriptorsToString(dd);

    else
        point=[0,0,0];
        str='';
    end
end


function str=localDescriptorsToString(hDescriptors)

    descriptor_cells=cell(numel(hDescriptors),1);
    for i=1:numel(hDescriptors)
        currStr=hDescriptors(i).Name;
        if iscell(currStr)
            descriptor_cells{i}=currStr(:);
        else
            val=hDescriptors(i).Value;
            if~isempty(val)
                if isnumeric(val)
                    currStr=sprintf('%s: %s',currStr,mat2str(val,4));
                elseif islogical(val)
                    currStr=sprintf('%s: %s',currStr,mat2str(double(val)));
                else
                    try
                        currStr=sprintf('%s: %s',currStr,char(val));
                    catch ignored


                    end
                end
            end
            descriptor_cells{i}={currStr};
        end
    end
    str=cat(1,descriptor_cells{:});
end

function TargetDA=localGetTarget(hTarget)


    TargetDA=matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(hTarget);

    if isempty(TargetDA)

        TargetDA=ancestor(hTarget,'matlab.graphics.chart.interaction.DataAnnotatable');
    end
end
