classdef(ConstructOnLoad,Sealed)Binscatter<matlab.graphics.primitive.Data...
    &matlab.graphics.mixin.Legendable&matlab.graphics.chart.interaction.DataAnnotatable...
    &matlab.graphics.mixin.Selectable&matlab.graphics.mixin.AxesParentable...
    &matlab.graphics.internal.Legacy





























    properties(Dependent,AffectsObject)



        XData=zeros(0,1)




        YData=zeros(0,1)











        NumBins=[1,1]






        XLimits=[0,1]






        YLimits=[0,1]
    end

    properties(Dependent,AffectsObject,NeverAmbiguous)





        NumBinsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Dependent,AffectsObject,AbortSet,NeverAmbiguous)





        XLimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'






        YLimitsMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(AffectsObject,AffectsLegend)




        FaceAlpha matlab.internal.datatype.matlab.graphics.datatype.ZeroToOne=1




        ShowEmptyBins matlab.internal.datatype.matlab.graphics.datatype.on_off='off'
    end

    properties(SetAccess=private,AffectsObject,AffectsLegend)




Values
    end

    properties(Dependent,SetAccess=private,AffectsObject)


XBinEdges



YBinEdges
    end

    properties(Hidden)
        XData_I=zeros(0,1)
        YData_I=zeros(0,1)
        NumBins_I double=[1,1]
XLimits_I
YLimits_I
XBinEdges_I
YBinEdges_I
    end

    properties(Hidden,NeverAmbiguous)
        NumBinsMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        XLimitsMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
        YLimitsMode_I matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto'
    end

    properties(Access=private)
ValuesHiRes

        AutoNumBins double=[1,1]
XBinEdgesHiRes
YBinEdgesHiRes
    end

    properties(Access=?matlab.graphics.chart.primitive.tall.internal.RestartManager)
        RestartManager matlab.graphics.chart.primitive.tall.internal.RestartManager
    end

    properties(Constant,Access=private)
        NumBinsHiRes=750

        NumBinsMax=floor(matlab.graphics.chart.primitive.Binscatter.NumBinsHiRes/3)
    end

    properties(Transient,Access=private)
        Face matlab.graphics.primitive.world.Quadrilateral

        InDoDensityLoop(1,1)logical=false
        Restart(1,1)logical=true

        PauseState matlab.graphics.chart.primitive.tall.internal.PauseState=...
        matlab.graphics.chart.primitive.tall.internal.PauseState.running
        CompletedPartitions logical{matlab.internal.validation.mustBeVector(CompletedPartitions)}=false

        ComputeNumBins(1,1)logical=true


        CurrentCount=0
        CurrentMeanX=0
        CurrentVarX=0
        CurrentMeanY=0
        CurrentVarY=0
    end

    properties(Transient,DeepCopy,Access=private)
        ProgressBar matlab.graphics.shape.internal.ProgressMeter
        SelectionHandle{mustBe_matlab_mixin_Heterogeneous};
    end

    methods

        function hObj=Binscatter(varargin)

            hObj.Face=matlab.graphics.primitive.world.Quadrilateral('Internal',true);



            varargin=extractInputNameValue(hObj,varargin,'Parent');

            varargin=extractInputNameValue(hObj,varargin,'XData','XData_I');
            varargin=extractInputNameValue(hObj,varargin,'YData','YData_I');

            hObj.addDependencyConsumed({'dataspace','hgtransform_under_dataspace',...
            'view','xyzdatalimits','ref_frame','figurecolormap','colorspace'});
            lh=addlistener(hObj,'MarkedClean',@(~,~)markedCleanCallback(hObj));
            lh.Recursive=true;


            if~isempty(varargin)
                set(hObj,varargin{:});
            end


            setInteractionHint(hObj,'DataBrushing',false);

            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');

            import matlab.graphics.chart.primitive.tall.internal.binpickerOnAxis;
            if~isempty(ax)&&strcmp(ax.XLimMode,'manual')
                axxlim=ax.ActiveDataSpace.XLim;
                hObj.XBinEdgesHiRes=binpickerOnAxis(axxlim(1),axxlim(2),...
                hObj.RestartManager.XNpixels,ax.XScale,1);
            end

            if~isempty(ax)&&strcmp(ax.YLimMode,'manual')
                axylim=ax.ActiveDataSpace.YLim;
                hObj.YBinEdgesHiRes=binpickerOnAxis(axylim(1),axylim(2),...
                hObj.RestartManager.YNpixels,ax.YScale,1);
            end

            hObj.ValuesHiRes=zeros(length(hObj.XBinEdgesHiRes)-1,...
            length(hObj.YBinEdgesHiRes)-1);

            if istall(hObj.XData)
                hObj.doTallDensity();
            else
                hObj.doDensity();
            end
        end

        function data=get.XData(hObj)
            data=hObj.XData_I;
        end

        function set.XData(hObj,data)
            if istall(data)~=istall(hObj.YData)
                error(message('MATLAB:binscatter:MixedTallData'));
            end
            if istall(data)
                data=tall.validateType(data,'set.XData',...
                {'numeric','logical','datetime','duration'},1);
                data=lazyValidate(data,{@(x)iscolumn(x)&&(~isnumeric(x)||isreal(x)),...
                'MATLAB:binscatter:InvalidTallData'});
            else
                validateattributes(data,{'numeric','logical','datetime','duration'},...
                {'vector','real'},class(hObj),'XData');
            end
            hObj.XData_I=data;
            if~isempty(hObj.RestartManager)
                hObj.RestartManager.DataLimitsCache(1:2)=NaN;
                hObj.RestartManager.XYDataChanged=true;
            end
            hObj.ComputeNumBins=true;
        end

        function data=get.YData(hObj)
            data=hObj.YData_I;
        end

        function set.YData(hObj,data)
            if istall(data)~=istall(hObj.XData)
                error(message('MATLAB:binscatter:MixedTallData'));
            end
            if istall(data)
                data=tall.validateType(data,'set.YData',...
                {'numeric','logical','datetime','duration'},1);
                data=lazyValidate(data,{@(y)iscolumn(y)&&(~isnumeric(y)||isreal(y)),...
                'MATLAB:binscatter:InvalidTallData'});
            else
                validateattributes(data,{'numeric','logical','datetime','duration'},...
                {'vector','real'},class(hObj),'YData');
            end
            hObj.YData_I=data;
            if~isempty(hObj.RestartManager)
                hObj.RestartManager.DataLimitsCache(3:4)=NaN;
                hObj.RestartManager.XYDataChanged=true;
            end
            hObj.ComputeNumBins=true;
        end

        function xlimits=get.XLimits(hObj)
            if strcmp(hObj.XLimitsMode,'auto')
                xbinedges=hObj.XBinEdges;
                if isempty(xbinedges)
                    xlimits=xbinedges;
                else
                    xlimits=xbinedges([1,end]);
                end
            else
                xlimits=hObj.XLimits_I;
            end
        end

        function set.XLimits(hObj,xlimits)
            if ismember(tall.getClass(hObj.XData),{'datetime','duration'})
                if~(isequal(class(xlimits),class(hObj.XData))...
                    &&numel(xlimits)==2&&issorted(xlimits)&&...
                    all(isfinite(xlimits)))
                    error(message('MATLAB:binscatter:InvalidDatetimeOrDurationXLimits'));
                end
            else
                validateattributes(xlimits,{'numeric'},{'real',...
                'nondecreasing','size',[1,2],'finite'},...
                class(hObj),'XLimits');
            end
            hObj.XLimits_I=xlimits;
            hObj.XLimitsMode_I='manual';
            if~isempty(hObj.RestartManager)
                hObj.RestartManager.DataLimitsCache(1:2)=NaN;
                hObj.RestartManager.XYDataChanged=true;
            end
            hObj.ComputeNumBins=true;
        end

        function xlimitsmode=get.XLimitsMode(hObj)
            xlimitsmode=hObj.XLimitsMode_I;
        end

        function set.XLimitsMode(hObj,xlimitsmode)
            xlimitsold=hObj.XLimits;
            hObj.XLimitsMode_I=xlimitsmode;
            if strcmp(xlimitsmode,'manual')
                hObj.XLimits_I=xlimitsold;
            else
                if~isempty(hObj.RestartManager)
                    hObj.RestartManager.DataLimitsCache(1:2)=NaN;
                    hObj.RestartManager.XYDataChanged=true;
                end
                hObj.ComputeNumBins=true;
            end
        end

        function ylimits=get.YLimits(hObj)
            if strcmp(hObj.YLimitsMode,'auto')
                ybinedges=hObj.YBinEdges;
                if isempty(ybinedges)
                    ylimits=ybinedges;
                else
                    ylimits=ybinedges([1,end]);
                end
            else
                ylimits=hObj.YLimits_I;
            end
        end

        function set.YLimits(hObj,ylimits)
            if ismember(tall.getClass(hObj.XData),{'datetime','duration'})
                if~(isequal(class(ylimits),class(hObj.YData))...
                    &&numel(ylimits)==2&&issorted(ylimits)&&...
                    all(isfinite(ylimits)))
                    error(message('MATLAB:binscatter:InvalidDatetimeOrDurationYLimits'));
                end
            else
                validateattributes(ylimits,{'numeric'},{'real',...
                'nondecreasing','size',[1,2],'finite'},...
                class(hObj),'YLimits');
            end
            hObj.YLimits_I=ylimits;
            hObj.YLimitsMode_I='manual';
            if~isempty(hObj.RestartManager)
                hObj.RestartManager.DataLimitsCache(3:4)=NaN;
                hObj.RestartManager.XYDataChanged=true;
            end
            hObj.ComputeNumBins=true;
        end

        function ylimitsmode=get.YLimitsMode(hObj)
            ylimitsmode=hObj.YLimitsMode_I;
        end

        function set.YLimitsMode(hObj,ylimitsmode)
            ylimitsold=hObj.YLimits;
            hObj.YLimitsMode_I=ylimitsmode;
            if strcmp(ylimitsmode,'manual')
                hObj.YLimits_I=ylimitsold;
            else
                if~isempty(hObj.RestartManager)
                    hObj.RestartManager.DataLimitsCache(3:4)=NaN;
                    hObj.RestartManager.XYDataChanged=true;
                end
                hObj.ComputeNumBins=true;
            end
        end

        function numbins=get.NumBins(hObj)
            numbins=hObj.NumBins_I;
        end

        function set.NumBins(hObj,numbins)
            if isscalar(numbins)
                numbins=[numbins,numbins];
            end
            validateattributes(numbins,{'numeric'},{'integer','positive',...
            'size',[1,2],'<=',hObj.NumBinsMax},...
            class(hObj),'NumBins');
            hObj.NumBins_I=double(numbins);
            hObj.NumBinsMode_I='manual';
            hObj.updateValuesFromHiRes();
        end

        function numbinsmode=get.NumBinsMode(hObj)
            numbinsmode=hObj.NumBinsMode_I;
        end

        function set.NumBinsMode(hObj,numbinsmode)
            if strcmp(numbinsmode,'auto')
                hObj.NumBins_I=hObj.AutoNumBins;
            end
            hObj.updateValuesFromHiRes();
        end

        function xbinedges=get.XBinEdges(hObj)
            xbinedges=matlab.graphics.internal.makeNonNumeric(hObj,...
            hObj.XBinEdges_I,hObj.YBinEdges_I);
        end

        function set.XBinEdges(hObj,xbinedges)
            hObj.XBinEdges_I=xbinedges;
        end

        function ybinedges=get.YBinEdges(hObj)
            [~,ybinedges]=matlab.graphics.internal.makeNonNumeric(hObj,...
            hObj.XBinEdges_I,hObj.YBinEdges_I);
        end

        function set.YBinEdges(hObj,ybinedges)
            hObj.YBinEdges_I=ybinedges;
        end

        function set.Values(hObj,values)
            hObj.Values=values;
            hObj.sendDataChangedEvent();
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

        function hpb=get.ProgressBar(hObj)
            if isempty(hObj.ProgressBar)&&istall(hObj.XData)
                hObj.ProgressBar=matlab.graphics.shape.internal.ProgressMeter(...
                'Progress',0,'ButtonType','pause','Visible','off',...
                'Internal',true);
            end
            hpb=hObj.ProgressBar;
        end

        function set.ProgressBar(hObj,hpb)
            if~isempty(hpb)
                hObj.ProgressBar=hpb;
                hObj.addNode(hObj.ProgressBar);
                lh=addlistener(hObj.ProgressBar,'Action',@(~,~)pauseButtonListener(hObj));
                lh.Recursive=true;
            end
        end

        function set.SelectionHandle(hObj,hsel)
            hObj.SelectionHandle=hsel;
            if~isempty(hObj.SelectionHandle)
                hObj.addNode(hObj.SelectionHandle);


                hObj.SelectionHandle.Description='Binscatter SelectionHandle';
            end
        end
    end

    methods(Hidden)
        function ex=getXYZDataExtents(hObj)
            x=matlab.graphics.chart.primitive.utilities.arraytolimits(hObj.XBinEdges_I);
            y=matlab.graphics.chart.primitive.utilities.arraytolimits(hObj.YBinEdges_I);
            z=[0,NaN,NaN,0];
            ex=[x;y;z];
        end

        function ex=getColorAlphaDataExtents(hObj)
            zdata=hObj.Values;
            ex=[matlab.graphics.chart.primitive.utilities.arraytolimits(zdata);NaN,NaN,NaN,NaN];
        end

        function doUpdate(hObj,us)
            xbinedges=hObj.XBinEdges_I;
            ybinedges=hObj.YBinEdges_I;
            facez=hObj.Values;

            X_scale=us.DataSpace.XScale;
            X_lim=us.DataSpace.XLim;
            Y_scale=us.DataSpace.YScale;
            Y_lim=us.DataSpace.YLim;


            if isa(us.DataSpace,'matlab.graphics.axis.dataspace.CartesianDataSpace')
                xIsInvalid=...
                matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
                X_scale,X_lim,xbinedges);
                yIsInvalid=...
                matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
                Y_scale,Y_lim,ybinedges);
            else
                xIsInvalid=false(size(xbinedges));
                yIsInvalid=false(size(ybinedges));
            end


            if all(xIsInvalid)
                rowKeep=false(1,length(xIsInvalid)-1);
            else
                index=find(~xIsInvalid,1,'last');
                rowKeep=(~xIsInvalid).';
                rowKeep(index)=[];
            end
            if all(yIsInvalid)
                colKeep=false(1,length(yIsInvalid)-1);
            else
                index=find(~yIsInvalid,1,'last');
                colKeep=~yIsInvalid;
                colKeep(index)=[];
            end
            xbinedges=xbinedges(~xIsInvalid);
            ybinedges=ybinedges(~yIsInvalid);

            facez=facez(rowKeep,:);
            facez=facez(:,colKeep);

            dropempty=strcmp(hObj.ShowEmptyBins,'off');
            [x,y,z]=matlab.graphics.chart.primitive.histogram2.internal.create_tile_coordinates(xbinedges,...
            ybinedges,facez,dropempty);

            piter=matlab.graphics.axis.dataspace.XYZPointsIterator;

            piter.XData=x;
            piter.YData=y;
            piter.ZData=z;

            vd=TransformPoints(us.DataSpace,...
            us.TransformUnderDataSpace,...
            piter);

            q=hObj.Face;
            q.VertexData=vd;

            facealpha=hObj.FaceAlpha;
            colortype='truecoloralpha';

            ci=matlab.graphics.axis.colorspace.IndexColorsIterator;

            if dropempty
                ci.Colors=facez(facez>0);
            else
                ci.Colors=facez;
            end
            ci.Colors=ci.Colors(:);
            colorbinding='discrete';


            ci.CDataMapping='scaled';
            cd=TransformColormappedToTrueColor(us.ColorSpace,ci);
            if~isempty(cd)
                cd.Data(4,:)=facealpha*255;
                cddata=cd.Data;
                set(q,'ColorData',cddata,'ColorBinding',colorbinding,...
                'ColorType',colortype,'Visible','on');
            else
                set(q,'ColorBinding','none','Visible','off');
            end


            if strcmp(hObj.Visible,'on')&&strcmp(hObj.Selected,'on')&&...
                strcmp(hObj.SelectionHighlight,'on')
                if isempty(hObj.SelectionHandle)
                    hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight('Internal',true);
                end
                hObj.SelectionHandle.VertexData=vd;
                hObj.SelectionHandle.Visible='on';
            else
                if~isempty(hObj.SelectionHandle)
                    hObj.SelectionHandle.VertexData=[];
                    hObj.SelectionHandle.Visible='off';
                end
            end
        end

        function actualValue=setParentImpl(hObj,proposedValue)



            proposedAxesParent=ancestor(proposedValue,'Axes','node');
            if~isempty(proposedAxesParent)
                if isempty(hObj.RestartManager)
                    hObj.RestartManager=...
                    matlab.graphics.chart.primitive.tall.internal.RestartManager(proposedAxesParent);

                    hObj.RestartManager.Enabled([hObj.RestartManager.ResizeXId...
                    ,hObj.RestartManager.ResizeYId])=false;
                else
                    initialize(hObj.RestartManager,proposedAxesParent);
                end


                hObj.RestartManager.BinEdgesCreateFcn=...
                @matlab.graphics.chart.primitive.tall.internal.binpickerOnAxis;
                hObj.RestartManager.XNpixels=hObj.NumBinsHiRes;
                hObj.RestartManager.YNpixels=hObj.NumBinsHiRes;
            end
            actualValue=proposedValue;
        end

        function graphic=getLegendGraphic(hObj)
            graphic=matlab.graphics.primitive.world.Quadrilateral;

            graphic.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);
            graphic.VertexIndices=[];
            graphic.StripData=[];
            graphic.ColorBinding='object';
            graphic.ColorType='truecoloralpha';


            values=hObj.Values;
            if strcmp(hObj.ShowEmptyBins,'off')
                values=values(values>0);
            end
            [~,index]=max(values(:));

            if isempty(hObj.Face.ColorData)
                graphic.ColorData=[];
                graphic.ColorBinding='none';
            else

                graphic.ColorData=hObj.Face.ColorData(:,index);
            end

            graphic.Visible=hObj.Face.Visible;
        end

        function mcodeConstructor(this,code)








            hAxes=ancestor(this,'matlab.graphics.axis.AbstractAxes','node');
            if isscalar(hAxes.Children)
                hFunc=codegen.codefunction(...
                'Name','hold','CodeRef',code);
                addPreConstructorFunction(code,hFunc);


                hAxesArg=codegen.codeargument(...
                'Value',hAxes,'IsParameter',true);
                addArgin(hFunc,hAxesArg);
                hArg=codegen.codeargument('Value','off');
                addArgin(hFunc,hArg);
            end

            propsToIgnore={'XData','YData'};

            arg1=codegen.codeargument('Name','xdata',...
            'IsParameter',true,'comment','X values');
            addConstructorArgin(code,arg1);
            arg2=codegen.codeargument('Name','ydata',...
            'IsParameter',true,'comment','Y values');
            addConstructorArgin(code,arg2);

            setConstructorName(code,'binscatter');

            ignoreProperty(code,propsToIgnore);


            generateDefaultPropValueSyntax(code);
        end


        function dataTipRows=createDefaultDataTipRows(~)
            dataTipRows=[...
            dataTipTextRow('Value','Values');...
            dataTipTextRow('XBinEdges','XBinEdges');...
            dataTipTextRow('YBinEdges','YBinEdges')];
        end

        function coordinateData=createCoordinateData(hObj,valueSource,dataIndex,~)
            import matlab.graphics.chart.interaction.dataannotatable.internal.CoordinateData;
            coordinateData=CoordinateData.empty(0,1);
            xbinedges=[];
            ybinedges=[];
            values=[];

            switch(valueSource)
            case 'Values'
                if~isempty(hObj.XBinEdges_I)&&~isempty(hObj.YBinEdges_I)
                    values=hObj.Values(dataIndex);
                end
                coordinateData=CoordinateData('Values',values);
            case 'XBinEdges'
                if~isempty(hObj.XBinEdges_I)&&~isempty(hObj.YBinEdges_I)
                    xindex=rem(dataIndex-1,length(hObj.XBinEdges_I)-1)+1;
                    xbinedges=hObj.XBinEdges;
                    if isdatetime(xbinedges)||isduration(xbinedges)
                        xbinedges=['[',char(xbinedges(xindex)),', ',char(xbinedges(xindex+1)),']'];
                    else
                        xbinedges=xbinedges(xindex:xindex+1);
                    end
                end
                coordinateData=CoordinateData('XBinEdges',xbinedges);
            case 'YBinEdges'
                if~isempty(hObj.XBinEdges_I)&&~isempty(hObj.YBinEdges_I)
                    yindex=ceil(dataIndex/(length(hObj.XBinEdges_I)-1));
                    ybinedges=hObj.YBinEdges;
                    if isdatetime(ybinedges)||isduration(ybinedges)
                        ybinedges=['[',char(ybinedges(yindex)),', ',char(ybinedges(yindex+1)),']'];
                    else
                        ybinedges=ybinedges(yindex:yindex+1);
                    end
                end
                coordinateData=CoordinateData('YBinEdges',ybinedges);
            end
        end


        function valueSources=getAllValidValueSources(~)
            valueSources=["Values";"XBinEdges";"YBinEdges"];
        end
    end

    methods(Access=protected,Hidden)
        function group=getPropertyGroups(~)

            group=matlab.mixin.util.PropertyGroup({...
            'NumBins','XBinEdges','YBinEdges',...
            'Values','XLimits','YLimits','FaceAlpha'});
        end


        function descriptors=doGetDataDescriptors(hObj,index,~)
            if~isempty(hObj.XBinEdges_I)&&~isempty(hObj.YBinEdges_I)
                xindex=rem(index-1,length(hObj.XBinEdges_I)-1)+1;
                yindex=ceil(index/(length(hObj.XBinEdges_I)-1));
                xbinedges=hObj.XBinEdges;
                if isdatetime(xbinedges)||isduration(xbinedges)
                    xbinedges=['[',char(xbinedges(xindex)),', ',char(xbinedges(xindex+1)),']'];
                else
                    xbinedges=xbinedges(xindex:xindex+1);
                end
                ybinedges=hObj.YBinEdges;
                if isdatetime(ybinedges)||isduration(ybinedges)
                    ybinedges=['[',char(ybinedges(yindex)),', ',char(ybinedges(yindex+1)),']'];
                else
                    ybinedges=ybinedges(yindex:yindex+1);
                end
                value=hObj.Values(index);
            else
                xbinedges=[];
                ybinedges=[];
                value=[];
            end
            descriptors=[...
            matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Value',value),...
            matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('XBinEdges',...
            xbinedges),...
            matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('YBinEdges',...
            ybinedges)];
        end

        function index=doGetNearestIndex(hObj,index)
            index=max(1,min(index,(length(hObj.XBinEdges_I)-1)*(length(hObj.YBinEdges_I)-1)));
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
            if~isempty(hObj.XBinEdges_I)&&~isempty(hObj.YBinEdges_I)
                nrows=length(hObj.XBinEdges_I)-1;
                if strcmp(direction,'left')
                    if rem(index,nrows)~=1
                        index=index-1;
                    end
                elseif strcmp(direction,'right')
                    if rem(index,nrows)~=0
                        index=index+1;
                    end
                elseif strcmp(direction,'up')
                    if ceil(index/nrows)<length(hObj.YBinEdges_I)-1
                        index=index+nrows;
                    end
                else
                    if ceil(index/nrows)>1
                        index=index-nrows;
                    end
                end
            end

            interpolationFactor=0;
        end

        function point=doGetDisplayAnchorPoint(hObj,index,~)
            if~isempty(hObj.XBinEdges_I)&&~isempty(hObj.YBinEdges_I)
                xindex=rem(index-1,length(hObj.XBinEdges_I)-1)+1;
                yindex=ceil(index/(length(hObj.XBinEdges_I)-1));
                point=matlab.graphics.shape.internal.util.SimplePoint(...
                [mean([hObj.XBinEdges_I(xindex),hObj.XBinEdges_I(xindex+1)])...
                ,mean([hObj.YBinEdges_I(yindex),hObj.YBinEdges_I(yindex+1)])...
                ,0]);
            else


                point=matlab.graphics.shape.internal.util.SimplePoint(...
                [NaN,NaN,0]);
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



        function doCleanup(hObj)
            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');
            if~isempty(ax)&&isvalid(ax)

                hObj.InDoDensityLoop=false;
                if~isPaused(hObj.PauseState)
                    hObj.ProgressBar.Visible='off';


                    hObj.ProgressBar.Progress=0;
                    hObj.CompletedPartitions=false;
                end
            end
        end

        function shouldStopTheCalculation=parallelBinningClient(hObj,info,eventForClient)


            if~isempty(eventForClient)&&~hObj.Restart




                if~isempty(eventForClient.XMin)
                    hObj.RestartManager.DataLimitsCache([1,3])=min(hObj.RestartManager.DataLimitsCache([1,3]),...
                    [eventForClient.XMin,eventForClient.YMin]);
                    hObj.RestartManager.DataLimitsCache([2,4])=max(hObj.RestartManager.DataLimitsCache([2,4]),...
                    [eventForClient.XMax,eventForClient.YMax]);
                end

                hObj.ValuesHiRes=hObj.ValuesHiRes+eventForClient.Values;

                if hObj.ComputeNumBins
                    [binwidthx,hObj.CurrentMeanX,hObj.CurrentVarX]=scottsrule(...
                    hObj.CurrentMeanX,hObj.CurrentVarX,hObj.CurrentCount,...
                    eventForClient.XMean,eventForClient.XVar,eventForClient.XLength);
                    [binwidthy,hObj.CurrentMeanY,hObj.CurrentVarY,hObj.CurrentCount]=...
                    scottsrule(hObj.CurrentMeanY,hObj.CurrentVarY,hObj.CurrentCount,...
                    eventForClient.YMean,eventForClient.YVar,eventForClient.YLength);

                    hObj.AutoNumBins=min(max([round(double(diff(...
                    hObj.RestartManager.DataLimitsCache(1:2)))/double(binwidthx)),...
                    round(double(diff(hObj.RestartManager.DataLimitsCache(3:4)))/double(binwidthy))],1),100);
                    if strcmp(hObj.NumBinsMode,'auto')
                        hObj.NumBins_I=hObj.AutoNumBins;
                    end
                end

                hObj.updateValuesFromHiRes();

                drawnow;
            end
            if isPaused(hObj.PauseState)

                hObj.CompletedPartitions=info.CompletedPartitions;
            end
            shouldStopTheCalculation=hObj.Restart||isPaused(hObj.PauseState);

            if hObj.PauseState=='pausing'
                hObj.PauseState=matlab.graphics.chart.primitive.tall.internal.PauseState.paused;
            end
        end

        function shouldStopTheCalculation=serialBinningClient(hObj,info,...
            eventForClient,xlimmanual,ylimmanual)


            if~isempty(eventForClient)&&~hObj.Restart


                x=eventForClient.X;
                y=eventForClient.Y;


                if strcmp(hObj.XLimitsMode,'manual')
                    xInRangeIndex=x>=hObj.XLimits(1)&x<=hObj.XLimits(2);
                else
                    xInRangeIndex=isfinite(x);
                end
                if strcmp(hObj.YLimitsMode,'manual')
                    yInRangeIndex=y>=hObj.YLimits(1)&y<=hObj.YLimits(2);
                else
                    yInRangeIndex=isfinite(y);
                end
                InRangeIndex=xInRangeIndex&yInRangeIndex;
                x=x(InRangeIndex);
                y=y(InRangeIndex);

                if~isempty(x)&&~isempty(y)
                    [x,y]=matlab.graphics.internal.makeNumeric(hObj,x,y);

                    ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');
                    xIsInvalid=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
                    ax.XScale,ax.XLim,x);
                    yIsInvalid=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
                    ax.YScale,ax.YLim,y);
                    xyIsInvalid=xIsInvalid|yIsInvalid;
                    x(xyIsInvalid)=[];
                    y(xyIsInvalid)=[];

                    [xmin,xmax]=bounds(x);

                    if~isfloat(xmin)
                        xmin=double(xmin);
                        xmax=double(xmax);
                    end
                    [ymin,ymax]=bounds(y);

                    if~isfloat(ymin)
                        ymin=double(ymin);
                        ymax=double(ymax);
                    end
                    hObj.RestartManager.DataLimitsCache([1,3])=min(...
                    hObj.RestartManager.DataLimitsCache([1,3]),[xmin,ymin]);
                    hObj.RestartManager.DataLimitsCache([2,4])=max(...
                    hObj.RestartManager.DataLimitsCache([2,4]),[xmax,ymax]);







                    import matlab.graphics.chart.primitive.tall.internal.stretchBinEdgesMax;
                    import matlab.graphics.chart.primitive.tall.internal.stretchBinEdgesMin;
                    import matlab.graphics.chart.primitive.tall.internal.binpickerOnAxis;
                    if~xlimmanual
                        if isempty(hObj.XBinEdgesHiRes)
                            hObj.XBinEdgesHiRes=binpickerOnAxis(xmin,xmax,...
                            hObj.RestartManager.XNpixels,ax.XScale,0);
                            hObj.ValuesHiRes=zeros(length(hObj.XBinEdgesHiRes)-1,...
                            length(hObj.YBinEdgesHiRes)-1);
                        else
                            [hObj.XBinEdgesHiRes,expandfactor]=stretchBinEdgesMax(xmax,...
                            hObj.XBinEdgesHiRes,hObj.RestartManager.XNpixels,ax.XScale);
                            hObj.ValuesHiRes=stretchBinValues(hObj.ValuesHiRes,expandfactor,1);
                            [hObj.XBinEdgesHiRes,expandfactor]=stretchBinEdgesMin(xmin,...
                            hObj.XBinEdgesHiRes,hObj.RestartManager.XNpixels,ax.XScale);
                            hObj.ValuesHiRes=stretchBinValues(hObj.ValuesHiRes,expandfactor,-1);
                        end
                    end


                    if~ylimmanual
                        if isempty(hObj.YBinEdgesHiRes)
                            hObj.YBinEdgesHiRes=binpickerOnAxis(ymin,ymax,...
                            hObj.RestartManager.YNpixels,ax.YScale,0);
                            hObj.ValuesHiRes=zeros(length(hObj.XBinEdgesHiRes)-1,...
                            length(hObj.YBinEdgesHiRes)-1);
                        else
                            [hObj.YBinEdgesHiRes,expandfactor]=stretchBinEdgesMax(ymax,...
                            hObj.YBinEdgesHiRes,hObj.RestartManager.YNpixels,ax.YScale);
                            hObj.ValuesHiRes=stretchBinValues(hObj.ValuesHiRes,expandfactor,2);
                            [hObj.YBinEdgesHiRes,expandfactor]=stretchBinEdgesMin(ymin,...
                            hObj.YBinEdgesHiRes,hObj.RestartManager.YNpixels,ax.YScale);
                            hObj.ValuesHiRes=stretchBinValues(hObj.ValuesHiRes,expandfactor,-2);
                        end
                    end

                    n=histcounts2(x,y,hObj.XBinEdgesHiRes,hObj.YBinEdgesHiRes);

                    hObj.ValuesHiRes=hObj.ValuesHiRes+n;

                    if hObj.ComputeNumBins
                        [binwidthx,hObj.CurrentMeanX,hObj.CurrentVarX]=scottsrule(...
                        hObj.CurrentMeanX,hObj.CurrentVarX,hObj.CurrentCount,x);
                        [binwidthy,hObj.CurrentMeanY,hObj.CurrentVarY,hObj.CurrentCount]=...
                        scottsrule(hObj.CurrentMeanY,hObj.CurrentVarY,hObj.CurrentCount,y);

                        hObj.AutoNumBins=min(max([round(double(diff(...
                        hObj.RestartManager.DataLimitsCache(1:2)))/double(binwidthx)),...
                        round(double(diff(hObj.RestartManager.DataLimitsCache(3:4)))/double(binwidthy))],1),100);
                        if strcmp(hObj.NumBinsMode,'auto')
                            hObj.NumBins_I=hObj.AutoNumBins;
                        end
                    end

                    hObj.updateValuesFromHiRes();

                    drawnow;
                end
            end
            if isPaused(hObj.PauseState)

                hObj.CompletedPartitions=info.CompletedPartitions;
            end
            shouldStopTheCalculation=hObj.Restart||isPaused(hObj.PauseState);

            if hObj.PauseState=='pausing'
                hObj.PauseState=matlab.graphics.chart.primitive.tall.internal.PauseState.paused;
            end
        end


        function doTallDensity(hObj)


            progressCleanupObj=matlab.bigdata.internal.startMultiExecution(...
            'OutputFunction',@hObj.updateProgress,'PrintBasicInformation',false,'CombineMultiProgress',false);%#ok<NASGU>


            finishup=onCleanup(@()doCleanup(hObj));

            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');

            if~isempty(ax)



                hObj.ProgressBar.Visible='on';
                drawnow nocallbacks;


                hObj.Restart=true;
                while hObj.Restart
                    hObj.Restart=false;


                    if hObj.ComputeNumBins
                        hObj.AutoNumBins=[1,1];
                        hObj.CurrentCount=0;
                        hObj.CurrentMeanX=0;
                        hObj.CurrentVarX=0;
                        hObj.CurrentMeanY=0;
                        hObj.CurrentVarY=0;
                    end









                    completedpartitions=hObj.CompletedPartitions;

                    xdata=hObj.XData;
                    ydata=hObj.YData;
                    [xdata,ydata]=matlab.bigdata.internal.lazyeval.resizeChunksForVisualization(xdata,ydata);

                    hObj.InDoDensityLoop=true;

                    xlimmanual=strcmp(ax.XLimMode,'manual');
                    ylimmanual=strcmp(ax.YLimMode,'manual');
                    if xlimmanual&&ylimmanual







                        workerFcn=@(varargin)parallelBinningWorker(varargin{:},...
                        hObj,ax,completedpartitions);



                        clientFcn=@(varargin)parallelBinningClient(hObj,varargin{:});

                        try
                            hClientforeach(workerFcn,clientFcn,xdata,ydata);
                        catch ME
                            if~(strcmp(ME.identifier,'MATLAB:class:InvalidHandle')||...
                                (~isempty(ME.cause)&&...
                                strcmp(ME.cause{1}.identifier,'MATLAB:class:InvalidHandle')))
                                throw(ME)
                            end
                        end
                    else








                        workerFcn=@(varargin)serialBinningWorker(varargin{:},completedpartitions);



                        clientFcn=@(varargin)serialBinningClient(hObj,varargin{:},...
                        xlimmanual,ylimmanual);

                        try
                            hOrderedClientforeach(workerFcn,clientFcn,xdata,ydata);
                        catch ME
                            if~(strcmp(ME.identifier,'MATLAB:class:InvalidHandle')||...
                                (~isempty(ME.cause)&&...
                                strcmp(ME.cause{1}.identifier,'MATLAB:class:InvalidHandle')))
                                throw(ME)
                            end
                        end
                    end

                    if~isvalid(ax)
                        return;
                    end
                    hObj.InDoDensityLoop=false;

                    if~isPaused(hObj.PauseState)
                        hObj.CompletedPartitions=false;
                    end
                end


                if~isPaused(hObj.PauseState)
                    hObj.ProgressBar.Progress=1;
                    drawnow nocallbacks;
                    hObj.ComputeNumBins=false;
                end


            end
        end


        function doDensity(hObj)
            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');

            if~isempty(ax)


                hObj.RestartManager.Margin=0;

                x=hObj.XData;
                y=hObj.YData;


                if strcmp(hObj.XLimitsMode,'manual')
                    xInRangeIndex=x>=hObj.XLimits(1)&x<=hObj.XLimits(2);
                else
                    xInRangeIndex=isfinite(x);
                end
                if strcmp(hObj.YLimitsMode,'manual')
                    yInRangeIndex=y>=hObj.YLimits(1)&y<=hObj.YLimits(2);
                else
                    yInRangeIndex=isfinite(y);
                end
                InRangeIndex=xInRangeIndex&yInRangeIndex;
                x=x(InRangeIndex);
                y=y(InRangeIndex);

                [x,y]=matlab.graphics.internal.makeNumeric(hObj,x,y);
                xIsInvalid=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
                ax.XScale,ax.XLim,x);
                yIsInvalid=matlab.graphics.chart.primitive.utilities.isInvalidInLogScale(...
                ax.YScale,ax.YLim,y);
                xyIsInvalid=xIsInvalid|yIsInvalid;
                x(xyIsInvalid)=[];
                y(xyIsInvalid)=[];

                [minx,maxx]=bounds(x);

                minx=full(minx);
                maxx=full(maxx);

                if~isfloat(minx)
                    minx=double(minx);
                    maxx=double(maxx);
                end

                import matlab.graphics.chart.primitive.tall.internal.binpickerOnAxis;
                if~strcmp(ax.XLimMode,'manual')
                    if~isempty(x)
                        hObj.XBinEdgesHiRes=binpickerOnAxis(minx,maxx,...
                        hObj.RestartManager.XNpixels,ax.XScale,0);
                    else
                        hObj.XBinEdgesHiRes=binpickerOnAxis(0,1,...
                        hObj.RestartManager.XNpixels,ax.XScale,0);
                    end
                end

                [miny,maxy]=bounds(y);

                miny=full(miny);
                maxy=full(maxy);

                if~isfloat(miny)
                    miny=double(miny);
                    maxy=double(maxy);
                end

                if~strcmp(ax.YLimMode,'manual')
                    if~isempty(y)
                        hObj.YBinEdgesHiRes=binpickerOnAxis(miny,maxy,...
                        hObj.RestartManager.YNpixels,ax.YScale,0);
                    else
                        hObj.YBinEdgesHiRes=binpickerOnAxis(0,1,...
                        hObj.RestartManager.YNpixels,ax.YScale,0);
                    end
                end
                if~isempty(x)&&~isempty(y)
                    hObj.RestartManager.DataLimitsCache([1,3])=...
                    min(hObj.RestartManager.DataLimitsCache([1,3]),[minx,miny]);
                    hObj.RestartManager.DataLimitsCache([2,4])=...
                    max(hObj.RestartManager.DataLimitsCache([2,4]),[maxx,maxy]);
                end

                hObj.InDoDensityLoop=true;

                hObj.ValuesHiRes=histcounts2(x,y,hObj.XBinEdgesHiRes,hObj.YBinEdgesHiRes);

                if hObj.ComputeNumBins
                    [binwidthx,hObj.CurrentMeanX,hObj.CurrentVarX]=scottsrule(...
                    0,0,0,x);
                    [binwidthy,hObj.CurrentMeanY,hObj.CurrentVarY,hObj.CurrentCount]=...
                    scottsrule(0,0,0,y);

                    hObj.AutoNumBins=min(max([round(double(diff(...
                    hObj.RestartManager.DataLimitsCache(1:2)))/double(binwidthx)),...
                    round(double(diff(hObj.RestartManager.DataLimitsCache(3:4)))/double(binwidthy))],1),100);
                    if strcmp(hObj.NumBinsMode,'auto')
                        hObj.NumBins_I=hObj.AutoNumBins;
                    end
                end

                hObj.updateValuesFromHiRes();
                hObj.InDoDensityLoop=false;

                hObj.ComputeNumBins=false;
            end
        end

        function markedCleanCallback(hObj)
            if~isempty(hObj.RestartManager)
                ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');



                oldaxeslimits=hObj.RestartManager.AxesLimitsCache;
                [~,hObj.RestartManager,xbinedgeshires,...
                ybinedgeshires,checkresults]=check(hObj.RestartManager,...
                ax,hObj.XBinEdgesHiRes,hObj.YBinEdgesHiRes);

                checkresults(1)=checkresults(1)&&zoomPastThreshold(hObj.XBinEdgesHiRes,...
                hObj.NumBins(1),ax.ActiveDataSpace.XLim,ax.XScale);
                checkresults(2)=checkresults(2)&&zoomPastThreshold(hObj.YBinEdgesHiRes,...
                hObj.NumBins(2),ax.ActiveDataSpace.YLim,ax.YScale);
                import matlab.graphics.chart.primitive.tall.internal.isPan1D;
                if any(checkresults)
                    hObj.XBinEdgesHiRes=xbinedgeshires;
                    hObj.YBinEdgesHiRes=ybinedgeshires;
                    if istall(hObj.XData)

                        hObj.Restart=true;

                        hObj.PauseState=matlab.graphics.chart.primitive.tall.internal.PauseState.running;
                        hObj.ProgressBar.ButtonType='pause';
                        hObj.ProgressBar.BarColor=[0,0.6,1.0];
                        hObj.CompletedPartitions=false;
                    end

                    hObj.ValuesHiRes=zeros(length(xbinedgeshires)-1,...
                    length(ybinedgeshires)-1);



                    if~hObj.InDoDensityLoop
                        if istall(hObj.XData)
                            hObj.doTallDensity();
                        else
                            hObj.doDensity();
                        end
                    end
                elseif~isPan1D(ax.ActiveDataSpace.XLim,oldaxeslimits(1:2),ax.XScale)...
                    ||~isPan1D(ax.ActiveDataSpace.YLim,oldaxeslimits(3:4),ax.YScale)

                    hObj.updateValuesFromHiRes();
                end
            end
        end

        function updateValuesFromHiRes(hObj)
            xHiRes=hObj.XBinEdgesHiRes;
            yHiRes=hObj.YBinEdgesHiRes;
            zHiRes=hObj.ValuesHiRes;
            nbinsXHiRes=length(xHiRes)-1;
            nbinsYHiRes=length(yHiRes)-1;

            nbinsdisplayx=hObj.NumBins(1);
            nbinsdisplayy=hObj.NumBins(2);
            if~isempty(xHiRes)&&~isempty(yHiRes)
                ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes','node');

                [axxlim,axylim]=matlab.graphics.internal.makeNumeric(hObj,ax.ActiveDataSpace.XLim,ax.ActiveDataSpace.YLim);
                if strcmp(ax.XLimMode,'manual')
                    if strcmp(ax.XScale,'log')
                        nbinsx=floor(nbinsdisplayx*(diff(log10(abs(xHiRes([1,end]))))...
                        /diff(log10(abs(axxlim)))));
                    else
                        nbinsx=floor(nbinsdisplayx*((xHiRes(end)-xHiRes(1))/diff(axxlim)));
                    end

                    nbinsx=max(1,min(nbinsx,nbinsXHiRes));
                else
                    nbinsx=nbinsdisplayx;
                end

                if strcmp(ax.YLimMode,'manual')
                    if strcmp(ax.YScale,'log')
                        nbinsy=floor(nbinsdisplayy*(diff(log10(abs(yHiRes([1,end]))))...
                        /diff(log10(abs(axylim)))));
                    else
                        nbinsy=floor(nbinsdisplayy*((yHiRes(end)-yHiRes(1))/diff(axylim)));
                    end

                    nbinsy=max(1,min(nbinsy,nbinsYHiRes));
                else
                    nbinsy=nbinsdisplayy;
                end

                [hObj.XBinEdges,blocksizex,paddingx]=getBinEdges(xHiRes,nbinsx,ax.XScale);
                [hObj.YBinEdges,blocksizey,paddingy]=getBinEdges(yHiRes,nbinsy,ax.YScale);


                zHiResPadded=[zeros(paddingx(1),size(zHiRes,2)+sum(paddingy));...
                zeros(size(zHiRes,1),paddingy(1)),zHiRes,zeros(size(zHiRes,1),paddingy(2));...
                zeros(paddingx(2),size(zHiRes,2)+sum(paddingy))];
                hObj.Values=blocksum(zHiResPadded,[blocksizex,blocksizey]);

            else
                hObj.XBinEdges=xHiRes;
                hObj.YBinEdges=yHiRes;
                hObj.Values=zHiRes;
            end
        end

        function pauseButtonListener(hObj)
            if isPaused(hObj.PauseState)
                pausecomplete=hObj.PauseState=='paused';
                hObj.PauseState=matlab.graphics.chart.primitive.tall.internal.PauseState.running;
                hObj.ProgressBar.ButtonType='pause';

                hObj.ProgressBar.BarColor=[0,0.6,1.0];



                if pausecomplete
                    hObj.doTallDensity();
                end
            else
                hObj.PauseState=matlab.graphics.chart.primitive.tall.internal.PauseState.pausing;
                hObj.ProgressBar.ButtonType='play';

                hObj.ProgressBar.BarColor=[0.8863,0.2392,0.1765];
            end
        end

        function index=localGetNearestPoint(hObj,position,isPixel)


            [x,y,z]=matlab.graphics.chart.primitive.histogram2.internal.create_tile_coordinates(hObj.XBinEdges_I,...
            hObj.YBinEdges_I,hObj.Values,false);
            verts=[x(:),y(:),z(:)];

            faces=transpose(reshape(1:size(verts,1),4,[]));

            pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();

            [vertexindex,faceindex]=pickUtils.nearestFacePoint(hObj,position,isPixel,...
            faces,verts);
            if~isempty(faceindex)
                index=faceindex;
            else
                index=ceil(vertexindex/4);
            end
        end

        function updateProgress(hObj,progressValue,passIndex,numPasses)

            progressValue=(passIndex-1+progressValue)/numPasses;
            progressValue=max(progressValue,mean(hObj.CompletedPartitions));
            if isvalid(hObj)&&isvalid(hObj.ProgressBar)&&~isPaused(hObj.PauseState)
                hObj.ProgressBar.Progress=progressValue;
                drawnow nocallbacks;
            end
        end
    end
end

function values=stretchBinValues(values,expandfactor,dim)


    sz=size(values);

    expandfactor=min(expandfactor,sz(abs(dim)));
    if expandfactor>1
        switch dim
        case-1
            values=blocksum(values,[expandfactor,1]);
            values=[zeros(sz(1)-size(values,1),sz(2));values];
        case 1
            values=blocksum(values,[expandfactor,1]);
            values=[values;zeros(sz(1)-size(values,1),sz(2))];
        case-2
            values=blocksum(values,[1,expandfactor]);
            values=[zeros(sz(1),sz(2)-size(values,2)),values];
        case 2
            values=blocksum(values,[1,expandfactor]);
            values=[values,zeros(sz(1),sz(2)-size(values,2))];
        end
    end
end

function x=blocksum(x,blocksize)
    sz=size(x);


    blksz1=blocksize(1);
    if blksz1>1

        x=[x;...
        zeros(rem(blksz1-rem(sz(1),blksz1),blksz1),sz(2))];

        x=reshape(sum(reshape(x,blksz1,[]),1),[],sz(2));
    end

    sz=size(x);


    blksz2=blocksize(2);
    if blksz2>1

        x=[x,...
        zeros(sz(1),rem(blksz2-rem(sz(2),blksz2),blksz2))];

        x=reshape(sum(reshape(x,sz(1),blksz2,[]),2),sz(1),[]);
    end
end









function[binedges,blocksize,padding]=getBinEdges(binedgesHiRes,nbins,scale)
    nbinsHiRes=length(binedgesHiRes)-1;
    blocksize=max(ceil(nbinsHiRes/nbins),1);

    if rem(nbins,2)==0


        nbinsInternalFront=floor(ceil(nbinsHiRes/2)/blocksize);


        nbinsExternalFront=nbins/2-nbinsInternalFront;
        firstInternalBinEdge=(ceil(nbinsHiRes/2)+1)-(nbinsInternalFront*blocksize);

        nbinsInternalBack=floor(floor(nbinsHiRes/2)/blocksize);
        nbinsExternalBack=nbins/2-nbinsInternalBack;
        lastInternalBinEdge=(ceil(nbinsHiRes/2)+1)+(nbinsInternalBack*blocksize);

    elseif rem(nbinsHiRes,2)==0
        nbinsInternalFront=floor((nbinsHiRes/2-floor(blocksize/2))/blocksize);
        nbinsExternalFront=(nbins-1)/2-nbinsInternalFront;
        firstInternalBinEdge=(nbinsHiRes/2-floor(blocksize/2)+1)-(nbinsInternalFront*blocksize);

        nbinsInternalBack=floor((nbinsHiRes/2-ceil(blocksize/2))/blocksize);
        nbinsExternalBack=(nbins-1)/2-nbinsInternalBack;
        lastInternalBinEdge=(nbinsHiRes/2+ceil(blocksize/2)+1)+(nbinsInternalBack*blocksize);

    else
        nbinsInternalFront=floor((ceil(nbinsHiRes/2)-ceil(blocksize/2))/blocksize);
        nbinsExternalFront=(nbins-1)/2-nbinsInternalFront;
        firstInternalBinEdge=(ceil(nbinsHiRes/2)-ceil(blocksize/2)+1)-(nbinsInternalFront*blocksize);

        nbinsInternalBack=floor((floor(nbinsHiRes/2)-floor(blocksize/2))/blocksize);
        nbinsExternalBack=(nbins-1)/2-nbinsInternalBack;
        lastInternalBinEdge=(ceil(nbinsHiRes/2)+floor(blocksize/2)+1)+(nbinsInternalBack*blocksize);

    end

    if strcmp(scale,'log')
        binwidthHiRes=diff(log10(abs(binedgesHiRes(1:2))));
        binedges=[sign(binedgesHiRes(1)).*10.^(log10(abs(binedgesHiRes(firstInternalBinEdge)))...
        -(nbinsExternalFront:-1:1)*blocksize*binwidthHiRes),...
        binedgesHiRes(firstInternalBinEdge:blocksize:lastInternalBinEdge),...
        sign(binedgesHiRes(1)).*10.^(log10(abs(binedgesHiRes(lastInternalBinEdge)))...
        +(1:nbinsExternalBack)*blocksize*binwidthHiRes)];
    else
        binwidthHiRes=binedgesHiRes(2)-binedgesHiRes(1);
        binedges=[binedgesHiRes(firstInternalBinEdge)-(nbinsExternalFront:-1:1)*blocksize*binwidthHiRes,...
        binedgesHiRes(firstInternalBinEdge:blocksize:lastInternalBinEdge),...
        binedgesHiRes(lastInternalBinEdge)+(1:nbinsExternalBack)*blocksize*binwidthHiRes];
    end
    padding=[nbinsExternalFront*blocksize-(firstInternalBinEdge-1),...
    nbinsExternalBack*blocksize-(nbinsHiRes+1-lastInternalBinEdge)];
end

function tf=zoomPastThreshold(binedges,nbins,axlimits,scale)
    tf=false;
    if~isempty(binedges)
        if strcmp(scale,'log')
            axisrange=diff(log10(abs(axlimits)));
            binrange=diff(log10(abs(binedges([1,end]))));
        else
            axisrange=diff(axlimits);
            binrange=binedges(end)-binedges(1);
        end
        tf=3*axisrange<binrange*nbins/(length(binedges)-1);
    end
end

function[binwidth,newmean,newvar,newcount]=scottsrule(oldmean,oldvar,oldcount,...
    chunkmean,chunkvar,chunkcount)
    if nargin==4
        x=chunkmean;
        if~isfloat(x)
            x=double(x);
        end
        chunkmean=mean(x);
        chunkvar=var(x);
        chunkcount=length(x);
    end
    newcount=oldcount+chunkcount;
    newmean=(oldmean*oldcount+chunkmean*chunkcount)./newcount;
    newvar=(oldcount*oldvar+chunkcount*chunkvar)./newcount+...
    (oldmean-chunkmean).^2.*((oldcount./newcount)*(chunkcount./newcount));
    newstd=sqrt(newvar);
    binwidth=(3.5*newstd)/(newcount^(1/4));
end

function[shouldStopThisPartition,eventForClient]=parallelBinningWorker(...
    info,x,y,hObj,ax,completedpartitions)









    xbinedgeshires=hObj.XBinEdgesHiRes;
    ybinedgeshires=hObj.YBinEdgesHiRes;


    completedpartitions=repmat(completedpartitions,1,...
    info.NumPartitions/length(completedpartitions));

    if completedpartitions(info.PartitionId)
        shouldStopThisPartition=true;
        eventForClient=[];
        return;
    end

    if strcmp(hObj.XLimitsMode,'manual')
        xInRangeIndex=x>=hObj.XLimits(1)&x<=hObj.XLimits(2);
    else
        xInRangeIndex=isfinite(x);
    end
    if strcmp(hObj.YLimitsMode,'manual')
        yInRangeIndex=y>=hObj.YLimits(1)&y<=hObj.YLimits(2);
    else
        yInRangeIndex=isfinite(y);
    end
    InRangeIndex=xInRangeIndex&yInRangeIndex;
    x=x(InRangeIndex);
    y=y(InRangeIndex);

    shouldStopThisPartition=info.IsLastChunk;





    if isempty(x)
        eventForClient=[];
        return;
    end


    [x,y]=matlab.graphics.internal.makeNumeric(ax,x,y);
    n=histcounts2(x,y,xbinedgeshires,ybinedgeshires);

    eventForClient.Values=n;


    [eventForClient.XMin,eventForClient.XMax]=bounds(x);
    [eventForClient.YMin,eventForClient.YMax]=bounds(y);


    if~isfloat(x)
        x=double(x);
    end
    eventForClient.XMean=mean(x);
    eventForClient.XVar=var(x);
    eventForClient.XLength=length(x);
    if~isfloat(y)
        y=double(y);
    end
    eventForClient.YMean=mean(y);
    eventForClient.YVar=var(y);
    eventForClient.YLength=length(y);
end

function[shouldStopThisPartition,eventForClient]=serialBinningWorker(...
    info,x,y,completedpartitions)







    completedpartitions=repmat(completedpartitions,1,...
    info.NumPartitions/length(completedpartitions));

    if completedpartitions(info.PartitionId)
        shouldStopThisPartition=true;
        eventForClient=[];
        return;
    end

    eventForClient.X=x;
    eventForClient.Y=y;

    shouldStopThisPartition=info.IsLastChunk;
end

function mustBe_matlab_mixin_Heterogeneous(input)
    if~isa(input,'matlab.mixin.Heterogeneous')&&~isempty(input)
        throwAsCaller(MException('MATLAB:type:PropInitialClsMismatch','%s',message('MATLAB:type:PropInitialClsMismatch','matlab.mixin.Heterogeneous').getString));
    end
end
