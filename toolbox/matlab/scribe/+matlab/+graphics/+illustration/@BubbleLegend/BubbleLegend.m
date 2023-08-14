
















classdef(ConstructOnLoad=true,UseClassDefaultsOnLoad=true)BubbleLegend<matlab.graphics.illustration.internal.AbstractLegend





    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        NumBubbles matlab.internal.datatype.matlab.graphics.datatype.PositiveInteger=3;
    end

    methods
        function valueToCaller=get.NumBubbles(hObj)


            valueToCaller=hObj.NumBubbles_I;

        end

        function set.NumBubbles(hObj,newValue)



            hObj.NumBubblesMode='manual';


            hObj.NumBubbles_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        NumBubblesMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.NumBubblesMode(hObj)
            storedValue=hObj.NumBubblesMode;
        end

        function set.NumBubblesMode(hObj,newValue)

            oldValue=hObj.NumBubblesMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.NumBubblesMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        NumBubbles_I matlab.internal.datatype.matlab.graphics.datatype.PositiveInteger=3;
    end

    methods
        function storedValue=get.NumBubbles_I(hObj)
            storedValue=hObj.getNumBubblesImpl(hObj.NumBubbles_I);
        end

        function set.NumBubbles_I(hObj,newValue)
            oldValue=hObj.NumBubbles_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.NumBubbles_I=hObj.setNumBubblesImpl(newValue);
            end
        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Style matlab.internal.datatype.matlab.graphics.chart.datatype.BubbleLegendStyleType='vertical';
    end

    methods
        function valueToCaller=get.Style(hObj)


            valueToCaller=hObj.Style_I;

        end

        function set.Style(hObj,newValue)



            hObj.StyleMode='manual';


            hObj.Style_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        StyleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.StyleMode(hObj)
            storedValue=hObj.StyleMode;
        end

        function set.StyleMode(hObj,newValue)

            oldValue=hObj.StyleMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.StyleMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Style_I matlab.internal.datatype.matlab.graphics.chart.datatype.BubbleLegendStyleType='vertical';
    end

    methods
        function storedValue=get.Style_I(hObj)
            storedValue=hObj.Style_I;
        end

        function set.Style_I(hObj,newValue)



            hObj.Style_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        BubbleSizeOrder matlab.internal.datatype.matlab.graphics.chart.datatype.BubbleLegendSizeOrderType='descending';
    end

    methods
        function valueToCaller=get.BubbleSizeOrder(hObj)


            valueToCaller=hObj.BubbleSizeOrder_I;

        end

        function set.BubbleSizeOrder(hObj,newValue)



            hObj.BubbleSizeOrderMode='manual';


            hObj.BubbleSizeOrder_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        BubbleSizeOrderMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BubbleSizeOrderMode(hObj)
            storedValue=hObj.BubbleSizeOrderMode;
        end

        function set.BubbleSizeOrderMode(hObj,newValue)

            oldValue=hObj.BubbleSizeOrderMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BubbleSizeOrderMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,AbortSet=true,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        BubbleSizeOrder_I matlab.internal.datatype.matlab.graphics.chart.datatype.BubbleLegendSizeOrderType='descending';
    end

    methods
        function storedValue=get.BubbleSizeOrder_I(hObj)
            storedValue=hObj.BubbleSizeOrder_I;
        end

        function set.BubbleSizeOrder_I(hObj,newValue)



            hObj.BubbleSizeOrder_I=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        LimitLabels matlab.internal.datatype.matlab.graphics.datatype.NumericOrString;
    end

    methods
        function valueToCaller=get.LimitLabels(hObj)


            valueToCaller=hObj.LimitLabels_I;

        end

        function set.LimitLabels(hObj,newValue)



            hObj.LimitLabelsMode='manual';


            hObj.LimitLabels_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LimitLabelsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LimitLabelsMode(hObj)
            storedValue=hObj.LimitLabelsMode;
        end

        function set.LimitLabelsMode(hObj,newValue)

            oldValue=hObj.LimitLabelsMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LimitLabelsMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        LimitLabels_I matlab.internal.datatype.matlab.graphics.datatype.NumericOrString;
    end

    methods
        function storedValue=get.LimitLabels_I(hObj)
            storedValue=hObj.getLimitLabelsImpl(hObj.LimitLabels_I);
        end

        function set.LimitLabels_I(hObj,newValue)
            oldValue=hObj.LimitLabels_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.LimitLabels_I=hObj.setLimitLabelsImpl(newValue);
            end
        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess={?BubbleLegendTestClass},GetAccess={?BubbleLegendTestClass},Dependent=false,Hidden=true,AffectsLegend)

        Padding(1,1)double;
    end

    methods
        function storedValue=get.Padding(hObj)
            storedValue=hObj.Padding;
        end

        function set.Padding(hObj,newValue)



            hObj.Padding=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess={?BubbleLegendTestClass},Dependent=false,Hidden=true,AffectsLegend)

        AxleWidth matlab.internal.datatype.matlab.graphics.datatype.PositiveInteger=8;
    end

    methods
        function storedValue=get.AxleWidth(hObj)
            storedValue=hObj.AxleWidth;
        end

        function set.AxleWidth(hObj,newValue)



            hObj.AxleWidth=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess={?BubbleLegendTestClass},Dependent=false,Hidden=true,AffectsLegend)

        AxlePadding(1,1)double=8;
    end

    methods
        function storedValue=get.AxlePadding(hObj)
            storedValue=hObj.AxlePadding;
        end

        function set.AxlePadding(hObj,newValue)



            hObj.AxlePadding=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess={?BubbleLegendTestClass},Dependent=false,Hidden=true,AffectsLegend)

        AxleIsUsed logical=true;
    end

    methods
        function storedValue=get.AxleIsUsed(hObj)
            storedValue=hObj.AxleIsUsed;
        end

        function set.AxleIsUsed(hObj,newValue)



            hObj.AxleIsUsed=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess={?BubbleLegendTestClass},GetAccess={?BubbleLegendTestClass},Dependent=false,Hidden=true,AffectsLegend)

        BubbleSizes;
    end

    methods
        function storedValue=get.BubbleSizes(hObj)
            storedValue=hObj.BubbleSizes;
        end

        function set.BubbleSizes(hObj,newValue)



            hObj.BubbleSizes=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess={?BubbleLegendTestClass},GetAccess={?BubbleLegendTestClass},Dependent=false,Hidden=true,AffectsLegend)

        BubbleColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor;
    end

    methods
        function storedValue=get.BubbleColor(hObj)
            storedValue=hObj.BubbleColor;
        end

        function set.BubbleColor(hObj,newValue)



            hObj.BubbleColor=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=false)

        Location matlab.internal.datatype.matlab.graphics.datatype.BubbleLegendLocationType='northeast';
    end

    methods
        function valueToCaller=get.Location(hObj)


            valueToCaller=hObj.Location_I;

        end

        function set.Location(hObj,newValue)



            hObj.LocationMode='manual';


            hObj.Location_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true)

        LocationMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.LocationMode(hObj)
            storedValue=hObj.LocationMode;
        end

        function set.LocationMode(hObj,newValue)

            oldValue=hObj.LocationMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.LocationMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end


    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,AffectsLegend)

        Location_I matlab.internal.datatype.matlab.graphics.datatype.BubbleLegendLocationType='northeast';
    end

    methods
        function storedValue=get.Location_I(hObj)
            storedValue=hObj.getLocationImpl(hObj.Location_I);
        end

        function set.Location_I(hObj,newValue)
            oldValue=hObj.Location_I;
            reallyDoCopy=~isequal(oldValue,newValue);
            if~reallyDoCopy&&isa(oldValue,'handle')&&isa(newValue,'handle')
                reallyDoCopy=~(oldValue==newValue);
            end


            if reallyDoCopy
                hObj.Location_I=hObj.setLocationImpl(newValue);
            end
        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess={?BubbleLegendTestClass},Dependent=false,Hidden=true,Transient=true,AffectsLegend)

        NeutralColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor;
    end

    methods
        function storedValue=get.NeutralColor(hObj)
            storedValue=hObj.NeutralColor;
        end

        function set.NeutralColor(hObj,newValue)



            hObj.NeutralColor=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess={?BubbleLegendTestClass},Dependent=false,Hidden=true,Transient=true,AffectsLegend)

        DefaultBubbleLineWidth(1,1)double=.50;
    end

    methods
        function storedValue=get.DefaultBubbleLineWidth(hObj)
            storedValue=hObj.DefaultBubbleLineWidth;
        end

        function set.DefaultBubbleLineWidth(hObj,newValue)



            hObj.DefaultBubbleLineWidth=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess={?BubbleLegendTestClass},Dependent=false,Hidden=true,Transient=true,AffectsLegend)

        BubbleLineWidth=.50;
    end

    methods
        function storedValue=get.BubbleLineWidth(hObj)
            storedValue=hObj.BubbleLineWidth;
        end

        function set.BubbleLineWidth(hObj,newValue)



            hObj.BubbleLineWidth=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess={?BubbleLegendTestClass},GetAccess={?BubbleLegendTestClass},Dependent=false,Hidden=true,AffectsLegend)

        BubbleEdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor;
    end

    methods
        function storedValue=get.BubbleEdgeColor(hObj)
            storedValue=hObj.BubbleEdgeColor;
        end

        function set.BubbleEdgeColor(hObj,newValue)



            hObj.BubbleEdgeColor=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess={?BubbleLegendTestClass},GetAccess={?BubbleLegendTestClass},Dependent=false,Hidden=true,Transient=true,AffectsLegend)

        BubbleAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne;
    end

    methods
        function storedValue=get.BubbleAlpha(hObj)
            storedValue=hObj.BubbleAlpha;
        end

        function set.BubbleAlpha(hObj,newValue)



            hObj.BubbleAlpha=newValue;

        end
    end


    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess='private',Dependent=false,Hidden=true,Transient=true,NonCopyable=true,AffectsLegend)

        PrintSettingsCache struct=struct();
    end

    methods
        function storedValue=get.PrintSettingsCache(hObj)
            storedValue=hObj.PrintSettingsCache;
        end

        function set.PrintSettingsCache(hObj,newValue)



            hObj.PrintSettingsCache=newValue;

        end
    end

    properties(SetObservable=true,SetAccess='public',GetAccess='public',Dependent=true,Hidden=true,Transient=true)

        BubbleContainer matlab.graphics.primitive.Marker;
    end

    methods
        function valueToCaller=get.BubbleContainer(hObj)


            valueToCaller=hObj.BubbleContainer_I;

        end

        function set.BubbleContainer(hObj,newValue)



            hObj.BubbleContainerMode='manual';


            hObj.BubbleContainer_I=newValue;

        end
    end
    properties(SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true)

        BubbleContainerMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    methods
        function storedValue=get.BubbleContainerMode(hObj)
            storedValue=hObj.BubbleContainerMode;
        end

        function set.BubbleContainerMode(hObj,newValue)

            oldValue=hObj.BubbleContainerMode;
            reallyDoCopy=~isequal(oldValue,newValue);

            if reallyDoCopy
                manualToAuto=strcmp(oldValue,'manual');
                hObj.BubbleContainerMode=newValue;
                if manualToAuto

                    hObj.MarkDirty('all');
                end
            end
        end
    end

    properties(AffectsObject,SetObservable=false,SetAccess='public',GetAccess='public',Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        BubbleContainer_I;
    end

    methods
        function set.BubbleContainer_I(hObj,newValue)
            oldValue=hObj.BubbleContainer_I;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.DecorationContainer.replaceChild(hObj.BubbleContainer_I,newValue);
                else

                    hObj.DecorationContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.BubbleContainer_I=newValue;
            try
                hObj.setBubbleContainer_IFanoutProps();
            catch
            end
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess={?BubbleLegendTestClass},Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        Axle;
    end

    methods
        function set.Axle(hObj,newValue)
            oldValue=hObj.Axle;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.BubbleContainer.replaceChild(hObj.Axle,newValue);
                else

                    hObj.BubbleContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.Axle=newValue;
            try
                hObj.setAxleFanoutProps();
            catch
            end
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess={?BubbleLegendTestClass},Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        Bubbles;
    end

    methods
        function set.Bubbles(hObj,newValue)
            oldValue=hObj.Bubbles;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.BubbleContainer.replaceChild(hObj.Bubbles,newValue);
                else

                    hObj.BubbleContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.Bubbles=newValue;
            try
                hObj.setBubblesFanoutProps();
            catch
            end
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess={?BubbleLegendTestClass},Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        LabelBig;
    end

    methods
        function set.LabelBig(hObj,newValue)
            oldValue=hObj.LabelBig;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.BubbleContainer.replaceChild(hObj.LabelBig,newValue);
                else

                    hObj.BubbleContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.LabelBig=newValue;
            try
                hObj.setLabelBigFanoutProps();
            catch
            end
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess={?BubbleLegendTestClass},Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        LabelMedium;
    end

    methods
        function set.LabelMedium(hObj,newValue)
            oldValue=hObj.LabelMedium;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.BubbleContainer.replaceChild(hObj.LabelMedium,newValue);
                else

                    hObj.BubbleContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.LabelMedium=newValue;
            try
                hObj.setLabelMediumFanoutProps();
            catch
            end
        end
    end

    properties(AffectsObject,SetObservable=true,SetAccess='private',GetAccess={?BubbleLegendTestClass},Dependent=false,Hidden=true,Transient=true,DeepCopy=true)

        LabelSmall;
    end

    methods
        function set.LabelSmall(hObj,newValue)
            oldValue=hObj.LabelSmall;
            if~isempty(newValue)&&isvalid(newValue)
                if~isempty(oldValue)&&isvalid(oldValue)

                    hObj.BubbleContainer.replaceChild(hObj.LabelSmall,newValue);
                else

                    hObj.BubbleContainer.addNode(newValue);
                end
            else
                if~isempty(oldValue)&&isvalid(oldValue)

                    set(oldValue,'Parent',matlab.graphics.primitive.world.Group.empty);
                end
            end
            hObj.LabelSmall=newValue;
            try
                hObj.setLabelSmallFanoutProps();
            catch
            end
        end
    end


    methods(Access='public',Hidden=true)
        function b=isChildProperty(obj,name)
            if strcmp(name,'BubbleContainer')
                b=true;
                return;
            end
            if strcmp(name,'BubbleContainer_I')
                b=true;
                return;
            end
            if strcmp(name,'Axle')
                b=true;
                return;
            end
            if strcmp(name,'Bubbles')
                b=true;
                return;
            end
            if strcmp(name,'LabelBig')
                b=true;
                return;
            end
            if strcmp(name,'LabelMedium')
                b=true;
                return;
            end
            if strcmp(name,'LabelSmall')
                b=true;
                return;
            end
            b=isChildProperty@matlab.graphics.illustration.internal.AbstractLegend(obj,name);
            return;
            b=false;
        end
    end





    methods
        function hObj=BubbleLegend(varargin)






            hObj.BubbleContainer_I=matlab.graphics.primitive.Marker;

            set(hObj.BubbleContainer,'Description_I','BubbleLegend BubbleContainer');

            set(hObj.BubbleContainer,'Internal',true);

            hObj.Axle=matlab.graphics.primitive.world.LineStrip;

            set(hObj.Axle,'Description_I','BubbleLegend Axle');

            set(hObj.Axle,'Internal',true);

            hObj.Bubbles=matlab.graphics.primitive.world.Marker;

            set(hObj.Bubbles,'Description_I','BubbleLegend Bubbles');

            set(hObj.Bubbles,'Internal',true);

            hObj.LabelBig=matlab.graphics.primitive.world.Text;

            set(hObj.LabelBig,'Description_I','BubbleLegend LabelBig');

            set(hObj.LabelBig,'Internal',true);

            hObj.LabelMedium=matlab.graphics.primitive.world.Text;

            set(hObj.LabelMedium,'Description_I','BubbleLegend LabelMedium');

            set(hObj.LabelMedium,'Internal',true);

            hObj.LabelSmall=matlab.graphics.primitive.world.Text;

            set(hObj.LabelSmall,'Description_I','BubbleLegend LabelSmall');

            set(hObj.LabelSmall,'Internal',true);



            hObj.doSetup;


            matlab.graphics.chart.internal.ctorHelper(hObj,varargin);
        end
    end

    methods(Access=private)
        function setBubbleContainer_IFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setAxleFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setBubblesFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setLabelBigFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setLabelMediumFanoutProps(hObj)
        end
    end
    methods(Access=private)
        function setLabelSmallFanoutProps(hObj)
        end
    end


    methods(Access='private',Hidden=true)
        function varargout=setNumBubblesImpl(hObj,newValue)


            if newValue~=2&&newValue~=3
                throwAsCaller(MException(message('MATLAB:bubblelegend:InvalidNumBubbles')));
            end
            varargout{1}=newValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getNumBubblesImpl(hObj,storedValue)

            varargout={storedValue};
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setLimitLabelsImpl(hObj,newValue)


            if(~isstring(newValue)&&~isnumeric(newValue)&&~iscell(newValue))||(numel(newValue)~=3&&numel(newValue)~=2)
                throwAsCaller(MException(message('MATLAB:bubblelegend:InvalidLimitLabels')));
            elseif~iscell(newValue)

                newValue=num2cell(newValue);
            end


            varargout{1}=newValue;


            for i=1:numel(newValue)
                if isnumeric(newValue{i})
                    newValue{i}=num2str(newValue{i});
                else
                    newValue{i}=char(newValue{i});
                end
            end

            hObj.LabelSmall.String=newValue{1};
            hObj.LabelBig.String=newValue{end};
            if hObj.NumBubbles==3&&numel(newValue)==3
                hObj.LabelMedium.String=newValue{2};
            end



        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getLimitLabelsImpl(hObj,storedValue)

            varargout={storedValue};
        end
    end
    methods(Access='public',Static=true,Hidden=true)

        varargout=getLabelSizeInPoints(us,textObj)
    end
    methods(Access='public',Static=true,Hidden=true)

        varargout=doloadobj(hObj)
    end
    methods(Access={?matlab.graphics.mixin.internal.Copyable,?matlab.graphics.internal.CopyContext},Hidden=true)

        varargout=copyElement(hObj)
    end
    methods(Access={?matlab.graphics.mixin.internal.Copyable,?matlab.graphics.internal.CopyContext},Hidden=true)

        connectCopyToTree(hObj,hCopy,hCopyParent,hContext)
    end
    methods(Access='private',Hidden=true)

        doSetup(hObj)
    end
    methods(Access='public',Hidden=true)

        doUpdate(hObj,updateState)
    end
    methods(Access='private',Hidden=true)
        function varargout=setAxesImpl(hObj,newValue)

            if~isempty(newValue)
                newValue=legendcolorbarlayout(newValue,'addToTree',hObj);
            end
        end
    end
    methods(Access='public',Static=true,Hidden=true)

        autoUpdateCallback(ed,bubbleLegend)
    end
    methods(Access='public',Hidden=true)
        function scaleForPrinting(hObj,flag,scaleFactor)






            switch lower(flag)
            case 'modify'

                hObj.PrintSettingsCache.AxleWidth=hObj.Axle.LineWidth;
                hObj.PrintSettingsCache.AxlePadding=hObj.AxlePadding;
                hObj.PrintSettingsCache.Padding=hObj.Padding;

                hObj.Axle.LineWidth=hObj.Axle.LineWidth/scaleFactor;
                hObj.Padding=hObj.Padding/scaleFactor;
                hObj.AxlePadding=hObj.AxlePadding/scaleFactor;
            case 'revert'
                if isfield(hObj.PrintSettingsCache,'AxleWidth')&&...
                    isfield(hObj.PrintSettingsCache,'Padding')&&...
                    isfield(hObj.PrintSettingsCache,'AxlePadding')
                    hObj.Axle.LineWidth=hObj.PrintSettingsCache.AxleWidth;
                    hObj.Padding=hObj.PrintSettingsCache.Padding;
                    hObj.AxlePadding=hObj.PrintSettingsCache.AxlePadding;
                    hObj.PrintSettingsCache=struct();
                end
            end
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=getLocationImpl(hObj,storedValue)

            varargout{1}=storedValue;
        end
    end
    methods(Access='private',Hidden=true)
        function varargout=setLocationImpl(hObj,newValue)



            if strcmp(newValue,'none')
                hObj.PositionMode='manual';
            else
                hObj.PositionMode='auto';
            end


            if~isempty(hObj.Axes)
                legendcolorbarlayout(hObj.Axes,'addToLayout',hObj);
            end

            varargout{1}=newValue;
        end
    end
    methods(Access='private',Hidden=true)

        updateLimitLabelsProperties(hObj)
    end
    methods(Access={?BubbleLegendTestClass},Hidden=true)

        syncPropertiesWithBubbleChart(hObj)
    end
    methods(Access={?BubbleLegendTestClass},Hidden=true)

        prepBubblesAndLabels(hObj)
    end
    methods(Access={?BubbleLegendTestClass},Hidden=true)

        positionBubblesAndLabels(hObj,width,height,titleHeight,updateState)
    end
    methods(Access={?BubbleLegendTestClass},Hidden=true)

        layoutBubbleLegendInternalObjects(hObj,updateState)
    end
    methods(Access={?BubbleLegendTestClass},Hidden=true)

        varargout=getWidthOfLegendInPoints(hObj,updateState)
    end
    methods(Access='public',Hidden=true)

        varargout=getPreferredSize(hObj,varargin)
    end
    methods(Access='public',Hidden=true)
        function setAbsoluteGraphicsLayoutPosition(hObj,newValue)


            hViewPort=hObj.Camera.Viewport;
            hViewPort.Position=newValue;
            set(hObj.Camera,'ViewPort',hViewPort)
        end
    end
    methods(Access={?BubbleLegendTestClass},Hidden=true)

        varargout=getHeightInPointsWithoutTitle(hObj)
    end
    methods(Access={?BubbleLegendTestClass},Hidden=true)

        markBubbleObjectsClean(hObj)
    end




end
