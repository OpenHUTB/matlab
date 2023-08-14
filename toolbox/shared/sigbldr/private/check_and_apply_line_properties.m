function chStruct=check_and_apply_line_properties(chStruct,chNum,color,lineStyle,lineWidth)





    persistent colorOrder

    if(nargin<2)
        error(message('sigbldr_ui:check_and_apply_line_properties:badNumOfInputArguments'))
    end

    if nargin==2
        color=[];
        lineStyle=[];
        lineWidth=[];

    elseif nargin==3
        lineStyle=[];
        lineWidth=[];

    elseif nargin==4
        lineWidth=[];
    end


    if isempty(colorOrder)
        colorOrder={[0.8431,0,0],...
        [0.7176,0,0.7176],...
        [0,0,1],...
        [0.2510,0,0.2510],...
        [0.9843,0.8627,0.0157],...
        [0.2510,0.5020,0.5020],...
        [0,0.5020,0.2510],...
        [1.0000,0,0.5020],...
        [0.1529,0.6588,0.1412],...
        [1.0000,0.5020,0.2510],...
        [0.6275,0.3922,0.2118],...
        [0.2510,0,0.2510]};
    end

    if~isempty(color)
        chStruct.color=color;
    elseif~isfield(chStruct,'color')||isempty(chStruct.color)
        chStruct.color=colorOrder{mod(chNum-1,length(colorOrder))+1};
    end


    if~isempty(lineStyle)
        chStruct.lineStyle=lineStyle;
    elseif~isfield(chStruct,'lineStyle')||isempty(chStruct.lineStyle)
        chStruct.lineStyle='-';
    end

    if~isempty(lineWidth)
        chStruct.lineWidth=lineWidth;
    elseif~isfield(chStruct,'lineWidth')||isempty(chStruct.lineWidth)
        chStruct.lineWidth=1.5;
    end
