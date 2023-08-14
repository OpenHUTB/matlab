classdef polariMBDataset<internal.polariMouseBehavior





    methods
        function obj=polariMBDataset(isButtonDown)

            if nargin>0&&isButtonDown
                obj.InstallFcn=@showToolTipAndPtr_datasetDown;
                obj.MotionEvent=@wbdrag;
                obj.DownEvent=[];
                obj.UpEvent=@internal.polariMBDataset.wbup;
                obj.ScrollEvent=[];
            else
                obj.InstallFcn=@(p)showToolTipAndPtr(p,'motion');
                obj.MotionEvent=@wbmotion;
                obj.DownEvent=@wbdown;
                obj.UpEvent=[];
                obj.ScrollEvent=@internal.polariMBMagTicks.wbscroll;
            end
        end
    end




    methods(Static)
        function wbup(p,ev)



            p.hFigure.CurrentPoint=ev.Point;


            s=computeHoverLocation(p,ev);
            if s.overDataset
                p.pHoverDataSetIndex=s.overDatasetIndex;
                changeMouseBehavior(p,'dataset');


                showToolTipAndPtr(p,'up');
            else
                plot_glow(p,false);
                autoChangeMouseBehavior(p,s);
            end
        end
    end
end

function wbmotion(p,ev)

    s=computeHoverLocation(p,ev);
    firstEntry=p.ChangedState;
    if firstEntry
        p.ChangedState=false;

    end

    if s.overDataset



        if p.pHoverDataSetIndex~=s.overDatasetIndex
            p.pHoverDataSetIndex=s.overDatasetIndex;
        end
        plot_glow(p,s.overDataset);
        if firstEntry
            showToolTipAndPtr(p,'motion');
        end
    else

        plot_glow(p,s.overDataset);
        autoChangeMouseBehavior(p,s);
    end
end

function wbdown(p,ev)


    if isa(p,'internal.polari')

        disableDefaultInteractivity(p.hAxes)
    end

    if isIntensityData(p)
        internal.polariMBGrid.wbdown(p,ev);
        return
    end

    p.hFigure.CurrentPoint=ev.Point;



    selType=p.hFigure.SelectionType;
    if strcmpi(selType,'alt')




        p.hCurrentObject=p.hFigure.CurrentObject;
        resetToolTip(p);
        return
    end

    isOpen=strcmpi(selType,'open');



    reorderDataPlot(p,+1);

    if isOpen||p.TemporaryCursor
        if~isa(p,'rf.internal.smithplot')





            fig=p.hFigure;
            dcm_obj=datacursormode(fig);
            if strcmp(dcm_obj.Enable,'on')
                return
            end







            p.pDeleteCurrentMarkerOnButtonRelease=~isOpen;



            pt=p.hAxes.CurrentPoint(1,1:2);
            datasetIndex=p.pHoverDataSetIndex;
            m=i_addCursor(p,pt,datasetIndex);



            changeMouseBehavior(p,'anglemarker');
            internal.polariMBAngleMarker.wbmotion(p,ev,m);



            if isOpen
                p.hFigure.SelectionType='normal';
            end
            internal.polariMBAngleMarker.wbdown(p,ev);





        end
    else
        plot_glow(p,true);
        changeMouseBehavior(p,'dataset_buttondown');
    end

    if(isprop(p.Parent,'ToolBar')&&~strcmp(p.Parent.ToolBar,'none'))||...
        (isprop(p.Parent.Parent,'ToolBar')&&...
        ~strcmp(p.ParentParent.ToolBar,'none'))
        enableDefaultInteractivity(p.hAxes)
    end
end

function wbdrag(p,ev)



    p.hFigure.CurrentPoint=ev.Point;
end

function showToolTipAndPtr_datasetDown(p)
    resetToolTip(p);
    setptr(p.hFigure,'arrow');
end

function showToolTipAndPtr(p,option,datasetIndex)

    if p.ToolTips&&~isempty(p.hToolTip)&&isvalid(p.hToolTip)


        if nargin<3
            datasetIndex=p.pHoverDataSetIndex;
        end
        if~isempty(datasetIndex)&&(getNumDatasets(p)>1)&&...
            (datasetIndex==p.pCurrentDataSetIndex)
            active=' (ACTIVE)';
        else
            active='';
        end
        str=sprintf('DATASET %d%s\n',datasetIndex,active);
        if strcmpi(option,'up')
            str={str,'Drag cursor to reposition'};
        else
            if isIntensityData(p)
                str={str,'Drag to change magnitude limits'};
            else

                if p.TemporaryCursor





                else
                    str={str};
                end
            end
            str=[str,'Double-click to add cursor'];
        end
        start(p.hToolTip,str);
    end

    setptr(p.hFigure,'arrow');

end
