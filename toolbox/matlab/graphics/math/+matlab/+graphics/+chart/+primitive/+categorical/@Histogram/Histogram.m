classdef(ConstructOnLoad,Sealed)Histogram<matlab.graphics.primitive.Data...
    &matlab.graphics.mixin.Legendable&matlab.graphics.chart.interaction.DataAnnotatable...
    &matlab.graphics.mixin.Selectable&matlab.graphics.mixin.AxesParentable...
    &matlab.graphics.mixin.PolarAxesParentable&matlab.graphics.internal.Legacy...
    &matlab.graphics.mixin.ColorOrderUser








































    properties(Dependent)



        Data{mustBeCategorical(Data)}=categorical([])






        BinCounts=0





        Categories{mustBeStringOrCellstrCategories(Categories)}=cell(1,0)




        NumDisplayBins=0










        DisplayOrder matlab.internal.datatype.matlab.graphics.datatype.CategoryOrder='data'






















        Normalization matlab.internal.datatype.matlab.graphics.datatype.HistogramNorm='count'






        ShowOthers matlab.internal.datatype.matlab.graphics.datatype.on_off='off'









        FaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto'








        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor=[0,0,0]




        LineWidth=0.5



        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'
    end

    properties(Dependent,NeverAmbiguous)






        BinCountsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Dependent,AbortSet)



        Orientation matlab.internal.datatype.matlab.graphics.datatype.HorizontalVertical='vertical'
    end

    properties






        DisplayStyle matlab.internal.datatype.matlab.graphics.datatype.HistogramStyle='bar'






        BarWidth=0.9





        FaceAlpha=0.6





        EdgeAlpha=1
    end

    properties(Transient,SetAccess=private)






        Values=zeros(1,0)






        OthersValue(1,1)double{mustBeReal}=0
    end

    properties(Hidden)
        Data_I categorical=categorical([])
        BinCounts_I double{matlab.internal.validation.mustBeVector(BinCounts_I)}=zeros(1,0)
        Categories_I cell{matlab.internal.validation.mustBeVector(Categories_I)}=cell(1,0)
        DisplayOrder_I matlab.internal.datatype.matlab.graphics.datatype.CategoryOrder='data'
        Normalization_I matlab.internal.datatype.matlab.graphics.datatype.HistogramNorm='count'
        ShowOthers_I matlab.internal.datatype.matlab.graphics.datatype.on_off='off'
        Orientation_I matlab.internal.datatype.matlab.graphics.datatype.HorizontalVertical='vertical'
        FaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto'
        EdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor=[0,0,0]
        EdgeColorStairs_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto'
        LineWidth_I(1,1)double{mustBeReal}=0.5
        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'
    end

    properties(Hidden,NeverAmbiguous)
        BinCountsMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        CategoriesMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        NumDisplayBinsMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Dependent,Access=private)


        BinCounts_P double{matlab.internal.validation.mustBeVector(BinCounts_P)}
    end

    properties(SetAccess=private,Hidden)
        AutoColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,1]
    end

    properties(Access=private,Hidden)
        Codes double{matlab.internal.validation.mustBeVector(Codes)}
    end

    properties(Transient,Access=?tcategoricalhistogram,Hidden)
        Face matlab.graphics.primitive.world.Quadrilateral
        Edge matlab.graphics.primitive.world.LineStrip
    end

    properties(Transient,DeepCopy,SetAccess=private,GetAccess=?graphicstest.mixins.Selectable)
        SelectionHandle{mustBe_matlab_mixin_Heterogeneous};
    end

    methods

        function hObj=Histogram(varargin)

            hObj.Face=matlab.graphics.primitive.world.Quadrilateral('Internal',true);
            hObj.Edge=matlab.graphics.primitive.world.LineStrip(...
            'LineJoin','miter','LineCap','square','LineWidth',0.5,...
            'AlignVertexCenters','on','Internal',true);

            try
                varargin=extractInputNameValue(hObj,varargin,'Parent');
                varargin=extractInputNameValue(hObj,varargin,'Data','Data_I');

                [varargin,cats,tf]=extractInputNameValue(hObj,varargin,...
                'Categories');
                if~tf
                    bincell={};
                else
                    bincell={'Categories',cats};
                    hObj.DisplayOrder_I='manual';
                end

                varargin=extractInputNameValue(hObj,varargin,'ShowOthers');

                [counts,catnames]=histcounts(hObj.Data,bincell{:});
                hObj.BinCounts_P=counts;
                catnames=reshape(catnames,1,[]);
                hObj.Categories_I=catnames;




                varargin=extractInputNameValue(hObj,varargin,...
                'Orientation','Orientation_I');




                [varargin,numdisplaybins,tf]=extractInputNameValue(hObj,varargin,...
                'NumDisplayBins');
                if~tf
                    numdisplaybins=length(catnames);
                else
                    hObj.NumDisplayBinsMode_I='manual';
                end

                varargin=extractInputNameValue(hObj,varargin,...
                'DisplayOrder','DisplayOrder_I');
                displayorder=hObj.DisplayOrder;

                if ismember(displayorder,{'ascend','descend'})
                    [~,ind]=sort(counts,displayorder);
                else
                    ind=1:length(catnames);
                end
                reorder(hObj,ind(1:numdisplaybins));

                allcategories=getAllCategories(hObj);
                if strcmp(hObj.Orientation,'horizontal')
                    [~,codes]=matlab.graphics.internal.makeNumeric(hObj,1,allcategories);
                else
                    codes=matlab.graphics.internal.makeNumeric(hObj,allcategories,1);
                end
                if isnumeric(codes)


                    hObj.Codes=codes;
                end

                hObj.addDependencyConsumed({'dataspace',...
                'hgtransform_under_dataspace','xyzdatalimits',...
                'colororder_linestyleorder'});



                if~isempty(varargin)
                    set(hObj,varargin{:});
                end
            catch me



                reset(hObj);
                rethrow(me);
            end
        end

        function data=get.Data(hObj)
            data=hObj.Data_I;
        end

        function set.Data(hObj,data)
            oldordinal=isordinal(hObj.Data_I);
            newordinal=isordinal(data);
            if oldordinal~=newordinal
                error(message('MATLAB:categorical:histogram:MixedOrdinalNonOrdinalAssign'));
            end
            datacategories=categories(data);
            if newordinal&&~isequal(datacategories,categories(hObj.Data_I))
                error(message('MATLAB:categorical:histogram:MixedOrdinalAssign'));
            end
            if strcmp(hObj.ShowOthers,'on')&&any(strcmpi("Others",datacategories))
                otherscat=datacategories{find(strcmpi("Others",datacategories),1)};
                error(message('MATLAB:categorical:histogram:AmbiguousOthers',otherscat));
            end
            hObj.Data_I=data;


            hObj.BinCountsMode='auto';
        end

        function bincounts=get.BinCounts(hObj)
            bincounts=hObj.BinCounts_I;
        end

        function set.BinCounts(hObj,bincounts)
            if strcmp(hObj.ShowOthers,'on')
                error(message('MATLAB:categorical:histogram:ShowOthersManualMode'));
            end
            validateattributes(bincounts,{'numeric'},{'row','real','finite','nonnegative'});
            hObj.BinCountsMode='manual';
            hObj.BinCounts_P=double(bincounts);

            if ismember(hObj.DisplayOrder,{'ascend','descend'})
                [~,ind]=sort(bincounts,hObj.DisplayOrder);
                reorder(hObj,ind);
            end
        end

        function set.BinCounts_P(hObj,bincounts)
            hObj.BinCounts_I=bincounts;
            normalize(hObj);
        end

        function bincountsmode=get.BinCountsMode(hObj)
            bincountsmode=hObj.BinCountsMode_I;
        end

        function set.BinCountsMode(hObj,bincountsmode)
            if strcmp(bincountsmode,'auto')
                cats=hObj.Categories;
                if strcmp(hObj.CategoriesMode_I,'auto')
                    [counts,cats]=histcounts(hObj.Data);
                else
                    counts=histcounts(hObj.Data,cats);
                end

                if ismember(hObj.DisplayOrder,{'ascend','descend'})
                    [~,ind]=sort(hObj.BinCounts,hObj.DisplayOrder);
                    reorder(hObj,ind);
                end
                nbins=hObj.NumDisplayBins;
                hObj.setNewCategories(cats,counts);

                if strcmp(hObj.NumDisplayBinsMode_I,'manual')&&nbins<length(cats)
                    hObj.NumDisplayBins=nbins;
                end
            else
                if strcmp(hObj.ShowOthers,'on')
                    error(message('MATLAB:categorical:histogram:ShowOthersManualMode'));
                end

                hlink=hggetbehavior(hObj,'Linked');
                if~isempty(hlink)
                    set(hlink,'YDataSource','');
                    f=ancestor(hObj,'figure');
                    datamanager.updateLinkedGraphics(f);
                end
            end
            hObj.BinCountsMode_I=bincountsmode;
        end

        function set.Values(hObj,values)
            hObj.Values=values;
            hObj.MarkDirty('all');
            hObj.sendDataChangedEvent();
        end

        function set.OthersValue(hObj,value)
            hObj.OthersValue=value;
            hObj.MarkDirty('all');
            hObj.sendDataChangedEvent();
        end

        function categories=get.Categories(hObj)
            categories=hObj.Categories_I;
        end

        function set.Categories(hObj,categories)
            mustBeStringOrCellstrCategories(categories);
            if isstring(categories)
                categories=cellstr(categories);
            end
            if numel(categories)~=numel(unique(categories))
                error(message('MATLAB:categorical:histogram:RepeatedCategories'));
            end

            if strcmp(hObj.ShowOthers,'on')&&any(strcmpi("Others",categories))
                otherscat=categories{find(strcmpi("Others",categories),1)};
                error(message('MATLAB:categorical:histogram:AmbiguousOthers',otherscat));
            end

            if strcmp(hObj.BinCountsMode,'auto')
                counts=histcounts(hObj.Data,categories);
                hObj.BinCounts_P=counts;
            else
                normalize(hObj);
            end
            hObj.Categories_I=reshape(categories,1,[]);
            hObj.DisplayOrder_I='manual';
            hObj.CategoriesMode_I='manual';

            updateAxis(hObj);
        end

        function numbins=get.NumDisplayBins(hObj)
            numbins=length(hObj.Categories);
        end

        function set.NumDisplayBins(hObj,numbins)
            if strcmp(hObj.BinCountsMode,'manual')
                error(message('MATLAB:categorical:histogram:NumDisplayBinsManualMode'));
            end
            validateattributes(numbins,{'numeric'},{'scalar',...
            'integer','nonnegative','<=',length(categories(hObj.Data))},...
            class(hObj),'NumDisplayBins');
            order=hObj.DisplayOrder;
            if ismember(order,{'ascend','descend'})
                counts=histcounts(hObj.Data);
                [sortedcounts,ind]=sort(counts,order);
                cats=categories(hObj.Data);
                setNewCategories(hObj,cats(ind(1:numbins)),sortedcounts(1:numbins));
            else
                allcats=categories(hObj.Data);
                setNewCategories(hObj,allcats(1:numbins));
                hObj.DisplayOrder_I='data';
            end
            hObj.NumDisplayBinsMode_I='manual';
        end

        function order=get.DisplayOrder(hObj)
            order=hObj.DisplayOrder_I;
        end

        function set.DisplayOrder(hObj,order)
            if strcmp(order,'manual')
                error(message('MATLAB:categorical:histogram:ManualDisplayOrder'));
            end
            bincounts=hObj.BinCounts_I;
            if ismember(order,{'ascend','descend'})
                [~,ind]=sort(bincounts,order);
            else
                cats=categories(hObj.Data);
                [~,locb]=ismember(hObj.Categories,cats);
                locb(locb==0)=Inf;
                [~,ind]=sort(locb);
            end
            reorder(hObj,ind);
            hObj.DisplayOrder_I=order;
        end

        function normalization=get.Normalization(hObj)
            normalization=hObj.Normalization_I;
        end

        function set.Normalization(hObj,normalization)
            hObj.Normalization_I=normalization;
            normalize(hObj);
        end

        function showothers=get.ShowOthers(hObj)
            showothers=hObj.ShowOthers_I;
        end

        function set.ShowOthers(hObj,showothers)
            if strcmp(showothers,'on')
                others="Others";
                if strcmp(hObj.BinCountsMode,'manual')
                    error(message('MATLAB:categorical:histogram:ShowOthersManualMode'));
                elseif any(strcmpi(others,categories(hObj.Data)))||...
                    any(strcmpi(others,hObj.Categories))



                    allcats=categories(hObj.Data);
                    otherscati=find(strcmpi(others,allcats),1);
                    if~isempty(otherscati)
                        otherscat=allcats{otherscati};
                    else
                        otherscati=find(strcmpi(others,hObj.Categories),1);
                        otherscat=hObj.Categories{otherscati};
                    end
                    error(message('MATLAB:categorical:histogram:AmbiguousOthers',otherscat));
                end
            end
            hObj.ShowOthers_I=showothers;
            updateAxis(hObj);
            normalize(hObj);
        end

        function set.DisplayStyle(hObj,displaystyle)
            hObj.DisplayStyle=displaystyle;
            hObj.MarkDirty('all');
        end

        function set.BarWidth(hObj,barwidth)
            validateattributes(barwidth,{'double','single'},...
            {'scalar','real','nonnegative','<=',1},class(hObj),...
            'BarWidth');
            hObj.BarWidth=barwidth;
            hObj.MarkDirty('all');
        end

        function ori=get.Orientation(hObj)
            ori=hObj.Orientation_I;
        end



        function set.Orientation(hObj,~)
            [swapped,err]=matlab.graphics.internal.swapNonNumericXYRulers(hObj);
            if~swapped
                if strcmp(err,'Type')
                    error(message('MATLAB:categorical:histogram:OrientationMixedType'));
                elseif strcmp(err,'YYAxis')
                    error(message('MATLAB:categorical:histogram:OrientationYYAxes'));
                end
            end
        end

        function facecolor=get.FaceColor(hObj)
            if strcmp(hObj.DisplayStyle,'bar')
                facecolor=hObj.FaceColor_I;
            else
                facecolor='none';
            end
        end

        function set.FaceColor(hObj,facecolor)
            if strcmp(hObj.DisplayStyle,'bar')
                hObj.FaceColor_I=facecolor;
            else
                if~strcmp(facecolor,'none')
                    error(message('MATLAB:histogram:InvalidStairsFaceColor'));
                end
            end
            hObj.MarkDirty('all');
        end

        function edgecolor=get.EdgeColor(hObj)
            if strcmp(hObj.DisplayStyle,'bar')
                edgecolor=hObj.EdgeColor_I;
            else
                edgecolor=hObj.EdgeColorStairs_I;
            end
        end

        function set.EdgeColor(hObj,edgecolor)
            if strcmp(hObj.DisplayStyle,'bar')
                hObj.EdgeColor_I=edgecolor;
            else
                hObj.EdgeColorStairs_I=edgecolor;
            end
            hObj.MarkDirty('all');
        end

        function set.FaceAlpha(hObj,facealpha)
            validateattributes(facealpha,{'double','single'},...
            {'scalar','real','nonnegative','<=',1},class(hObj),...
            'FaceAlpha');
            hObj.FaceAlpha=facealpha;
            hObj.MarkDirty('all');
        end

        function set.EdgeAlpha(hObj,edgealpha)
            validateattributes(edgealpha,{'double','single'},...
            {'scalar','real','nonnegative','<=',1},class(hObj),...
            'EdgeAlpha');
            hObj.EdgeAlpha=edgealpha;
            hObj.MarkDirty('all');
        end

        function linewidth=get.LineWidth(hObj)
            linewidth=hObj.LineWidth_I;
        end

        function set.LineWidth(hObj,linewidth)
            validateattributes(linewidth,{'numeric'},...
            {'scalar','real','positive','finite'},class(hObj),...
            'LineWidth');
            hObj.Edge.LineWidth=linewidth;

            hObj.LineWidth_I=hObj.Edge.LineWidth;
            hObj.MarkDirty('all');
        end

        function linestyle=get.LineStyle(hObj)
            linestyle=hObj.LineStyle_I;
        end

        function set.LineStyle(hObj,linestyle)
            hgfilter('LineStyleToPrimLineStyle',hObj.Edge,...
            linestyle);
            hObj.LineStyle_I=linestyle;
            hObj.MarkDirty('all');
        end

        function set.Codes(hObj,codes)

            hObj.Codes=reshape(codes,1,[]);
            hObj.MarkDirty('all');
        end

        function set.Face(hObj,face)

            if~isempty(hObj.Face)
                delete(hObj.Face);
            end

            if isempty(face.Parent)
                hObj.Face=face;
            else

                hObj.Face=copy(face);
            end
            hObj.addNode(hObj.Face);
        end

        function set.Edge(hObj,edge)

            if~isempty(hObj.Edge)
                delete(hObj.Edge);
            end

            if isempty(edge.Parent)
                hObj.Edge=edge;
            else

                hObj.Edge=copy(edge);
            end
            hObj.addNode(hObj.Edge);
        end

        function set.SelectionHandle(hObj,hsel)
            hObj.SelectionHandle=hsel;
            if~isempty(hObj.SelectionHandle)
                hObj.addNode(hObj.SelectionHandle);


                hObj.SelectionHandle.Description='Histogram SelectionHandle';
            end
        end

    end

    methods(Hidden)
        function ex=getXYZDataExtents(hObj)
            values=getAllValues(hObj);
            codes=hObj.Codes;

            x=matlab.graphics.chart.primitive.utilities.arraytolimits(...
            codes);
            y=matlab.graphics.chart.primitive.utilities.arraytolimits(values);
            y(1)=0;
            y(4)=max(0,y(4));
            z=[0,NaN,NaN,0];

            if strcmp(hObj.Orientation,'vertical')
                ex=[x;y;z];
            else
                ex=[y;x;z];
            end
        end

        function doUpdate(hObj,us)

            if strcmp(hObj.BinCountsMode,'manual')&&(length(hObj.Categories)~=length(hObj.BinCounts))

                hObj.Face.Visible='off';
                hObj.Edge.Visible='off';
                error(message('MATLAB:categorical:histogram:CategoriesInvalidSize'));
            end

            values=getAllValues(hObj);
            vertical=strcmp(hObj.Orientation,'vertical');

            if~vertical
                dep_scale=us.DataSpace.XScale;
                dep_lim=us.DataSpace.XLim;
            else
                dep_scale=us.DataSpace.YScale;
                dep_lim=us.DataSpace.YLim;
            end

            if strcmp(hObj.DisplayStyle,'bar')
                create_fcn=@hObj.create_bar_coordinates;
                facevisible='on';
            else
                create_fcn=@hObj.create_stairs_coordinates;
                facevisible='off';
            end
            [x,y,s]=create_fcn(hObj.Codes,values,hObj.BarWidth);

            yIsNonFinite=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
            dep_scale,dep_lim,y);
            y(yIsNonFinite)=eps(0);

            piter=matlab.graphics.axis.dataspace.XYZPointsIterator;

            if~vertical
                piter.XData=y;
                piter.YData=x;
            else
                piter.XData=x;
                piter.YData=y;
            end

            vd=TransformPoints(us.DataSpace,...
            us.TransformUnderDataSpace,...
            piter);

            q=hObj.Face;
            q.VertexData=vd;

            r=hObj.Edge;
            set(r,'VertexData',vd,'StripData',s);

            facecolor=hObj.FaceColor;
            facealpha=hObj.FaceAlpha;

            if strcmp(facecolor,'auto')
                if hObj.SeriesIndex~=0
                    facecolor=hObj.getColor(us);
                    if~isempty(facecolor)
                        hObj.AutoColor=facecolor;
                    end
                else
                    facecolor=hObj.AutoColor;
                end

                facecolor=uint8(([facecolor,facealpha]*255).');
                set(q,'ColorData',facecolor,'ColorBinding','object',...
                'ColorType','truecoloralpha','Visible',facevisible);
            elseif strcmp(facecolor,'none')
                set(q,'Visible','off');
            else
                facecolor=uint8(([facecolor,facealpha]*255).');
                set(q,'ColorData',facecolor,'ColorBinding','object',...
                'ColorType','truecoloralpha','Visible',facevisible);
            end

            edgecolor=hObj.EdgeColor;
            edgealpha=hObj.EdgeAlpha;

            if strcmp(edgecolor,'auto')
                edgecolor=hObj.AutoColor;
                edgecolor=uint8(([edgecolor,edgealpha]*255).');
                set(r,'ColorData',edgecolor,'ColorBinding','object',...
                'ColorType','truecoloralpha','Visible','on');
            elseif strcmp(edgecolor,'none')
                set(r,'Visible','off');
            else
                edgecolor=uint8(([edgecolor,edgealpha]*255).');
                set(r,'ColorData',edgecolor,'ColorBinding','object',...
                'ColorType','truecoloralpha','Visible','on');
            end


            if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&strcmp(hObj.SelectionHighlight,'on')
                if isempty(hObj.SelectionHandle)
                    hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);
                end
                if vertical
                    indep_row=1;
                    dep_row=2;
                else
                    indep_row=2;
                    dep_row=1;
                end


                vd_sel=vd(dep_row,:)>vd(dep_row,1);


                [~,minindex]=min(vd(indep_row,1:4:end));
                [~,maxindex]=max(vd(indep_row,4:4:end));
                vd_sel([(minindex-1)*4+1,(maxindex-1)*4+4])=true;
                hObj.SelectionHandle.VertexData=vd(:,vd_sel);
                hObj.SelectionHandle.Visible='on';
            else
                if~isempty(hObj.SelectionHandle)
                    hObj.SelectionHandle.VertexData=[];
                    hObj.SelectionHandle.Visible='off';
                end
            end

        end

        function actualValue=setParentImpl(hObj,proposedValue)
            proposedParent=ancestor(proposedValue,...
            'matlab.graphics.axis.AbstractAxes','node');
            if isa(proposedParent,'matlab.graphics.axis.PolarAxes')
                error(message('MATLAB:categorical:histogram:UnsupportedPolarCoordinates'));
            end


            [oldxr,oldyr]=matlab.graphics.internal.getRulersForChild(hObj);
            allcategories=getAllCategories(hObj);
            hori=strcmp(hObj.Orientation,'horizontal');

            if hori
                oldruler=oldyr;
            else
                oldruler=oldxr;
            end
            if~isempty(oldruler)&&...
                isa(oldruler,'matlab.graphics.axis.decorator.CategoricalRuler')
                updateRulerCategories(oldruler,hObj,{});
            end

            if~isempty(proposedParent)
                [newxr,newyr]=matlab.graphics.internal.getRulersForChild(proposedParent);
                if hori
                    newruler=newyr;
                else
                    newruler=newxr;
                end


                if~isempty(newruler)&&...
                    isa(newruler,'matlab.graphics.axis.decorator.CategoricalRuler')&&...
                    ~isempty(allcategories)
                    updateRulerCategories(newruler,hObj,allcategories);
                end
                if hori
                    [~,hObj.Codes]=matlab.graphics.internal.makeNumeric(proposedParent,1,allcategories);
                else
                    hObj.Codes=matlab.graphics.internal.makeNumeric(proposedParent,allcategories,1);
                end
            end
            actualValue=proposedValue;
        end

        function delete(hObj)
            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');
            if~isempty(ax)&&strcmp(ax.BeingDeleted,'off')

                [xr,yr]=matlab.graphics.internal.getRulersForChild(hObj);

                if strcmp(hObj.Orientation,'horizontal')
                    ruler=yr;
                else
                    ruler=xr;
                end

                if~isempty(ruler)&&...
                    isa(ruler,'matlab.graphics.axis.decorator.CategoricalRuler')
                    updateRulerCategories(ruler,hObj,{});
                end
            end
        end

        function graphic=getLegendGraphic(hObj)
            graphic=matlab.graphics.primitive.world.Group;

            face=matlab.graphics.primitive.world.Quadrilateral;

            face.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);
            face.VertexIndices=[];
            face.StripData=[];
            face.ColorBinding='object';
            face.ColorType='truecoloralpha';
            face.ColorData=hObj.Face.ColorData;
            face.Visible=hObj.Face.Visible;
            face.Parent=graphic;

            edge=matlab.graphics.primitive.world.LineLoop('LineJoin',...
            'miter','AlignVertexCenters','on');
            edge.LineWidth=hObj.Edge.LineWidth;
            edge.LineStyle=hObj.Edge.LineStyle;

            edge.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);
            edge.VertexIndices=[];
            edge.StripData=uint32([1,5]);
            edge.ColorBinding='object';
            edge.ColorType='truecoloralpha';
            edge.ColorData=hObj.Edge.ColorData;
            edge.Visible=hObj.Edge.Visible;
            edge.Parent=graphic;
        end

        function mcodeConstructor(this,code)


            propsToAdd={'Categories','Normalization','Orientation'};
            propsToIgnore={'Data','NumDisplayBins'};
            autobincountsmode=strcmp(this.BinCountsMode,'auto');
            if autobincountsmode
                propsToIgnore=[propsToIgnore,{'BinCounts'}];

            else
                propsToAdd=[propsToAdd,{'BinCounts'}];
            end
            if strcmp(this.DisplayOrder,'manual')
                propsToIgnore=[propsToIgnore,{'DisplayOrder'}];
            else
                propsToAdd=[propsToAdd,{'DisplayOrder'}];
            end

            setConstructorName(code,'histogram');

            if autobincountsmode
                arg=codegen.codeargument('Name','data',...
                'IsParameter',true,'comment','histogram data');
                addConstructorArgin(code,arg);
            end

            ignoreProperty(code,propsToIgnore);
            addProperty(code,propsToAdd);


            generateDefaultPropValueSyntax(code);
        end

        function morebins(~)
            error(message('MATLAB:categorical:histogram:UnsupportedMorebins'));
        end

        function fewerbins(~)
            error(message('MATLAB:categorical:histogram:UnsupportedFewerbins'));
        end

        function resetDataCachePropertiesPost(hObj)
            cats=getAllCategories(hObj);
            if strcmp(hObj.Orientation,'horizontal')
                [~,codes]=matlab.graphics.internal.makeNumeric(hObj,1,cats);
            else
                codes=matlab.graphics.internal.makeNumeric(hObj,cats,1);
            end
            hObj.Codes=codes;
        end

        function reactToXYRulerSwap(hObj)
            oldval=hObj.Orientation;
            if strcmp(oldval,'horizontal')
                newval='vertical';
            else
                newval='horizontal';
            end
            hObj.Orientation_I=newval;
            hObj.MarkDirty('all');
            hObj.sendDataChangedEvent();
        end


        function data=getDimensionData(hObj,dim)
            data=[];
            if strcmp(hObj.Orientation,'horizontal')
                if dim==1
                    data=getAllValues(hObj);
                elseif dim==2
                    data=getAllCategories(hObj);
                end
            else
                if dim==1
                    data=getAllCategories(hObj);
                elseif dim==2
                    data=getAllValues(hObj);
                end
            end
        end


        function dataTipRows=createDefaultDataTipRows(~)

            dataTipRows=[dataTipTextRow(getString(message('MATLAB:categorical:histogram:Value')),'BinCount');...
            dataTipTextRow(getString(message('MATLAB:categorical:histogram:Category')),'CategoryName')];
        end

        function coordinateData=createCoordinateData(hObj,valueSource,dataIndex,~)
            import matlab.graphics.chart.interaction.dataannotatable.internal.CoordinateData;
            coordinateData=CoordinateData.empty(0,1);

            switch(valueSource)
            case 'BinCount'
                allvalues=getAllValues(hObj);
                coordinateData=CoordinateData(valueSource,allvalues(dataIndex));
            case 'CategoryName'
                [~,catnames]=getAllCategories(hObj);
                coordinateData=CoordinateData(valueSource,catnames{dataIndex});
            end
        end


        function valueSources=getAllValidValueSources(~)
            valueSources=["BinCount";"CategoryName"];
        end
    end

    methods(Access=protected)
        function group=getPropertyGroups(~)
            group=matlab.mixin.util.PropertyGroup({'Data',...
            'Values','NumDisplayBins','Categories','DisplayOrder',...
            'Normalization','DisplayStyle','FaceColor','EdgeColor'});
        end


        function descriptors=doGetDataDescriptors(hObj,index,~)



            [~,catnames]=getAllCategories(hObj);
            allvalues=getAllValues(hObj);
            descriptors=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
            catnames{index},allvalues(index));
        end

        function index=doGetNearestIndex(hObj,index)
            index=max(1,min(index,length(getAllCategories(hObj))));
        end

        function index=doGetNearestPoint(hObj,position)
            index=localGetNearestPoint(hObj,position,true);
        end

        function[index,interpolationFactor]=doGetInterpolatedPoint(hObj,position)
            index=doGetNearestPoint(hObj,position);
            interpolationFactor=0;
        end

        function[index,interpolationFactor]=doGetInterpolatedPointInDataUnits(hObj,position)
            index=localGetNearestPoint(hObj,position,false);
            interpolationFactor=0;
        end

        function points=doGetEnclosedPoints(~,~)
            points=[];
        end

        function[index,interpolationFactor]=doIncrementIndex(hObj,index,direction,~)
            if any(strcmp(direction,{'left','down'}))
                index=max(index-1,1);
            else
                index=min(index+1,length(hObj.Categories));
            end

            interpolationFactor=0;
        end

        function point=doGetDisplayAnchorPoint(hObj,index,~)
            allvalues=getAllValues(hObj);
            if strcmp(hObj.Orientation,'vertical')
                point=matlab.graphics.shape.internal.util.SimplePoint(...
                [hObj.Codes(index),allvalues(index),0]);
            else
                point=matlab.graphics.shape.internal.util.SimplePoint(...
                [allvalues(index),hObj.Codes(index),0]);
            end
        end

        function point=doGetReportedPosition(hObj,index,interpolationFactor)
            point=doGetDisplayAnchorPoint(hObj,index,interpolationFactor);
        end
    end

    methods(Access=private)


        function[inputs,propval,found]=extractInputNameValue(hObj,inputs,propname,assignname)
            if nargin<4
                assignname=propname;
            end
            if nargout>1
                returnval=true;
                propval=[];
                found=false;
            else
                returnval=false;
            end
            index=(find(strcmp(inputs(1:2:end),propname))-1)*2+1;
            for i=1:length(index)


                if returnval
                    propval=inputs{index(i)+1};
                    found=true;
                else
                    set(hObj,assignname,inputs{index(i)+1});
                end
            end
            inputs([index,index+1])=[];
        end



        function normalize(hObj)
            counts=hObj.BinCounts;
            if strcmp(hObj.BinCountsMode,'auto')
                counts=[counts,numel(hObj.Data)-sum(hObj.BinCounts)];
            else
                counts=[counts,0];
            end
            switch hObj.Normalization
            case{'count','countdensity'}
                values=counts;
            case 'cumcount'
                values=cumsum(counts);
            case{'probability','pdf'}
                values=counts/sum(counts);
            case 'cdf'
                values=cumsum(counts/sum(counts));
            end

            hObj.Values=values(1:end-1);
            hObj.OthersValue=values(end);
        end



        function reorder(hObj,ind)

            ind=reshape(ind,1,[]);
            hObj.Categories_I=hObj.Categories(ind);
            hObj.BinCounts_P=hObj.BinCounts(ind);

            updateAxis(hObj);
        end




        function setNewCategories(hObj,categories,counts)
            if nargin<3
                counts=histcounts(hObj.Data,categories);
            end
            hObj.BinCounts_P=counts;

            hObj.Categories_I=reshape(categories,1,[]);

            updateAxis(hObj);
        end



        function[cats,catnames]=getAllCategories(hObj)
            if strcmp(hObj.ShowOthers,'on')
                catnames=[hObj.Categories,"Others"];
            else
                catnames=hObj.Categories;
            end
            if isordinal(hObj.Data)
                catorder=intersect(categories(hObj.Data),catnames,'stable');
                if strcmp(hObj.ShowOthers,'on')
                    catorder=[catorder;catnames(end)];
                end
                cats=categorical(catnames,catorder,'Ordinal',true);
            else
                cats=categorical(catnames,catnames);
            end
        end


        function values=getAllValues(hObj)
            if strcmp(hObj.ShowOthers,'on')
                values=[hObj.Values,hObj.OthersValue];
            else
                values=hObj.Values;
            end
        end


        function updateAxis(hObj)
            [xr,yr]=matlab.graphics.internal.getRulersForChild(hObj);
            if strcmp(hObj.Orientation,'horizontal')
                ruler=yr;
            else
                ruler=xr;
            end

            if~isempty(ruler)
                cats=getAllCategories(hObj);

                if isa(ruler,'matlab.graphics.axis.decorator.CategoricalRuler')
                    updateRulerCategories(ruler,hObj,cats);
                end

                if strcmp(hObj.Orientation,'horizontal')
                    [~,codes]=matlab.graphics.internal.makeNumeric(hObj,...
                    1,cats);
                else
                    codes=matlab.graphics.internal.makeNumeric(hObj,...
                    cats,1);
                end
                if isnumeric(codes)


                    hObj.Codes=codes;
                end
            end
        end

        function faceIndex=localGetNearestPoint(hObj,position,isPixelPosition)
            allvalues=getAllValues(hObj);
            [x,y]=hObj.create_bar_coordinates(hObj.Codes,allvalues,hObj.BarWidth);
            y=max(y,eps(0));
            if strcmp(hObj.Orientation,'vertical')
                verts=[x(:),y(:)];
            else
                verts=[y(:),x(:)];
            end
            faces=transpose(reshape(1:size(verts,1),4,[]));



            faces(:,[3,4])=faces(:,[4,3]);



            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            faceIndex=pickUtils.nearestFace(hObj,position,isPixelPosition,faces,verts);

            if isempty(faceIndex)








                midverts=(verts(faces(:,3),:)+verts(faces(:,2),:))./2;

                if strcmp(hObj.Orientation,'vertical')
                    metric='x';
                else
                    metric='y';
                end

                faceIndex=pickUtils.nearestPoint(hObj,position,isPixelPosition,midverts,metric);
            end
        end
    end

    methods(Static,Access=private)
        function[x,y,stripdata]=create_bar_coordinates(codes,values,barwidth)


            halfwidth=barwidth/2;
            x=bsxfun(@plus,repmat(codes,4,1),halfwidth*[-1;-1;1;1]);
            x=reshape(x,1,[]);

            values(isnan(values))=0;
            y=[zeros(1,numel(values));repmat(reshape(values,1,[]),2,1);...
            zeros(1,numel(values))];
            y=reshape(y,1,[]);

            stripdata=uint32(1:4:length(x)+1);
        end

        function[x,y,stripdata]=create_stairs_coordinates(codes,values,~)


            if~isempty(codes)
                halfwidth=0.5;
                isconsec=diff(codes)==1;

                x=reshape([codes-halfwidth;codes+halfwidth],1,[]);
                repfactors=[2,repelem(1+~isconsec,1,2),2];
                x=repelem(x,1,repfactors);

                values(isnan(values))=0;
                y=[0,reshape([values;zeros(1,length(values))],1,[])];
                repfactors=[1...
                ,reshape([2*ones(1,length(isconsec));2*~isconsec],1,[]),2,1];
                y=repelem(y,1,repfactors);

                stripdata=cumsum(2+2*~isconsec);
                stripdata=uint32([1,1+stripdata(~isconsec),length(x)+1]);
            else
                x=zeros(1,0);
                y=zeros(1,0);
                stripdata=uint32([1,1]);
            end
        end
    end

    methods(Static,Hidden)
        function varargout=doloadobj(hObj)
            if strcmp(hObj.BinCountsMode,'auto')
                hObj.BinCounts_P=histcounts(hObj.Data,hObj.Categories);
            else
                normalize(hObj);
            end


            hObj.LineWidth=hObj.LineWidth;
            hObj.LineStyle=hObj.LineStyle;
            varargout{1}=hObj;
        end
    end

end

function mustBeStringOrCellstrCategories(cats)

    if(~iscellstr(cats)&&~isstring(cats))||~isvector(cats)
        error(message('MATLAB:categorical:histogram:InvalidCategoriesAssign'));
    end
end

function mustBe_matlab_mixin_Heterogeneous(input)
    if~isa(input,'matlab.mixin.Heterogeneous')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropInitialClsMismatch','%s',message('MATLAB:type:PropInitialClsMismatch','matlab.mixin.Heterogeneous').getString));
    end
end

function mustBeCategorical(data)
    if~iscategorical(data)
        error(message('MATLAB:class:RequireClass','categorical'));
    end
end
