classdef polariPeaksTable<handle


    events
CloseRequest
    end

    properties(Dependent)
Location
    end

    properties
ContextMenuFcn
PolariObj
        Title='Peaks'
        Units=''
        Values=[]
        Visible=true
        Width=150
    end

    properties(Access=private)
        pLocation=[1,1]
hFigPanel
hListeners
    end

    properties(Constant,Hidden)
        MaxPeaksInTable=10
    end

    methods
        function obj=polariPeaksTable(p,varargin)


            obj.PolariObj=p;
            fig=p.hFigure;
            if~ishghandle(fig)
                error('Parent must be an HG handle.');
            end
            if~any(strcmpi(fig.Type,{'figure','uicontainer','uipanel'}))
                error('Parent must be a figure, uicontainer or uipanel.');
            end


            if nargin>1
                Nv=numel(varargin);
                if rem(Nv,2)~=0
                    error('Incorrect number of parameter/value arguments.');
                end
                for i=1:2:Nv
                    obj.(varargin{i})=varargin{i+1};
                end
            end

            init(obj);
        end

        function set.Values(obj,val)
            if~isempty(val)
                validateattributes(val,{'numeric'},...
                {'vector','real'},'polariPeaksTable','Values');
            end
            obj.Values=val;


            updateString(obj);
        end

        function set.Location(obj,val)
            validateattributes(val,{'numeric'},...
            {'vector','numel',2,'real','positive'},...
            'polariPeaksTable','Location');
            obj.pLocation=val;


            fp=obj.hFigPanel;
            if~isempty(fp)&&ishghandle(fp)
                h=fp.Position(4);
                fp.Position(1:2)=val-[0,h];
            end
        end

        function set.Title(obj,val)
            if isempty(val)
                val='';
            else
                validateattributes(val,{'char','string'},...
                {'vector'},...
                'polariPeaksTable','Title');
            end
            obj.Title=val;


            updateTitle(obj);
        end

        function set.Units(obj,val)
            if isempty(val)
                val='';
            else
                validateattributes(val,{'char','string'},...
                {'vector'},...
                'polariPeaksTable','Units');
            end
            obj.Units=val;


            updateString(obj);
        end

        function val=get.Location(obj)

            fp=obj.hFigPanel;
            if~isempty(fp)&&ishghandle(fp)
                h=fp.Position(4);
                val=fp.Position(1:2)+[0,h];
                obj.pLocation=val;
            else
                val=obj.pLocation;
            end
        end

        function set.Width(obj,val)
            validateattributes(val,{'numeric'},...
            {'scalar','real','positive'},...
            'polariPeaksTable','Width');
            obj.Width=val;


            updatePosition(obj);
        end

        function set.Visible(obj,val)
            validateattributes(val,{'logical','numeric'},...
            {'scalar','real'},...
            'polariPeaksTable','Visible');
            obj.Visible=logical(val);


            updateVisible(obj);
        end

        function val=get.Visible(obj)

            fp=obj.hFigPanel;
            if~isempty(fp)&&ishghandle(fp)

                val=obj.Visible;
            else

                val=false;
            end
        end

        function delete(obj)


            deleteAllListeners(obj);
            delete(obj.hFigPanel);
        end
    end

    methods(Access=private)
        function init(obj,loc)


            p=obj.PolariObj;
            hf=p.hFigure;
            if~isempty(hf)&&ishghandle(hf)


                hc=uicontextmenu(...
                'Parent',hf,...
                'Callback',@(h,ev)callbackContextMenu(obj,h,ev),...
                'HandleVisibility','off');


                if~matlab.ui.internal.isUIFigure(hf)
                    fp=...
                    matlab.graphics.shape.internal.FigurePanel('Parent',hf);
                    fp.DeleteFcn=@(h,ev)deleteFigPanel(obj);
                    fp.UIContextMenu=hc;
                    obj.hFigPanel=fp;
                else
                    fp=...
                    annotation(hf,'textbox','FitBoxToText','on');
                    fp.DeleteFcn=@(h,ev)deleteFigPanel(obj);
                    fp.ContextMenu=hc;
                    obj.hFigPanel=fp;
                    fp.Position(1:2)=[0,0];
                    fp.BackgroundColor=[0.98,0.98,0.98];
                    fp.Units='pixels';
                end


                updateTitle(obj);
                updateString(obj);
                if nargin>1
                    updatePosition(obj,loc);
                else
                    updatePosition(obj);
                end
                updateVisible(obj);
            end


            initListeners(obj);

            updatePeakMarkersList(obj);
        end

        function initListeners(obj)





            deleteAllListeners(obj);
            p=obj.PolariObj;





            lis.PeakMarkersListListener=addlistener(p,...
            {'hPeakAngleMarkers','pCurrentDataSetIndex'},...
            'PostSet',@(~,~)updatePeakMarkersList(obj));



            lis.PolariDataUnits=addlistener(p,...
            'DataUnitsChanged',@(~,~)updatePeakMarkersList(obj));

            obj.hListeners=lis;
        end

        function callbackContextMenu(obj,h,ev)






            cmFcn=obj.ContextMenuFcn;
            if~isempty(cmFcn)
                cmFcn(h,ev);
            end
        end

        function updatePeakMarkersList(obj)


            p=obj.PolariObj;
            if isempty(p)
                return
            end

            dIdx=p.pCurrentDataSetIndex;
            if isempty(dIdx)
                obj.Title='Peaks';
                obj.Values=[];
                obj.Units='';
            else
                obj.Title=sprintf('Peaks (Dataset %d)',dIdx);



                mAll=findPeakMarkersOnDataset(p,dIdx);
                Np=numel(mAll);
                v=zeros(1,Np);
                u_i='';
                for i=1:Np
                    m_i=mAll(i);
                    d=getData(m_i);
                    v(i)=d.mag.*d.scale;
                    u_i=d.units;
                end
                obj.Values=v;
                obj.Units=u_i;
            end
        end

        function deleteFigPanel(obj)



            if isvalid(obj)


                dummy=obj.Location;%#ok<NASGU>

                notify(obj,'CloseRequest');
            end
        end

        function deleteAllListeners(obj)
            obj.hListeners=internal.polariCommon.deleteListenerStruct(...
            obj.hListeners);
        end

        function updateTitle(obj)

            fp=obj.hFigPanel;
            if~isempty(fp)&&isvalid(fp)
                if isa(fp,'matlab.graphics.shape.internal.FigurePanel')
                    fp.Title=obj.Title;
                else
                    fp.String=[{obj.Title};fp.String];
                end
            end
        end

        function updatePosition(obj,loc)




            fp=obj.hFigPanel;
            if~isempty(fp)&&isvalid(fp)







                pos=fp.Position;
                h=pos(4);
                if nargin>1
                    pos(1:2)=loc-[0,h];
                else
                    pos(1:2)=obj.Location-[0,h];
                end
                pos(3)=obj.Width;
                fp.Position=pos;
            end
        end

        function updateVisible(obj)
            fp=obj.hFigPanel;
            if isempty(fp)||~ishghandle(fp)

                init(obj,obj.pLocation);
            else
                fp.Visible=internal.LogicalToOnOff(obj.Visible);
            end
        end

        function updateString(obj)




            fp=obj.hFigPanel;
            if~isempty(fp)&&isvalid(fp)


                v=obj.Values;
                Nv=numel(v);
                if Nv==0
                    str={'(no peaks)'};
                else



                    Nmax=obj.MaxPeaksInTable;
                    suppress=Nv>Nmax;
                    if suppress
                        Nx=Nv-Nmax;
                        Nv=Nmax;
                        Nstrs=Nv+1;
                    else
                        Nstrs=Nv;
                    end
                    vstr=internal.polariCommon.sprintfMaxNumTotalDigits(v(1:Nv),4,true);
                    unitStr=obj.Units;
                    str=cell(Nstrs,1);
                    for i=1:Nv
                        str{i}=[sprintf('%d: ',i),vstr{i},' ',unitStr];
                    end
                    if suppress
                        str{end}=sprintf(' (+%d more)',Nx);
                    end
                end

                repositionForSizeChange(obj,str);
            end
        end

        function repositionForSizeChange(obj,str_new)





            fp=obj.hFigPanel;
            loc_orig=obj.Location;
            pos_orig=fp.Position;

            p=obj.PolariObj;
            hf=p.hFigure;

            if~matlab.ui.internal.isUIFigure(hf)
                fp.String=str_new;
                updateTitle(obj);

            end


            obj.Location=loc_orig;


            loc_new=obj.Location;
            pos_new=fp.Position;
            if pos_new(2)<1


                fig_pos=obj.PolariObj.hFigure.Position;
                fig_dy=fig_pos(4);
                del=pos_orig(2)-pos_new(2);
                loc_new(2)=loc_new(2)+del;
                if loc_new(2)>fig_dy



                    del=loc_new(2)-fig_dy;
                    loc_new(2)=loc_new(2)-del;
                end
                obj.Location=loc_new;
            end
        end
    end
end
