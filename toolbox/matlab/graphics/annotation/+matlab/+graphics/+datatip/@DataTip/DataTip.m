classdef(ConstructOnLoad,Hidden)DataTip<handle&matlab.graphics.primitive.world.Group&...
    matlab.graphics.mixin.Selectable&...
    matlab.graphics.internal.Legacy





    properties(AffectsObject,Dependent)
        Location(1,1)string{mustBeMember(Location,["northeast","northwest","southeast","southwest"])};
        SnapToDataVertex matlab.internal.datatype.matlab.graphics.datatype.on_off
        DataIndex{mustBeNonempty,mustBeNumeric,mustBeInteger,mustBeGreaterThan(DataIndex,0)}
        InterpolationFactor{mustBeNonempty,mustBeNumeric}
        FontSize matlab.internal.datatype.matlab.graphics.datatype.Positive
        FontAngle matlab.internal.datatype.matlab.graphics.datatype.FontAngle
        Interpreter matlab.internal.datatype.matlab.graphics.datatype.TextInterpreter
        FontName matlab.internal.datatype.matlab.graphics.datatype.FontName
    end

    properties(AffectsObject,Dependent,NeverAmbiguous)
        LocationMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual;
    end

    properties
        ValueChangedFcn matlab.internal.datatype.matlab.graphics.datatype.Callback='';
    end

    properties(NeverAmbiguous)
        FontSizeMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        FontNameMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        FontAngleMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        InterpreterMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
    end

    properties(Access=?matlab.graphics.datatip.DataTipTemplate)
        FontSize_I=10
        FontName_I='Helvetica'
        FontAngle_I='normal'
        Interpreter_I='tex'
    end

    properties(SetAccess=private,Dependent)
Content
    end

    properties(Access=protected)
        XMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        YMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        ZMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
        InterpolationFactorMode matlab.internal.datatype.matlab.graphics.datatype.AutoManual='auto';
Y_I
X_I
Z_I
DynamicCoordProperties


InterpolationFactor_I

        PointDataTip matlab.graphics.Graphics;
    end

    properties(Access=?tDataTip,Transient)
        PropertyChangeListeners=event.listener.empty;
        ReparentListener=event.listener.empty;
        PointDataTipListeners=event.listener.empty;
        ContextMenuSetListener=event.listener.empty;
    end

    methods
        function hObj=DataTip(varargin)
            hObj.Tag='datatip';
            hObj.Type='DataTip';

            if nargin



                if isa(varargin{1},'matlab.graphics.shape.internal.PointDataTip')
                    hObj.PointDataTip=varargin{1};
                    hObj.Parent=hObj.PointDataTip.DataSource.getAnnotationTarget();
                else
                    matlab.graphics.datatip.DataTip.validateParent(varargin{1});
                    hObj.Parent=varargin{1};
                end

                varargin(1)=[];
            end


            if~isempty(hObj.Parent)&&isempty(hObj.PointDataTip)
                hParent=matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(hObj.Parent);
                hObj.PointDataTip=matlab.graphics.shape.internal.PointDataTip(hParent,...
                'HandleVisibility','off','IsAddedViaDataTipAPI',true);


                hObj.bringToFront();
            end




            hObj.applyDataTipTemplate(hObj.Parent);

            if nargin>1
                set(hObj,varargin{:});
            end
        end

        function set.PointDataTip(hObj,newValue)

            hObj.PointDataTip=newValue;
            hObj.addListenersToUpdateDataTip();
        end

        function set.DataIndex(hObj,newValue)



            hObj.doUpdateIfNeeded();

            newValue=double(newValue);
            oldValue=hObj.PointDataTip.Cursor.DataIndex;
            if~isequal(oldValue,newValue)
                nearestIndex=hObj.PointDataTip.DataSource.getNearestIndex(newValue);

                hObj.updatePointDataTipLocation(nearestIndex,hObj.InterpolationFactor);
            end
        end

        function dataIndex=get.DataIndex(hObj)



            hObj.doUpdateIfNeeded();


            dataIndex=hObj.PointDataTip.Cursor.DataIndex;
        end

        function set.InterpolationFactor(hObj,newValue)






            hObj.InterpolationFactor_I=newValue;
            hObj.InterpolationFactorMode='manual';
            hObj.PointDataTip.Cursor.InterpolationFactor=newValue;
        end

        function iFactor=get.InterpolationFactor(hObj)



            hObj.doUpdateIfNeeded();
            if strcmpi(hObj.InterpolationFactorMode,'auto')
                iFactor=hObj.PointDataTip.Cursor.InterpolationFactor;
            else
                iFactor=hObj.InterpolationFactor_I;
            end
        end

        function val=get.Content(hObj)
            forceFullUpdate(hObj.PointDataTip,'all','String');
            stringVal=string(hObj.PointDataTip.String);

            val={};
            for i=1:length(stringVal)


                stringVal(i)=eraseBetween(stringVal(i),"\color","}",'Boundaries','inclusive');
                stringVal(i)=regexprep(stringVal(i),'\\[a-z]{2}','');
                stringVal(i)=regexprep(stringVal(i),'[{}]','');
                val{i,1}=char(strtrim(stringVal(i)));%#ok<AGROW>
            end
        end

        function set.SnapToDataVertex(hObj,newValue)


            if strcmpi(newValue,'on')
                hObj.PointDataTip.Cursor.Interpolate='off';
            else
                hObj.PointDataTip.Cursor.Interpolate='on';
            end
        end

        function val=get.SnapToDataVertex(hObj)


            if strcmpi(hObj.PointDataTip.Cursor.Interpolate,'on')
                val='off';
            else
                val='on';
            end
        end

        function val=get.Location(hObj)



            hObj.doUpdateIfNeeded();
            switch lower(hObj.PointDataTip.Orientation)
            case 'topright'
                val='northeast';
            case 'topleft'
                val='northwest';
            case 'bottomright'
                val='southeast';
            case 'bottomleft'
                val='southwest';
            end
        end

        function set.Location(hObj,newValue)

            hObj.LocationMode='manual';

            switch char(lower(newValue))
            case 'northeast'
                hObj.PointDataTip.Orientation='topright';
            case 'northwest'
                hObj.PointDataTip.Orientation='topleft';
            case 'southeast'
                hObj.PointDataTip.Orientation='bottomright';
            case 'southwest'
                hObj.PointDataTip.Orientation='bottomleft';
            end
        end

        function val=get.LocationMode(hObj)

            val=hObj.PointDataTip.OrientationMode;
        end

        function set.LocationMode(hObj,newValue)

            hObj.PointDataTip.OrientationMode=newValue;
        end

        function set.ValueChangedFcn(hObj,newValue)

            hObj.ValueChangedFcn=hgcastvalue('matlab.graphics.datatype.Callback',newValue);
        end




        function val=get.FontSize(hObj)
            val=hObj.FontSize_I;
        end

        function set.FontSize(hObj,newValue)
            hObj.FontSize_I=newValue;
            hObj.PointDataTip.FontSize=newValue;
            hObj.FontSizeMode='manual';
        end

        function set.FontSizeMode(hObj,newValue)


            if~strcmpi(hObj.FontSizeMode,newValue)
                hObj.FontSizeMode=newValue;
                hObj.updateStylePropertyIfNeeded(hObj.Parent,'FontSize');
            end
        end




        function val=get.FontAngle(hObj)
            val=hObj.FontAngle_I;
        end

        function set.FontAngle(hObj,newValue)
            hObj.FontAngle_I=newValue;
            hObj.PointDataTip.FontAngle=newValue;
            hObj.FontAngleMode='manual';
        end

        function set.FontAngleMode(hObj,newValue)


            if~strcmpi(hObj.FontAngleMode,newValue)
                hObj.FontAngleMode=newValue;
                hObj.updateStylePropertyIfNeeded(hObj.Parent,'FontAngle');
            end
        end




        function val=get.FontName(hObj)
            val=hObj.FontName_I;
        end

        function set.FontName(hObj,newValue)
            hObj.FontName_I=newValue;
            hObj.PointDataTip.FontName=newValue;
            hObj.FontNameMode='manual';
        end

        function set.FontNameMode(hObj,newValue)


            if~strcmpi(hObj.FontNameMode,newValue)
                hObj.FontNameMode=newValue;
                hObj.updateStylePropertyIfNeeded(hObj.Parent,'FontName');
            end
        end




        function val=get.Interpreter(hObj)
            val=hObj.Interpreter_I;
        end

        function set.Interpreter(hObj,newValue)
            hObj.Interpreter_I=newValue;
            hObj.PointDataTip.Interpreter=newValue;
            hObj.InterpreterMode='manual';
        end

        function set.InterpreterMode(hObj,newValue)


            if~strcmpi(hObj.InterpreterMode,newValue)
                hObj.InterpreterMode=newValue;
                localUpdateInterpreter(hObj,hObj.Parent);
            end
        end


        function delete(hObj)

            delete(hObj.PointDataTipListeners);
            delete(hObj.PointDataTip);
            delete(hObj.PropertyChangeListeners);
            delete(hObj.ContextMenuSetListener);
            delete(hObj.ReparentListener);
        end
    end

    methods(Hidden)
        doUpdate(hObj,updateState)
        mcodeConstructor(this,code)

        function actualValue=setParentImpl(hObj,proposedValue)
            actualValue=proposedValue;

            matlab.graphics.datatip.DataTip.validateParent(proposedValue);


            hObj.updateBasedOnParent(proposedValue);



            hObj.ReparentListener=event.proplistener(proposedValue,findprop(proposedValue,'Parent'),'PostSet',@(obj,evd)updateBasedOnParent(hObj,hObj.Parent));
        end

        function setX(hObj,newValue)
            validatedValue=hObj.validateCoordinates(hObj.DynamicCoordProperties{1},newValue);
            hObj.X_I=validatedValue;
            hObj.XMode='manual';
            hObj.MarkDirty('all');
        end

        function setY(hObj,newValue)
            validatedValue=hObj.validateCoordinates(hObj.DynamicCoordProperties{2},newValue);
            hObj.Y_I=validatedValue;
            hObj.YMode='manual';
            hObj.MarkDirty('all');
        end

        function setZ(hObj,newValue)
            validatedValue=hObj.validateCoordinates(hObj.DynamicCoordProperties{3},newValue);
            hObj.Z_I=validatedValue;
            hObj.ZMode='manual';
            hObj.MarkDirty('all');
        end

        function val=getX(hObj)



            hObj.doUpdateIfNeeded();
            val=matlab.graphics.internal.makeNonNumeric(hObj.Parent,hObj.PointDataTip.Cursor.Position(1),[],[]);
        end

        function val=getY(hObj)



            hObj.doUpdateIfNeeded();
            [~,val]=matlab.graphics.internal.makeNonNumeric(hObj.Parent,[],hObj.PointDataTip.Cursor.Position(2),[]);
        end

        function val=getZ(hObj)



            hObj.doUpdateIfNeeded();
            zPos=0;
            if numel(hObj.PointDataTip.Cursor.Position)>2
                zPos=hObj.PointDataTip.Cursor.Position(3);
            end
            [~,~,val]=matlab.graphics.internal.makeNonNumeric(hObj.Parent,[],[],zPos);
        end


        function bringToFront(hObj)
            hTip=hObj.PointDataTip;
            if ishghandle(hTip)
                hFig=ancestor(hObj,'figure');
                if~isempty(hFig)
                    dcm=datacursormode(hFig);
                    if~isempty(dcm)

                        if~isempty(dcm.CurrentCursor)&&dcm.CurrentCursor~=hTip.Cursor
                            dcm.CurrentCursor=hTip.Cursor;
                        end
                        hTip.UIContextMenu=dcm.UIContextMenu;
                    end

                    hTip.CurrentTip='on';

                    hTip.TipHandle.ScribeHost.bringToFront();
                    hTip.LocatorHandle.ScribeHost.bringToFront();
                end
            end
        end

        function dynamicCoord=getDynamicCoordinates(hObj)
            dynamicCoord=hObj.DynamicCoordProperties;
        end

        function pDT=getPointDataTip(hObj)
            pDT=hObj.PointDataTip;
        end



        function updateStylePropertyIfNeeded(hObj,hParent,propName)
            if~isempty(hParent)&&...
                strcmpi(hObj.([propName,'Mode']),'auto')&&...
                ~isempty(hObj.PointDataTip)
                hParent=matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(hParent);
                hObj.([propName,'_I'])=hParent.DataTipTemplate.(propName);
                hObj.PointDataTip.(propName)=hObj.([propName,'_I']);
            end
        end
    end

    methods(Access=private)



        function doUpdateIfNeeded(hObj)
            if strcmpi(hObj.XMode,'manual')||...
                strcmpi(hObj.YMode,'manual')||...
                strcmpi(hObj.ZMode,'manual')
                forceFullUpdate(hObj,'all','DataIndex');
            end
        end




        function updatePointDataTipLocation(hObj,index,interp)
            hObj.PointDataTip.Cursor.setLocation(index,interp);


            hObj.InterpolationFactorMode='auto';
            forceFullUpdate(hObj.PointDataTip,'all','DataIndex');
        end


        function addGetMethodForProperty(hObj,prop)
            switch prop.Name
            case hObj.DynamicCoordProperties{1}
                prop.GetMethod=@getX;
            case hObj.DynamicCoordProperties{2}
                prop.GetMethod=@getY;
            case hObj.DynamicCoordProperties{3}
                prop.GetMethod=@getZ;
            end
        end


        function addSetMethodForProperty(hObj,prop)
            switch prop.Name
            case hObj.DynamicCoordProperties{1}
                prop.SetMethod=@setX;
            case hObj.DynamicCoordProperties{2}
                prop.SetMethod=@setY;
            case hObj.DynamicCoordProperties{3}
                prop.SetMethod=@setZ;
            end
        end



        function moveDataTip(hObj)
            moveDataTipListener=addlistener(hObj,'MarkedClean',@(s,e)nDelayedMove());

            function nDelayedMove()
                delete(moveDataTipListener);
                if strcmpi(hObj.XMode,'auto')||isempty(hObj.X_I)
                    hObj.X_I=hObj.getX;
                end

                if strcmpi(hObj.YMode,'auto')||isempty(hObj.Y_I)
                    hObj.Y_I=hObj.getY;
                end

                if strcmpi(hObj.ZMode,'auto')||isempty(hObj.Z_I)
                    hObj.Z_I=hObj.getZ;
                end
                [pos1,pos2,pos3]=matlab.graphics.internal.makeNumeric(hObj.Parent,hObj.X_I,hObj.Y_I,hObj.Z_I);



                pixel=matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(hObj.PointDataTip.DataSource.getAnnotationTarget,[pos1,pos2,pos3]');





                OffSet=brushing.select.translateToContainer(hObj.PointDataTip.DataSource,[0,0]);
                pixel=pixel-OffSet';


                pixel=pixel(:)';

                if strcmpi(hObj.SnapToDataVertex,'on')
                    newIndex=hObj.PointDataTip.DataSource.getNearestPoint(pixel);
                    interp=0;
                elseif strcmpi(hObj.InterpolationFactorMode,'manual')
                    newIndex=hObj.PointDataTip.DataSource.getInterpolatedPoint(pixel);
                    interp=hObj.InterpolationFactor;
                else
                    [newIndex,interp]=hObj.PointDataTip.DataSource.getInterpolatedPoint(pixel);
                end


                hObj.updatePointDataTipLocation(newIndex,interp);





                hObj.XMode='auto';
                hObj.YMode='auto';
                hObj.ZMode='auto';
            end
        end



        function recalculateDataIndex(hObj)
            moveDataTipListener=addlistener(hObj,'MarkedClean',@(s,e)nDelayedMove());

            function nDelayedMove()
                delete(moveDataTipListener);
                hObj.updatePointDataTipLocation(hObj.DataIndex,hObj.InterpolationFactor);
            end
        end


        function callbackValueChanged(hObj,eventData)
            try


                hgfeval(hObj.ValueChangedFcn,hObj,eventData);
            catch ex

                warnState=warning('off','backtrace');
                warning(message('MATLAB:graphics:datatip:ErrorWhileEvaluating',ex.message,'ValueChangedFcn'));
                warning(warnState);
            end
        end


        function makeCurrent(hObj)
            fig=ancestor(hObj,'figure');
            fig.CurrentObject=hObj;
        end

        function setPropertyOnPointDataTip(hObj,metaProp)
            if ishghandle(hObj.PointDataTip)
                hTip=hObj.PointDataTip;
                switch metaProp.Name
                case 'Parent'
                    hObj.PointDataTip.DataSource=matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(hObj.Parent);
                case 'PickableParts'
                    hTip.TipHandle.ScribeHost.getScribePeer().PickableParts=hObj.PickableParts;
                    hTip.LocatorHandle.setMarkerPickableParts(hObj.PickableParts);
                case 'HitTest'
                    hTip.TipHandle.ScribeHost.getScribePeer().HitTest=hObj.HitTest;
                    hTip.LocatorHandle.ScribeHost.getScribePeer().HitTest=hObj.HitTest;
                otherwise
                    hObj.PointDataTip.(metaProp.Name)=hObj.(metaProp.Name);
                end
            end
        end

        function setPropertyOnDataTip(hObj,metaProp)


            if strcmpi(metaProp.Name,'DataSource')
                if~isempty(hObj.PointDataTip.DataSource)
                    hObj.Parent=hObj.PointDataTip.DataSource.getAnnotationTarget();
                end
            elseif strcmpi(metaProp.Name,'UIContextMenu')||strcmpi(metaProp.Name,'ContextMenu')






                hObj.updateDataTipContextMenu();
            else
                hObj.(metaProp.Name)=hObj.PointDataTip.(metaProp.Name);
            end
        end



        function updateDataTipContextMenu(hObj)
            if~isempty(hObj.PointDataTip)&&isvalid(hObj.PointDataTip)
                hObj.ContextMenuSetListener(1).Enabled=false;
                hObj.ContextMenuSetListener(2).Enabled=false;
                hObj.ContextMenu=hObj.PointDataTip.ContextMenu;
                hObj.ContextMenuSetListener(1).Enabled=true;
                hObj.ContextMenuSetListener(2).Enabled=true;
            end
        end




        function updateDynamicPropIfNeeded(hObj,hParent)
            if nargin==1
                hParent=hObj.Parent;
            end

            dimNames=hParent.DimensionNames;
            if isempty(hObj.DynamicCoordProperties)

                hObj.constructDynamicCoordProperties(dimNames);
            else
                if all(strcmpi(dimNames,hObj.DynamicCoordProperties))


                    dynamicCoordinates=hObj.DynamicCoordProperties;
                    for i=1:numel(dynamicCoordinates)
                        prop=findprop(hObj,dynamicCoordinates{i});
                        if~numel(prop)
                            prop=addprop(hObj,dimNames{i});
                            prop.Dependent=1;
                        end
                        hObj.addGetMethodForProperty(prop);
                        hObj.addSetMethodForProperty(prop);
                    end
                else


                    dynamicCoordinates=hObj.DynamicCoordProperties;
                    for i=1:numel(dynamicCoordinates)
                        dynamicProp=findprop(hObj,dynamicCoordinates{i});
                        if numel(dynamicProp)
                            delete(dynamicProp);
                        end
                    end
                    hObj.DynamicCoordProperties={};
                    hObj.constructDynamicCoordProperties(dimNames);
                end
            end
        end

        function constructDynamicCoordProperties(hObj,dimNames)





            for i=1:numel(dimNames)
                if~isprop(hObj,dimNames{i})
                    prop=addprop(hObj,dimNames{i});
                    hObj.DynamicCoordProperties{end+1}=prop.Name;
                    prop.Dependent=1;
                    hObj.addGetMethodForProperty(prop);
                    hObj.addSetMethodForProperty(prop);
                end
            end
        end


        function validatedValue=validateCoordinates(hObj,prop,newValue)
            validatedValue=newValue;
            ax=ancestor(hObj,'matlab.graphics.axis.AbstractAxes');
            if~isempty(ax)&&isvalid(ax)
                rulerPropName=[prop,'Axis'];


                if isprop(ax,rulerPropName)
                    rulerProp=ax.(rulerPropName);
                    switch class(rulerProp)
                    case 'matlab.graphics.axis.decorator.NumericRuler'
                        if~isnumeric(validatedValue)
                            error(message('MATLAB:graphics:datatip:InvalidValueForNumerical',prop));
                        end
                    case 'matlab.graphics.axis.decorator.DatetimeRuler'
                        if~isdatetime(validatedValue)
                            error(message('MATLAB:graphics:datatip:InvalidValueForDateTime',prop));
                        end
                    case 'matlab.graphics.axis.decorator.DurationRuler'
                        if~isduration(validatedValue)
                            error(message('MATLAB:graphics:datatip:InvalidValueForDuration',prop));
                        end
                    case 'matlab.graphics.axis.decorator.CategoricalRuler'
                        if ischar(validatedValue)||isstring(validatedValue)
                            validatedValue=categorical(cellstr(validatedValue));
                        end
                        if~iscategorical(validatedValue)
                            error(message('MATLAB:graphics:datatip:InvalidValueForCategorical',prop));
                        end
                    end
                else


                    if~isnumeric(validatedValue)
                        error(message('MATLAB:graphics:datatip:InvalidValueForNumerical',prop));
                    end
                end
            end
        end

        function applyDataTipTemplate(hObj,hParent)
            if~isempty(hParent)
                hParent=matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(hParent);

                hObj.updateStylePropertyIfNeeded(hParent,'FontSize');


                hObj.updateStylePropertyIfNeeded(hParent,'FontName');


                hObj.updateStylePropertyIfNeeded(hParent,'FontAngle');




                localUpdateInterpreter(hObj,hParent);
            end
        end



        function updateBasedOnParent(hObj,hParent)


            hObj.doUpdateIfNeeded();
            hObj.updateDynamicPropIfNeeded(hParent);



            hObj.applyDataTipTemplate(hParent);
        end
    end

    methods(Hidden,Access={?matlab.graphics.mixin.internal.Copyable,...
        ?matlab.graphics.internal.CopyContext})

        function connectCopyToTree(hObj,hCopy,hCopyParent,hContext)
            connectCopyToTree@matlab.graphics.primitive.world.Group(hObj,hCopy,hCopyParent,hContext);

            hOldPointDataTip=hObj.PointDataTip;
            if~isempty(hOldPointDataTip)

                if hContext.willBeCopied(hOldPointDataTip)
                    hNewPointDataTip=hContext.getCopy(hOldPointDataTip);
                else

                    hNewSource=matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(hCopy.Parent);
                    hNewPointDataTip=hOldPointDataTip.copy();
                    hNewPointDataTip.DataSource=hNewSource;
                end


                hCopy.PointDataTip=hNewPointDataTip;
                hCopy.updateBasedOnParent(hCopy.Parent);
            end
        end
    end

    methods(Access=private)




        function addListenersToUpdateDataTip(hObj)
            if~isempty(hObj.PointDataTip)&&isvalid(hObj.PointDataTip)
                hObj.PointDataTipListeners=[event.listener(hObj.PointDataTip,'ObjectBeingDestroyed',@(obj,evd)delete(hObj)),...
                event.listener(hObj.PointDataTip,'ValueChanged',@(obj,evd)callbackValueChanged(hObj,evd)),...
                event.proplistener(hObj.PointDataTip,findprop(hObj.PointDataTip,'DataSource'),'PostSet',@(obj,evd)setPropertyOnDataTip(hObj,obj)),...
                event.proplistener(hObj.PointDataTip,findprop(hObj.PointDataTip,'UIContextMenu'),'PostSet',@(obj,evd)setPropertyOnDataTip(hObj,obj)),...
                event.proplistener(hObj.PointDataTip,findprop(hObj.PointDataTip,'ContextMenu'),'PostSet',@(obj,evd)setPropertyOnDataTip(hObj,obj)),...
                event.proplistener(hObj.PointDataTip,findprop(hObj.PointDataTip,'Selected'),'PostSet',@(obj,evd)setPropertyOnDataTip(hObj,obj)),...
                event.proplistener(hObj.PointDataTip,findprop(hObj.PointDataTip,'SelectionHighlight'),'PostSet',@(obj,evd)setPropertyOnDataTip(hObj,obj)),...
                event.proplistener(hObj.PointDataTip,findprop(hObj.PointDataTip,'Visible'),'PostSet',@(obj,evd)setPropertyOnDataTip(hObj,obj)),...
                event.proplistener(hObj.PointDataTip,findprop(hObj.PointDataTip,'PickableParts'),'PostSet',@(obj,evd)setPropertyOnDataTip(hObj,obj)),...
                event.proplistener(hObj.PointDataTip,findprop(hObj.PointDataTip,'HitTest'),'PostSet',@(obj,evd)setPropertyOnDataTip(hObj,obj))];


                hObj.PropertyChangeListeners=[event.proplistener(hObj,findprop(hObj,'Parent'),'PostSet',@(obj,evd)setPropertyOnPointDataTip(hObj,obj)),...
                event.proplistener(hObj,findprop(hObj,'Selected'),'PostSet',@(obj,evd)setPropertyOnPointDataTip(hObj,obj)),...
                event.proplistener(hObj,findprop(hObj,'SelectionHighlight'),'PostSet',@(obj,evd)setPropertyOnPointDataTip(hObj,obj)),...
                event.proplistener(hObj,findprop(hObj,'Visible'),'PostSet',@(obj,evd)setPropertyOnPointDataTip(hObj,obj)),...
                event.proplistener(hObj,findprop(hObj,'PickableParts'),'PostSet',@(obj,evd)setPropertyOnPointDataTip(hObj,obj)),...
                event.proplistener(hObj,findprop(hObj,'HitTest'),'PostSet',@(obj,evd)setPropertyOnPointDataTip(hObj,obj))];



                hObj.ContextMenuSetListener=[event.proplistener(hObj,findprop(hObj,'ContextMenu'),'PostSet',@(obj,evd)hObj.showWarningOnSetUIContextMenu()),...
                event.proplistener(hObj,findprop(hObj,'UIContextMenu'),'PostSet',@(obj,evd)hObj.showWarningOnSetUIContextMenu())];
            end
        end





        function showWarningOnSetUIContextMenu(hObj)
            hFig=ancestor(hObj,'figure');
            if isvalid(hFig)
                hMode=getuimode(hFig,'Exploration.Datacursor');






                if isvalid(hMode.UIContextMenu)
                    warnState=warning('off','backtrace');
                    warning(message('MATLAB:graphics:datatip:CannotSetUIContextMenu'));
                    warning(warnState);


                    hObj.updateDataTipContextMenu();
                end
            end
        end
    end

    methods(Access='protected',Hidden)

        function varargout=getPropertyGroups(~)


            varargout{1}=matlab.mixin.util.PropertyGroup(...
            {'DataIndex','Location','Parent'});
        end


        function label=getDescriptiveLabelForDisplay(hObj)






            label='';
            if isvalid(hObj)&&~isempty(hObj.PointDataTip)
                forceFullUpdate(hObj,'all','Content');
                label=matlab.graphics.internal.convertStringToCharArgs(hObj.Content);
            end
        end
    end

    methods(Static,Hidden)
        function isValid=isValidParent(hParent)
            isValid=(~isempty(hParent)&&...
            length(hParent)==1&&...
            ~isnumeric(hParent)&&...
            ishandle(hParent)&&...
            isgraphics(hParent)&&...
            ~isempty(matlab.graphics.chart.interaction.dataannotatable.internal.createDataAnnotatable(hParent)));
        end

        function validateParent(hParent)
            if~matlab.graphics.datatip.DataTip.isValidParent(hParent)
                error(message('MATLAB:graphics:datatip:IncorrectParent'));
            end
        end
    end
end

function localUpdateInterpreter(hObj,hParent)
    if~isempty(hParent)&&~isempty(hObj.PointDataTip)
        hDT=hParent.DataTipTemplate;
        if strcmpi(hObj.InterpreterMode,'auto')
            if strcmpi(hDT.InterpreterMode,'manual')
                hObj.Interpreter_I=hDT.Interpreter;
            else
                hFig=ancestor(hParent,'figure');
                if~isempty(hFig)
                    dcm=datacursormode(hFig);
                    hObj.Interpreter_I=dcm.Interpreter;
                end
            end
        end
        hObj.PointDataTip.Interpreter=hObj.Interpreter_I;
    end
end