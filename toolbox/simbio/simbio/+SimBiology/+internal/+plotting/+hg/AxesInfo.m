classdef AxesInfo<SimBiology.internal.plotting.hg.HGObjectInfo




    methods(Access=public)
        function obj=AxesInfo(input)
            if nargin>0
                dims=size(input);
                obj(dims(1),dims(2))=SimBiology.internal.plotting.hg.AxesInfo();
                if isstruct(input)
                    arrayfun(@(ax,in)set(ax,'handle',obj.returnValidHandle(in.handle),...
                    'props',SimBiology.internal.plotting.hg.AxesProperties(in.props)),...
                    obj,input);



                elseif isa(input(1),'matlab.graphics.axis.Axes')
                    arrayfun(@(ax,in)set(ax,'handle',obj.returnValidHandle(in),...
                    'props',SimBiology.internal.plotting.hg.AxesProperties()),...
                    obj,input);
                else

                    obj=obj.configureFromAxesParent(input);
                end
            else
                obj.props=SimBiology.internal.plotting.hg.AxesProperties();
            end
        end

        function info=getStruct(obj)

            if isempty(obj(1).handle)
                figurePosition=[];
            else
                parent=obj.getParentFigureForAxes(obj(1).handle);
                figurePosition=parent.Position;
            end
            info=arrayfun(@(ax)struct('handle',ax.convertHandleToDouble(),...
            'props',ax.props.getStruct(),...
            'position',ax.getSingleAxesPosition(ax.handle,figurePosition),...
            'patches',ax.getSingleAxesPatches(ax.handle)),obj);

            info=[info(:)];
        end

        function h=getEmptyHandle(obj)
            h=matlab.graphics.axis.Axes.empty;
        end
    end

    methods(Access=private)
        function obj=configureFromAxesParent(obj,axesParent)
            hgAxes=obj.getAllPlotAxesHandles(axesParent);
            for i=numel(hgAxes):-1:1
                obj(i)=SimBiology.internal.plotting.hg.AxesInfo;
                obj(i).configureSingleObjectFromHGAxes(hgAxes(i));
            end
        end

        function configureSingleObjectFromHGAxes(obj,hgAxes)
            obj.handle=hgAxes;
            obj.props=SimBiology.internal.plotting.hg.AxesProperties(hgAxes);
        end
    end

    methods(Access=public)
        function updatePropertiesFromHGAxes(obj)
            for i=1:numel(obj)

                if obj(i).isValid()
                    set(obj(i),'props',SimBiology.internal.plotting.hg.AxesProperties(obj(i).handle));
                end
            end
        end
    end

    methods(Static,Access=public)


        function info=getSingleAxesPositionInfo(ax,figurePosition)
            position=SimBiology.internal.plotting.hg.AxesInfo.getSingleAxesPosition(ax,figurePosition);
            patches=SimBiology.internal.plotting.hg.AxesInfo.getSingleAxesPatches(ax);
            info=struct('handle',double(ax),'position',position,'patches',patches);
        end

        function position=getSingleAxesPosition(ax,figurePosition)
            if isempty(ax)||~ishandle(ax)
                position=[];
            else
                apos=ax.InnerPosition;
                position.width=apos(3);
                position.left=apos(1);
                position.right=apos(1)+position.width;
                position.height=apos(4);
                position.top=figurePosition(4)-(position.height+apos(2));
                position.bottom=position.top+position.height;
            end
        end

        function patches=getSingleAxesPatches(ax)
            if isempty(ax)||~ishandle(ax)
                patches=[];
            else
                patches=SimBiology.internal.plotting.hg.AxesInfo.getBarInfo(ax);
            end
        end

        function hgAxes=getAllPlotAxesHandles(axesParent)


            hgAxes=findobj(axesParent,'Type','axes','-not','Tag',SimBiology.internal.plotting.sbioplot.SBioPlotObject.BACKGROUND_AXES_TAG);



            if isa(axesParent,'matlab.ui.Figure')







                numRows=axesParent.UserData.gridDimensions(1);
                numCols=axesParent.UserData.gridDimensions(2);


                [positionsSortedByY,sortedByRowIdx]=sortrows(vertcat(hgAxes.Position),2,'descend');
                hgAxes=hgAxes(sortedByRowIdx);


                for row=numRows:-1:1
                    rowIdxOffset=(row-1)*numCols;
                    [~,sortedByColIdx]=sort(positionsSortedByY((1:numCols)+rowIdxOffset,1),'ascend');
                    hgAxes((1:numCols)+rowIdxOffset)=hgAxes(sortedByColIdx+rowIdxOffset);
                end
            else
                layouts=[hgAxes.Layout];
                [~,idx]=sort([layouts.Tile]);
                hgAxes=hgAxes(idx);
            end
        end

        function parent=getParentFigureForAxes(ax)

            parent=ax;
            while~isa(parent,'matlab.ui.Figure')
                parent=parent.Parent;
            end
        end
    end




    methods(Access=public)
        function handles=getHandles(obj)
            handles=arrayfun(@(ax)ax.handle,obj);
        end

        function handles=getValidHandles(obj)

            handles=[obj.handle];
            idx=arrayfun(@(h)ishandle(h),handles);
            handles=handles(idx);
        end

        function validObj=getValidAxesInfo(obj)
            idx=isValid(obj);
            validObj=obj(idx);
        end

        function flag=isValid(obj)
            flag=arrayfun(@(ax)(~isempty(ax.handle)&&ishandle(ax.handle)),obj);
        end

        function selectedObj=selectByHandle(obj,axesHandles)
            validAxes=obj.getValidAxesInfo();
            idx=arrayfun(@(ax)(any(arrayfun(@(h)(ax.handle==h),axesHandles))),validAxes);
            selectedObj=validAxes(idx);
        end

        function flag=isHistogramAxes(obj)
            flag=arrayfun(@(ax)isa(ax.handle.Children,'matlab.graphics.chart.primitive.Histogram')||...
            isa(ax.handle.Children,'matlab.graphics.chart.primitive.categorical.Histogram'),...
            obj);
        end

        function flag=isNumericHistogramAxes(obj)
            flag=arrayfun(@(ax)isa(ax.handle.Children,'matlab.graphics.chart.primitive.Histogram'),...
            obj);
        end

        function[autoMin,autoMax]=isAutoLimits(obj,useX)

            if useX
                autoMin=strcmp(obj.props.XMin,'auto');
                autoMax=strcmp(obj.props.XMax,'auto');
            else
                autoMin=strcmp(obj.props.YMin,'auto');
                autoMax=strcmp(obj.props.YMax,'auto');
            end
        end
    end




    methods(Access=public)
        function updateHandles(obj,handles)

            arrayfun(@(a,h)set(a,'handle',h),obj,handles);
        end

        function resetLabels(obj)
            arrayfun(@(ax)ax.props.resetLabels(),obj);
        end

        function setProperty(obj,property,values)
            if iscell(values)

                arrayfun(@(ax,val)set(ax.props,property,val{1}),obj,values);
            else

                arrayfun(@(ax)set(ax.props,property,values),obj);
            end
        end

        function setProperties(obj,inputStruct)
            if numel(obj)==numel(inputStruct)

                for i=1:numel(obj)
                    obj(i).props.set(inputStruct(i));
                end
            else

                for i=1:numel(obj)
                    obj(i).props.set(inputStruct);
                end
            end
        end

        function copyProperties(obj,axesToCopy)
            arrayfun(@(ax)set(ax,'props',SimBiology.internal.plotting.hg.AxesProperties(axesToCopy.props)),obj);
        end
    end




    methods(Access=public)
        function format(obj,applyEmptyLabels)

            validObj=obj.getValidAxesInfo();

            validObj.applyAxesProperties();
            validObj.applyLabels(applyEmptyLabels);
        end

        function formatProperties(obj)

            validObj=obj.getValidAxesInfo();
            validObj.applyAxesProperties();
        end

        function formatLabels(obj)

            validObj=obj.getValidAxesInfo();
            validObj.applyLabels(true);
        end

        function formatProperty(obj,property)

            validObj=obj.getValidAxesInfo();

            property={property};
            values=validObj.getSetValuesInputCell(property);
            set(validObj.getHandles(),property,values);
        end

        function configureProperty(obj,property,value)



            if any(strcmp(property,{'XMin','XMax'}))
                set([obj.props],'IsZoomedX',false);
            elseif any(strcmp(property,{'YMin','YMax'}))
                set([obj.props],'IsZoomedY',false);
            end

            arrayfun(@(ax)set(ax.props,property,value),obj);
            obj.applyPropertyValue(property,value);
        end

        function applyAxesLimits(obj,useX,updateY,applyAuto)
            if applyAuto
                obj.resetAxesLimitsToAuto(useX)
            end

            arrayfun(@(ax)ax.applyAxesLimitsSingleObject(useX,updateY),obj);
        end

        function resetAxesLimitsToAuto(obj,useX)
            if useX
                modeProp='XLimMode';
            else
                modeProp='YLimMode';
            end



            refLines=getReferenceLines(obj);
            set(refLines,'Visible',false);


            set(obj.getValidHandles(),modeProp,'auto');


            drawnow;


            set(refLines,'Visible',true);
        end

        function applyAxesLimitsSingleObject(obj,useX,updateY)
            if(useX&&obj.props.IsZoomedX)||(~useX&&obj.props.IsZoomedY)
                return;
            end

            if useX
                minProp='XMin';
                maxProp='XMax';
                limProp='XLim';
            else
                minProp='YMin';
                maxProp='YMax';
                limProp='YLim';
            end


            [autoMin,autoMax]=obj.isAutoLimits(useX);


            if~autoMin||~autoMax

                if~autoMin&&~autoMax
                    set(obj.handle,limProp,[obj.props.getValue(minProp),obj.props.getValue(maxProp)]);

                else
                    axLim=get(obj.handle,limProp);
                    if autoMin
                        maxLim=obj.props.getValue(maxProp);
                        if maxLim<=axLim(1)
                            warning(message('SimBiology:Plotting:INVALID_MAX_AXIS_LIMIT'));
                            set(obj.props,maxProp,'auto');
                        else
                            set(obj.handle,limProp,[axLim(1),maxLim]);
                        end
                    else
                        minLim=obj.props.getValue(minProp);
                        if minLim>=axLim(2)
                            warning(message('SimBiology:Plotting:INVALID_MIN_AXIS_LIMIT'));
                            set(obj.props,minProp,'auto');
                        else
                            set(obj.handle,limProp,[minLim,axLim(2)]);
                        end
                    end
                end
            end


            if useX&&updateY
                [autoYMin,autoYMax]=obj.isAutoLimits(false);
                if autoYMin||autoYMax
                    obj.applyAxesLimitsSingleObject(false,false);
                end
            end
        end

        function refLines=getReferenceLines(obj)
            refLines=findobj(obj.getValidHandles(),'Tag',SimBiology.internal.plotting.sbioplot.SBioPlotObject.REFERENCE_LINE_TAG);
        end

    end


    methods(Access=private)
        function applyAxesProperties(obj)


            props=SimBiology.internal.plotting.hg.AxesProperties.getAxesProperties();
            values=obj.getSetValuesInputCell(props);
            set(obj.getHandles(),props,values);
        end

        function applyLabels(obj,applyEmptyLabels)

            props=SimBiology.internal.plotting.hg.AxesProperties.getLabelProperties();
            cellfun(@(prop)obj.applyLabel(prop,applyEmptyLabels),props);
        end

        function applyLabel(obj,labelProperty,applyEmptyLabels)
            arrayfun(@(ax)ax.applyLabelToSingleObject(labelProperty,applyEmptyLabels),obj);
        end

        function applyLabelToSingleObject(obj,labelProperty,applyEmptyLabels)

            label=obj.props.(labelProperty);
            if~isempty(label)||applyEmptyLabels
                set(obj.handle.(labelProperty),'String',label,'Interpreter','None');
            end
        end

        function applyPropertyValue(obj,property,value)

            switch(property)
            case{'Title','XLabel','YLabel'}
                obj.applyLabelValue(property,value);
            case{'XMin','XMax'}
                obj.applyAxesLimits(true,true,true);
            case{'YMin','YMax'}
                obj.applyAxesLimits(false,false,true);
            otherwise
                obj.applyAxesPropertyValue(property,value);
            end
        end

        function applyAxesPropertyValue(obj,property,value)

            set(obj.getValidHandles(),property,value);
        end

        function applyLabelValue(obj,labelProperty,labelValue)

            arrayfun(@(ax)set(ax.handle.(labelProperty),'String',labelValue,'Interpreter','None'),obj);
        end

        function values=getSetValuesInputCell(obj,properties)
            numObj=numel(obj);
            numProps=numel(properties);
            values=cell(numObj,numProps);
            for i=1:numObj
                for j=1:numProps
                    values{i,j}=obj(i).props.getValue(properties{j});
                end
            end
        end
    end




    methods(Static,Access=private)
        function out=getBarInfo(ax,varargin)
            if isempty(varargin)
                hbar=get(ax,'Children');
            else
                hbar=varargin{1};
            end

            f=ax.Parent;

            if isempty(hbar)
                out=[];
                return;
            end

            type=hbar(1).Type;
            if(strcmp(type,'surface')||strcmp(type,'bar'))


                drawnow;
                if strcmp(type,'surface')
                    out=SimBiology.internal.plotting.hg.AxesInfo.getBar3PositionInfo(f,ax,flipud(hbar));
                elseif strcmp(type,'bar')
                    if strcmp(hbar(1).Horizontal,'off')
                        out=SimBiology.internal.plotting.hg.AxesInfo.getBarPositionInfo(f,ax,hbar);
                    else
                        out=SimBiology.internal.plotting.hg.AxesInfo.getHBarPositionInfo(f,ax,hbar);
                    end
                end
            else
                out=[];
                return;
            end
        end

        function out=getBar3PositionInfo(f,ax,hbar)

            x=[];
            for i=1:length(hbar)
                xdata=get(hbar(i),'XData');
                xdata=xdata(1,:);
                xdata=xdata(~isnan(xdata));
                x=[x,xdata];%#ok<AGROW>
            end


            y=get(hbar(1),'YData');
            y=y(:,1);
            y=y(~isnan(y));


            [info,x,y]=SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertDataSpaceToPixelUnits(f,ax,x,y);

            xnames=ax.UserData.SensitivityArgs.Inputs;
            ynames=flip(ax.UserData.SensitivityArgs.Outputs);
            out=SimBiology.internal.plotting.hg.AxesInfo.initBarPositionStruct(length(xnames)*length(ynames));

            xcount=1;
            count=1;


            for i=1:length(xnames)
                x1=x(xcount);
                x2=x(xcount+1);
                xcount=xcount+2;
                xname=xnames{i};

                ycount=1;
                for j=1:length(ynames)
                    y1=y(ycount);
                    y2=y(ycount+1);
                    ycount=ycount+2;
                    yname=ynames{j};
                    out(count)=SimBiology.internal.plotting.hg.AxesInfo.calculateBarPosition(xname,yname,info,x1,x2,y1,y2);
                    count=count+1;
                end
            end
        end

        function out=getBarPositionInfo(f,ax,hbar)

            width=get(hbar,'BarWidth');
            hwidth=width/2;
            xdata=get(hbar,'XData');
            x=zeros(1,2*length(xdata));
            count=1;
            for i=1:length(xdata)
                x(count)=xdata(i)-hwidth;
                x(count+1)=xdata(i)+hwidth;
                count=count+2;
            end


            ydata=get(hbar,'YData');
            y=zeros(1,2*length(ydata));
            count=2;
            for i=1:length(ydata)
                y(count)=ydata(i);
                count=count+2;
            end


            [info,x,y]=SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertDataSpaceToPixelUnits(f,ax,x,y);

            xnames=ax.UserData.SensitivityArgs.Inputs;
            yname=ax.UserData.SensitivityArgs.Outputs{1};
            out=SimBiology.internal.plotting.hg.AxesInfo.initBarPositionStruct(length(xnames));

            xcount=1;
            count=1;


            for i=1:length(xnames)
                x1=x(xcount);
                x2=x(xcount+1);
                y1=y(xcount);
                y2=y(xcount+1);
                xname=xnames{i};
                out(count)=SimBiology.internal.plotting.hg.AxesInfo.calculateBarPosition(xname,yname,info,x1,x2,y1,y2);

                xcount=xcount+2;
                count=count+1;
            end
        end

        function out=getHBarPositionInfo(f,ax,hbar)

            width=get(hbar,'BarWidth');
            hwidth=width/2;
            xdata=get(hbar,'XData');
            y=zeros(1,2*length(xdata));
            count=1;
            for i=1:length(xdata)
                y(count)=xdata(i)-hwidth;
                y(count+1)=xdata(i)+hwidth;
                count=count+2;
            end


            ydata=get(hbar,'YData');
            x=zeros(1,2*length(ydata));
            count=2;
            for i=1:length(ydata)
                x(count)=ydata(i);
                count=count+2;
            end


            [info,x,y]=SimBiology.internal.plotting.sbioplot.SBioPlotObject.convertDataSpaceToPixelUnits(f,ax,x,y);


            xname=ax.UserData.SensitivityArgs.Inputs{1};
            ynames=flip(ax.UserData.SensitivityArgs.Outputs);
            out=SimBiology.internal.plotting.hg.AxesInfo.initBarPositionStruct(length(ynames));

            xcount=1;
            count=1;


            for i=1:length(ynames)
                x1=x(xcount);
                x2=x(xcount+1);
                y1=y(xcount);
                y2=y(xcount+1);
                yname=ynames{i};
                out(count)=SimBiology.internal.plotting.hg.AxesInfo.calculateBarPosition(xname,yname,info,x1,x2,y1,y2);

                xcount=xcount+2;
                count=count+1;
            end
        end

        function out=initBarPositionStruct(count)
            template=struct('XName','',...
            'YName','',...
            'width',0,...
            'left',0',...
            'right',0,...
            'height',0,...
            'top',0,...
            'bottom',0);

            out=repmat(template,1,count);
        end

        function out=calculateBarPosition(xname,yname,info,x1,x2,y1,y2)
            out.XName=xname;
            out.YName=yname;
            out.width=x2-x1;
            out.left=info.left+x1-3;
            out.right=out.left+out.width;
            out.height=y2-y1;
            out.top=info.bottom-y2;
            out.bottom=info.bottom-y1;
        end
    end
end