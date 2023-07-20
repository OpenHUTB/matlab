classdef(ConstructOnLoad,Sealed)Histogram<matlab.graphics.primitive.Data...
    &matlab.graphics.mixin.Legendable&matlab.graphics.chart.interaction.DataAnnotatable...
    &matlab.graphics.mixin.Selectable&matlab.graphics.mixin.AxesParentable...
    &matlab.graphics.mixin.PolarAxesParentable&matlab.graphics.internal.Legacy...
    &matlab.graphics.mixin.ColorOrderUser















































    properties(Dependent)









        Data=[]






        BinCounts=0




        NumBins=1











        BinEdges=[0,1]







        BinWidth=1







































        BinMethod matlab.internal.datatype.matlab.graphics.datatype.HistogramBinMethod='manual'






        BinLimits=[0,1]

































        Normalization matlab.internal.datatype.matlab.graphics.datatype.HistogramNorm='count'









        FaceColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto'








        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor=[0,0,0]




        LineWidth=0.5



        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'
    end

    properties(Dependent,NeverAmbiguous)






        BinCountsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'






        BinLimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(AbortSet)



        Orientation matlab.internal.datatype.matlab.graphics.datatype.HorizontalVertical='vertical'
    end

    properties






        DisplayStyle matlab.internal.datatype.matlab.graphics.datatype.HistogramStyle='bar'





        FaceAlpha=0.6





        EdgeAlpha=1
    end

    properties(Transient,SetAccess=private)






        Values double=0
    end

    properties(Hidden)
        Data_I=[]
        BinCounts_I double{matlab.internal.validation.mustBeVector(BinCounts_I)}=0;
        BinEdges_I=[0,1]
        BinWidth_I=1
        BinMethod_I matlab.internal.datatype.matlab.graphics.datatype.HistogramBinMethod='manual'
        Normalization_I matlab.internal.datatype.matlab.graphics.datatype.HistogramNorm='count'
        FaceColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto'
        EdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor=[0,0,0]
        EdgeColorStairs_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor='auto'
        LineWidth_I(1,1)double{mustBeReal}=0.5
        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'
    end

    properties(Hidden,NeverAmbiguous)
        BinCountsMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        BinLimitsMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Dependent,Access=private)


        BinCounts_P double{matlab.internal.validation.mustBeVector(BinCounts_P)}



        BinEdgesCache=[0,1]
    end

    properties(SetAccess=private,Hidden)
        AutoColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,1]
    end

    properties(Transient,Access={?tHistogram,?thistogram,?thistogramDatetime,?thistogramDuration},Hidden)
        Face matlab.graphics.primitive.world.Quadrilateral
        Edge matlab.graphics.primitive.world.LineStrip
        BrushFace matlab.graphics.primitive.world.Quadrilateral
        BrushEdge matlab.graphics.primitive.world.LineStrip
    end

    properties(Transient,DeepCopy,SetAccess=private,GetAccess=?graphicstest.mixins.Selectable)
        SelectionHandle{mustBe_matlab_mixin_Heterogeneous};
    end

    properties(Transient,Hidden)






        Orientation_I matlab.internal.datatype.matlab.graphics.datatype.HorizontalVertical='vertical'
        BrushValues double
        BrushColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[1,0,0]
    end

    properties(Transient,Access=private)
        indepLimCache=[0,1]
    end

    properties(Transient,SetAccess=private,Hidden)



        Brushed(1,1)logical=false



        HasNewParent(1,1)logical=false



        BinsWereComputedForPolar(1,1)logical=false
    end

    properties(Access=private,Constant)

        BrushAlpha=0.6
    end

    methods

        function hObj=Histogram(varargin)

            hObj.Face=matlab.graphics.primitive.world.Quadrilateral('Internal',true);
            hObj.Edge=matlab.graphics.primitive.world.LineStrip(...
            'LineJoin','miter','LineCap','square','LineWidth',0.5,...
            'AlignVertexCenters','on','Internal',true);
            hObj.BrushFace=matlab.graphics.primitive.world.Quadrilateral(...
            'HitTest','on','Internal',true);
            hObj.BrushEdge=matlab.graphics.primitive.world.LineStrip(...
            'LineJoin','miter','LineCap','square',...
            'AlignVertexCenters','on','HitTest','on','Internal',true);
            addlistener(hObj.BrushFace,'Hit',@(~,ed)...
            matlab.graphics.chart.primitive.brushingUtils.addBrushContextMenuCallback(hObj,ed));
            addlistener(hObj.BrushEdge,'Hit',@(~,ed)...
            matlab.graphics.chart.primitive.brushingUtils.addBrushContextMenuCallback(hObj,ed));



            varargin=extractInputNameValue(hObj,varargin,'Parent');


            setInteractionHint(hObj,'DataBrushing',false);




            hObj.HasNewParent=false;

            dataindex=(find(strcmp(varargin(1:2:end),'Data'))-1)*2+1;
            for i=1:length(dataindex)
                data=varargin{dataindex(i)+1};
                validateattributes(data,{'numeric','logical','datetime',...
                'duration'},{'real'},class(hObj),'Data');
                hObj.Data_I=data;
            end
            varargin([dataindex,dataindex+1])=[];

            binfieldnames={'NumBins','BinWidth','BinMethod',...
            'BinLimits','BinEdges'};
            binindex=(find(ismember(varargin(1:2:end),binfieldnames))-1)*2+1;
            if~isempty(binindex)
                bincell=varargin(reshape([binindex;binindex+1],1,[]));
                countsindex=(find(ismember(varargin(1:2:end),'BinCounts'))-1)*2+1;
                if isempty(countsindex)
                    [counts,binedges]=computeBinEdgesAndCounts(hObj,hObj.Data,bincell{:});
                    binedges=reshape(binedges,1,[]);
                    if islogical(binedges)
                        hObj.BinEdges_I=double(binedges);
                    else
                        hObj.BinEdges_I=binedges;
                    end
                    hObj.BinCounts_P=counts;
                else
                    hObj.BinCounts_P=double(varargin{countsindex(end)+1});
                    hObj.BinCountsMode='manual';
                    set(hObj,bincell{:});
                    binindex=[binindex,countsindex];
                    binedges=hObj.BinEdges;
                end

                hObj.BinWidth_I=hObj.binEdgesToBinWidth(binedges);


                binpropnames=bincell(1:2:end);
                if ismember('BinEdges',binpropnames)
                    hObj.BinLimitsMode_I='manual';
                else
                    index=(find(strcmp(binpropnames,'BinMethod'))-1)*2+1;
                    if~isempty(index)&&~any(ismember({'NumBins','BinWidth'},...
                        bincell(index(end)+2:2:end)))
                        hObj.BinMethod_I=bincell{index(end)+1};
                    end
                    if ismember('BinLimits',varargin(binindex))
                        hObj.BinLimitsMode_I='manual';
                    end
                end
                varargin([binindex,binindex+1])=[];
            else
                hObj.BinMethod='auto';
            end




            orientationindex=(find(strcmp(varargin(1:2:end),'Orientation'))-1)*2+1;
            for i=1:length(orientationindex)
                hObj.Orientation_I=varargin{orientationindex(i)+1};
            end
            varargin([orientationindex,orientationindex+1])=[];

            hObj.addDependencyConsumed({'dataspace',...
            'hgtransform_under_dataspace','xyzdatalimits',...
            'colororder_linestyleorder'});





            varargin=extractInputNameValue(hObj,varargin,'DisplayStyle');
            if~isempty(varargin)
                set(hObj,varargin{:});
            end

        end

        function data=get.Data(hObj)
            data=hObj.Data_I;
        end

        function set.Data(hObj,data)
            validateattributes(data,{'numeric','logical','datetime',...
            'duration'},{'real'},class(hObj),'Data');

            if~isequal(class(data),class(hObj.Data))&&(isdatetime(data)...
                ||isduration(data)||isdatetime(hObj.Data)||isduration(hObj.Data))
                error(message('MATLAB:histogram:FixedDataClass'));
            end
            hObj.Data_I=data;



            hObj.BinCountsMode='auto';
        end

        function bincounts=get.BinCounts(hObj)
            bincounts=hObj.BinCounts_I;
        end

        function set.BinCounts(hObj,bincounts)
            validateattributes(bincounts,{'numeric'},{'row','real','finite','nonnegative'});
            hObj.BinCountsMode='manual';
            hObj.BinCounts_P=double(bincounts);
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
                if~strcmp(hObj.BinMethod,'manual')
                    if strcmp(hObj.BinLimitsMode,'auto')
                        [counts,hObj.BinEdges_I]=hObj.computeBinEdgesAndCounts(hObj.Data,...
                        'BinMethod',hObj.BinMethod);
                    else
                        [counts,hObj.BinEdges_I]=hObj.computeBinEdgesAndCounts(hObj.Data,...
                        'BinMethod',hObj.BinMethod,'BinLimits',hObj.BinLimits);
                    end


                    hObj.BinCounts_P=counts;
                else
                    hObj.BinCounts_P=hObj.computeBinEdgesAndCounts(hObj.Data,hObj.BinEdges);
                end
            else

                hlink=hggetbehavior(hObj,'Linked');
                if~isempty(hlink)
                    set(hlink,'YDataSource','');
                    f=ancestor(hObj,'figure');
                    if~isempty(f)&&~isempty(f.findprop('LinkPlot'))&&f.LinkPlot
                        datamanager.updateLinkedGraphics(f);
                    end
                end
            end
            hObj.BinCountsMode_I=bincountsmode;
        end

        function numbins=get.NumBins(hObj)
            numbins=length(hObj.BinEdges)-1;
        end

        function set.NumBins(hObj,numbins)
            if strcmp(hObj.BinCountsMode,'manual')
                error(message('MATLAB:histogram:ReadOnlyPropertyManualBinCounts','NumBins'));
            end
            validateattributes(numbins,{'numeric'},...
            {'scalar','integer','positive'},class(hObj),'NumBins');
            data=hObj.Data;

            if strcmp(hObj.BinLimitsMode,'manual')
                [counts,binedges]=hObj.computeBinEdgesAndCounts(data,numbins,...
                'BinLimits',hObj.BinLimits);
            else
                [counts,binedges]=hObj.computeBinEdgesAndCounts(data,numbins);
            end

            hObj.BinEdges_I=binedges;
            hObj.BinMethod_I='manual';
            hObj.BinWidth_I=hObj.binEdgesToBinWidth(binedges);
            hObj.BinCounts_P=counts;
        end

        function edges=get.BinEdges(hObj)
            edges=hObj.BinEdges_I;
        end

        function set.BinEdges(hObj,binedges)
            if strcmp(hObj.BinCountsMode,'auto')
                if isdatetime(hObj.Data)
                    if~(isdatetime(binedges)&&isrow(binedges))
                        error(message('MATLAB:histogram:InvalidDatetimeEdges'));
                    elseif~issorted(binedges)||any(isnat(binedges))
                        error(message('MATLAB:histogram:UnsortedDatetimeEdges'));
                    end
                elseif isduration(hObj.Data)
                    if~(isduration(binedges)&&isrow(binedges))
                        error(message('MATLAB:histogram:InvalidDurationEdges'));
                    elseif~issorted(binedges)||any(isnan(binedges))
                        error(message('MATLAB:histogram:UnsortedDurationEdges'));
                    end
                else
                    validateattributes(binedges,{'numeric'},...
                    {'row','nondecreasing'},class(hObj),'BinEdges');
                end
            else
                if isdatetime(binedges)||isduration(binedges)
                    if~isrow(binedges)
                        bincountslen=length(hObj.BinCounts);
                        error(message('MATLAB:histogram:ManualEdges',...
                        bincountslen+1,bincountslen));
                    end
                    if isdatetime(binedges)
                        if~issorted(binedges)||any(isnat(binedges))
                            error(message('MATLAB:histogram:UnsortedDatetimeEdges'));
                        end
                    elseif isduration(binedges)
                        if~issorted(binedges)||any(isnan(binedges))
                            error(message('MATLAB:histogram:UnsortedDurationEdges'));
                        end
                    end
                else
                    validateattributes(binedges,{'numeric'},...
                    {'row','nondecreasing'},class(hObj),'BinEdges');
                end
            end
            if length(binedges)<2
                error(message('MATLAB:histogram:EmptyOrScalarBinEdges'));
            end

            hObj.BinEdges_I=binedges;
            hObj.BinLimitsMode_I='manual';
            hObj.BinMethod_I='manual';

            hObj.BinWidth_I=hObj.binEdgesToBinWidth(binedges);

            if strcmp(hObj.BinCountsMode,'auto')
                counts=hObj.computeBinEdgesAndCounts(hObj.Data,binedges);
                hObj.BinCounts_P=counts;
            else
                normalize(hObj);
            end
        end


        function numericedges=get.BinEdgesCache(hObj)
            if strcmp(hObj.Orientation,'horizontal')
                [~,tempedges]=matlab.graphics.internal.makeNumeric(hObj,1,hObj.BinEdges);
            else
                tempedges=matlab.graphics.internal.makeNumeric(hObj,hObj.BinEdges,1);
            end
            if isnumeric(tempedges)


                numericedges=tempedges;
            else


                numericedges=[];
            end
        end

        function binwidth=get.BinWidth(hObj)
            binwidth=hObj.BinWidth_I;
        end

        function set.BinWidth(hObj,binwidth)
            if strcmp(hObj.BinCountsMode,'manual')
                error(message('MATLAB:histogram:ReadOnlyPropertyManualBinCounts','BinWidth'));
            end

            if isdatetime(hObj.Data)||isduration(hObj.Data)
                if isduration(binwidth)
                    if~(isscalar(binwidth)&&isfinite(binwidth)&&binwidth>0)
                        error(message('MATLAB:histogram:InvalidBinWidth'));
                    end
                elseif iscalendarduration(binwidth)
                    if isduration(hObj.Data)
                        error(message('MATLAB:histogram:InvalidDurationBinWidth'));
                    end
                    if~(isscalar(binwidth)&&isfinite(binwidth))
                        error(message('MATLAB:histogram:InvalidBinWidth'));
                    end
                    [caly,calm,cald,calt]=split(binwidth,{'year','month','day','time'});
                    if(caly<0||calm<0||cald<0||calt<0)||...
                        (caly==0&&calm==0&&cald==0&&calt==0)
                        error(message('MATLAB:histogram:InvalidBinWidth'));
                    end
                else
                    if isduration(hObj.Data)
                        error(message('MATLAB:histogram:InvalidDurationBinWidth'));
                    else
                        error(message('MATLAB:histogram:InvalidDatetimeBinWidth'));
                    end
                end
            else
                validateattributes(binwidth,{'numeric'},...
                {'scalar','positive','finite'},class(hObj),'BinWidth');
            end

            pvpairs={'BinWidth',binwidth};
            if strcmp(hObj.BinLimitsMode,'manual')
                pvpairs=[pvpairs,{'BinLimits',hObj.BinLimits}];
            end
            [counts,binedges]=hObj.computeBinEdgesAndCounts(hObj.Data,...
            pvpairs{:});
            hObj.BinEdges_I=binedges;
            hObj.BinWidth_I=hObj.binEdgesToBinWidth(binedges);
            hObj.BinMethod_I='manual';
            hObj.BinCounts_P=counts;
        end

        function binmethod=get.BinMethod(hObj)
            binmethod=hObj.BinMethod_I;
        end

        function set.BinMethod(hObj,binmethod)
            if strcmp(hObj.BinCountsMode,'manual')
                error(message('MATLAB:histogram:ReadOnlyPropertyManualBinCounts','BinMethod'));
            end
            if strcmp(binmethod,'manual')
                error(message('MATLAB:histogram:InvalidBinMethod'));
            end
            if(isnumeric(hObj.Data)||islogical(hObj.Data))
                if ismember(binmethod,{'century','decade','year',...
                    'quarter','month','week','day','hour','minute',...
                    'second'})
                    error(message('MATLAB:histogram:UnsupportedBinMethod',...
                    binmethod,class(hObj.Data)));
                end
            elseif isdatetime(hObj.Data)
                if ismember(binmethod,{'integers'})
                    error(message('MATLAB:histogram:UnsupportedBinMethod',...
                    binmethod,class(hObj.Data)));
                end
            else
                if ismember(binmethod,{'integers','century',...
                    'decade','quarter','month','week'})
                    error(message('MATLAB:histogram:UnsupportedBinMethod',...
                    binmethod,class(hObj.Data)));
                end
            end
            pvpairs={'BinMethod',binmethod};
            if strcmp(hObj.BinLimitsMode,'manual')
                pvpairs=[pvpairs,{'BinLimits',hObj.BinLimits}];
            end
            [counts,binedges]=hObj.computeBinEdgesAndCounts(hObj.Data,...
            pvpairs{:});

            hObj.BinEdges_I=binedges;
            hObj.BinCounts_P=counts;

            hObj.BinMethod_I=binmethod;
            hObj.BinWidth_I=hObj.binEdgesToBinWidth(binedges);
        end

        function binlimits=get.BinLimits(hObj)
            binedges=hObj.BinEdges;
            binlimits=[binedges(1),binedges(end)];
        end

        function set.BinLimits(hObj,binlimits)



            if strcmp(hObj.BinCountsMode,'manual')
                error(message('MATLAB:histogram:ReadOnlyPropertyManualBinCounts','BinLimits'));
            end
            if isdatetime(hObj.Data)||isduration(hObj.Data)
                if~(isequal(class(binlimits),class(hObj.Data))...
                    &&numel(binlimits)==2&&issorted(binlimits)&&...
                    all(isfinite(binlimits)))
                    error(message('MATLAB:histogram:InvalidDatetimeOrDurationBinLimits',...
                    class(hObj.Data)));
                end
            else
                validateattributes(binlimits,{'numeric'},{'real',...
                'nondecreasing','size',[1,2],'finite'},...
                class(hObj),'BinLimits');
            end

            bw=hObj.BinWidth;
            if ischar(bw)
                bw=diff(binlimits)/hObj.NumBins;
            end
            [counts,binedges]=hObj.computeBinEdgesAndCounts(hObj.Data,'BinWidth',bw,...
            'BinLimits',binlimits);

            hObj.BinWidth_I=bw;
            hObj.BinEdges_I=binedges;
            hObj.BinLimitsMode_I='manual';
            hObj.BinMethod_I='manual';
            hObj.BinCounts_P=counts;
        end

        function binlimitsmode=get.BinLimitsMode(hObj)
            binlimitsmode=hObj.BinLimitsMode_I;
        end

        function set.BinLimitsMode(hObj,binlimitsmode)






            if strcmp(hObj.BinCountsMode,'manual')
                error(message('MATLAB:histogram:ReadOnlyPropertyManualBinCounts','BinLimitsMode'));
            end
            hObj.BinLimitsMode_I=binlimitsmode;

            if strcmp(binlimitsmode,'auto')
                if isPolar(hObj)
                    hObj.NumBins=hObj.NumBins;
                else
                    bw=hObj.BinWidth;
                    if~ischar(bw)
                        hObj.BinWidth=bw;
                    else
                        binlimitsdiff=diff(hObj.BinLimits);
                        if isfinite(binlimitsdiff)
                            hObj.BinWidth=binlimitsdiff/hObj.NumBins;
                        end
                    end
                end
            end
        end

        function set.Values(hObj,values)
            hObj.Values=values;
            hObj.MarkDirty('all');
            hObj.sendDataChangedEvent();
        end

        function normalization=get.Normalization(hObj)
            normalization=hObj.Normalization_I;
        end

        function set.Normalization(hObj,normalization)
            if isdatetime(hObj.BinEdges)||isduration(hObj.BinEdges)
                if ismember(normalization,{'countdensity','pdf'})
                    error(message('MATLAB:histogram:UnsupportedDatetimeOrDurationNormalization',...
                    normalization))
                end
            end
            hObj.Normalization_I=normalization;
            normalize(hObj);
        end

        function set.DisplayStyle(hObj,displaystyle)
            hObj.DisplayStyle=displaystyle;
            hObj.MarkDirty('all');
        end

        function ori=get.Orientation(hObj)
            ori=hObj.Orientation_I;
        end

        function set.Orientation(hObj,ori)
            hori=strcmpi(ori,'horizontal');
            if isPolar(hObj)&&hori
                error(message('MATLAB:histogram:UnsupportedOrientationInPolarCoordinates'));
            end




            if isnumeric(hObj.BinEdges)%#ok<MCSUP>
                reactToXYRulerSwap(hObj);
            else
                [swapped,err]=matlab.graphics.internal.swapNonNumericXYRulers(hObj);
                if~swapped
                    if strcmp(err,'Type')
                        error(message('MATLAB:histogram:OrientationMixedType'));
                    elseif strcmp(err,'YYAxis')
                        error(message('MATLAB:histogram:OrientationYYAxes'));
                    end
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

        function set.BrushFace(hObj,face)


            if isempty(hObj.BrushFace)
                hObj.BrushFace=face;
                hObj.addNode(hObj.BrushFace);
            end
        end

        function set.BrushEdge(hObj,edge)


            if isempty(hObj.BrushEdge)
                hObj.BrushEdge=edge;
                hObj.addNode(hObj.BrushEdge);
            end
        end

        function set.BrushValues(hObj,brushvalues)
            hObj.BrushValues=brushvalues;
            hObj.MarkDirty('all');
        end

        function numbins=morebins(hObj)





            if any(strcmp({hObj.BinCountsMode},'manual'))
                error(message('MATLAB:histogram:UnsupportedMethodManualBinCounts','morebins'));
            end
            hlen=numel(hObj);
            numbins=ceil([hObj.NumBins]*1.1);
            for i=1:hlen
                hObj(i).NumBins=numbins(i);
            end
        end

        function numbins=fewerbins(hObj)





            if any(strcmp({hObj.BinCountsMode},'manual'))
                error(message('MATLAB:histogram:UnsupportedMethodManualBinCounts','fewerbins'));
            end
            hlen=numel(hObj);
            numbins=max(floor([hObj.NumBins]*0.9),1);
            for i=1:hlen
                hObj(i).NumBins=numbins(i);
            end

        end

    end

    methods(Hidden)
        function ex=getXYZDataExtents(hObj)

            hObj.recomputeBinsForNewCoordinateSystem();

            ori=hObj.Orientation;
            values=hObj.Values;
            edges=matlab.graphics.chart.primitive.histogram.internal.handleNonFiniteEdges(hObj.BinEdgesCache);

            x=matlab.graphics.chart.primitive.utilities.arraytolimits(edges);
            xd=double(x);


            if~any(xd<0)
                xd(2)=NaN;
            end
            if~any(xd>0)
                xd(3)=NaN;
            end
            y=matlab.graphics.chart.primitive.utilities.arraytolimits(values);
            y(1)=0;
            y(4)=max(0,y(4));
            z=[0,NaN,NaN,0];
            if strcmp(ori,'vertical')
                ex=[xd;y;z];
            else
                ex=[y;xd;z];
            end
        end

        function actualValue=setParentImpl(hObj,proposedValue)




            proposedAxesParent=ancestor(proposedValue,...
            'matlab.graphics.axis.AbstractAxes','node');

            if isa(proposedAxesParent,'matlab.graphics.axis.PolarAxes')
                if strcmp(hObj.Orientation,'horizontal')
                    error(message('MATLAB:histogram:UnsupportedOrientationInPolarCoordinates'));
                elseif strcmpi(hObj.BinMethod,'manual')&&...
                    (max(hObj.BinEdges)-min(hObj.BinEdges)>2*pi)
                    error(message('MATLAB:histogram:BinRangePolar'));
                end
            end
            actualValue=proposedValue;

            hObj.HasNewParent=true;
        end

        function doUpdate(hObj,us)
            if isequal(hObj.BinCountsMode,'manual')&&~isequal(length(hObj.BinCounts)+1,length(hObj.BinEdges))

                hObj.Face.Visible='off';
                hObj.Edge.Visible='off';
                hObj.BrushFace.Visible='off';
                hObj.BrushEdge.Visible='off';
                error(message('MATLAB:histogram:BinCountsBinEdgesSizeMismatch'));
            end
            hObj.recomputeBinsForNewCoordinateSystem();

            binedges=hObj.BinEdgesCache;
            values=hObj.Values;
            vertical=strcmp(hObj.Orientation,'vertical');

            dsHasScale=isprop(us.DataSpace,'XScale');

            dsIsPolar=isPolar(hObj);




            if(dsIsPolar&&~vertical)


                error(message('MATLAB:histogram:UnsupportedOrientationInPolarCoordinates'));
            end


            indep_scale='linear';
            dep_scale='linear';

            if~vertical
                if dsHasScale
                    indep_scale=us.DataSpace.YScale;
                    dep_scale=us.DataSpace.XScale;
                end
                indep_lim=us.DataSpace.YLim;
                dep_lim=us.DataSpace.XLim;
            else
                if dsHasScale
                    indep_scale=us.DataSpace.XScale;
                    dep_scale=us.DataSpace.YScale;
                end
                indep_lim=us.DataSpace.XLim;
                dep_lim=us.DataSpace.YLim;
            end



            if dsIsPolar
                indep_lim=indep_lim./us.TransformUnderDataSpace(1);
            end
            hObj.indepLimCache=indep_lim;


            if dsHasScale
                xIsInvalid=...
                matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
                indep_scale,indep_lim,binedges);
                binedges=binedges(~xIsInvalid);

                if all(xIsInvalid)
                    yRemove=false(1,length(xIsInvalid)-1);
                else
                    index=find(~xIsInvalid,1,'last');
                    yRemove=~xIsInvalid;
                    yRemove(index)=[];
                end
                values=values(yRemove);
            else
                yRemove=true(1,length(values));
            end

            stairs=strcmp(hObj.DisplayStyle,'stairs');
            if~stairs
                if dsIsPolar
                    create_fcn=@matlab.graphics.chart.primitive.Histogram.create_bar_coordinates_interp;
                else
                    create_fcn=@matlab.graphics.chart.primitive.Histogram.create_bar_coordinates;
                end
                facevisible='on';
            else
                if dsIsPolar
                    create_fcn=@matlab.graphics.chart.primitive.Histogram.create_stairs_coordinates_interp;
                else
                    create_fcn=@matlab.graphics.chart.primitive.Histogram.create_stairs_coordinates;
                end
                facevisible='off';
            end







            [finiteEdges,validValues]=...
            matlab.graphics.chart.primitive.Histogram.clipInfiniteEdgesForDisplay...
            (binedges,values,indep_lim,dsIsPolar);

            interp=1;
            if(dsIsPolar)


                minvertspercircle=64;
                interp=ceil(max(diff(binedges))*minvertspercircle/(2*pi));


                if mod(interp,2)==0
                    interp=interp+1;
                end

                interp=max(3,interp);
            end

            [x,y,s,facestrip,faceinds,selinds]=create_fcn(finiteEdges,validValues,interp);


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
            q.StripData=facestrip;
            q.VertexIndices=faceinds;

            r=hObj.Edge;
            set(r,'VertexData',vd,'StripData',s);

            if(dsIsPolar)
                r.AlignVertexCenters='off';
            else
                r.AlignVertexCenters='on';
            end

            if hObj.SeriesIndex~=0
                colorOrderColor=hObj.getColor(us);
                if~isempty(colorOrderColor)
                    hObj.AutoColor=colorOrderColor;
                end
            end

            facecolor=hObj.FaceColor;
            facealpha=hObj.FaceAlpha;
            if strcmp(facecolor,'auto')
                facecolor=uint8(([hObj.AutoColor,facealpha]*255).');
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




                hObj.SelectionHandle.VertexData=vd(:,selinds);
                hObj.SelectionHandle.MaxNumPoints=100;
                hObj.SelectionHandle.Visible='on';
            else
                if~isempty(hObj.SelectionHandle)
                    hObj.SelectionHandle.VertexData=[];
                    hObj.SelectionHandle.Visible='off';
                end
            end


            brushvalues=hObj.BrushValues;
            if~isempty(brushvalues)&&isequal(size(brushvalues),size(hObj.Values))...
                &&~any(brushvalues>hObj.Values)
                brushvalues=brushvalues(yRemove);

                [brushFiniteEdges,brushValidValues]=...
                matlab.graphics.chart.primitive.Histogram.clipInfiniteEdgesForDisplay...
                (binedges,brushvalues,indep_lim,dsIsPolar);


                [bx,by,bs,bfacestrip,bfaceinds]=create_fcn(brushFiniteEdges,brushValidValues,interp);
                byIsNonFinite=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
                dep_scale,dep_lim,by);
                by(byIsNonFinite)=eps(0);


                if stairs&&hObj.Brushed

                    byremove=(by==by(1));
                    bslogical=[false,diff(byremove)==-1,true];
                    bx(byremove)=[];
                    by(byremove)=[];
                    bslogical(byremove)=[];
                    bs=uint32(find(bslogical));
                end

                if~vertical
                    piter.XData=by;
                    piter.YData=bx;
                else
                    piter.XData=bx;
                    piter.YData=by;
                end

                bvd=TransformPoints(us.DataSpace,...
                us.TransformUnderDataSpace,...
                piter);

                bq=hObj.BrushFace;
                bq.VertexData=bvd;
                bq.StripData=bfacestrip;
                bq.VertexIndices=bfaceinds;

                brushcolor=uint8(([hObj.BrushColor,hObj.BrushAlpha]*255).');
                set(bq,'ColorData',brushcolor,'ColorBinding','object',...
                'ColorType','truecoloralpha');

                br=hObj.BrushEdge;
                set(br,'VertexData',bvd,'StripData',bs);
                set(br,'ColorData',brushcolor,'ColorBinding','object',...
                'ColorType','truecoloralpha','LineWidth',r.LineWidth+2);

                br.AlignVertexCenters=~dsIsPolar;
                hasB=any(hObj.BrushValues);
                bq.Visible=hasB&&~stairs;
                br.Visible=hasB&&stairs;
            else
                set(hObj.BrushFace,'Visible','off');
                set(hObj.BrushEdge,'Visible','off');
            end

            hObj.Brushed=false;
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

            edge.VertexData=face.VertexData;
            edge.VertexIndices=[];
            edge.StripData=uint32([1,5]);
            edge.ColorBinding='object';
            edge.ColorType='truecoloralpha';
            edge.ColorData=hObj.Edge.ColorData;
            edge.Visible=hObj.Edge.Visible;
            edge.Parent=graphic;
        end

        function mcodeConstructor(this,code)



            hParentMomento=up(get(code,'MomentoRef'));
            hPropertyList=get(hParentMomento,'PropertyObjects');

            if~isempty(hParentMomento)&&...
                isempty(findobj(hPropertyList,'Name','NextPlot'))

                hAxes=ancestor(this,'matlab.graphics.axis.AbstractAxes','node');
                if length(findobj(hAxes,'type','histogram'))>1
                    hParentCode=up(code);
                    if~isempty(hParentCode)
                        hPre=get(findobj(hParentCode,'-depth',1),...
                        'PreConstructorFunctions');


                        if all(cellfun(@(x)isempty(findobj(...
                            x,'Name','hold')),hPre))
                            hFunc=codegen.codefunction(...
                            'Name','hold','CodeRef',code);
                            addPreConstructorFunction(code,hFunc);


                            hAxesArg=codegen.codeargument(...
                            'Value',hAxes,'IsParameter',true);
                            addArgin(hFunc,hAxesArg);
                            hArg=codegen.codeargument('Value','on');
                            addArgin(hFunc,hArg);
                        end
                    end
                end
            end


            autobincountsmode=strcmp(this.BinCountsMode,'auto');
            if isdatetime(this.BinEdges)||isduration(this.BinEdges)



                propsToIgnore={'Data','BinEdges','BinLimits','BinWidth','NumBins'};
                if autobincountsmode
                    propsToIgnore=[propsToIgnore,{'BinCounts'}];
                    arg=codegen.codeargument('Name','data',...
                    'IsParameter',true,'comment','histogram data');
                    addConstructorArgin(code,arg);
                    if~strcmp(this.BinMethod,'manual')&&...
                        strcmp(this.BinLimitsMode,'auto')
                        propsToAdd={'BinMethod'};
                    else
                        propsToAdd={};
                        arg2=codegen.codeargument('Name','binedges',...
                        'IsParameter',true,'comment','histogram bin edges');
                        addConstructorArgin(code,arg2);
                    end
                else
                    propsToIgnore=[propsToIgnore,{'BinMethod'}];
                    propsToAdd={'BinCounts'};
                    arg=codegen.codeargument('Name','BinEdgesString',...
                    'IsParameter',false,'Value','BinEdges');
                    addConstructorArgin(code,arg);
                    arg2=codegen.codeargument('Name','binedges',...
                    'IsParameter',true,'comment','histogram bin edges');
                    addConstructorArgin(code,arg2);
                end
            else
                if autobincountsmode
                    if strcmp(this.BinMethod,'manual')
                        propsToIgnore={'Data','BinMethod','BinCounts'};
                        if strcmp(this.BinLimitsMode,'manual')
                            if strcmp(this.BinWidth,'nonuniform')
                                propsToAdd={'BinEdges'};
                                propsToIgnore=[propsToIgnore,{'BinWidth',...
                                'NumBins','BinLimits'}];
                            else
                                propsToAdd={'BinLimits','BinWidth'};
                                propsToIgnore=[propsToIgnore,{'BinEdges','NumBins'}];
                            end
                        elseif rem(this.BinLimits(1),this.BinWidth)==0
                            propsToAdd={'BinWidth'};
                            propsToIgnore=[propsToIgnore,{'BinEdges',...
                            'NumBins','BinLimits'}];
                        else
                            propsToAdd={'NumBins'};
                            propsToIgnore=[propsToIgnore,{'BinEdges',...
                            'BinWidth','BinLimits'}];
                        end
                    else
                        propsToIgnore={'Data','BinEdges','BinWidth',...
                        'NumBins','BinCounts'};
                        propsToAdd={'BinMethod'};
                        if strcmp(this.BinLimitsMode,'manual')
                            propsToAdd=[propsToAdd,{'BinLimits'}];
                        else
                            propsToIgnore=[propsToIgnore,{'BinLimits'}];
                        end
                    end
                    arg=codegen.codeargument('Name','data',...
                    'IsParameter',true,'comment','histogram data');
                    addConstructorArgin(code,arg);
                else
                    propsToAdd={'BinCounts','BinEdges'};
                    propsToIgnore={'Data','BinMethod','NumBins','BinWidth',...
                    'BinMethod','BinLimits'};
                end
            end

            setConstructorName(code,'histogram');

            ignoreProperty(code,propsToIgnore);
            addProperty(code,propsToAdd);


            generateDefaultPropValueSyntax(code);
        end

        function I=getBrushedElements(hObj,region)









            brushedIndex=localGetBrushedBins(hObj,region);
            if isPolar(hObj)


                minedge=min(hObj.BinEdges);


                data=mod(hObj.Data-minedge,2*pi)+minedge;
                bin=discretize(data,hObj.BinEdges);
            else
                bin=discretize(hObj.Data,hObj.BinEdges);
            end
            I=find(ismember(bin,brushedIndex));
        end



        function I=updatePartiallyBrushedI(hObj,I,Iextend,extendMode)
            if extendMode


                if isequal(size(hObj.Values),size(hObj.BrushValues))
                    partialbins=find((hObj.BrushValues<hObj.Values)&(hObj.BrushValues>0));
                    bin=discretize(hObj.Data,hObj.BinEdges);
                    Ipartial=ismember(bin,partialbins);
                else
                    Ipartial=[];
                end

                if~isempty(Ipartial)&&~isempty(Iextend)
                    I(Ipartial(:)&Iextend(:))=false;
                end
            end
        end

        function updateBrushedGraphic(hObj,region,lastregion)





            if~isequal(size(hObj.BrushValues),size(hObj.Values))
                hObj.BrushValues=zeros(size(hObj.Values));
            end

            if any(strcmp(hObj.Normalization,{'cumcount','cdf'}))
                Icurrent=localGetBrushedBins(hObj,region);
                if~isempty(lastregion)
                    Ilast=localGetBrushedBins(hObj,lastregion);
                else
                    Ilast=[];
                end
                Iextend=setdiff(Icurrent,Ilast);
                Icontract=setdiff(Ilast,Icurrent);


                fig=ancestor(hObj,'figure');
                if strcmp(fig.SelectionType,'extend')


                    hObj.BrushValues(Iextend)=~hObj.BrushValues(Iextend).*hObj.Values(Iextend);
                    hObj.BrushValues(Icontract)=~hObj.BrushValues(Icontract)...
                    .*hObj.Values(Icontract);
                else
                    hObj.BrushValues(Iextend)=hObj.Values(Iextend);
                    hObj.BrushValues(Icontract)=0;
                end


                hObj.BrushValues((hObj.BrushValues<hObj.Values)&(hObj.BrushValues>0))=0;
            end
            hObj.Brushed=true;
        end

        function polar=isPolar(hObj)
            polar=isa(...
            ancestor(hObj,'matlab.graphics.axis.dataspace.DataSpace','node'),...
            'matlab.graphics.axis.dataspace.PolarDataSpace');
        end

        function recomputeBinsForNewCoordinateSystem(hObj)

            if~hObj.HasNewParent||...
                isPolar(hObj)==hObj.BinsWereComputedForPolar




                return
            end

            pvpairs={};






            if strcmp(hObj.BinCountsMode,'manual')
                return;
            else
                if strcmpi(hObj.BinMethod,'manual')
                    pvpairs=[pvpairs,{'BinEdges',hObj.BinEdges}];
                else
                    pvpairs={'BinMethod',hObj.BinMethod};
                    if strcmp(hObj.BinLimitsMode,'manual')
                        pvpairs=[pvpairs,{'BinLimits',hObj.BinLimits}];
                    end
                end
            end
            [counts,binedges]=hObj.computeBinEdgesAndCounts(hObj.Data,...
            pvpairs{:});


            hObj.BinEdges_I=binedges;
            hObj.BinCounts_P=counts;
            hObj.BinWidth_I=hObj.binEdgesToBinWidth(binedges);
            hObj.HasNewParent=false;
        end
        function[n,edges]=computeBinEdgesAndCounts(hObj,data,varargin)




            binargs={};
            if isPolar(hObj)

                chunk=pi/4;





                binedgeargi=find(strcmpi('BinEdges',varargin));
                binedges=[];
                if~isempty(binedgeargi)
                    binedges=varargin{binedgeargi+1};
                elseif nargin>1&&isnumeric(varargin{1})&&length(varargin{1})>1
                    binedges=varargin{1};
                end

                if~isempty(binedges)
                    binedgesmin=min(binedges(isfinite(binedges)));
                    binedgestrunc=binedges(isfinite(binedges)&(binedges<=binedgesmin+2*pi));
                    if length(binedgestrunc)<length(binedges)
                        error(message('MATLAB:histogram:BinRangePolar'));
                    elseif~isempty(binedges)
                        binargs={'BinEdges',binedges};
                    end
                else



                    binlimargi=find(strcmpi('BinLimits',varargin));
                    if~isempty(binlimargi)
                        manlims=varargin{binlimargi+1};
                        lowedge=manlims(1);
                        upedge=manlims(2);
                        if(upedge-lowedge>2*pi)
                            error(message('MATLAB:histogram:BinLimitsRangePolar'));
                        end
                    else
                        dmin=min(data,[],'all');
                        dmax=max(data,[],'all');
                        lowedge=floor(dmin/chunk)*chunk;
                        if dmax-dmin>2*pi



                            upedge=lowedge+2*pi;
                        else

                            upedge=ceil(dmax/chunk)*chunk;
                            if upedge-lowedge>2*pi



                                chunk=pi/12;
                                lowedge=floor(dmin/chunk)*chunk;
                                upedge=ceil(dmax/chunk)*chunk;
                                if upedge-lowedge>2*pi



                                    lowedge=dmin;
                                    upedge=lowedge+2*pi;
                                end
                            end
                        end
                    end

                    binlims=[lowedge,upedge];
                    if~isempty(binlims)
                        binargs={'BinLimits',binlims};
                    end
                end





                binmethodargi=find(strcmpi('BinMethod',varargin));
                if~isempty(binmethodargi)
                    if strcmpi(varargin{binmethodargi+1},'auto')
                        varargin{binmethodargi+1}='scott';
                    end
                end


                [~,tbinedges]=histcounts(data,varargin{:},binargs{:});
                minedge=min(tbinedges);


                data=mod(data-minedge,2*pi)+minedge;
                hObj.BinsWereComputedForPolar=true;
            end
            [n,edges]=histcounts(data,varargin{:},binargs{:});
            hObj.BinsWereComputedForPolar=false;
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


        function dataTipRows=createDefaultDataTipRows(~)
            dataTipRows=[dataTipTextRow(getString(message('MATLAB:histogram:Value')),'BinCount');...
            dataTipTextRow(getString(message('MATLAB:histogram:BinEdges')),'BinEdges')];
        end

        function coordinateData=createCoordinateData(hObj,valueSource,dataIndex,~)
            import matlab.graphics.chart.interaction.dataannotatable.internal.CoordinateData;
            coordinateData=CoordinateData.empty(0,1);

            switch(valueSource)
            case 'BinCount'
                coordinateData=CoordinateData(valueSource,hObj.Values(dataIndex));
            case 'BinEdges'
                binedges=hObj.BinEdges;
                if isduration(binedges)
                    if~isempty(hObj.Data_I)

                        binedges.Format=hObj.Data_I.Format;
                    end
                    binedges=['[',char(binedges(dataIndex)),', ',char(binedges(dataIndex+1)),']'];
                elseif isdatetime(binedges)
                    binedges=['[',char(binedges(dataIndex)),', ',char(binedges(dataIndex+1)),']'];
                else
                    binedges=binedges(dataIndex:dataIndex+1);
                end
                coordinateData=CoordinateData(valueSource,binedges);
            end
        end


        function valueSources=getAllValidValueSources(~)
            valueSources=["BinCount";"BinEdges"];
        end
    end

    methods(Access=protected,Hidden)
        function group=getPropertyGroups(~)
            group=matlab.mixin.util.PropertyGroup({'Data',...
            'Values','NumBins','BinEdges','BinWidth',...
            'BinLimits','Normalization',...
            'FaceColor','EdgeColor'});
        end


        function descriptors=doGetDataDescriptors(hObj,index,~)
            binedges=hObj.BinEdges;
            if isdatetime(binedges)||isduration(binedges)
                binedges=['[',char(binedges(index)),', ',char(binedges(index+1)),']'];
            else
                binedges=binedges(index:index+1);
            end
            descriptors=[matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
            getString(message('MATLAB:histogram:Value')),hObj.Values(index)),...
            matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
            getString(message('MATLAB:histogram:BinEdges')),binedges)];
        end



        function index=doGetNearestIndex(hObj,index)
            index=max(1,min(index,hObj.NumBins));
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

            polar=isPolar(hObj);
            if any(strcmp(direction,{'left','down'}))
                if(polar)
                    index=mod(index-2,hObj.NumBins)+1;
                else
                    index=max(index-1,1);
                end
            else
                if(polar)
                    index=mod(index,hObj.NumBins)+1;
                else
                    index=min(index+1,hObj.NumBins);
                end
            end

            interpolationFactor=0;
        end


        function point=doGetDisplayAnchorPoint(hObj,index,~)
            binEdges=hObj.BinEdgesCache([index,index+1]);
            binEdges=min(max(binEdges,hObj.indepLimCache(1)),hObj.indepLimCache(2));
            if strcmp(hObj.Orientation,'vertical')
                point=matlab.graphics.shape.internal.util.SimplePoint(...
                [mean(binEdges),hObj.Values(index),0]);
            else
                point=matlab.graphics.shape.internal.util.SimplePoint(...
                [hObj.Values(index),mean(binEdges),0]);
            end
        end


        function point=doGetReportedPosition(hObj,index,interpolationFactor)
            point=doGetDisplayAnchorPoint(hObj,index,interpolationFactor);
        end
    end

    methods(Access=private)


        function inputs=extractInputNameValue(hObj,inputs,propname)
            index=(find(strcmp(inputs(1:2:end),propname))-1)*2+1;
            for i=1:length(index)


                set(hObj,propname,inputs{index(i)+1});
            end
            inputs([index,index+1])=[];
        end

        function normalize(hObj)
            binedges=hObj.BinEdges;
            counts=hObj.BinCounts;
            if strcmp(hObj.BinCountsMode,'auto')
                denom=numel(hObj.Data);
            else
                denom=sum(counts);
            end
            switch hObj.Normalization
            case 'count'
                values=counts;
            case 'countdensity'
                values=counts./double(diff(binedges));
            case 'cumcount'
                values=cumsum(counts);
            case 'probability'
                values=counts/denom;
            case 'pdf'
                values=counts/denom./double(diff(binedges));
            case 'cdf'
                values=cumsum(counts/denom);
            end

            hObj.Values=values;
        end

        function faceIndex=localGetNearestPoint(hObj,position,isPixelPosition)


            [x,y]=hObj.create_bar_coordinates(hObj.BinEdgesCache,hObj.Values);
            y=max(y,eps(0));
            x=min(max(x,hObj.indepLimCache(1)),hObj.indepLimCache(2));
            if strcmp(hObj.Orientation,'vertical')
                verts=[x(:),y(:)];
            else
                verts=[y(:),x(:)];
            end
            faces=transpose(reshape(1:size(verts,1),4,[]));



            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            faceIndex=pickUtils.nearestFace(hObj,position,isPixelPosition,faces,verts);

            if isempty(faceIndex)








                midverts=(verts(faces(:,2),:)+verts(faces(:,3),:))./2;

                if isPolar(hObj)
                    metric='euclidian';
                elseif strcmp(hObj.Orientation,'vertical')
                    metric='x';
                else
                    metric='y';
                end

                faceIndex=pickUtils.nearestPoint(hObj,position,isPixelPosition,midverts,metric);
            end
        end


        function brushedBins=localGetBrushedBins(hObj,region)
            brushedBins=[];
            if~isempty(region)



                vData=hObj.Face.VertexData;
                vertical=strcmp(hObj.Orientation,'vertical');
                if vertical
                    indep_row=1;
                    dep_row=2;
                else
                    dep_row=1;
                    indep_row=2;
                end

                vData=vData(:,vData(dep_row,:)>vData(dep_row,1));
                vLeft=vData(:,1:2:end);
                vRight=vData(:,2:2:end);

                pixelvLeftLocations=brushing.select.transformCameraToFigCoord(hObj,vLeft);
                pixelvRightLocations=brushing.select.transformCameraToFigCoord(hObj,vRight);

                nonzerobars=find(hObj.Values>0);

                if length(region)==4

                    brushedLeft=brushing.select.inpolygon(region,pixelvLeftLocations);
                    brushedRight=brushing.select.inpolygon(region,pixelvRightLocations);


                    brushedBins=nonzerobars(unique([brushedLeft(:);brushedRight(:)]));
                elseif length(region)==2


                    brushedLeft=find(pixelvLeftLocations(indep_row,:)<=...
                    region(indep_row),1,'last');
                    if~isempty(brushedLeft)&&...
                        pixelvRightLocations(indep_row,brushedLeft)>=...
                        region(indep_row)
                        brushedBins=nonzerobars(brushedLeft);
                    end
                end
            end
        end
    end




    methods(Static,Access=?tHistogram_CreateBarCoordinatesFlat)
        function[x,y,linestripdata,facestripdata,faceinds,selinds]=...
            create_bar_coordinates(edges,values,~)


            x=reshape(repmat(edges,4,1),1,[]);
            x=x(3:end-2);

            values(isnan(values))=0;
            y=[zeros(1,numel(values));repmat(reshape(values,1,[]),2,1);...
            zeros(1,numel(values))];
            y=reshape(y,1,[]);

            valuescmp=values(1:end-1)>=values(2:end);




            linestripdata=uint32(1:4:length(x)+1);
            linestripdata(2:end-1)=linestripdata(2:end-1)+uint32(valuescmp)-...
            uint32(~valuescmp);

            facestripdata=[];
            faceinds=[];

            vd_sel=y>0;
            if~isempty(vd_sel)
                vd_sel([1,end])=true;
            end
            selinds=vd_sel;
        end
    end



    methods(Static,Access=?tHistogram_CreateBarCoordinatesInterp)
        function[x,y,linestripdata,facestripdata,faceinds,selinds]=...
            create_bar_coordinates_interp(edges,values,samples)

            roundverts=samples;



            selection_handle_offset=floor((roundverts)/2);

            nvalues=length(values);
            capvertsx=zeros(nvalues,(roundverts));
            vertsPerBar=((2*(roundverts)+1));
            vertsTotal=(nvalues)*vertsPerBar;
            badbars=false(nvalues,1);
            values(isnan(values))=0;
            x=[];
            y=[];



            valuescmp=values(1:end-1)>=values(2:end);

            linestripdata=uint32(1);







            for e=1:nvalues
                keep=1;
                if any(~isfinite(edges(e:e+1)))
                    badbars(e)=1;
                    if(e>1)

                        valuescmp(e-1)=1;
                    end
                    keep=0;
                end


                capvertsx(e,:)=linspace(edges(e),edges(e+1),roundverts);
                newx=keep*[capvertsx(e,1),capvertsx(e,:),fliplr(capvertsx(e,1:end))];
                x=[x,newx];%#ok<AGROW>
                newy=keep*[0,values(e).*ones(1,roundverts),zeros(1,roundverts)];
                y=[y,newy];%#ok<AGROW>






                if(e>1)
                    if~valuescmp(e-1)||badbars(e-1)

















                        newstrip=[(e-1)*(vertsPerBar)-roundverts+1,...
                        ((e-1)*vertsPerBar)+1];
                        linestripdata=[linestripdata,newstrip];%#ok<AGROW>
                    else














                        newstrip=[((e-1)*vertsPerBar)+1,((e-1)*vertsPerBar)+2];
                        linestripdata=[linestripdata,newstrip];%#ok<AGROW>
                    end
                end
            end

            if nvalues>0
                linestripdata=[linestripdata,vertsTotal+1];
            end



            faceinds=[];
            for b=1:nvalues
                base=(b-1)*vertsPerBar;
                strip=[(base+vertsPerBar):-1:(base+vertsPerBar-roundverts+1);...
                base+2:base+roundverts+1];
                faceinds=[faceinds,uint32(strip(:)')];%#ok<AGROW>
            end



            facestripdata=uint32(1:2*(roundverts):(length(faceinds)+1));


            barmask=false(1,vertsPerBar);
            barmask(selection_handle_offset+1+1)=1;

            selinds=repmat(barmask,1,nvalues);
        end
    end

    methods(Static,Access=?tHistogram_CreateStairsCoordinatesFlat)
        function[x,y,linestripdata,facestripdata,faceinds,selinds]=create_stairs_coordinates(edges,values,~)


            x=reshape(repmat(edges,2,1),1,[]);

            values(isnan(values))=0;
            y=[0,reshape(repmat(values,2,1),1,[]),0];

            linestripdata=uint32([1,length(x)+1]);
            facestripdata=[];
            faceinds=[];
            selinds=true(1,length(x));
        end
    end

    methods(Static,Access=?tHistogram_CreateStairsCoordinatesInterp)
        function[x,y,linestripdata,facestripdata,faceinds,selinds]=create_stairs_coordinates_interp(edges,values,interp)



            values(isnan(values))=0;


            loop=abs(max(edges)-2*pi-min(edges))<1e-6;

            roundverts=interp;
            nvalues=length(values);
            capvertsx=zeros(nvalues,(roundverts));


            x=[];
            y=[];
            if~loop
                x=edges(1);
                y=0;
            end

            for e=1:nvalues

                capvertsx(e,:)=linspace(edges(e),edges(e+1),roundverts);
                newx=capvertsx(e,:);
                x=[x,newx];%#ok<AGROW>
                newy=values(e).*ones(1,roundverts);
                y=[y,newy];%#ok<AGROW>
            end

            if~isempty(loop)
                if~loop
                    x=[x,x(end)];
                    y=[y,0];
                else
                    x=[x,x(1)];
                    y=[y,y(1)];
                end
            end

            linestripdata=uint32([1,length(x)+1]);
            facestripdata=[];
            faceinds=[];


            barmask=false(1,roundverts);
            selection_handle_offset=floor((roundverts)/2);
            barmask(selection_handle_offset+1)=1;

            selinds=repmat(barmask,1,nvalues);
        end
    end


    methods(Static,Hidden)

        function binwidth=binEdgesToBinWidth(binedges)
            if isdatetime(binedges)

                if all(diff(binedges)==(binedges(2)-binedges(1)))
                    binwidth=binedges(2)-binedges(1);
                else

                    edgesdiff=num2cell(caldiff(binedges));
                    if isequal(edgesdiff{:})
                        binwidth=edgesdiff{1};
                    else
                        binwidth='nonuniform';
                    end
                end
            else
                if matlab.graphics.chart.primitive.histogram.internal.areBinEdgesUniform(binedges)
                    binwidth=binedges(2)-binedges(1);
                else
                    binwidth='nonuniform';
                end
            end
        end

        function[finiteEdges,validValues]=clipInfiniteEdgesForDisplay(binedges,values,indep_lim,dsIsPolar)
            finiteEdges=binedges;
            if dsIsPolar

                goodedges=~isinf(binedges);
                finiteEdges=binedges(goodedges);

                goodedges(end-1)=goodedges(end)&goodedges(end-1);
                validValues=values(goodedges(1:end-1));
            else
                width=indep_lim(2)-indep_lim(1);
                finiteEdges(binedges==-inf)=indep_lim(1)-width;
                finiteEdges(binedges==inf)=indep_lim(2)+width;
                validValues=values;
            end
        end

        function varargout=doloadobj(hObj)
            if strcmp(hObj.BinCountsMode,'auto')
                hObj.BinCounts_P=hObj.computeBinEdgesAndCounts(hObj.Data,hObj.BinEdges);
            else
                normalize(hObj);
            end



            hObj.LineWidth=hObj.LineWidth;
            hObj.LineStyle=hObj.LineStyle;
            varargout{1}=hObj;
        end
    end

end


function mustBe_matlab_mixin_Heterogeneous(input)
    if~isa(input,'matlab.mixin.Heterogeneous')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropInitialClsMismatch','%s',message('MATLAB:type:PropInitialClsMismatch','matlab.mixin.Heterogeneous').getString));
    end
end
