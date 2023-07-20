function mtp=getMobileTargetProperties(hBlock,asJSON)




    hModel=bdroot(hBlock);
    mtp=getDefaultProperties;

    [xOffset,e]=slResolve(get_param(hBlock,'XOffset'),hModel);
    if e
        mtp.xOffset=xOffset;
    end

    [sampInc,e]=slResolve(get_param(hBlock,'SampleIncrement'),hModel);
    if e
        mtp.sampleIncrement=sampInc;
    end

    mtp.plotType=get_param(hBlock,'PlotType');


    if strcmpi(get_param(hBlock,'AxesScaling'),'Auto')
        scaling='auto';
    else
        scaling='manual';
    end
    mtp.axesScaling=scaling;

    mtp.displays{1}.showGrid=utils.onOffToLogical(get_param(hBlock,'ShowGrid'));
    mtp.displays{1}.showLegend=utils.onOffToLogical(get_param(hBlock,'ShowLegend'));
    mtp.displays{1}.yLimits=str2num(get_param(hBlock,'YLimits'));%#ok<ST2NM>

    graphicalSettings=get_param(hBlock,'GraphicalSettings');
    if~isempty(graphicalSettings)
        graphicalSettings=strrep(graphicalSettings,'''','"');

        graphicalSettings=jsondecode(graphicalSettings);
        if isfield(graphicalSettings,'Style')
            style=graphicalSettings.Style;

            if isfield(style,'AxesColor')
                mtp.axesColor=style.AxesColor.';


                mtp.displays{1}.lineColors=utils.getColorOrder(style.AxesColor.');
            end

            if isfield(style,'LabelsColor')
                mtp.axesTickColor=style.LabelsColor.';
            end

            if isfield(style,'LineStyle')
                for idx=1:numel(style.LineStyle)
                    mtp.displays{1}.lineStyles{idx}=style.LineStyle{idx};
                end
            end

            if isfield(style,'LineWidth')
                for idx=1:numel(style.LineStyle)
                    mtp.displays{1}.lineWidths(idx)=style.LineWidth(idx);
                end
            end


            if isfield(style,'LineColor')
                for idx=1:size(style.LineColor,1)
                    mtp.displays{1}.lineColors(idx,:)=style.LineColor(idx,:);
                end
            end
        end
    end

    mtp.blockType=get_param(hBlock,'BlockType');
    mtp.inputNames=Simulink.scopes.ArrayPlotUtils.getBlockInputNames(hBlock,true);

    if nargin<2||asJSON
        mtp=jsonencode(mtp);
    end
end

function props=getDefaultProperties
    props.axesColor=[0,0,0];
    props.axesScaling='manual';
    props.axesTickColor=[175,175,175]/255;
    props.displays={getDefaultDisplay(props.axesColor)};
    props.plotType='Stem';
    props.xOffset=0;
    props.sampleIncrement=1;
end

function display=getDefaultDisplay(axesColor)
    display.lineColors=utils.getColorOrder(axesColor);
    display.lineStyles=repmat({'-'},7,1);
    display.lineWidths=repmat(1.5,7,1);
    display.showGrid=true;
    display.showLegend=false;
    display.yLimits=[-10,10];
end