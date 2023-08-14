classdef(ConstructOnLoad,Sealed)GeographicBubbleChart...
    <matlab.graphics.chart.GeographicChart&...
    matlab.graphics.chartcontainer.mixin.ColorOrderMixin&...
    matlab.graphics.datatip.internal.mixin.DataTipMixin

















































    properties(Transient,Hidden=true,GetAccess=public,SetAccess=protected,NonCopyable)
        Type='geobubble'
    end

    properties(Dependent,AffectsObject)
SourceTable
LatitudeVariable
LongitudeVariable
SizeVariable
ColorVariable
    end

    properties(Dependent,AffectsObject)
LatitudeData
LongitudeData
    end

    properties(Access=private)
        LatitudeData_I=[]
        LongitudeData_I=[]
    end

    properties(Dependent,AffectsObject)
        ColorLegendTitle matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
        SizeLegendTitle matlab.internal.datatype.matlab.graphics.datatype.NumericOrString
        LegendVisible matlab.lang.OnOffSwitchState
    end

    properties(Hidden,AbortSet,Access={?tGeographicBubbleChart,...
        ?tGeographicBubbleChart_TableProperties})
        ColorLegendTitle_I=''
        SizeLegendTitle_I=''


        LatitudeVariableName char=''
        LongitudeVariableName char=''
        SizeVariableName char=''
        ColorVariableName char=''
    end

    properties(Access=private,AbortSet)
        LegendVisible_I=true
    end

    properties(Transient,AffectsObject)
        SizeData=[]
        ColorData=[]
    end

    properties(AffectsObject)
BubbleColorList
BubbleWidthRange
SizeLimits
    end

    properties(AffectsObject,Dependent,Access=protected)
        BubbleColorList_I matlab.internal.datatype.matlab.graphics.datatype.ColorOrder
        BubbleColorListMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Access=protected)
        BubbleColorListStructure struct=struct('BubbleColorListMode','auto',...
        'BubbleColorList_I',[],...
        'ColorOrderInternalMode','auto');
    end

    properties(Access=private,Transient,NonCopyable)
BubbleObject
SizeLegend
ColorLegend



        DataPropertiesHaveChanged=true



        LegendsDirty=true
    end

    properties(Dependent,Hidden,Access=?tGeographicBubbleChart)
ColorLegendPositionInPoints
    end

    properties(AffectsObject,Hidden,...
        Access={?tGeographicBubbleChart,?tGeographicBubbleChart_TableProperties})
        SourceTable_I tabular=table.empty();
        LatitudeVariable_I=''
        LongitudeVariable_I=''
        SizeVariable_I=''
        ColorVariable_I=''
    end

    properties(Hidden,AbortSet,Access=?tGeographicBubbleChart_TableProperties)
        SizeLegendTitleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        ColorLegendTitleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'

        UsingTableForData=true
    end

    properties(Access=private,AbortSet)
        LegendVisibleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Access=private,Constant)
        DataValidator=matlab.graphics.chart.internal.maps.GeographicBubbleDataValidator("properties")
    end

    properties(Access=private,Transient,NonCopyable)
BubbleDatatip
    end

    properties(Access=private,NonCopyable)

DataStorage
    end

    methods
        function obj=GeographicBubbleChart(varargin)

            obj@matlab.graphics.chart.GeographicChart()
            ax=obj.Axes;
            addlistener(ax.LongitudeAxis_I,'LimitsChanged',...
            @(~,~)obj.updateDataObjects);


            bubbleobj=matlab.graphics.chart.internal.maps.Bubble(ax);
            obj.BubbleObject=bubbleobj;


            scatterobj=bubbleobj.ScatterPrimitive;
            datatip=matlab.graphics.chart.internal.maps.BubbleDatatip(scatterobj);
            obj.BubbleDatatip=datatip;
            configureDatatipForPrint(obj);


            sizelegend=matlab.graphics.chart.internal.maps.SizeLegend(ax);
            obj.SizeLegend=sizelegend;
            colorlegend=matlab.graphics.illustration.internal.ColorLegend(ax);
            obj.ColorLegend=colorlegend;


            colorLegendNode=getNode(obj.ColorLegend);
            addNode(obj,colorLegendNode);
            sizeLegendNode=getNode(obj.SizeLegend);
            addNode(obj,sizeLegendNode);


            initializeBubbleSizeLegend(obj);
            initializeColorLegend(obj);


            matlab.graphics.chart.internal.ctorHelper(obj,varargin);

            addlistener(ax,'Hit',@(e,d)obj.showContextMenu(d));


            addlistener(scatterobj,'Hit',@(e,d)obj.showContextMenu(d));
            obj.initializeDataTipConfiguration();
        end
    end


    methods(Access=protected)
        function validateDataProperties(obj)
            validateSizeConsistency(obj.DataValidator,...
            obj.LatitudeData,obj.LongitudeData,obj.SizeData,obj.ColorData)
        end


        function updateLegends(obj,updateState)

            if obj.DataPropertiesHaveChanged||obj.LegendsDirty
                updateSizeLegend(obj,updateState)
                updateColorLegend(obj,updateState)
            end
            updateLegendLayout(obj,updateState)
            obj.LegendsDirty=false;
        end


        function updateDataObjects(obj)
            updateBubbleObject(obj)
        end


        function updateLegendFontName(obj,fontName)
            obj.SizeLegend.FontName=fontName;
            obj.ColorLegend.FontName=fontName;
            obj.LegendsDirty=true;
        end


        function updateLegendFontSize(obj,fontSize)
            obj.SizeLegend.FontSize=fontSize;
            obj.ColorLegend.FontSize=fontSize;
            obj.LegendsDirty=true;
        end


        function dtConfig=getDefaultDataTipConfiguration(obj)


            dtConfig=string.empty(0,1);
            if~isempty(obj.SourceTable)
                dtConfig{end+1}=obj.LatitudeVariableName;
                dtConfig{end+1}=obj.LongitudeVariableName;
                if~isempty(obj.SizeVariableName)
                    dtConfig{end+1}=obj.SizeVariableName;
                end
                if~isempty(obj.ColorVariableName)
                    dtConfig{end+1}=obj.ColorVariableName;
                end



                dtConfig{end+1}=obj.SourceTable.Properties.DimensionNames{1};
            end
        end

        function showContextMenu(obj,evd)
            if obj.UsingTableForData
                showContextMenu@matlab.graphics.datatip.internal.mixin.DataTipMixin(obj,evd);
            end
        end
    end

    methods(Access=protected)
        function dataPropertySettings=cacheDataProperties(obj)
            dataPropertySettings.BubbleLineWidth=obj.BubbleObject.BubbleLineWidth;
            dataPropertySettings.LegendBubbleLineWidth=obj.SizeLegend.LineWidth;

        end


        function scaleDataProperties(obj,dataPropertySettings,scale)



            obj.BubbleObject.BubbleLineWidth=dataPropertySettings.BubbleLineWidth./scale;
            obj.SizeLegend.LineWidth=dataPropertySettings.LegendBubbleLineWidth./scale;
        end


        function revertDataProperties(obj,dataPropertySettings)

            obj.BubbleObject.BubbleLineWidth=dataPropertySettings.BubbleLineWidth;
            obj.SizeLegend.LineWidth=dataPropertySettings.LegendBubbleLineWidth;
        end

        function setColorOrderInternal(pc,listOfColors)
            pc.BubbleColorListStructure.ColorOrderInternalMode='manual';
            if~isempty(pc.ColorData)
                numCategories=numel(categories(pc.ColorData));
            else

                numCategories=1;
            end
            numColors=size(listOfColors,1);


            if numCategories>numColors
                newBubbleColorList=listOfColors(rem(0:numCategories-1,numColors)+1,:);
            else
                newBubbleColorList=listOfColors(1:numCategories,:);
            end
            pc.BubbleColorList_I=newBubbleColorList;
        end
    end


    methods(Hidden)

        function actualValue=setParentImpl(obj,proposedParent)

            if isa(proposedParent,'matlab.graphics.internal.GraphicsPropertyHandler')&&...
                isempty(obj.Parent)&&strcmp(obj.BubbleColorListStructure.ColorOrderInternalMode,'auto')
                colors=get(proposedParent,'DefaultGeoaxesColorOrder');
                obj.ColorOrderInternal=colors;
                if strcmp(obj.BubbleColorListMode,'auto')
                    obj.setColorOrderInternal(colors);
                end
            end

            actualValue=obj.setParentImpl@matlab.graphics.chart.GeographicChart(proposedParent);
        end

        function ignore=mcodeIgnoreHandle(~,~)
            ignore=false;
        end

        function mcodeConstructor(obj,code)


            mcodeConstructor@matlab.graphics.chart.GeographicChart(obj,code)



            setConstructorName(code,'geobubble')



            ignoreProperty(code,'SourceTable');
            ignoreProperty(code,'LatitudeVariable');
            ignoreProperty(code,'LongitudeVariable');
            ignoreProperty(code,'SizeVariable');
            ignoreProperty(code,'ColorVariable');
            ignoreProperty(code,'ContextMenu');



            ignoreProperty(code,'LatitudeData');
            ignoreProperty(code,'LongitudeData');
            ignoreProperty(code,'SizeData');
            ignoreProperty(code,'ColorData');


            if~obj.UsingTableForData




                latarg=codegen.codeargument('Name','lat',...
                'Value',obj.LatitudeData,...
                'IsParameter',true,'Comment','geobubble lat');
                addConstructorArgin(code,latarg);


                lonarg=codegen.codeargument('Name','lon',...
                'Value',obj.LongitudeData,...
                'IsParameter',true,'Comment','geobubble lon');
                addConstructorArgin(code,lonarg);

                if~isempty(obj.SizeData)

                    sizearg=codegen.codeargument('Name','sizedata',...
                    'Value',obj.SizeData,...
                    'IsParameter',true,...
                    'Comment','geobubble sizedata');
                    addConstructorArgin(code,sizearg);
                end

                if~isempty(obj.ColorData)

                    if isempty(obj.SizeData)
                        sizearg=codegen.codeargument(...
                        'Name','sizedata','Value',[],...
                        'IsParameter',false,...
                        'Comment','geobubble sizedata');
                        addConstructorArgin(code,sizearg);
                    end


                    colorarg=codegen.codeargument('Name','colordata',...
                    'Value',obj.ColorData,...
                    'IsParameter',true,...
                    'Comment','geobubble colordata');
                    addConstructorArgin(code,colorarg);
                end
            else




                arg=codegen.codeargument('Name','tbl',...
                'Value',obj.SourceTable,...
                'IsParameter',true,'Comment','geobubble tbl');
                addConstructorArgin(code,arg);


                arg=codegen.codeargument('Name','latvar',...
                'Value',obj.LatitudeVariable,...
                'IsParameter',true,'Comment','geobubble latvar');
                addConstructorArgin(code,arg);


                arg=codegen.codeargument('Name','lonvar',...
                'Value',obj.LongitudeVariable,...
                'IsParameter',true,'Comment','geobubble lonvar');
                addConstructorArgin(code,arg);


                if~isempty(obj.SizeVariable)






                    arg=codegen.codeargument('Value','SizeVariable',...
                    'ArgumentType',codegen.ArgumentType.PropertyName);
                    addConstructorArgin(code,arg);


                    arg=codegen.codeargument('Name','sizevar',...
                    'Value',obj.SizeVariable,...
                    'IsParameter',true,'Comment','geobubble sizevar',...
                    'ArgumentType',codegen.ArgumentType.PropertyValue);
                    addConstructorArgin(code,arg);
                end


                if~isempty(obj.ColorVariable)






                    arg=codegen.codeargument('Value','ColorVariable',...
                    'ArgumentType',codegen.ArgumentType.PropertyName);
                    addConstructorArgin(code,arg);


                    arg=codegen.codeargument('Name','colorvar',...
                    'Value',obj.ColorVariable,...
                    'IsParameter',true,'Comment','geobubble colorvar',...
                    'ArgumentType',codegen.ArgumentType.PropertyValue);
                    addConstructorArgin(code,arg);
                end
            end


            propsWithModes={'ColorLegendTitle','SizeLegendTitle',...
            'LegendVisible','BubbleColorList'};
            for p=1:numel(propsWithModes)

                propName=propsWithModes{p};
                modePropName=[propName,'Mode'];


                if obj.(modePropName)=="auto"

                    ignoreProperty(code,propName);
                end
            end



            if~obj.BubbleObject.ManualSizeLimits
                ignoreProperty(code,'SizeLimits');
            end
            if~obj.BubbleObject.ManualBubbleWidthRange
                ignoreProperty(code,'BubbleWidthRange');
            end






            if isempty(code.Constructor.Argout)
                generateDefaultPropValueSyntax(code);
            else
                generateDefaultPropValueSyntaxNoOutput(code);
            end
        end


        function pos=getLegendPixelPosition(obj)
            sizeLegend=obj.SizeLegend;
            if~isempty(sizeLegend)&&strcmp(sizeLegend.Visible,'on')
                pos1=getPixelPosition(sizeLegend);
            else
                pos1=[];
            end

            colorLegend=obj.ColorLegend;
            if~isempty(colorLegend)&&strcmp(colorLegend.Visible,'on')
                pos2=matlab.graphics.chart.internal.getOrangeChartChildPixelPosition(colorLegend.Legend);
            else
                pos2=[];
            end

            if isempty(pos1)
                pos=pos2;
            elseif isempty(pos2)
                pos=pos1;
            else
                pos(1)=pos1(1);
                if pos2(1)<pos1(1)
                    pos(1)=pos2(1);
                end

                pos(2)=pos1(2);
                if pos2(2)<pos1(2)
                    pos(2)=pos2(2);
                end

                pos(3)=pos1(1)+pos1(3)-pos(1);
                if pos2(1)+pos2(3)>pos1(1)+pos1(3)
                    pos(3)=pos2(1)+pos2(3)-pos(1);
                end

                pos(4)=pos1(2)+pos1(4)-pos(2);
                if pos2(2)+pos2(4)>pos1(2)+pos1(4)
                    pos(4)=pos2(2)+pos2(4)-pos(2);
                end
            end
        end
    end


    methods(Hidden,Access={?matlab.graphics.mixin.internal.Copyable,?matlab.graphics.internal.CopyContext})
        function copiedObject=copyElement(obj)

            manualSizeLimits=obj.BubbleObject.ManualSizeLimits;
            manualBubbleWidthRange=obj.BubbleObject.ManualBubbleWidthRange;
            copiedObject=copyElement@matlab.graphics.mixin.internal.Copyable(obj);
            copiedObject.BubbleObject.ManualSizeLimits=manualSizeLimits;
            copiedObject.BubbleObject.ManualBubbleWidthRange=manualBubbleWidthRange;
            copiedObject.DataPropertiesHaveChanged=true;
        end
    end


    methods

        function set.SourceTable(gb,tbl)


            assert(gb.UsingTableForData,...
            message('MATLAB:graphics:geobubble:MatrixWorkflow',...
            'SourceTable'));


            assert(isa(tbl,'tabular'),...
            message('MATLAB:graphics:geobubble:InvalidSourceTable'));


            [latVarName,~,errLat]=...
            matlab.graphics.chart.internal.validateTableSubscript(...
            tbl,gb.LatitudeVariable_I,'LatitudeVariable');
            [lonVarName,~,errLon]=...
            matlab.graphics.chart.internal.validateTableSubscript(...
            tbl,gb.LongitudeVariable_I,'LongitudeVariable');
            [sizeVarName,~,errSize]=...
            matlab.graphics.chart.internal.validateTableSubscript(...
            tbl,gb.SizeVariable_I,'SizeVariable');
            [colorVarName,~,errColor]=...
            matlab.graphics.chart.internal.validateTableSubscript(...
            tbl,gb.ColorVariable_I,'ColorVariable');



            if~isempty(errLat)
                throwAsCaller(errLat);
            end
            if~isempty(errLon)
                throwAsCaller(errLon);
            end
            if~isempty(errSize)
                throwAsCaller(errSize);
            end
            if~isempty(errColor)
                throwAsCaller(errColor);
            end


            gb.SourceTable_I=tbl;


            gb.DataPropertiesHaveChanged=true;


            gb.LatitudeVariableName=latVarName;
            gb.LongitudeVariableName=lonVarName;
            gb.SizeVariableName=sizeVarName;
            gb.ColorVariableName=colorVarName;


            if strcmp(gb.SizeLegendTitleMode,'auto')
                gb.SizeLegendTitle_I=replace(gb.SizeVariableName,'_','\_');
            end
            if strcmp(gb.ColorLegendTitleMode,'auto')
                gb.ColorLegendTitle_I=replace(gb.ColorVariableName,'_','\_');
            end


            initializeDataTipConfiguration(gb);
        end


        function tbl=get.SourceTable(gb)
            tbl=gb.SourceTable_I;
        end


        function set.LatitudeVariable(gb,var)


            assert(gb.UsingTableForData,...
            message('MATLAB:graphics:geobubble:MatrixWorkflow',...
            'LatitudeVariable'));


            tbl=gb.SourceTable_I;
            [varName,var,err]=...
            matlab.graphics.chart.internal.validateTableSubscript(...
            tbl,var,'LatitudeVariable');
            if~isempty(err)
                throwAsCaller(err);
            end


            if~isempty(varName)
                lat=validateLatitude(gb.DataValidator,tbl.(varName));
                gb.LatitudeData_I=lat;
            else
                gb.LatitudeData_I=[];
            end


            gb.LatitudeVariable_I=var;


            gb.LatitudeVariableName=varName;


            gb.DataPropertiesHaveChanged=true;





            gb.initializeDataTipConfiguration();
        end


        function var=get.LatitudeVariable(gb)
            var=gb.LatitudeVariable_I;
        end


        function set.LongitudeVariable(gb,var)


            assert(gb.UsingTableForData,...
            message('MATLAB:graphics:geobubble:MatrixWorkflow',...
            'LongitudeVariable'));


            tbl=gb.SourceTable_I;
            [varName,var,err]=...
            matlab.graphics.chart.internal.validateTableSubscript(...
            tbl,var,'LongitudeVariable');
            if~isempty(err)
                throwAsCaller(err);
            end


            if~isempty(varName)
                lon=validateLongitude(gb.DataValidator,tbl.(varName));
                gb.LongitudeData_I=lon;
            else
                gb.LongitudeData_I=[];
            end


            gb.LongitudeVariable_I=var;


            gb.LongitudeVariableName=varName;


            gb.DataPropertiesHaveChanged=true;





            gb.initializeDataTipConfiguration();
        end


        function var=get.LongitudeVariable(gb)
            var=gb.LongitudeVariable_I;
        end


        function set.SizeVariable(gb,var)


            assert(gb.UsingTableForData,...
            message('MATLAB:graphics:geobubble:MatrixWorkflow',...
            'SizeVariable'));


            tbl=gb.SourceTable_I;
            [varName,var,err]=...
            matlab.graphics.chart.internal.validateTableSubscript(...
            tbl,var,'SizeVariable');
            if~isempty(err)
                throwAsCaller(err);
            end


            if~isempty(varName)
                sz=validateSizeData(gb.DataValidator,tbl.(varName));
                try
                    gb.BubbleObject.SizeData=sz;
                catch e
                    throwAsCaller(e)
                end
            else
                gb.BubbleObject.SizeData=[];
            end


            gb.SizeVariable_I=var;


            gb.SizeVariableName=varName;


            gb.DataPropertiesHaveChanged=true;


            if strcmp(gb.SizeLegendTitleMode,'auto')
                gb.SizeLegendTitle_I=replace(gb.SizeVariableName,'_','\_');
            end





            gb.initializeDataTipConfiguration();
        end


        function var=get.SizeVariable(gb)
            var=gb.SizeVariable_I;
        end


        function set.ColorVariable(gb,var)


            assert(gb.UsingTableForData,...
            message('MATLAB:graphics:geobubble:MatrixWorkflow',...
            'ColorVariable'));


            tbl=gb.SourceTable_I;
            [varName,var,err]=...
            matlab.graphics.chart.internal.validateTableSubscript(...
            tbl,var,'ColorVariable');
            if~isempty(err)
                throwAsCaller(err);
            end


            if~isempty(varName)
                clr=validateColorData(gb.DataValidator,tbl.(varName));
                try
                    gb.BubbleObject.ColorData=clr;
                catch e
                    throwAsCaller(e)
                end
            else
                gb.BubbleObject.ColorData=[];
            end


            gb.ColorVariable_I=var;


            gb.ColorVariableName=varName;


            gb.DataPropertiesHaveChanged=true;


            if strcmp(gb.ColorLegendTitleMode,'auto')
                gb.ColorLegendTitle_I=replace(gb.ColorVariableName,'_','\_');
            end





            gb.initializeDataTipConfiguration();
        end


        function var=get.ColorVariable(gb)
            var=gb.ColorVariable_I;
        end


        function set.BubbleColorList(gb,rgbmatrix)
            if isnumeric(rgbmatrix)
                validateattributes(rgbmatrix,{'double'},...
                {'nonempty','>=',0,'<=',1,'ncols',3,'ndims',2,...
                'finite','real'},'','BubbleColorList');
            else
                if iscellstr(rgbmatrix)
                    rgbmatrix=string(rgbmatrix);
                end
                if isstring(rgbmatrix)
                    rgbmatrix=rgbmatrix(:);
                end
                try
                    rgbmatrix=arrayfun(@(x)colorSpecToRGB(rgbmatrix(x,:)),...
                    1:size(rgbmatrix,1),'UniformOutput',false);
                catch e
                    throwAsCaller(e)
                end
                rgbmatrix=cell2mat(rgbmatrix');
            end

            gb.BubbleColorList_I=rgbmatrix;
            gb.BubbleColorListMode='manual';
        end


        function out=get.BubbleColorListMode(gb)
            out=gb.BubbleColorListStructure.BubbleColorListMode;
        end

        function set.BubbleColorListMode(gb,val)
            gb.BubbleColorListStructure.BubbleColorListMode=val;
        end

        function out=get.BubbleColorList_I(gb)
            out=gb.BubbleColorListStructure.BubbleColorList_I;
        end

        function set.BubbleColorList_I(gb,rgbmatrix)
            gb.BubbleObject.BubbleColorList=rgbmatrix;
            gb.DataPropertiesHaveChanged=true;%#ok<MCSUP>


            colorlegend=gb.ColorLegend;%#ok<MCSUP>
            colorlegend.ColorList=rgbmatrix;

            gb.BubbleColorListStructure.BubbleColorList_I=rgbmatrix;
        end

        function color=get.BubbleColorList(gb)
            color=gb.BubbleObject.BubbleColorList;
        end


        function set.BubbleWidthRange(gb,width)
            if isscalar(width)&&isnumeric(width)
                width=[width,width];
            end
            if~isempty(width)
                validateattributes(width,{'numeric'},...
                {'real','finite','size',[1,2],'nondecreasing','>=',1,'<=',100},...
                '','BubbleWidthRange')
            end
            gb.BubbleObject.BubbleWidthRange=double(width);
            gb.DataPropertiesHaveChanged=true;%#ok<MCSUP>
        end


        function width=get.BubbleWidthRange(gb)
            width=gb.BubbleObject.BubbleWidthRange;
        end


        function set.ColorLegendTitle(gb,title)
            gb.ColorLegendTitle_I=convertStringsToChars(title);
            gb.LegendsDirty=true;
            gb.ColorLegendTitleMode='manual';
        end


        function title=get.ColorLegendTitle(obj)
            title=obj.ColorLegendTitle_I;
        end


        function set.ColorLegendTitle_I(gb,title)
            gb.ColorLegendTitle_I=title;
            gb.ColorLegend.TitleString=title;%#ok<MCSUP>
        end


        function set.SizeLegendTitle(gb,title)
            gb.SizeLegendTitle_I=convertStringsToChars(title);
            gb.LegendsDirty=true;
            gb.SizeLegendTitleMode='manual';
        end


        function title=get.SizeLegendTitle(obj)
            title=obj.SizeLegendTitle_I;
        end


        function set.SizeLegendTitle_I(gb,title)
            gb.SizeLegendTitle_I=title;
            gb.SizeLegend.TitleString=title;%#ok<MCSUP>
        end


        function set.LatitudeData(gb,lat)


            matrixMode=~gb.UsingTableForData||width(gb.SourceTable)==0;
            assert(matrixMode,message('MATLAB:graphics:geobubble:TableWorkflow','LatitudeData'));

            lat=validateLatitude(gb.DataValidator,lat);
            gb.LatitudeData_I=lat;
            gb.DataPropertiesHaveChanged=true;
            gb.UsingTableForData=false;
        end


        function lat=get.LatitudeData(gb)
            if gb.UsingTableForData
                updateTableDataProperties(gb,'Latitude')
            end
            lat=gb.LatitudeData_I;
        end


        function set.LongitudeData(gb,lon)


            matrixMode=~gb.UsingTableForData||width(gb.SourceTable)==0;
            assert(matrixMode,message('MATLAB:graphics:geobubble:TableWorkflow','LongitudeData'));

            lon=validateLongitude(gb.DataValidator,lon);
            gb.LongitudeData_I=lon;
            gb.DataPropertiesHaveChanged=true;
            gb.UsingTableForData=false;
        end


        function lon=get.LongitudeData(gb)
            if gb.UsingTableForData
                updateTableDataProperties(gb,'Longitude')
            end
            lon=gb.LongitudeData_I;
        end


        function set.SizeData(gb,sizedata)


            matrixMode=~gb.UsingTableForData||width(gb.SourceTable)==0;%#ok<MCSUP>
            assert(matrixMode,message('MATLAB:graphics:geobubble:TableWorkflow','SizeData'));

            sizedata=validateSizeData(gb.DataValidator,sizedata);
            b=gb.BubbleObject;
            try
                b.SizeData=sizedata;
            catch e
                throwAsCaller(e)
            end
            gb.DataPropertiesHaveChanged=true;%#ok<MCSUP>
            gb.UsingTableForData=false;%#ok<MCSUP>
            checkSizeLegendVisibility(gb)
        end


        function values=get.SizeData(gb)
            if gb.UsingTableForData
                updateTableDataProperties(gb,'SizeVar')
            end
            values=gb.BubbleObject.SizeData;
        end


        function set.ColorData(gb,colordata)


            matrixMode=~gb.UsingTableForData||width(gb.SourceTable)==0;%#ok<MCSUP>
            assert(matrixMode,message('MATLAB:graphics:geobubble:TableWorkflow','ColorData'));

            colordata=validateColorData(gb.DataValidator,colordata);
            b=gb.BubbleObject;
            try
                b.ColorData=colordata;
            catch e
                throwAsCaller(e)
            end
            gb.DataPropertiesHaveChanged=true;%#ok<MCSUP>
            gb.UsingTableForData=false;%#ok<MCSUP>
            checkColorLegendVisibility(gb);
        end


        function values=get.ColorData(gb)
            if gb.UsingTableForData
                updateTableDataProperties(gb,'ColorVar')
            end
            values=gb.BubbleObject.ColorData;
        end


        function set.SizeLimits(gb,limits)
            if~isempty(limits)
                validateattributes(limits,{'numeric'},...
                {'size',[1,2],'real','finite','nonsparse','nondecreasing'},'','SizeLimits')
            end
            gb.BubbleObject.SizeLimits=limits;
            gb.DataPropertiesHaveChanged=true;%#ok<MCSUP>
        end


        function limits=get.SizeLimits(gb)
            limits=gb.BubbleObject.SizeLimits;
        end


        function set.LegendVisible(gb,legendVisible)
            try
                tf=matlab.graphics.chart.internal.maps.validateOnOffProperty('LegendVisible',legendVisible);
            catch e
                throwAsCaller(e)
            end
            gb.LegendVisible_I=tf;
            gb.LegendVisibleMode='manual';
            colorlegend=gb.ColorLegend;
            sizelegend=gb.SizeLegend;
            colorlegend.Visible=char(...
            matlab.lang.OnOffSwitchState(tf&&~isempty(gb.ColorData)));
            sizelegend.Visible=char(...
            matlab.lang.OnOffSwitchState(tf&&~isempty(gb.SizeData)));
        end


        function onoff=get.LegendVisible(gb)
            tf=gb.LegendVisible_I;
            onoff=char(matlab.lang.OnOffSwitchState(tf));
        end


        function pos=get.ColorLegendPositionInPoints(gb)
            pos=gb.ColorLegend.PositionInPoints;
        end


        function set.ColorLegendPositionInPoints(gb,pos)
            gb.ColorLegend.PositionInPoints=pos;
        end

        function set.DataStorage(gb,data)


            gb.BubbleObject.SizeData=data.SizeData;
            gb.BubbleObject.ColorData=data.ColorData;
            gb.BubbleObject.ManualSizeLimits=data.ManualSizeLimits;
            gb.BubbleObject.ManualBubbleWidthRange=data.ManualBubbleWidthRange;
            gb.UsingTableForData=data.UsingTableForData;%#ok<MCSUP>
        end


        function data=get.DataStorage(gb)


            data.SizeData=gb.BubbleObject.SizeData;
            data.ColorData=gb.BubbleObject.ColorData;
            data.ManualSizeLimits=gb.BubbleObject.ManualSizeLimits;
            data.ManualBubbleWidthRange=gb.BubbleObject.ManualBubbleWidthRange;
            data.UsingTableForData=gb.UsingTableForData;
        end
    end


    methods(Access=protected,Hidden)
        function groups=getPropertyGroups(obj)

            if obj.UsingTableForData
                props={
'Basemap'
'MapLayout'
'SourceTable'
'LatitudeVariable'
'LongitudeVariable'
'SizeVariable'
'ColorVariable'
                };
            else
                props={
'Basemap'
'MapLayout'
'LatitudeData'
'LongitudeData'
'SizeData'
'ColorData'
                };
            end
            groups=matlab.mixin.util.PropertyGroup(props);
        end
    end


    methods(Access=private)
        function initializeBubbleSizeLegend(obj)









            szleg=obj.SizeLegend;
            if isempty(szleg.SizeLimits)
                szleg.ColorList=obj.BubbleColorList;
                szleg.WidthRange=[1,10];
                szleg.Alpha=.8;
                szleg.LineWidth=1;
                szleg.SizeLimits=[1,10];
                szleg.SizeDataGreaterThanLimits=false;
                szleg.SizeDataLessThanLimits=false;
                szleg.TitleString='';
                szleg.Visible='off';
                updateLegend(szleg);

                szleg.ColorList=[];
                szleg.WidthRange=[];
                szleg.Alpha=[];
                szleg.LineWidth=[];
                szleg.SizeLimits=[];
                szleg.SizeDataGreaterThanLimits=false;
                szleg.SizeDataLessThanLimits=false;
            end
        end


        function initializeColorLegend(obj)

            colorlegend=obj.ColorLegend;
            colorlegend.ColorList=obj.BubbleColorList;
            colorlegend.Categories=[];
            colorlegend.TitleString='';
            colorlegend.Visible='off';
        end


        function configureDatatipForPrint(obj)

            behaviorProp=findprop(obj,'Behavior');
            if isempty(behaviorProp)
                behaviorProp=addprop(obj,'Behavior');
                behaviorProp.Hidden=true;
                behaviorProp.Transient=true;
            end
            datatip=obj.BubbleDatatip;
            hBehavior=hggetbehavior(obj,'print');
            hBehavior.PrePrintCallback=@(~,~)updateDatatipDuringPrint(datatip);
        end


        function bubbleSizeLegend(obj,updateState)
            if iscategorical(obj.ColorData)
                bubbleColorList=obj.BubbleObject.DefaultSizeLegendBubbleFaceColor;
            else
                bubbleColorList=obj.BubbleColorList(1,:);
            end
            bubbleAlpha=obj.BubbleObject.DefaultMarkerFaceAlpha;
            bubbleLineWidth=obj.BubbleObject.DefaultLineWidth;

            sizelegend=obj.SizeLegend;
            sizelegend.ColorList=bubbleColorList;
            sizelegend.SizeDataGreaterThanLimits=...
            max(obj.SizeData(:))>obj.SizeLimits(2);
            sizelegend.SizeDataLessThanLimits=...
            min(obj.SizeData(:))<obj.SizeLimits(1);
            sizelegend.SizeLimits=obj.SizeLimits;
            sizelegend.WidthRange=obj.BubbleWidthRange;
            sizelegend.Alpha=bubbleAlpha;
            sizelegend.LineWidth=bubbleLineWidth;
            constructSizeLegend(sizelegend,updateState);
        end


        function cats=addUndefinedCategory(obj)



            colordata=obj.ColorData;
            cats=categories(colordata);
            cats(end+1)={'<undefined>'};
        end


        function updateTableDataProperties(obj,prop)
            if obj.UsingTableForData&&obj.DataPropertiesHaveChanged
                tbl=obj.SourceTable;
                switch prop
                case 'Latitude'
                    [latvar,~,~]=...
                    matlab.graphics.chart.internal.validateTableSubscript(...
                    tbl,obj.LatitudeVariable_I,'LatitudeVariable');
                    if~isempty(latvar)
                        obj.LatitudeData_I=tbl.(latvar);
                    else
                        obj.LatitudeData_I=[];
                    end
                case 'Longitude'
                    [lonvar,~,~]=...
                    matlab.graphics.chart.internal.validateTableSubscript(...
                    tbl,obj.LongitudeVariable_I,'LongitudeVariable');
                    if~isempty(lonvar)
                        obj.LongitudeData_I=tbl.(lonvar);
                    else
                        obj.LongitudeData_I=[];
                    end
                case 'SizeVar'
                    [sizevar,~,~]=...
                    matlab.graphics.chart.internal.validateTableSubscript(...
                    tbl,obj.SizeVariable_I,'SizeVariable');
                    if~isempty(sizevar)
                        obj.BubbleObject.SizeData=tbl.(sizevar);
                    else
                        obj.BubbleObject.SizeData=[];
                    end
                case 'ColorVar'
                    [colorvar,~,~]=...
                    matlab.graphics.chart.internal.validateTableSubscript(...
                    tbl,obj.ColorVariable_I,'ColorVariable');
                    if~isempty(colorvar)
                        obj.BubbleObject.ColorData=tbl.(colorvar);
                    else
                        obj.BubbleObject.ColorData=[];
                    end
                end
            end
        end


        function updateBubbleObject(obj)


            bubbleobj=obj.BubbleObject;
            if~isempty(bubbleobj)
                lat=obj.LatitudeData;
                lon=obj.LongitudeData;


                if~isempty(lon)&&any(isfinite(lon))...
                    &&obj.DataPropertiesHaveChanged
                    lonlim=longitudeLimitsFromData(lon);
                    mapcenter=lonlim(1)+diff(lonlim)/2;
                else
                    ax=obj.Axes;
                    mapcenter=ax.MapCenter_I(2);
                end
                lonlim=mapcenter+[-180,180];
                lon=wrapLongitudeToLimits(lon,lonlim);

                oldlon=bubbleobj.YData;
                bubbleobj.XData=lat;
                bubbleobj.YData=lon;
                if obj.DataPropertiesHaveChanged
                    obj.DataPropertiesHaveChanged=false;
                    update(bubbleobj)
                    bh=hggetbehavior(bubbleobj.ScatterPrimitive,'DataCursor');
                    bh.UpdateFcn=@makeGeobubbleDatatipText;
                    bh.Enable=0;
                elseif~isequaln(oldlon,lon)



                    updateBubblePositions(bubbleobj)
                end
            end
        end


        function updateSizeLegend(obj,updateState)
            sizelegend=obj.SizeLegend;
            if~isempty(obj.SizeData)
                bubbleSizeLegend(obj,updateState)
            else
                sizelegend.Visible='off';
            end
            sizeLegendSize=getPreferredSize(sizelegend);
            sizeLegendSize=ensureTitleWithinLegend(...
            sizelegend,sizeLegendSize,updateState);
            sizelegend.PositionInPoints(3:4)=sizeLegendSize;
        end


        function updateColorLegend(obj,updateState)
            colorlegend=obj.ColorLegend;
            if~isempty(obj.ColorData)&&iscategorical(obj.ColorData)
                colorlegend.ColorList=obj.BubbleColorList;
                if any(isundefined(obj.ColorData))
                    colorlegend.Categories=addUndefinedCategory(obj);
                else
                    colorlegend.Categories=categories(obj.ColorData);
                end
                categoricalLegend(obj.ColorLegend);
            else
                colorlegend.Visible='off';
            end
            colorLegendSize=getPreferredSize(colorlegend,updateState);
            colorlegend.PositionInPoints(3:4)=colorLegendSize;
        end


        function updateLegendLayout(obj,updateState)

            checkColorLegendVisibility(obj)
            checkSizeLegendVisibility(obj)
            colorlegend=obj.ColorLegend;
            sizelegend=obj.SizeLegend;

            if strcmp(obj.LegendVisibleMode,'auto')
                obj.LegendVisible_I=true;

            end

            lv=strcmpi('on',obj.LegendVisible)||strcmp(obj.LegendVisibleMode,'auto');

            enoughDataForColorLegend=~isempty(obj.ColorData);
            enoughDataForSizeLegend=~isempty(obj.SizeData);



            clrvis=lv&&enoughDataForColorLegend;
            szvis=lv&&enoughDataForSizeLegend;
            legendsAreDesiredIfRoom=clrvis||szvis;

            if strcmp(obj.LegendVisibleMode,'auto')&&~enoughDataForColorLegend&&~enoughDataForSizeLegend


                obj.LegendVisible_I=false;
            end
            if legendsAreDesiredIfRoom

                ensureLegendWidthsMatch(colorlegend,sizelegend)
            end

            layoutValues=matlab.graphics.internal.getSuggestedLayoutValues(obj,updateState);
            horizontalMarginInPoints=layoutValues.DecorationSpacing(1);
            verticalMarginInPoints=layoutValues.DecorationSpacing(2);
            marginInPoints=10;
            if~szvis
                sizeLegendSize=[0,0];
            else
                sizeLegendSize=sizelegend.PositionInPoints(3:4);
            end
            if~clrvis
                colorLegendSize=[0,0];
            else
                colorLegendSize=colorlegend.PositionInPoints(3:4);
            end
            if maximizeMap(obj)
                initialDesiredLooseInset=[0,0,0,0];


                marginTop=4+obj.Axes.Toolbar.ToolbarHeight;
                verticalMarginInPoints=verticalMarginInPoints+marginTop;
                if szvis
                    sizelegend.UpperRightMargin=[marginInPoints,marginTop];
                end

                if clrvis
                    marginTop=sizeLegendSize(2)+marginTop+4;
                    colorlegend.UpperRightMargin=[marginInPoints,marginTop];
                end

                desiredLooseInset=initialDesiredLooseInset;
                rightInsetForLegend=0;
            else
                ax=obj.Axes;
                outerPos=ax.OuterPosition_I;
                units=ax.Units_I;
                vp=ax.Camera.Viewport;
                outerPosDevicePixels=obj.convertUnits(vp,'devicepixels',units,outerPos);







                if isempty(obj.LooseInsetCache)




                    liCache=vp;



                    liCache.RefFrame=outerPosDevicePixels;
                    liCache.Units=units;
                    obj.LooseInsetCache=liCache;
                    obj.LooseInsetCachePosition=ax.LooseInset;
                else


                    lic=obj.LooseInsetCache;
                    lic.RefFrame=outerPosDevicePixels;
                    lic.ScreenResolution_I=vp.ScreenResolution;



                    lic.Units=units;


                    obj.LooseInsetCache=lic;
                end

                initialDesiredLooseInset=obj.convertUnits(vp,'points',units,obj.LooseInsetCachePosition);
                desiredLooseInset=initialDesiredLooseInset;
                rightInsetForLegend=max(colorLegendSize(1),sizeLegendSize(1));
                if(rightInsetForLegend>0)
                    legendAndMargins=rightInsetForLegend+2*horizontalMarginInPoints;
                    if(desiredLooseInset(3)<legendAndMargins)
                        desiredLooseInset(3)=legendAndMargins;
                    end
                end
            end



            outerActive=strcmpi(obj.PositionConstraint,'outerposition');
            innerposPoints=updateState.convertUnits('canvas','points',obj.Units,obj.Position_I);
            tightInsetPoints=getTightInsetPoints(obj,updateState);
            totalInset=max(tightInsetPoints,desiredLooseInset);

            if(outerActive||maximizeMap(obj))



                minMapWidth=100;

                outerposPoints=updateState.convertUnits('canvas','points',obj.Units,obj.OuterPosition_I);
                legendTooWide=outerposPoints(3)<totalInset(1)+totalInset(3)+minMapWidth;
                legendTooTall=outerposPoints(4)<desiredLooseInset(4)+sizeLegendSize(2)+verticalMarginInPoints+colorLegendSize(2);

                if legendTooWide||legendTooTall

                    if strcmp(obj.LegendVisibleMode,'auto')

                        desiredLooseInset=initialDesiredLooseInset;
                        colorlegend.Visible='off';
                        sizelegend.Visible='off';
                        szvis=false;
                        clrvis=false;
                        obj.LegendVisible_I=false;
                    elseif legendTooWide



                        desiredLooseInset=initialDesiredLooseInset;
                    end
                end
                setAxesLooseInsetInPoints(obj,desiredLooseInset);
            else


                desiredOuterPos=innerposPoints+[-totalInset(1),-totalInset(2),...
                totalInset(1)+totalInset(3),...
                totalInset(2)+totalInset(4)];

                setAxesLooseInsetInPoints(obj,totalInset,desiredOuterPos);
            end


            if isInnerPositionManagedBySubplot(obj)

                decorationInsetPoints=max(tightInsetPoints,desiredLooseInset);
                obj.ChartDecorationInset=updateState.convertUnits(...
                'canvas',obj.Units,'points',decorationInsetPoints);
            end
            marginRight=-rightInsetForLegend-horizontalMarginInPoints;
            marginBetween=verticalMarginInPoints;

            if~maximizeMap(obj)
                if szvis
                    sizelegend.UpperRightMargin=[marginRight,0];
                else
                    marginBetween=0;
                end

                if clrvis
                    marginTop=sizeLegendSize(2)+marginBetween;
                    colorlegend.UpperRightMargin=[marginRight,marginTop];
                end
            end


            if~obj.Axes.PanZoomActionUpdatePending
                updateSizeLegendObject(sizelegend,sizeLegendSize)
                updateColorLegendObject(colorlegend,colorLegendSize)
            end
        end


        function checkSizeLegendVisibility(obj)
            sizelegend=obj.SizeLegend;
            if strcmp(sizelegend.Visible,'on')&&isempty(obj.SizeData)
                sizelegend.Visible='off';
            elseif strcmp(sizelegend.Visible,'off')...
                &&~isempty(obj.SizeData)&&...
                (strcmp(obj.LegendVisible,'on')||strcmp(obj.LegendVisibleMode,'auto'))
                sizelegend.Visible='on';

                try
                    validateSizeConsistency(obj.DataValidator,...
                    obj.LatitudeData,obj.LongitudeData,...
                    obj.SizeData,obj.ColorData)
                catch
                    sizelegend.Visible='off';
                end
                obj.LegendVisible_I=true;
            end
        end


        function checkColorLegendVisibility(obj)
            colorlegend=obj.ColorLegend;
            if strcmp(colorlegend.Visible,'on')&&isempty(obj.ColorData)
                colorlegend.Visible='off';
            elseif strcmp(colorlegend.Visible,'off')...
                &&~isempty(obj.ColorData)&&...
                (strcmp(obj.LegendVisible,'on')||strcmp(obj.LegendVisibleMode,'auto'))
                colorlegend.Visible='on';

                try
                    validateSizeConsistency(obj.DataValidator,...
                    obj.LatitudeData,obj.LongitudeData,...
                    obj.SizeData,obj.ColorData)
                catch
                    colorlegend.Visible='off';
                end
                obj.LegendVisible_I=true;
            end
        end
    end


    methods(Access=protected)
        function[latlim,lonlim]=limitsFromData(obj)
            lat=obj.LatitudeData;
            lon=obj.LongitudeData;
            [lat,lon]=filterPolarAndNonFinite(lat,lon);
            if~isempty(lat)
                bufferInPercent=5;
                f=1+bufferInPercent/100;
                minlat=double(min(lat));
                maxlat=double(max(lat));
                half=f*(maxlat-minlat)/2;
                latlim=[-half,half]+(minlat+maxlat)/2;
                latlim(1)=max(latlim(1),-90);
                latlim(2)=min(latlim(2),90);
                lonlim=double(longitudeLimitsFromData(lon));
                half=f*diff(lonlim)/2;
                lonlim=[-half,half]+(lonlim(1)+lonlim(2))/2;
            else
                latlim=[];
                lonlim=[];
            end
        end
    end
end


function[lat,lon]=filterPolarAndNonFinite(lat,lon)

    discard=isnan(lon)|isinf(lon)|isnan(lat)...
    |(lat<=-90)|(lat>=90);
    lat(discard)=[];
    lon(discard)=[];
end


function lonlim=longitudeLimitsFromData(lon)
    lonlim=matlab.graphics.chart.internal.maps.pointwiseLongitudeLimits(lon);
    lonlim=matlab.graphics.chart.internal.maps.unwrapLongitudeLimits(lonlim);
end


function lon=wrapLongitudeToLimits(lon,lonlim)



    west=lonlim(1);
    east=lonlim(2);
    wlon=lon<west;
    elon=lon>east;
    lon(wlon)=west+mod(lon(wlon)-west,360);
    lon(elon)=east-mod(east-lon(elon),360);
end


function rgb=colorSpecToRGB(colorSpec)
















    if ischar(colorSpec)||isstring(colorSpec)

        validateattributes(colorSpec,{'char','string'},...
        {'nonempty','vector'},'','BubbleColorList')
        rgb=stringColorSpecToRGB(colorSpec);
    else


        validateattributes(colorSpec,{'double'},...
        {'nonempty','>=',0,'<=',1,'size',[1,3]},'',...
        'BubbleColorList');
        rgb=colorSpec;
    end
end


function rgb=stringColorSpecToRGB(colorSpec)




    colorSpec=strtrim(colorSpec);


    index=strcmp(colorSpec,{'k','b'});
    if any(index)



        blackOrBlue=[0,0,0;0,0,1];
        rgb=blackOrBlue(index,:);
    else

        colorSpecStrings=[...
        "red","green","blue","white","cyan","magenta","yellow","black"];
        rgbSpec=[1,0,0;0,1,0;0,0,1;1,1,1;0,1,1;1,0,1;1,1,0;0,0,0];





        colorString=validatestring(colorSpec,colorSpecStrings,'',...
        'BubbleColorList');
        index=strcmp(colorString,colorSpecStrings);
        rgb=rgbSpec(index,:);
    end
end


function ensureLegendWidthsMatch(colorlegend,sizelegend)


    clrpos=colorlegend.PositionInPoints;
    szpos=sizelegend.PositionInPoints;

    if~isempty(clrpos)&&~isempty(szpos)
        clrvis=colorlegend.Visible;
        szvis=sizelegend.Visible;

        clr_width=clrpos(3);
        clr_vis=strcmp(clrvis,'on');
        if~clr_vis
            clr_width=0;
        end

        slz_width=szpos(3);
        slz_vis=strcmp(szvis,'on');
        if~slz_vis
            slz_width=0;
        end
        if(clr_width<slz_width)&&clr_vis
            diff=slz_width-clr_width;
            clrpos(3)=slz_width;
            clrpos(1)=clrpos(1)-diff;
            colorlegend.PositionInPoints=clrpos;
        elseif(slz_width<clr_width)&&slz_vis
            diff=clr_width-slz_width;
            szpos(3)=clr_width;
            szpos(1)=szpos(1)-diff;
            sizelegend.PositionInPoints=szpos;
        end
    end
end




function datatipText=makeGeobubbleDatatipText(scatterobj,eventobj)





    gb=ancestor(scatterobj,'matlab.graphics.chart.GeographicBubbleChart');
    idx=gb.BubbleObject.SizeIndex(eventobj.DataIndex);

    texLabelFormat='\color[rgb]{.25 .25 .25}\rm';
    texValueFormat='\color[rgb]{0 0.6 1}\bf';

    if gb.UsingTableForData



        datatipText='';
        dtVars=gb.getDataTipVariables();
        for i=1:numel(dtVars)
            dtVar=dtVars{i};





            if strcmp(gb.SourceTable.Properties.DimensionNames{1},dtVar)&&...
                isa(gb.SourceTable,'table')&&isempty(gb.SourceTable.Properties.RowNames)
                valueToDisplay=idx;
            else
                valueToDisplay=gb.SourceTable.(dtVar)(idx,:);
            end
            valueToDisplay=matlab.graphics.datatip.internal.formatDataTipValue(valueToDisplay,'auto');
            datatipText{end+1}=...
            [texLabelFormat,dtVar,' ',texValueFormat,valueToDisplay];%#ok<AGROW>
        end
    else
        LatitudeString=getString(message('MATLAB:graphics:maps:Latitude'));
        LongitudeString=getString(message('MATLAB:graphics:maps:Longitude'));
        datatipText={[texLabelFormat,LatitudeString,' ',texValueFormat,num2str(gb.LatitudeData(idx),4)],...
        [texLabelFormat,LongitudeString,' ',texValueFormat,num2str(gb.LongitudeData(idx),4)]};


        if~isempty(gb.SizeData)
            sizeString=getString(message('MATLAB:Chart:DatatipSize'));
            datatipText{end+1}=[texLabelFormat,sizeString,' ',texValueFormat,num2str(gb.SizeData(idx),4)];
        end

        if~isempty(gb.ColorData)
            colorString=getString(message('MATLAB:Chart:DatatipColor'));
            datatipText{end+1}=[texLabelFormat,colorString,' ',texValueFormat,char(gb.ColorData(idx))];
        end
    end

end
