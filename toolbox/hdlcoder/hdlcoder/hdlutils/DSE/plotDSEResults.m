function plotDSEResults(log,targetResources)

    numIter=height(log{2});
    axesLabels={'CP Delay','Latency','Multipliers','Adders/Subtractors','Registers','1-Bit Regsiters','RAMs','Multiplexers','I/O Bits','Static Shift operators','Dynamic Shift operators'};
    columnOrder=["CPDelay","latency","multipliers","addersSubtractors","registers","oneBitRegisters","rams","multiplexers","IOBits","staticShiftOperators","dynamicShiftOperators"];

    legends=strings(1,numIter);
    for i=1:numIter
        legends(i)=['Iter #',num2str(i)];
    end


    defaultSelectedResource=ismember(columnOrder,targetResources);
    defaultSelectedIterations=true(1,numIter);
    P=cell2mat(table2array(log{2}(:,columnOrder)));
    for i=2:numel(legends)
        if all(P(i,defaultSelectedResource)==P(i-1,defaultSelectedResource))
            defaultSelectedIterations(i)=false;
        end
    end
    createSpiderPlot(P,axesLabels,legends,defaultSelectedResource,defaultSelectedIterations);


    CPDelayCheckBox=uicontrol('Style','checkbox','Position',[10,450,150,30],'String','CP Delay','Value',defaultSelectedResource(1));
    latencyCheckBox=uicontrol('Style','checkbox','Position',[10,410,150,30],'String','Latency','Value',defaultSelectedResource(2));
    multipliersCheckBox=uicontrol('Style','checkbox','Position',[10,370,150,30],'String','Multipliers','Value',defaultSelectedResource(3));
    addersSubtractorsCheckBox=uicontrol('Style','checkbox','Position',[10,330,150,30],'String','Adders/Subtractors','Value',defaultSelectedResource(4));
    registersCheckBox=uicontrol('Style','checkbox','Position',[10,290,150,30],'String','Registers','Value',defaultSelectedResource(5));
    bitRegistersCheckBox=uicontrol('Style','checkbox','Position',[10,250,150,30],'String','1-Bit Regsiters','Value',defaultSelectedResource(6));
    RAMsCheckBox=uicontrol('Style','checkbox','Position',[10,210,150,30],'String','RAMs','Value',defaultSelectedResource(7));
    multiplexersCheckBox=uicontrol('Style','checkbox','Position',[10,170,150,30],'String','Multiplexers','Value',defaultSelectedResource(8));
    IOBitsCheckBox=uicontrol('Style','checkbox','Position',[10,130,150,30],'String','I/O Bits','Value',defaultSelectedResource(9));
    staticShiftOperatorsCheckBox=uicontrol('Style','checkbox','Position',[10,90,150,30],'String','Static Shift operators','Value',defaultSelectedResource(10));
    dynamicShiftOperatorsCheckBox=uicontrol('Style','checkbox','Position',[10,50,150,30],'String','Dynamic Shift operators','Value',defaultSelectedResource(11));


    iterCheckBoxes=cell(1,numIter);
    for i=1:numIter
        if defaultSelectedIterations(i)
            iterCheckBoxes{i}=uicontrol('Style','checkbox','Position',[170,50+40*(numIter-i),150,30],'String',['Iteration #',num2str(i)],'Value',1);
        else
            iterCheckBoxes{i}=uicontrol('Style','checkbox','Position',[170,50+40*(numIter-i),150,30],'String',['Iteration #',num2str(i)]);
        end
    end


    uicontrol('Style','pushbutton','Position',[115,10,100,30],'String','Update Plot','Callback',@updateButtonPushed);

    function updateButtonPushed(~,~)

        selectedResource=[CPDelayCheckBox.Value,latencyCheckBox.Value,multipliersCheckBox.Value,addersSubtractorsCheckBox.Value,registersCheckBox.Value,bitRegistersCheckBox.Value...
        ,RAMsCheckBox.Value,multiplexersCheckBox.Value,IOBitsCheckBox.Value,staticShiftOperatorsCheckBox.Value,dynamicShiftOperatorsCheckBox.Value];
        selectedIterations=false(1,numIter);
        for j=1:numIter
            selectedIterations(j)=iterCheckBoxes{j}.Value;
        end
        createSpiderPlot(P,axesLabels,legends,logical(selectedResource),selectedIterations);
    end
end

function createSpiderPlot(P,axesLabels,legends,selectedResource,selectedIterations)

    selectedP=P(selectedIterations,selectedResource);
    selectedAxesLabels=axesLabels(selectedResource);

    spider_plot(selectedP,...
    'AxesLabels',selectedAxesLabels,...
    'AxesInterval',5,...
    'AxesPrecision',0,...
    'FillOption','on',...
    'FillTransparency',0.1,...
    'LineWidth',4,...
    'Marker','none',...
    'AxesFontSize',14,...
    'LabelFontSize',10,...
    'AxesColor',[0.8,0.8,0.8],...
    'AxesLabelsEdge','none');

    title('GA Optimization Results','FontSize',14);
    legend(legends(selectedIterations),'Location','northeast');
end