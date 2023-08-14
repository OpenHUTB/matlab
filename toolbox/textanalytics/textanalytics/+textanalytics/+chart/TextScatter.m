classdef(ConstructOnLoad,Sealed)TextScatter<matlab.graphics.chart.primitive.Data3D...
    &matlab.graphics.internal.Legacy...
    &matlab.graphics.mixin.Selectable...
    &matlab.graphics.mixin.Legendable...
    &matlab.graphics.chart.interaction.DataAnnotatable...
    &matlab.graphics.mixin.AxesParentable



    properties(Dependent,Access=public,AffectsObject)
        TextData;
        ColorData;
        BackgroundColor;
        MarkerColor;
        TextDensityPercentage;
        MaxTextLength;
    end
    properties(Access=public,AffectsObject,AffectsLegend=true)
        Colors matlab.internal.datatype.matlab.graphics.datatype.ColorOrder=[0,0,0];
        EdgeColor matlab.internal.datatype.matlab.graphics.datatype.RGBAColor='none';
        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName='Helvetica';
        FontSize matlab.internal.datatype.matlab.graphics.datatype.Positive=10;
        FontSmoothing matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
        FontAngle matlab.internal.datatype.matlab.graphics.datatype.FontAngle='normal';
        FontWeight matlab.internal.datatype.matlab.graphics.datatype.FontWeight='normal';
        Margin matlab.internal.datatype.matlab.graphics.datatype.Positive=1;
        MarkerSize matlab.internal.datatype.matlab.graphics.datatype.Positive=6;
    end
    properties(Hidden,Access=public,SetObservable=true,AffectsObject)




        Clipping matlab.internal.datatype.matlab.graphics.datatype.on_off='on';
    end
    properties(Hidden)
        TextData_I=string(zeros(1,0));
        TextCell_I={};
        BackgroundColor_I='none';
        ColorData_I=zeros(0,3);
        MarkerColor_I='auto';
        Colors_I=[0,0,0];
        TextDensityPercentage_I=65;
        MaxTextLength_I=40;
        OldMask_I=[];
    end

    properties(GetAccess=?tTextScatter,Transient,NonCopyable,Hidden)

        TextHandle matlab.graphics.primitive.world.Text;
        MarkerHandle{matlab.internal.validation.mustBeValidGraphicsObject(MarkerHandle,'matlab.graphics.primitive.world.Marker')}=matlab.graphics.primitive.world.Marker.empty;
        SelectionHandle;
    end

    methods
        function hObj=TextScatter(varargin)
            hObj.Type='textscatter';
            addDependencyConsumed(hObj,{...
            'dataspace','xyzdatalimits','ref_frame','view','hgtransform_under_dataspace'});
            hObj.MarkerHandle=matlab.graphics.primitive.world.Marker(...
            'EdgeColorData',uint8([0;114;189;255]),...
            'Style','point',...
            'Size',3,...
            'Internal',true);
            hObj.addNode(hObj.MarkerHandle);

            hObj.SelectionHandle=matlab.graphics.interactor.ListOfPointsHighlight;
            set(hObj.SelectionHandle,'Description_I','TextScatter SelectionHandle');
            set(hObj.SelectionHandle,'Internal',true);
            hObj.addNode(hObj.SelectionHandle);


            b=hggetbehavior(hObj,'Brush');
            b.Enable=false;
            b.Serialize=false;

            b=hggetbehavior(hObj,'Linked');
            b.Enable=false;
            b.Serialize=false;
            if~isempty(varargin)
                set(hObj,varargin{:});
            end
        end
    end

    methods

        function val=get.TextData(hObj)
            val=hObj.TextData_I;
        end
        function set.TextData(hObj,val)
            val=reshape(val,1,[]);
            hObj.TextData_I=string(val);
            hObj.TextCell_I=cellstr(val(:));
            hObj.MarkDirty('all');
        end


        function val=get.TextDensityPercentage(hObj)
            val=hObj.TextDensityPercentage_I;
        end
        function set.TextDensityPercentage(hObj,val)
            validateattributes(val,{'double'},{'scalar','>=',0,'<=',100});
            hObj.TextDensityPercentage_I=val;
            hObj.MarkDirty('all');
        end


        function val=get.MaxTextLength(hObj)
            val=hObj.MaxTextLength_I;
        end
        function set.MaxTextLength(hObj,val)
            validateattributes(val,{'numeric'},{'scalar','positive','integer'});
            hObj.MaxTextLength_I=full(double(val));
            hObj.MarkDirty('all');
        end


        function val=get.BackgroundColor(hObj)
            val=hObj.BackgroundColor_I;
        end
        function set.BackgroundColor(hObj,val)
            enumValues={'none','data'};
            val=validateColorProp(val,enumValues,'InvalidBackgroundColor');
            hObj.BackgroundColor_I=val;
            hObj.MarkDirty('all');
        end


        function val=get.MarkerColor(hObj)
            val=hObj.MarkerColor_I;
        end
        function set.MarkerColor(hObj,val)
            enumValues={'none','auto'};
            val=validateColorProp(val,enumValues,'InvalidMarkerColor');
            hObj.MarkerColor_I=val;
            hObj.MarkDirty('all');
        end


        function val=get.ColorData(hObj)
            val=hObj.ColorData_I;
        end
        function set.ColorData(hObj,val)
            val=validateColorData(val);
            hObj.ColorData_I=val;
            hObj.MarkDirty('all');
        end

    end

    methods(Hidden)

        function doUpdate(hObj,updateState)

            x=hObj.XDataCache;
            y=hObj.YDataCache;
            z=hObj.ZDataCache;
            is3D=~isempty(z);
            str=hObj.TextCell_I;
            [color,back,markerColor]=resolveColorProperties(hObj);


            msg=checkLengths(x,y,z,str,back,color);
            if~isempty(msg)
                set(hObj.TextHandle,'Visible','off');
                error(msg);
            end

            ds=updateState.DataSpace;
            vFinite=textanalytics.internal.textscatter.validDataMask(x,y,z,ds);

            [x,y,z]=filterData(x,y,z,vFinite);
            str=str(vFinite);
            back=filterColors(back,vFinite);
            color=filterColors(color,vFinite);
            markerColor=filterColors(markerColor,vFinite);


            density=hObj.TextDensityPercentage_I;
            mask=textanalytics.internal.textscatter.densityMask(...
            x,y,z,density,ds,hObj.OldMask_I);
            hObj.OldMask_I=mask;


            markerItems=mask==0;
            [mx,my,mz]=filterData(x,y,z,markerItems);
            markerColor=filterColors(markerColor,markerItems);
            markerColor=lightenAutoColor(length(mx),markerColor,hObj.MarkerColor_I,hObj.ColorData_I);


            labelledItems=mask==1;
            [x,y,z]=filterData(x,y,z,labelledItems);
            str=str(labelledItems);
            back=filterColors(back,labelledItems);
            color=filterColors(color,labelledItems);

            if~is3D
                mz=zeros(size(mx));
                z=zeros(size(x));
            end


            iter=matlab.graphics.axis.dataspace.XYZPointsIterator;
            iter.XData=x;
            iter.YData=y;
            iter.ZData=z;
            vd=TransformPoints(updateState.DataSpace,...
            updateState.TransformUnderDataSpace,iter);

            createTextHandles(hObj,length(x),back,color);
            hText=hObj.TextHandle;

            str=textanalytics.internal.truncate(str,hObj.MaxTextLength);
            updateTextProps(hText,vd,str,back,color);

            f=matlab.graphics.general.Font;
            f.Name=hObj.FontName;
            f.Size=hObj.FontSize;
            f.Weight=hObj.FontWeight;
            f.Angle=hObj.FontAngle;

            edge=textanalytics.internal.textscatter.textColor(...
            hObj.EdgeColor,hObj.Colors);
            margin=hObj.Margin;
            smooth=hObj.FontSmoothing;
            set(hText,'EdgeColor',edge.ColorData,...
            'Margin',margin,'FontSmoothing',smooth,...
            'Font',f);


            iter=matlab.graphics.axis.dataspace.XYZPointsIterator;
            iter.XData=mx;
            iter.YData=my;
            iter.ZData=mz;
            vd=TransformPoints(updateState.DataSpace,...
            updateState.TransformUnderDataSpace,iter);
            updateMarkerProps(hObj.MarkerHandle,hObj,vd,markerColor);


            hSel=hObj.SelectionHandle;
            textanalytics.internal.textscatter.updateSelectionHandle(hObj,hSel,vd);

        end

        function ex=getXYZDataExtents(hObj,~,constraints)

            xdata=hObj.XDataCache;
            ydata=hObj.YDataCache;
            zdata=hObj.ZDataCache;


            gap=0.05;

            xmargin=(max(xdata)-min(xdata))*gap;
            if~constraints.AllowZeroCrossing(1)
                xmargin=0;
            end
            x=matlab.graphics.chart.primitive.utilities.arraytolimits(...
            [xdata,min(xdata)-xmargin,max(xdata)+xmargin]);

            ymargin=(max(ydata)-min(ydata))*gap/2;
            if~constraints.AllowZeroCrossing(2)
                ymargin=0;
            end
            y=matlab.graphics.chart.primitive.utilities.arraytolimits(...
            [ydata,min(ydata)-ymargin,max(ydata)+ymargin]);

            if isempty(zdata)
                z=matlab.graphics.chart.primitive.utilities.arraytolimits([]);
            else
                zmargin=(max(zdata)-min(zdata))*gap;
                if~constraints.AllowZeroCrossing(3)
                    zmargin=0;
                end
                z=matlab.graphics.chart.primitive.utilities.arraytolimits(...
                [zdata,min(zdata)-zmargin,max(zdata)+zmargin]);
            end

            ex=[x;y;z];
        end


        function graphic=getLegendGraphic(hObj)
            graphic=matlab.graphics.primitive.world.Quadrilateral;
            graphic.VertexData=single([0,0,1,1;0,1,1,0;0,0,0,0]);
            graphic.StripData=[];
            if~isempty(hObj.TextHandle)
                prim=hObj.TextHandle(1);
                color=prim.BackgroundColor;
                if isempty(color)
                    color=prim.ColorData;
                end
                graphic.ColorData_I=color;
                graphic.ColorBinding_I='object';
            end
        end


        function mcodeConstructor(this,code)

            is3D=false;
            ZData=this.ZData_I;
            if~isempty(ZData)
                is3D=true;
            end

            dnames=this.DimensionNames;

            if is3D
                setConstructorName(code,'textscatter3');
                constName='textscatter3';
            else
                setConstructorName(code,'textscatter');
                constName='textscatter';
            end

            plotutils('makemcode',this,code)

            ignoreProperty(code,{'XData','YData','ZData','TextData',...
            'XDataSource','YDataSource','ZDataSource'});



            xName=code.cleanName(this.XDataSource_I,dnames{1});
            arg=codegen.codeargument('Name',xName,'Value',this.XData_I,'IsParameter',true,...
            'Comment',[constName,' ',dnames{1}]);
            addConstructorArgin(code,arg);



            yName=code.cleanName(this.YDataSource_I,dnames{2});
            arg=codegen.codeargument('Name',yName,'Value',this.YData_I,'IsParameter',true,...
            'Comment',[constName,' ',dnames{2}]);
            addConstructorArgin(code,arg);

            if is3D

                zName=code.cleanName(this.ZDataSource_I,dnames{3});
                arg=codegen.codeargument('Name',zName,'Value',this.ZData_I,'IsParameter',true,...
                'Comment',[constName,' ',dnames{3}]);
                addConstructorArgin(code,arg);
            end



            strName=code.cleanName('str','str');
            arg=codegen.codeargument('Name',strName,'Value',this.TextData_I,'IsParameter',true,...
            'Comment',[constName,' str']);
            addConstructorArgin(code,arg);

            generateDefaultPropValueSyntax(code);
        end







        function dataTipRows=createDefaultDataTipRows(hObj)
            dataTipRows=matlab.graphics.datatip.DataTipTextRow.empty(0,1);
            dimensionNames=hObj.DimensionNames;
            for i=1:numel(dimensionNames)

                if strcmpi(strcat(dimensionNames{i},'Data'),'ZData')&&...
                    (~isprop(hObj,'ZData')||(isprop(hObj,'ZData')&&...
                    isempty(hObj.ZData)))
                    continue;
                end

                dataTipRows(i,1)=matlab.graphics.datatip.DataTipTextRow(dimensionNames{i},strcat(dimensionNames{i},'Data'));
            end

            dataTipRows(end+1,1)=dataTipTextRow('Text','TextData');
        end


        function coordinateData=createCoordinateData(hObj,valueSource,dataIndex,~)
            import matlab.graphics.chart.interaction.dataannotatable.internal.CoordinateData;
            coordinateData=CoordinateData.empty(0,1);


            valueSource=char(valueSource);

            if strcmpi(valueSource,'TextData')
                coordinateData=CoordinateData(valueSource,hObj.TextData(dataIndex));
                return;
            end



            is2D=isempty(hObj.ZData);
            primpos=doGetDisplayAnchorPoint(hObj,dataIndex,0);
            if is2D
                primpos.Is2D=true;
            end
            location=primpos.getLocation(hObj);
            dnames=hObj.DimensionNames;

            location3=[];
            if~is2D
                location3=location(3);
            end
            [xLoc,yLoc,zLoc]=matlab.graphics.internal.makeNonNumeric(hObj,location(1),location(2),location3);

            switch(valueSource)
            case[dnames{1},'Data']
                coordinateData=CoordinateData(valueSource,xLoc);
            case[dnames{2},'Data']
                coordinateData=CoordinateData(valueSource,yLoc);
            case[dnames{3},'Data']
                coordinateData=CoordinateData(valueSource,zLoc);
            end
        end


        function valueSources=getAllValidValueSources(hObj)
            dnames=hObj.DimensionNames;
            valueSources=[[dnames{1},'Data'];[dnames{2},'Data'];[dnames{3},'Data'];"TextData"];
        end
    end

    methods(Access=protected,Hidden)




        function pt=doGetDisplayAnchorPoint(hObj,index,~)

            pt=textanalytics.internal.textscatter.doGetDisplayAnchorPoint(hObj,index);
        end

        function pt=doGetReportedPosition(hObj,index,~)
            pt=textanalytics.internal.textscatter.doGetDisplayAnchorPoint(hObj,index);
        end

        function[index,interp]=doIncrementIndex(~,index,~,~)


            interp=0;
        end

        function varargout=doGetNearestIndex(hObj,index)



            numPoints=numel(hObj.XDataCache);


            if numPoints>0
                index=max(1,min(index,numPoints));
            end
            varargout{1}=index;

        end

        function ind=doGetNearestPoint(hObj,position)

            data={hObj.XDataCache,hObj.YDataCache};
            if~isempty(hObj.ZDataCache)
                data{3}=hObj.ZDataCache;
            end

            sz=cellfun(@numel,data,'UniformOutput',true);
            if~all(sz==max(sz))
                ind=1;
                return
            end


            utils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            ind=utils.nearestPoint(hObj,position,true,data{:});

            if isempty(ind)
                ind=1;
            end
        end

        function[index,interp]=doGetInterpolatedPoint(hObj,position)



            index=hObj.doGetNearestPoint(position);
            interp=0;
        end

        function[index,interp]=doGetInterpolatedPointInDataUnits(hObj,position)



            data={hObj.XDataCache,hObj.YDataCache};
            if~isempty(hObj.ZDataCache)
                data{3}=hObj.ZDataCache;
            end

            sz=cellfun(@numel,data,'UniformOutput',true);
            if~all(sz==max(sz))
                index=1;
                return
            end


            utils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();
            index=utils.nearestPoint(hObj,position,false,data{:});

            if isempty(index)
                index=1;
            end
            interp=0;
        end

        function desc=doGetDataDescriptors(hObj,index,~)


            is2D=isempty(hObj.ZData);
            primpos=doGetDisplayAnchorPoint(hObj,index,0);
            if is2D
                primpos.Is2D=true;
            end
            location=primpos.getLocation(hObj);

            dnames=hObj.DimensionNames;

            zloc=[];
            if~is2D
                zloc=location(3);
            end
            [xloc,yloc,zloc]=matlab.graphics.internal.makeNonNumeric(hObj,location(1),location(2),zloc);


            xVal=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(dnames{1},xloc);
            yVal=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(dnames{2},yloc);
            zVal=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor.empty;
            if~is2D
                zVal=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(dnames{3},zloc);
            end

            str=hObj.TextData(index);
            word=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Text',str);

            desc=[xVal,yVal,zVal,word];
        end


        function group=getPropertyGroups(hObj)

            if~isempty(hObj.ZDataCache)
                props={'XData','YData','ZData','TextData','TextDensityPercentage'};
            else
                props={'XData','YData','TextData','TextDensityPercentage'};
            end
            group=matlab.mixin.util.PropertyGroup(props);
        end
    end

    methods(Access=private)
        function[color,back,marker]=resolveColorProperties(hObj)
            cdata=textanalytics.internal.textscatter.textColor(...
            hObj.ColorData_I,hObj.Colors);


            if strcmp(hObj.BackgroundColor_I,'data')
                back=cdata;
                color=textanalytics.internal.textscatter.computeContrastingColors(back);
            else
                color=cdata;
                if isempty(color.ColorData)

                    color=textanalytics.internal.textscatter.textColor([0,0,0],hObj.Colors);
                end
                back=textanalytics.internal.textscatter.textColor(...
                hObj.BackgroundColor_I,hObj.Colors);
            end


            if strcmp(hObj.MarkerColor_I,'auto')
                marker=cdata;
                if isempty(marker.ColorData)
                    blue=defaultBlue;
                    marker=textanalytics.internal.textscatter.textColor(...
                    blue,hObj.Colors);
                end
            else
                marker=textanalytics.internal.textscatter.textColor(...
                hObj.MarkerColor_I,hObj.Colors);
            end
        end
    end
    methods
        function set.MarkerHandle(obj,value)
            if isa(value,'double')
                obj.MarkerHandle=handle(value);
            else
                obj.MarkerHandle=value;
            end
        end
    end
end

function createTextHandles(hObj,datalen,back,color)
    if back.Scalar&&color.Scalar
        N=1;
    else
        N=datalen;
    end
    h=hObj.TextHandle;
    len=length(h);
    if len<N

        for i=N:-1:(len+1)
            prim=matlab.graphics.primitive.world.Text(...
            'HorizontalAlignment','center',...
            'VerticalAlignment','middle','Internal',true);
            set(prim,'Description_I','TextScatter TextHandle');
            hObj.addNode(prim);
            h(i)=prim;
        end
        hObj.TextHandle=h;
    elseif len>N

        h2=h((N+1):len);
        h((N+1):len)=[];
        hObj.TextHandle=h;
        delete(h2);
    end
end

function[x,y,z]=filterData(x,y,z,keep)
    x=x(keep);
    y=y(keep);
    if~isempty(z)
        z=z(keep);
    end
end

function color=validateColorData(color)
    ok=false;
    if iscategorical(color)&&(isempty(color)||isvector(color))
        color=reshape(color,1,[]);
        ok=true;
    elseif isnumeric(color)&&(size(color,2)==3)&&isreal(color)
        color=double(color);
        allowNaN=true;
        ok=isValidColorRange(color,allowNaN);
    end
    if~ok
        error(message('textanalytics:textscatter:ColorDataProperty'));
    end
    color=full(color);
end

function color=validateColorProp(color,enumValues,id)
    ok=false;
    if(ischar(color)||isstring(color))&&any(strcmp(color,enumValues))
        color=char(color);
        ok=true;
    elseif isnumeric(color)&&isequal(size(color),[1,3])&&isreal(color)
        color=full(double(color));
        allowNaN=false;
        ok=isValidColorRange(color,allowNaN);
    end
    if~ok
        error(message(['textanalytics:textscatter:',id]));
    end
end

function b=isValidColorRange(color,allowNaN)
    b=true;
    if~isempty(color)
        color=color(:);
        if allowNaN
            color(isnan(color))=0;
        else
            b=~any(isnan(color));
        end
        b=b&&((min(color)>=0)&&(max(color)<=1));
    end
end

function updateTextProps(hText,vd,str,back,color)

    nverts=size(vd,2);
    set(hText,'Visible','on');
    set(hText((nverts+1):end),'Visible','off');
    if nverts>0
        if isscalar(hText)

            back1=pickColor(back,1);
            color1=pickColor(color,1);
            setTextProps(hText,vd,str,back1,color1);
        else
            distributeTextProps(hText,vd,str,back,color);
        end
    end
end

function distributeTextProps(hText,vd,str,back,color)

    N=size(vd,2);
    for i=1:N
        vdi=vd(:,i);
        stri=str(i);
        backi=pickColor(back,i);
        colori=pickColor(color,i);
        setTextProps(hText(i),vdi,stri,backi,colori);
    end
end

function setTextProps(hText,vd,str,back,color)
    if~isempty(color)
        if isempty(back)
            back=uint8([]);
        end
        set(hText,'VertexData',vd,'String',str,...
        'BackgroundColor',back,'Color',color);
    else
        set(hText,'Visible','off','String','','VertexData',uint8([]));
    end
end

function updateMarkerProps(markerObj,hObj,vd,markerColor)
    markerObj.VertexData=vd;
    markerObj.EdgeColorData=markerColor.ColorData;
    if size(markerColor.ColorData,2)>1
        markerObj.EdgeColorBinding='discrete';
    else
        markerObj.EdgeColorBinding='object';
    end
    markerObj.Size=hObj.MarkerSize;
end

function mismatchMsg=checkLengths(xdata,ydata,zdata,str,back,color)


    mismatchMsg='';
    xlen=length(xdata);
    ylen=length(ydata);
    zlen=[];
    if~isempty(zdata)
        zlen=length(zdata);
    end
    strlen=length(str);
    blen=getColorLength(back);
    clen=getColorLength(color);
    if any([ylen,zlen,strlen,blen,clen]~=xlen)
        mismatchMsg=message('textanalytics:textscatter:InvalidData');
    end
end

function markerColor=lightenAutoColor(len,markerColor,objMarkerColor,objColorData)


    cutoff=500;
    if len>=cutoff&&isempty(objColorData)&&...
        ischar(objMarkerColor)&&strcmp(objMarkerColor,'auto')&&markerColor.Scalar

        lightblue=[0.67,0.85,1];
        if len>=2*cutoff
            target=lightblue;
        else
            t=(len-cutoff)/cutoff;
            blue=defaultBlue;
            target=(1-t)*blue+t*lightblue;
        end
        markerColor=textanalytics.internal.textscatter.textColor(...
        target,[]);
    end
end

function blue=defaultBlue
    blue=[0,0.447,0.741];
end
