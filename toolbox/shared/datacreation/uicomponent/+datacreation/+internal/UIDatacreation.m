classdef UIDatacreation<matlab.ui.componentcontainer.ComponentContainer





    properties


Value

SelectedIndices
    end


    properties(Hidden)
        START_UP_COMPLETE=false
    end




    properties(Access=private,Transient,NonCopyable)

        Grid matlab.ui.container.GridLayout
    end


    properties(Access=protected,Transient,NonCopyable)

        UIDrawScope datacreation.internal.uidrawscope
ScopeDataListener
ScopeStartListener
ScopeSelectionListener
    end


    properties(Dependent)
XLabel
YLabel
LineInterpolationType
XRulerType

XLim
YLim
Title
    end


    events(HasCallbackProperty,NotifyAccess=protected)

ValueChanged
SelectionChanged

    end


    events
StartUpComplete
    end


    methods


        function delete(obj)


            delete(obj.ScopeDataListener);
            delete(obj.ScopeStartListener);


            delete@matlab.ui.componentcontainer.ComponentContainer(obj);

        end


        function set.Value(obj,inVal)

            try
                validateInput(obj,inVal);
            catch ME_INVALID
                throwAsCaller(ME_INVALID);
            end


            obj.Value=inVal;
        end


        function set.SelectedIndices(obj,indicesOneBased)

            if~isa(indicesOneBased,'double')||(~isempty(indicesOneBased)&&...
                any(indicesOneBased<=0))

                error(message('datacreation:datacreation:selectionValueError'));
            end

            obj.SelectedIndices=indicesOneBased;

        end


        function setAndPublishSelectedIndices(obj,indicesOneBased)

            outpayload.hasselection=false;
            outpayload.signalID=0;
            outpayload.signalIndex=0;

            if~isempty(indicesOneBased)
                outpayload.hasselection=true;


                outpayload.selectedIndex=indicesOneBased-1;

                outpayload.x=datacreation.internal.makeJsonSafe(double(getSelectedXData(obj,indicesOneBased)));
                outpayload.y=double(getSelectedYData(obj,indicesOneBased));

            end

            obj.SelectedIndices=indicesOneBased;
            obj.setScopeSelectedPoints(outpayload);
        end


        function set.XLabel(obj,inVal)
            try
                obj.UIDrawScope.XLabel=inVal;
            catch ME
                throwAsCaller(ME);
            end
        end


        function set.Title(obj,inTitle)
            try
                obj.UIDrawScope.Title=inTitle;
            catch ME
                throwAsCaller(ME);
            end
        end


        function theTitle=get.Title(obj)
            theTitle=obj.UIDrawScope.Title;
        end


        function outVal=get.XLabel(obj)
            outVal=obj.UIDrawScope.XLabel;
        end


        function set.XLim(obj,inVal)
            try
                obj.UIDrawScope.XLim=inVal;
            catch ME
                throwAsCaller(ME);
            end
        end


        function outVal=get.XLim(obj)
            outVal=obj.UIDrawScope.XLim;
        end


        function set.YLim(obj,inVal)
            try
                obj.UIDrawScope.YLim=inVal;
            catch ME
                throwAsCaller(ME);
            end
        end


        function outVal=get.YLim(obj)
            outVal=obj.UIDrawScope.YLim;
        end


        function set.XRulerType(obj,inVal)
            try
                obj.UIDrawScope.XRulerType=inVal;
            catch ME
                throwAsCaller(ME);
            end
        end


        function outVal=get.XRulerType(obj)
            outVal=obj.UIDrawScope.XRulerType;
        end


        function set.YLabel(obj,inVal)
            try
                obj.UIDrawScope.YLabel=inVal;
            catch ME
                throwAsCaller(ME);
            end
        end


        function outVal=get.YLabel(obj)
            outVal=obj.UIDrawScope.YLabel;
        end


        function set.LineInterpolationType(obj,inVal)
            try
                obj.UIDrawScope.LineInterpolationType=inVal;
            catch ME
                throwAsCaller(ME);
            end
        end



        function fitToView(obj)
            obj.UIDrawScope.fitToView();
        end
    end


    methods(Hidden)


        function updateClient(obj)
            obj.setLineData(1,constructDataFromValue(obj,obj.Value),false);

            obj.UIDrawScope.XLabel=obj.XLabel;
            obj.UIDrawScope.YLabel=obj.YLabel;
            obj.UIDrawScope.XRulerType=obj.XRulerType;
        end


        function outScope=hGetScope(obj)

            outScope=obj.UIDrawScope;
        end
    end


    methods(Access='protected')


        function setup(obj)
            obj.Grid=uigridlayout(obj,[1,1],'ColumnWidth',{'1x'},...
            'RowHeight',{'1x'},'Padding',0);
            obj.UIDrawScope=datacreation.internal.uidrawscope(obj.Grid);
            setUpListeners(obj);
        end


        function setUpListeners(obj)

            obj.ScopeDataListener=addlistener(obj.UIDrawScope,'DataFromClientChange',@obj.onDataFromClient);
            obj.ScopeStartListener=addlistener(obj.UIDrawScope,'StartUpComplete',@obj.onStartupMessage);
            obj.ScopeSelectionListener=addlistener(obj.UIDrawScope,'SelectionFromClientChange',@obj.onSelectionFromClient);
        end


        function update(obj)

            updateClient(obj);
        end



        function onDataFromClient(obj,~,inVal)
            if iscell(inVal.NewState.Data.x)
                inVal.NewState.Data.x;
            end


            if iscell(inVal.NewState.Data.y)

                nanIndices=strcmpi(inVal.NewState.Data.y,'NaN');
                nanIndices=find(nanIndices==1);

                if~isempty(nanIndices)

                    for k=1:length(nanIndices)
                        inVal.NewState.Data.y{nanIndices(k)}=NaN;
                    end

                    inVal.NewState.Data.y=[inVal.NewState.Data.y{:}];
                    [~,N]=size(inVal.NewState.Data.y);

                    if N>1
                        inVal.NewState.Data.y=inVal.NewState.Data.y';
                    end
                end

            end

            obj.Value=constructValueFromData(obj,inVal.NewState.Data);

            theEvent=datacreation.internal.DrawScopeDataChangeEvent(inVal.NewState);

            notify(obj,'ValueChanged',theEvent);
        end

        function onSelectionFromClient(obj,~,inVal)


            obj.SelectedIndices=inVal.NewState.selectedIndex+1;
            theEvent=datacreation.internal.DrawScopeSelectionChangeEvent(inVal.NewState);

            notify(obj,'SelectionChanged',theEvent);
        end


        function validateInput(obj,inVal)

            if isempty(inVal)
                inVal.x=[];
                inVal.y=[];
            end

            if~isstruct(inVal)||~all(isfield(inVal,{'x','y'}))
                error(...
                message('datacreation:datacreation:uicomponentvaluenotstruct'));
            end



            if~(isvector(inVal.x)&&isvector(inVal.y)&&(...
                length(inVal.x)==length(inVal.y)))&&~(isempty(inVal.x)&&isempty(inVal.y))
                error(...
                message('datacreation:datacreation:uicomponentvaluenotstruct'));
            end
        end


        function outData=constructValueFromData(~,inData)
            outData=inData;
        end


        function outData=constructDataFromValue(~,inData)
            outData=inData;
        end


        function onStartupMessage(obj,~,~)

            obj.START_UP_COMPLETE=true;
            updateClient(obj);

            notify(obj,'StartUpComplete');

        end


        function xData=getSelectedXData(obj,inIndices)
            xData=[];
            if~isempty(inIndices)
                xData=obj.Value.x(inIndices);
            end
        end


        function yData=getSelectedYData(obj,inIndices)
            yData=[];
            if~isempty(inIndices)
                yData=obj.Value.y(inIndices);
            end
        end
    end


    methods(Hidden)



        function outUUID=getUUID(obj)
            outUUID=obj.UIDrawScope.getUUID();
        end


        function setLineData(obj,childZeroOrderIndex,inValue,varargin)





            if childZeroOrderIndex~=1
                error(message('datacreation:datacreation:uicomponentnonzeroindex'));
            end

            inVal.NewState.Data=inValue;

            if isempty(varargin)
                forceUPDATE=false;
            else
                forceUPDATE=varargin{1};
            end
            obj.UIDrawScope.setLineData(childZeroOrderIndex,inValue,forceUPDATE);


            if~isempty(varargin)&&varargin{1}
                theEvent=datacreation.internal.DrawScopeDataChangeEvent(inVal.NewState);

                notify(obj,'ValueChanged',theEvent);
            end

        end


        function setDataType(obj,inDataType)

            try

                obj.UIDrawScope.setDataType(inDataType);
            catch ME_DATATYPE
                throwAsCaller(ME_DATATYPE);
            end

        end


        function outDT=getDataType(obj)
            outDT=obj.UIDrawScope.getDataType();
        end


        function setYLim(obj,yLims)

            try
                obj.UIDrawScope.setYLim(yLims);
            catch ME_YLIM
                throwAsCaller(ME_YLIM);
            end

        end


        function setXRulerType(obj,inTypeChar)

            try
                obj.UIDrawScope.setXRulerType(inTypeChar);
            catch ME_XRulerType
                throwAsCaller(ME_XRulerType);
            end

        end


        function setYRulerType(obj,inTypeStruct)

            try
                obj.UIDrawScope.setYRulerType(inTypeStruct);
            catch ME_YRulerType
                throwAsCaller(ME_YRulerType);
            end

        end


        function clearLineData(obj,childID,varargin)

            if childID~=1
                error(message('datacreation:datacreation:uicomponentnonzeroindex'));
            end

            try
                obj.UIDrawScope.clearLineData(childID,varargin{:});
            catch ME_clearLineData
                throwAsCaller(ME_clearLineData);
            end

        end


        function setScopeSelectedPoints(obj,outpayload)
            obj.UIDrawScope.setSelectedPoints(outpayload);
        end

    end
end
