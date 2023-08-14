classdef(ConstructOnLoad,Sealed)Histogram2<matlab.graphics.primitive.Data...
    &matlab.graphics.mixin.Legendable&matlab.graphics.chart.interaction.DataAnnotatable...
    &matlab.graphics.mixin.Selectable&matlab.graphics.mixin.AxesParentable...
    &matlab.graphics.internal.Legacy&matlab.graphics.mixin.ColorOrderUser



















































    properties(Dependent)








        Data=zeros(0,2)







        BinCounts=0





        NumBins=[1,1]











        XBinEdges=[0,1]











        YBinEdges=[0,1]





        BinWidth=[1,1]






























        BinMethod matlab.internal.datatype.matlab.graphics.datatype.Histogram2BinMethod='manual'






        XBinLimits=[0,1]






        YBinLimits=[0,1]































        Normalization matlab.internal.datatype.matlab.graphics.datatype.HistogramNorm='count'











        FaceColor matlab.internal.datatype.matlab.graphics.datatype.MarkerColor='auto'







        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor=[0.15,0.15,0.15]




        LineWidth=0.5



        LineStyle matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'













        FaceLighting matlab.internal.datatype.matlab.graphics.datatype.Histogram2Lighting='lit'
    end

    properties(Dependent,NeverAmbiguous)






        BinCountsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'






        XBinLimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'






        YBinLimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties





        DisplayStyle matlab.internal.datatype.matlab.graphics.datatype.Histogram2Style='bar3'





        FaceAlpha=1





        EdgeAlpha=1




        ShowEmptyBins matlab.internal.datatype.matlab.graphics.datatype.on_off='off'
    end

    properties(Transient,SetAccess=private)







Values
    end

    properties(Transient,Access=private)

        XLimCache=[0,1]
        YLimCache=[0,1]
    end

    properties(Hidden)
        Data_I=zeros(0,2)
        BinCounts_I double{matlab.internal.validation.mustBeMatrix(BinCounts_I)}=0;
        XBinEdges_I=[0,1]
        YBinEdges_I=[0,1]
        BinWidth_I=[1,1]
        BinMethod_I matlab.internal.datatype.matlab.graphics.datatype.Histogram2BinMethod='manual'
        Normalization_I matlab.internal.datatype.matlab.graphics.datatype.HistogramNorm='count'
        FaceColor_I matlab.internal.datatype.matlab.graphics.datatype.MarkerColor='auto'
        EdgeColor_I matlab.internal.datatype.matlab.graphics.datatype.RGBAutoNoneColor=[0.15,0.15,0.15]
        LineWidth_I(1,1)double{mustBeReal}=0.5
        LineStyle_I matlab.internal.datatype.matlab.graphics.datatype.LineStyle='-'
        FaceLighting_I matlab.internal.datatype.matlab.graphics.datatype.Histogram2Lighting='lit'
    end

    properties(Hidden,NeverAmbiguous)
        BinCountsMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        XBinLimitsMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        YBinLimitsMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Dependent,Access=private)


        BinCounts_P double{matlab.internal.validation.mustBeMatrix(BinCounts_P)}
    end

    properties(SetAccess=private,Hidden)
        AutoColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[0,0,1]
    end

    properties(Constant,Access=private,Hidden)
        XZColorMultiplier=0.75;
        YZColorMultiplier=0.65;
        EdgeColorDefaultNoneThreshold=2000;
    end

    properties(Transient,Access=?thistogram2,Hidden)
        Face matlab.graphics.primitive.world.Quadrilateral
        Edge matlab.graphics.primitive.world.LineLoop
        SupportTransparency(1,1)logical=true
        TransparencyWarningIssued(1,1)logical=false
        BrushFace matlab.graphics.primitive.world.Quadrilateral
        BrushEdge matlab.graphics.primitive.world.LineLoop
    end

    properties(Transient,DeepCopy,SetAccess=private,GetAccess=?graphicstest.mixins.Selectable)
        SelectionHandle{mustBe_matlab_mixin_Heterogeneous};
    end

    properties(Transient,Hidden)
        BrushValues double
        BrushColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor=[1,0,0]
    end

    properties(Transient,SetAccess=private,Hidden)



        Brushed(1,1)logical=false
    end

    properties(Access=private,Constant)
        BrushAlpha=1
    end

    methods

        function hObj=Histogram2(varargin)

            hObj.Face=matlab.graphics.primitive.world.Quadrilateral('Internal',true);
            hObj.Edge=matlab.graphics.primitive.world.LineLoop(...
            'LineJoin','miter','LineWidth',0.5,'Internal',true);
            hObj.BrushFace=matlab.graphics.primitive.world.Quadrilateral(...
            'HitTest','on','Internal',true);
            hObj.BrushEdge=matlab.graphics.primitive.world.LineLoop(...
            'LineJoin','miter','HitTest','on','Internal',true);
            addlistener(hObj.BrushFace,'Hit',@(~,ed)...
            matlab.graphics.chart.primitive.brushingUtils.addBrushContextMenuCallback(hObj,ed));
            addlistener(hObj.BrushEdge,'Hit',@(~,ed)...
            matlab.graphics.chart.primitive.brushingUtils.addBrushContextMenuCallback(hObj,ed));



            varargin=extractInputNameValue(hObj,varargin,'Parent');


            setInteractionHint(hObj,'DataBrushing',false);

            dataindex=(find(strcmp(varargin(1:2:end),'Data'))-1)*2+1;
            for i=1:length(dataindex)
                data=varargin{dataindex(i)+1};
                validateattributes(data,{'numeric','logical'},{'real','ncols',2},...
                class(hObj),'Data');
                hObj.Data_I=data;
            end
            varargin([dataindex,dataindex+1])=[];

            binfieldnames={'NumBins','BinWidth','BinMethod',...
            'XBinLimits','YBinLimits','XBinEdges','YBinEdges'};

            binindex=(find(ismember(varargin(1:2:end),binfieldnames))-1)*2+1;
            if~isempty(binindex)
                bincell=varargin(reshape([binindex;binindex+1],1,[]));
                [counts,xbinedges,ybinedges]=histcounts2(...
                hObj.Data(:,1),hObj.Data(:,2),bincell{:});

                xbinedges=reshape(xbinedges,1,[]);
                ybinedges=reshape(ybinedges,1,[]);
                if islogical(xbinedges)
                    hObj.XBinEdges_I=double(xbinedges);
                else
                    hObj.XBinEdges_I=xbinedges;
                end
                if islogical(ybinedges)
                    hObj.YBinEdges_I=double(ybinedges);
                else
                    hObj.YBinEdges_I=ybinedges;
                end
                hObj.BinCounts_P=counts;
                hObj.BinWidth_I=[xbinedges(2)-xbinedges(1),...
                ybinedges(2)-ybinedges(1)];


                binpropnames=bincell(1:2:end);
                index=(find(strcmp(binpropnames,'BinMethod'))-1)*2+1;
                if~isempty(index)&&~any(ismember({'XBinEdges','YBinEdges'},...
                    binpropnames))&&~any(ismember({'NumBins','BinWidth'},...
                    bincell(index(end)+2:2:end)))
                    hObj.BinMethod_I=bincell{index(end)+1};
                end
                if ismember('XBinEdges',binpropnames)
                    hObj.BinMethod_I='manual';
                    hObj.XBinLimitsMode_I='manual';
                    if~matlab.graphics.chart.primitive.histogram.internal.areBinEdgesUniform(xbinedges)
                        hObj.BinWidth_I='nonuniform';
                    end
                elseif ismember('XBinLimits',binpropnames)
                    hObj.XBinLimitsMode_I='manual';
                end
                if ismember('YBinEdges',binpropnames)
                    hObj.BinMethod_I='manual';
                    hObj.YBinLimitsMode_I='manual';
                    if~matlab.graphics.chart.primitive.histogram.internal.areBinEdgesUniform(ybinedges)
                        hObj.BinWidth_I='nonuniform';
                    end
                elseif ismember('YBinLimits',binpropnames)
                    hObj.YBinLimitsMode_I='manual';
                end
            else
                hObj.BinMethod='auto';
            end
            varargin([binindex,binindex+1])=[];

            addDependencyConsumed(hObj,{'dataspace',...
            'hgtransform_under_dataspace','xyzdatalimits',...
            'figurecolormap','colorspace',...
            'colororder_linestyleorder'});


            if prod(hObj.NumBins)>hObj.EdgeColorDefaultNoneThreshold
                hObj.EdgeColor='none';
            end





            varargin=extractInputNameValue(hObj,varargin,'DisplayStyle');
            for i=1:2:length(varargin)
                set(hObj,varargin{i},varargin{i+1});
            end


            if ispc
                d=opengl('data');
                hObj.SupportTransparency=~d.Software;
            end

        end

        function data=get.Data(hObj)
            data=hObj.Data_I;
        end

        function set.Data(hObj,data)
            validateattributes(data,{'numeric','logical'},{'real','ncols',2},...
            class(hObj),'Data');
            hObj.Data_I=data;


            hObj.BinCountsMode='auto';
        end

        function bincounts=get.BinCounts(hObj)
            bincounts=hObj.BinCounts_I;
        end

        function set.BinCounts(hObj,bincounts)
            validateattributes(bincounts,{'numeric'},{'2d','nonempty',...
            'real','finite','nonnegative'});
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
                    [counts,hObj.XBinEdges_I,hObj.YBinEdges_I]=...
                    histcounts2(hObj.Data(:,1),hObj.Data(:,2),...
                    'BinMethod',hObj.BinMethod);


                    hObj.BinCounts_P=counts;
                else
                    hObj.BinCounts_P=histcounts2(hObj.Data(:,1),hObj.Data(:,2),...
                    hObj.XBinEdges,hObj.YBinEdges);
                end
            else

                hlink=hggetbehavior(hObj,'Linked');
                if~isempty(hlink)
                    set(hlink,'XDataSource','','YDataSource','');
                    f=ancestor(hObj,'figure');
                    datamanager.updateLinkedGraphics(f);
                end
            end
            hObj.BinCountsMode_I=bincountsmode;
        end

        function numbins=get.NumBins(hObj)
            numbins=[length(hObj.XBinEdges)-1,length(hObj.YBinEdges)-1];
        end

        function set.NumBins(hObj,numbins)
            if strcmp(hObj.BinCountsMode,'manual')
                error(message('MATLAB:histogram2:ReadOnlyPropertyManualBinCounts','NumBins'));
            end
            validateattributes(numbins,{'numeric'},...
            {'integer','positive','numel',2},class(hObj),'NumBins');
            data=hObj.Data;

            trailingargs={};

            if strcmp(hObj.XBinLimitsMode,'manual')
                trailingargs=[trailingargs,{'XBinLimits',hObj.XBinLimits}];
            end
            if strcmp(hObj.YBinLimitsMode,'manual')
                trailingargs=[trailingargs,{'YBinLimits',hObj.YBinLimits}];
            end


            skipx=false;
            skipy=false;
            if numbins(1)==hObj.NumBins(1)
                skipx=true;
                trailingargs=[trailingargs,{'XBinEdges',hObj.XBinEdges}];
            end
            if numbins(2)==hObj.NumBins(2)
                skipy=true;
                trailingargs=[trailingargs,{'YBinEdges',hObj.YBinEdges}];
            end

            if~skipx||~skipy
                [counts,xbinedges,ybinedges]=histcounts2(data(:,1),...
                data(:,2),numbins,trailingargs{:});

                hObj.XBinEdges_I=xbinedges;
                hObj.YBinEdges_I=ybinedges;
                hObj.BinMethod_I='manual';
                if(~skipx&&~skipy)||(skipx&&matlab.graphics.chart.primitive.histogram.internal.areBinEdgesUniform(xbinedges))||...
                    (skipy&&matlab.graphics.chart.primitive.histogram.internal.areBinEdgesUniform(ybinedges))
                    hObj.BinWidth_I=[xbinedges(2)-xbinedges(1),...
                    ybinedges(2)-ybinedges(1)];
                end
                hObj.BinCounts_P=counts;
            end
        end

        function edges=get.XBinEdges(hObj)
            edges=hObj.XBinEdges_I;
        end

        function set.XBinEdges(hObj,xbinedges)
            validateattributes(xbinedges,{'numeric'},...
            {'row','nondecreasing'},class(hObj),'XBinEdges');
            if length(xbinedges)<2
                error(message('MATLAB:histogram2:EmptyOrScalarXBinEdges'));
            end
            hObj.XBinEdges_I=xbinedges;
            hObj.XBinLimitsMode_I='manual';
            hObj.BinMethod_I='manual';
            if matlab.graphics.chart.primitive.histogram.internal.areBinEdgesUniform(xbinedges)
                if isnumeric(hObj.BinWidth)
                    hObj.BinWidth_I(1)=xbinedges(2)-xbinedges(1);
                else
                    if matlab.graphics.chart.primitive.histogram.internal.areBinEdgesUniform(hObj.YBinEdges)
                        hObj.BinWidth_I=[xbinedges(2)-xbinedges(1)...
                        ,hObj.YBinEdges(2)-hObj.YBinEdges(1)];
                    end
                end
            else
                hObj.BinWidth_I='nonuniform';
            end

            if strcmp(hObj.BinCountsMode,'auto')
                counts=histcounts2(hObj.Data(:,1),hObj.Data(:,2),...
                xbinedges,hObj.YBinEdges);
                hObj.BinCounts_P=counts;
            else
                normalize(hObj);
            end
        end

        function edges=get.YBinEdges(hObj)
            edges=hObj.YBinEdges_I;
        end

        function set.YBinEdges(hObj,ybinedges)
            validateattributes(ybinedges,{'numeric'},...
            {'row','nondecreasing'},class(hObj),'YBinEdges');
            if length(ybinedges)<2
                error(message('MATLAB:histogram2:EmptyOrScalarYBinEdges'));
            end
            hObj.YBinEdges_I=ybinedges;
            hObj.YBinLimitsMode_I='manual';
            hObj.BinMethod_I='manual';
            if matlab.graphics.chart.primitive.histogram.internal.areBinEdgesUniform(ybinedges)
                if isnumeric(hObj.BinWidth)
                    hObj.BinWidth_I(2)=ybinedges(2)-ybinedges(1);
                else
                    if matlab.graphics.chart.primitive.histogram.internal.areBinEdgesUniform(hObj.XBinEdges)
                        hObj.BinWidth_I=[hObj.XBinEdges(2)-hObj.XBinEdges(1)...
                        ,ybinedges(2)-ybinedges(1)];
                    end
                end
            else
                hObj.BinWidth_I='nonuniform';
            end

            if strcmp(hObj.BinCountsMode,'auto')
                counts=histcounts2(hObj.Data(:,1),hObj.Data(:,2),...
                hObj.XBinEdges,ybinedges);
                hObj.BinCounts_P=counts;
            else
                normalize(hObj);
            end
        end

        function binwidth=get.BinWidth(hObj)
            binwidth=hObj.BinWidth_I;
        end

        function set.BinWidth(hObj,binwidth)
            if strcmp(hObj.BinCountsMode,'manual')
                error(message('MATLAB:histogram2:ReadOnlyPropertyManualBinCounts','BinWidth'));
            end
            validateattributes(binwidth,{'numeric'},...
            {'positive','finite','numel',2},class(hObj),'BinWidth');

            trailingargs={};

            if strcmp(hObj.XBinLimitsMode,'manual')
                trailingargs=[trailingargs,{'XBinLimits',hObj.XBinLimits}];
            end
            if strcmp(hObj.YBinLimitsMode,'manual')
                trailingargs=[trailingargs,{'YBinLimits',hObj.YBinLimits}];
            end


            skipx=false;
            skipy=false;
            if binwidth(1)==hObj.BinWidth(1)
                skipx=true;
                trailingargs=[trailingargs,{'XBinEdges',hObj.XBinEdges}];
            end
            if binwidth(2)==hObj.BinWidth(2)
                skipy=true;
                trailingargs=[trailingargs,{'YBinEdges',hObj.YBinEdges}];
            end

            if~skipx||~skipy
                [counts,xbinedges,ybinedges]=histcounts2(hObj.Data(:,1),...
                hObj.Data(:,2),'BinWidth',binwidth,trailingargs{:});

                if(~skipx&&~skipy)||(skipx&&matlab.graphics.chart.primitive.histogram.internal.areBinEdgesUniform(xbinedges))||...
                    (skipy&&matlab.graphics.chart.primitive.histogram.internal.areBinEdgesUniform(ybinedges))
                    hObj.BinWidth_I=[xbinedges(2)-xbinedges(1),...
                    ybinedges(2)-ybinedges(1)];
                end
                hObj.XBinEdges_I=xbinedges;
                hObj.YBinEdges_I=ybinedges;
                hObj.BinMethod_I='manual';
                hObj.BinCounts_P=counts;
            end
        end

        function binmethod=get.BinMethod(hObj)
            binmethod=hObj.BinMethod_I;
        end

        function set.BinMethod(hObj,binmethod)
            if strcmp(hObj.BinCountsMode,'manual')
                error(message('MATLAB:histogram2:ReadOnlyPropertyManualBinCounts','BinMethod'));
            end
            if strcmp(binmethod,'manual')
                error(message('MATLAB:histogram2:InvalidBinMethod'));
            end
            binlimitsargs={};

            if strcmp(hObj.XBinLimitsMode,'manual')
                binlimitsargs=[binlimitsargs,{'XBinLimits',hObj.XBinLimits}];
            end
            if strcmp(hObj.YBinLimitsMode,'manual')
                binlimitsargs=[binlimitsargs,{'YBinLimits',hObj.YBinLimits}];
            end

            [counts,xbinedges,ybinedges]=histcounts2(hObj.Data(:,1),...
            hObj.Data(:,2),'BinMethod',binmethod,binlimitsargs{:});

            hObj.XBinEdges_I=xbinedges;
            hObj.YBinEdges_I=ybinedges;
            hObj.BinCounts_P=counts;

            hObj.BinMethod_I=binmethod;
            hObj.BinWidth_I=[xbinedges(2)-xbinedges(1),...
            ybinedges(2)-ybinedges(1)];
        end

        function xbinlimits=get.XBinLimits(hObj)
            xbinedges=hObj.XBinEdges;
            xbinlimits=[xbinedges(1),xbinedges(end)];
        end

        function set.XBinLimits(hObj,xbinlimits)
            if strcmp(hObj.BinCountsMode,'manual')
                error(message('MATLAB:histogram2:ReadOnlyPropertyManualBinCounts','XBinLimits'));
            end
            validateattributes(xbinlimits,{'numeric'},{'real',...
            'size',[1,2],'finite','nondecreasing'},class(hObj),...
            'XBinLimits');
            bw=hObj.BinWidth;
            uniformbw=isnumeric(bw);
            if~uniformbw

                bw=[diff(xbinlimits)/hObj.NumBins(1),1];
            end
            [counts,xbinedges]=histcounts2(hObj.Data(:,1),...
            hObj.Data(:,2),'BinWidth',bw,'XBinLimits',xbinlimits,...
            'YBinEdges',hObj.YBinEdges);

            if uniformbw
                hObj.BinWidth_I(1)=bw(1);
            else
                ybinedges=hObj.YBinEdges;
                if matlab.graphics.chart.primitive.histogram.internal.areBinEdgesUniform(ybinedges)
                    hObj.BinWidth_I=[bw(1),ybinedges(2)-ybinedges(1)];
                end
            end
            hObj.XBinEdges_I=xbinedges;
            hObj.XBinLimitsMode_I='manual';
            hObj.BinMethod_I='manual';
            hObj.BinCounts_P=counts;
        end

        function ybinlimits=get.YBinLimits(hObj)
            ybinedges=hObj.YBinEdges;
            ybinlimits=[ybinedges(1),ybinedges(end)];
        end

        function set.YBinLimits(hObj,ybinlimits)
            if strcmp(hObj.BinCountsMode,'manual')
                error(message('MATLAB:histogram2:ReadOnlyPropertyManualBinCounts','YBinLimits'));
            end
            validateattributes(ybinlimits,{'numeric'},{'real',...
            'size',[1,2],'finite','nondecreasing'},class(hObj),...
            'YBinLimits');
            bw=hObj.BinWidth;
            uniformbw=isnumeric(bw);
            if~uniformbw

                bw=[1,diff(ybinlimits)/hObj.NumBins(2)];
            end
            [counts,xbinedges,ybinedges]=histcounts2(hObj.Data(:,1),...
            hObj.Data(:,2),'BinWidth',bw,'YBinLimits',ybinlimits,...
            'XBinEdges',hObj.XBinEdges);

            if uniformbw
                hObj.BinWidth_I(2)=bw(2);
            else
                if matlab.graphics.chart.primitive.histogram.internal.areBinEdgesUniform(xbinedges)
                    hObj.BinWidth_I=[xbinedges(2)-xbinedges(1),bw(2)];
                end
            end
            hObj.YBinEdges_I=ybinedges;
            hObj.YBinLimitsMode_I='manual';
            hObj.BinMethod_I='manual';
            hObj.BinCounts_P=counts;
        end

        function xbinlimitsmode=get.XBinLimitsMode(hObj)
            xbinlimitsmode=hObj.XBinLimitsMode_I;
        end

        function set.XBinLimitsMode(hObj,xbinlimitsmode)
            if strcmp(hObj.BinCountsMode,'manual')
                error(message('MATLAB:histogram2:ReadOnlyPropertyManualBinCounts','XBinLimitsMode'));
            end
            hObj.XBinLimitsMode_I=xbinlimitsmode;

            if strcmp(xbinlimitsmode,'auto')
                bw=hObj.BinWidth;
                uniformbw=isnumeric(bw);
                if~uniformbw
                    xdata=hObj.Data(isfinite(hObj.Data(:,1)),1);
                    if~isempty(xdata)

                        bw=[(max(xdata)-min(xdata))/hObj.NumBins(1),1];
                    else

                        bw=[1,1];
                    end
                end
                [counts,xbinedges]=histcounts2(hObj.Data(:,1),...
                hObj.Data(:,2),'BinWidth',bw,'YBinEdges',hObj.YBinEdges);

                if uniformbw
                    hObj.BinWidth_I(1)=bw(1);
                else
                    ybinedges=hObj.YBinEdges;
                    if matlab.graphics.chart.primitive.histogram.internal.areBinEdgesUniform(ybinedges)
                        hObj.BinWidth_I=[bw(1),ybinedges(2)-ybinedges(1)];
                    end
                end
                hObj.XBinEdges_I=xbinedges;
                hObj.BinMethod_I='manual';
                hObj.BinCounts_P=counts;
            end
        end

        function ybinlimitsmode=get.YBinLimitsMode(hObj)
            ybinlimitsmode=hObj.YBinLimitsMode_I;
        end

        function set.YBinLimitsMode(hObj,ybinlimitsmode)
            if strcmp(hObj.BinCountsMode,'manual')
                error(message('MATLAB:histogram2:ReadOnlyPropertyManualBinCounts','YBinLimitsMode'));
            end
            hObj.YBinLimitsMode_I=ybinlimitsmode;

            if strcmp(ybinlimitsmode,'auto')
                bw=hObj.BinWidth;
                uniformbw=isnumeric(bw);
                if~uniformbw
                    ydata=hObj.Data(isfinite(hObj.Data(:,2)),2);
                    if~isempty(ydata)

                        bw=[1,(max(ydata)-min(ydata))/hObj.NumBins(2)];
                    else

                        bw=[1,1];
                    end
                end
                [counts,xbinedges,ybinedges]=histcounts2(hObj.Data(:,1),...
                hObj.Data(:,2),'BinWidth',bw,'XBinEdges',hObj.XBinEdges);

                if uniformbw
                    hObj.BinWidth_I(2)=bw(2);
                else
                    if matlab.graphics.chart.primitive.histogram.internal.areBinEdgesUniform(xbinedges)
                        hObj.BinWidth_I=[xbinedges(2)-xbinedges(1),bw(2)];
                    end
                end
                hObj.YBinEdges_I=ybinedges;
                hObj.BinMethod_I='manual';
                hObj.BinCounts_P=counts;
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
            hObj.Normalization_I=normalization;
            normalize(hObj);
        end

        function set.DisplayStyle(hObj,displaystyle)
            hObj.DisplayStyle=displaystyle;
            hObj.MarkDirty('all');
            hObj.sendDataChangedEvent();
        end

        function facecolor=get.FaceColor(hObj)
            if strcmp(hObj.DisplayStyle,'bar3')
                facecolor=hObj.FaceColor_I;
            else
                facecolor='flat';
            end
        end

        function set.FaceColor(hObj,facecolor)
            if strcmp(hObj.DisplayStyle,'bar3')
                hObj.FaceColor_I=facecolor;
            else
                if~strcmp(facecolor,'flat')
                    error(message('MATLAB:histogram2:InvalidTileFaceColor'));
                end
            end
            hObj.MarkDirty('all');
        end

        function edgecolor=get.EdgeColor(hObj)
            edgecolor=hObj.EdgeColor_I;
        end

        function set.EdgeColor(hObj,edgecolor)
            hObj.EdgeColor_I=edgecolor;
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

        function facelighting=get.FaceLighting(hObj)
            if strcmp(hObj.DisplayStyle,'tile')
                facelighting='none';
            else
                facelighting=hObj.FaceLighting_I;
            end
        end

        function set.FaceLighting(hObj,facelighting)
            if strcmp(hObj.DisplayStyle,'bar3')
                hObj.FaceLighting_I=facelighting;
            else
                if~strcmp(facelighting,'none')
                    error(message('MATLAB:histogram2:InvalidTileFaceLighting'));
                end
            end
            hObj.MarkDirty('all');
        end

        function set.ShowEmptyBins(hObj,showemptybins)
            hObj.ShowEmptyBins=showemptybins;
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


                hObj.SelectionHandle.Description='Histogram2 SelectionHandle';
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

        function numbins=morebins(hObj,dim)












            if any(strcmp({hObj.BinCountsMode},'manual'))
                error(message('MATLAB:histogram2:UnsupportedMethodManualBinCounts','morebins'));
            end
            if nargin>1
                dim=validatestring(dim,{'x','y','both'});
            else
                dim='both';
            end

            hlen=numel(hObj);
            switch dim
            case 'x'
                numbins=[hObj.NumBins];
                numbins(1:2:end)=ceil(numbins(1:2:end)*1.1);
                for i=1:hlen
                    hObj(i).NumBins=numbins(2*i-1:2*i);
                end
            case 'y'
                numbins=[hObj.NumBins];
                numbins(2:2:end)=ceil(numbins(2:2:end)*1.1);
                for i=1:hlen
                    hObj(i).NumBins=numbins(2*i-1:2*i);
                end
            otherwise
                numbins=ceil([hObj.NumBins]*1.1);
                for i=1:hlen
                    hObj(i).NumBins=numbins(2*i-1:2*i);
                end
            end
        end

        function numbins=fewerbins(hObj,dim)












            if any(strcmp({hObj.BinCountsMode},'manual'))
                error(message('MATLAB:histogram2:UnsupportedMethodManualBinCounts','fewerbins'));
            end
            if nargin>1
                dim=validatestring(dim,{'x','y','both'});
            else
                dim='both';
            end

            hlen=numel(hObj);
            switch dim
            case 'x'
                numbins=[hObj.NumBins];
                numbins(1:2:end)=max(floor(numbins(1:2:end)*0.9),1);
                for i=1:hlen
                    hObj(i).NumBins=numbins(2*i-1:2*i);
                end
            case 'y'
                numbins=[hObj.NumBins];
                numbins(2:2:end)=max(floor(numbins(2:2:end)*0.9),1);
                for i=1:hlen
                    hObj(i).NumBins=numbins(2*i-1:2*i);
                end
            case 'both'
                numbins=max(floor([hObj.NumBins]*0.9),1);
                for i=1:hlen
                    hObj(i).NumBins=numbins(2*i-1:2*i);
                end
            end

        end
    end

    methods(Hidden)
        function ex=getXYZDataExtents(hObj)
            values=hObj.Values;

            xedges=matlab.graphics.chart.primitive.histogram.internal.handleNonFiniteEdges(hObj.XBinEdges);
            x=matlab.graphics.chart.primitive.utilities.arraytolimits(xedges);
            xd=double(x);


            if~any(xd<0)
                xd(2)=NaN;
            end
            if~any(xd>0)
                xd(3)=NaN;
            end

            yedges=matlab.graphics.chart.primitive.histogram.internal.handleNonFiniteEdges(hObj.YBinEdges);
            y=matlab.graphics.chart.primitive.utilities.arraytolimits(yedges);
            yd=double(y);


            if~any(yd<0)
                yd(2)=NaN;
            end
            if~any(yd>0)
                yd(3)=NaN;
            end

            z=matlab.graphics.chart.primitive.utilities.arraytolimits(values(:));
            z(1)=0;
            ex=[xd;yd;z];
        end

        function ex=getColorAlphaDataExtents(hObj)
            ex=[matlab.graphics.chart.primitive.utilities.arraytolimits(hObj.Values);NaN,NaN,NaN,NaN];
        end


        doUpdate(hObj,us)


        graphic=getLegendGraphic(hObj)


        mcodeConstructor(this,code)

        function I=getBrushedElements(hObj,region)








            brushedIndex=localGetBrushedBins(hObj,region);
            I=localFindDataInBins(hObj,brushedIndex);
        end



        function I=updatePartiallyBrushedI(hObj,I,Iextend,extendMode)
            if extendMode
                if isequal(size(hObj.Values),size(hObj.BrushValues))
                    partialbins=find((hObj.BrushValues<hObj.Values)&(hObj.BrushValues>0));
                    Ipartial=localFindDataInBins(hObj,partialbins);
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


        function dataTipRows=createDefaultDataTipRows(~)
            dataTipRows=[...
            dataTipTextRow(getString(message('MATLAB:histogram2:Value')),'BinCount');...
            dataTipTextRow(getString(message('MATLAB:histogram2:XBinEdges')),'XBinEdges');...
            dataTipTextRow(getString(message('MATLAB:histogram2:YBinEdges')),'YBinEdges')];
        end

        function coordinateData=createCoordinateData(hObj,valueSource,dataIndex,~)
            import matlab.graphics.chart.interaction.dataannotatable.internal.CoordinateData;
            coordinateData=CoordinateData.empty(0,1);

            switch(valueSource)
            case 'BinCount'
                coordinateData=CoordinateData(valueSource,hObj.Values(dataIndex));
            case 'XBinEdges'
                xindex=rem(dataIndex-1,hObj.NumBins(1))+1;
                coordinateData=CoordinateData(valueSource,[hObj.XBinEdges(xindex),hObj.XBinEdges(xindex+1)]);
            case 'YBinEdges'
                yindex=ceil(dataIndex/hObj.NumBins(1));
                coordinateData=CoordinateData(valueSource,[hObj.YBinEdges(yindex),hObj.YBinEdges(yindex+1)]);
            end
        end


        function valueSources=getAllValidValueSources(~)
            valueSources=["BinCount";"XBinEdges";"YBinEdges"];
        end
    end

    methods(Access=protected)
        function group=getPropertyGroups(~)
            group=matlab.mixin.util.PropertyGroup({'Data',...
            'Values','NumBins','XBinEdges','YBinEdges',...
            'BinWidth','Normalization',...
            'FaceColor','EdgeColor'});
        end


        function descriptors=doGetDataDescriptors(hObj,index,~)
            xindex=rem(index-1,hObj.NumBins(1))+1;
            yindex=ceil(index/hObj.NumBins(1));
            descriptors=[...
            matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
            getString(message('MATLAB:histogram2:Value')),hObj.Values(index)),...
            matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
            getString(message('MATLAB:histogram2:XBinEdges')),...
            [hObj.XBinEdges(xindex),hObj.XBinEdges(xindex+1)]),...
            matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(...
            getString(message('MATLAB:histogram2:YBinEdges')),...
            [hObj.YBinEdges(yindex),hObj.YBinEdges(yindex+1)])];
        end

        function index=doGetNearestIndex(hObj,index)
            index=max(1,min(index,prod(hObj.NumBins)));
        end

        function index=doGetNearestPoint(hObj,position)
            index=localGetNearestPoint(hObj,position,true);
        end

        function index=doGetNearestPointInDataUnits(hObj,position)
            index=localGetNearestPoint(hObj,position,false);
        end

        function[index,interpolationFactor]=doGetInterpolatedPoint(hObj,position)
            index=doGetNearestPoint(hObj,position);
            interpolationFactor=0;
        end

        function[index,interpolationFactor]=doGetInterpolatedPointInDataUnits(hObj,position)
            index=doGetNearestPointInDataUnits(hObj,position);
            interpolationFactor=0;
        end

        function points=doGetEnclosedPoints(~,~)
            points=[];
        end

        function[index,interpolationFactor]=doIncrementIndex(hObj,index,direction,~)
            nrows=hObj.NumBins(1);
            if strcmp(direction,'left')
                if rem(index,nrows)~=1
                    index=index-1;
                end
            elseif strcmp(direction,'right')
                if rem(index,nrows)~=0
                    index=index+1;
                end
            elseif strcmp(direction,'up')
                if ceil(index/nrows)<hObj.NumBins(2)
                    index=index+nrows;
                end
            else
                if ceil(index/nrows)>1
                    index=index-nrows;
                end
            end

            interpolationFactor=0;
        end

        function point=doGetDisplayAnchorPoint(hObj,index,~)
            xindex=rem(index-1,hObj.NumBins(1))+1;
            yindex=ceil(index/hObj.NumBins(1));
            if strcmp(hObj.DisplayStyle,'bar3')
                zvalue=hObj.Values(index);
            else
                zvalue=0;
            end
            xbounds=hObj.XBinEdges([xindex,xindex+1]);
            ybounds=hObj.YBinEdges([yindex,yindex+1]);


            xbounds=min(max(xbounds,hObj.XLimCache(1)),hObj.XLimCache(2));
            ybounds=min(max(ybounds,hObj.YLimCache(1)),hObj.YLimCache(2));

            point=matlab.graphics.shape.internal.util.SimplePoint(...
            [mean(xbounds),mean(ybounds),zvalue]);
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
            xedges=hObj.XBinEdges_I;
            yedges=hObj.YBinEdges_I;
            counts=hObj.BinCounts;
            if strcmp(hObj.BinCountsMode,'auto')
                denom=size(hObj.Data,1);
            else
                denom=sum(counts(:));
            end
            switch hObj.Normalization
            case 'count'
                values=counts;
            case 'countdensity'
                binarea=double(diff(xedges.')).*double(diff(yedges));
                values=counts./binarea;
            case 'cumcount'
                values=cumsum(cumsum(counts,1),2);
            case 'probability'
                values=counts/denom;
            case 'pdf'
                binarea=double(diff(xedges.')).*double(diff(yedges));
                values=counts/denom./binarea;
            case 'cdf'
                values=cumsum(cumsum(counts/denom,1),2);
            end
            hObj.Values=values;
        end

        index=localGetNearestPoint(hObj,position,isPixel)

        binIndex=localBarFaceIndexToBinIndex(hObj,faceIndex,isxz,isyz)

        function brushedBins=localGetBrushedBins(hObj,region)
            brushedBins=[];
            if~isempty(region)

                if length(region)>2
                    isbar3=strcmp(hObj.DisplayStyle,'bar3');
                    if isbar3
                        [vx,vy,vz,isxz,isyz]=hObj.create_bar_coordinates(...
                        hObj.XBinEdges,hObj.YBinEdges,hObj.Values,false);
                        vData=[vx;vy;vz];
                        vData(:,vData(3,:)==vData(3,1))=NaN;
                    else
                        [vx,vy,vz]=matlab.graphics.chart.primitive.histogram2.internal.create_tile_coordinates(...
                        hObj.XBinEdges,hObj.YBinEdges,hObj.Values,false);
                        vData=[vx;vy;vz];
                    end

                    pixelvLocations=brushing.select.transformCameraToFigCoord(hObj,vData);


                    brushedv=brushing.select.inpolygon(region(:,1:4),pixelvLocations);


                    faceIndex=unique(ceil(brushedv/4));

                    if isbar3
                        brushedBins=zeros(size(faceIndex));
                        for ii=1:length(faceIndex)
                            brushedBins(ii)=localBarFaceIndexToBinIndex(hObj,...
                            faceIndex(ii),isxz,isyz);
                        end
                        brushedBins=unique(brushedBins);
                    else
                        brushedBins=faceIndex;
                    end
                    if strcmp(hObj.ShowEmptyBins,'off')
                        brushedBins=brushedBins(hObj.Values(brushedBins)>0);
                    end
                elseif length(region)==2

                    brushedBins=localGetNearestPoint(hObj,region,true);
                end
            end
        end

        function I=localFindDataInBins(hObj,binIndices)


            [~,~,~,binx,biny]=histcounts2(hObj.Data(:,1),hObj.Data(:,2),...
            hObj.XBinEdges,hObj.YBinEdges);
            bin=zeros(size(binx));
            binned=binx>0&biny>0;
            bin(binned)=sub2ind(hObj.NumBins,binx(binned),biny(binned));
            I=ismember(bin,binIndices);
        end
    end

    methods(Static,Access=private)

        [x,y,z,isxz,isyz]=create_bar_coordinates(xedges,yedges,...
        values,dropzero,isInfEdgeX,isInfEdgeY,basevalues)


        n=compute_normals(values,dropzero)
    end

    methods(Static,Hidden)
        function varargout=doloadobj(hObj)
            if strcmp(hObj.BinCountsMode,'auto')
                hObj.BinCounts_P=histcounts2(hObj.Data(:,1),hObj.Data(:,2),...
                hObj.XBinEdges,hObj.YBinEdges);
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
