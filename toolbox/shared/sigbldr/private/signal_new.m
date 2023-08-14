function UD=signal_new(UD,stepX,stepY,labelStr,color,lineStyle,...
    lineWidth)





    outIndex=UD.numChannels+1;

    if(nargin<5)
        color=[];
        lineStyle=[];
        lineWidth=[];
    end

    chStruct=signal_data_struct(stepX,stepY,labelStr,outIndex);

    chStruct=check_and_apply_line_properties(chStruct,UD.numChannels+1,...
    color,lineStyle,lineWidth);


    if~isfield(UD,'channels')||isempty(UD.channels)
        UD.channels=chStruct;
    else
        UD.channels(end+1)=chStruct;
    end


    hiddenPlot=[char(9744),' '];


    padding=length(hiddenPlot);


    if length(labelStr)>29-length(hiddenPlot)

        ellipseStr='...';


        ellipseIDX=padding+length(ellipseStr);


        newStr=[char(32*ones(1,padding)),labelStr(1:29-ellipseIDX),ellipseStr];


        newStr=[newStr,blanks(29-length(newStr))];

    else
        newStr=[char(32*ones(1,padding)),labelStr,char(32*ones(1,29-length(labelStr)-padding))];
    end


    newStr(1:2)=hiddenPlot;


    if UD.numChannels==0
        set(UD.hgCtrls.chanListbox,'String',newStr);
    else
        chanStr=get(UD.hgCtrls.chanListbox,'String');
        set(UD.hgCtrls.chanListbox,'String',strvcat(chanStr,newStr));
    end

    UD.numChannels=UD.numChannels+1;


    UD=update_undo(UD,'add','channel',UD.numChannels,[]);

    UD=set_dirty_flag(UD);

    if isfield(UD,'simulink')&&~isempty(UD.simulink)
        UD.simulink=sigbuilder_block('add_outport',UD.simulink,labelStr);
    end
