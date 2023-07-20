function privateLayoutResidualDistributionPlot(ax,responseName,residualTypes,xlimits)










    numResponse=numel(responseName);

    outermost=sbioGroupLayout('grid','gap',[0,0],'gridDimensions',[numResponse,1]);
    for i=1:numResponse
        l=layout(ax{i},responseName{i},residualTypes,xlimits{i});
        outermost.add(l);
    end
    outermost.fill(gcf);

    function outerLayout=layout(ax,responseName,residualTypes,xlimits)
        nAxes=numel(ax);

        outerLayout=sbioGroupLayout('border','gap',[5,15],'tightAxes',false,'insets',[5,5,5,5]);
        innerLayout=sbioGroupLayout('grid','gap',[15,5],'tightAxes',true,'gridDimensions',[2,2],'insets',[15,35,15,15]);

        for i=1:nAxes

            if rem(i,2)~=0
                grid(ax(i),'off');
                set(ax(i),'XTickLabel',[]);
            end


            xlabel(ax(i),'');


            set(ax(i),'YTickLabel','');
            set(ax(i),'YTick',[]);


            ylabel(ax(i),'');


            setappdata(ax(i),'axesgroup',ax);
            setappdata(ax(i),'residualTypes',residualTypes);
            setappdata(ax(i),'xlimits',xlimits);
            setappdata(ax(i),'responseName',responseName);
        end

        set(ax([1,2]),'xlim',[-xlimits(1),xlimits(1)]*1.05);
        set(ax([3,4]),'xlim',[-xlimits(2),xlimits(2)]*1.05);


        ylim2=ylim(ax(2));
        ylim4=ylim(ax(4));
        ylim(ax(2),[min(ylim2(1),ylim4(1)),max(ylim2(2),ylim4(2))])
        ylim(ax(4),[min(ylim2(1),ylim4(1)),max(ylim2(2),ylim4(2))])


        title(ax(1),residualTypes{1});
        title(ax(2),'');
        title(ax(3),residualTypes{2});
        title(ax(4),'');


        set(ax,'Box','on');

        set(ax,'ButtonDownFcn',@openInNewWindow);
        innerLayout.add(ax(:));
        outerLayout.center=innerLayout;
        outerLayout.north=uicontrol('style','Text','String',responseName,'FontSize',12,'Position',[0,0,25,25]);

        function openInNewWindow(src,~)
            f1=figure;
            ax=getappdata(src,'axesgroup');
            allAxes=copyobj(ax,f1);
            l=layout(allAxes,getappdata(src,'responseName'),getappdata(src,'residualTypes'),getappdata(src,'xlimits'));
            set(allAxes,'ButtonDownFcn','');
            l.fill(f1);

            set(f1,'DefaultAxesToolbarVisible','off');
            addToolbarExplorationButtons(f1);
            set(allAxes,'Toolbar',[]);
            arrayfun(@(ax)matlab.graphics.interaction.disableDefaultAxesInteractions(ax),allAxes);