function legend(p,varargin)














    hL=p.hLegend;
    refreshLegend=false;
    p.pLegend=true;
    if(nargin==2)&&islogical(varargin{1})

        if varargin{1}


            refreshLegend=true;
            varargin={};
        else

            if~isempty(hL)
                delete(hL);
                p.hLegend=[];
                p.pLegend=false;
            end


            return
        end
    end






    if~p.pPlotExecutedAtLeastOnce
        return
    end


    defaultOpts=numel(varargin)<2;
    hData=getDataWidgetHandles(p);
    newLegendCreated=false;

    strChange=false;
    newStr='';

    hValid=~isempty(hL)&&isvalid(hL);
    if hValid





        lis=p.hListeners;

        if~isempty(lis.LegendBeingDestroyed)
            lis.LegendBeingDestroyed.Enabled=false;
        end

        if refreshLegend



            param={'Location','Orientation','FontSize'};
            value=get(hL,param);
            value_position=get(hL,'Position');


            delete(hL);
            hL=local_createLegend(p,hData);
            p.hLegend=hL;
            newLegendCreated=true;


            set(hL,param,value);
            if strcmp(value{1},'none')
                set(p.hLegend,'Position',value_position);
            end



            newStr=createStringsForLegend(p);
            strChange=true;

        elseif defaultOpts

            newStr=createStringsForLegend(p);
            strChange=true;

        else

            delete(hL);
            hL=local_createLegend(p,hData,varargin{:});
            p.hLegend=hL;
            newLegendCreated=true;
        end

        lis.LegendBeingDestroyed.Enabled=true;
    else

        hL=local_createLegend(p,hData,varargin{:});
        p.hLegend=hL;
        newLegendCreated=true;
        if defaultOpts
            newStr=createStringsForLegend(p);
            strChange=true;
        end
    end




    tagStr=sprintf('smithplotLegend%d',p.pAxesIndex);
    set(hL,...
    'Tag',tagStr,...
    'Color',p.GridBackgroundColor);












    lis=p.hListeners;
    if strChange

        hh=lis.LegendStringChanged;
        lisActive=~isempty(lis)&&~isempty(hh);
        if lisActive
            for k=1:numel(hh)
                hh(k).Enabled=false;
            end
        end


        hL.String=internal.polariCommon.convertStringMatrixToCR(newStr);


        if lisActive
            for k=1:numel(hh)
                hh(k).Enabled=true;
            end
        end
    end










    if newLegendCreated

        if~isempty(lis.LegendBeingDestroyed)
            delete(lis.LegendBeingDestroyed);
        end
        lis.LegendBeingDestroyed=addlistener(hL,...
        'ObjectBeingDestroyed',@(~,~)legendBeingDestroyed(p));









        if~isempty(lis.LegendStringChanged)
            delete(lis.LegendStringChanged);
        end
        lis.LegendStringChanged=addlistener(hData,...
        'DisplayName','PostSet',@(~,~)legendInteractiveChange(p));

        if~isempty(lis.LegendMarkedClean)
            delete(lis.LegendMarkedClean);
        end
        lis.LegendMarkedClean=addlistener(hL,...
        'MarkedClean',@(~,~)legendMarkedClean(p));

        p.hListeners=lis;
    end

end

function hL=local_createLegend(p,hData,varargin)

    hL=legend(hData,'Location','northwest',varargin{:});
    hL.Interpreter='none';
    delete(hL.UIContextMenu);

    hc=uicontextmenu(...
    'Parent',p.hFigure,...
    'HandleVisibility','off');

    opts={hc,'Show Legend',@(~,~)legend(p,false)};
    hs=internal.ContextMenus.createContext(opts);
    hs.Checked='on';

    hL.UIContextMenu=hc;

end
