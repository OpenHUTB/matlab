classdef(Hidden)uidrawscope<handle






    properties(Access=protected)

UiHtmlContainer
UUID

StartUpToken
GetDataFromServerToken
GetSelectionFromServerToken
GetLimitsFromServerToken

        BaseUrl='toolbox/shared/datacreation/index.html'
        DebugBaseUrl='toolbox/shared/datacreation/index-debug.html'

        START_UP_COMPLETE=false
        IS_DEBBUG=false


        DataType='double'

        ALLOWED_DATA_TYPES={'double','single',...
        'int8','uint8','int16','uint16','int32','uint32',...
        'int64','uint64','half','boolean'};

    end


    properties
        YLabel char=''
        XLabel char=''
        XLim(1,2)double{mustBeReal,mustBeFinite}=[0,10]
        YLim(1,2)double{mustBeReal,mustBeFinite}=[0,10]
        LineInterpolationType{mustBeMember(LineInterpolationType,{'linear','zoh','discrete','continuous'})}='linear'
        XRulerType{mustBeMember(XRulerType,{'vector','timebased'})}='timebased'
        Title char=''
    end


    events
StartUpComplete
DataFromClientChange
SelectionFromClientChange
    end


    methods


        function obj=uidrawscope(inParent,varargin)

            obj.UUID=char(matlab.lang.internal.uuid());
            subscribeToClientSideDraw(obj);

            obj.UiHtmlContainer=uihtml(inParent);

            if~isempty(varargin)
                obj.IS_DEBBUG=varargin{1};
            end

            if(obj.IS_DEBBUG)
                tempUrl=connector.getUrl(obj.DebugBaseUrl);
            else
                tempUrl=connector.getUrl(obj.BaseUrl);
            end


            sep='?';
            if strfind(tempUrl,'?')>1
                sep='&';
            end

            tempUrl=strcat(tempUrl,sep,'UUID=',obj.UUID,' ');
            obj.UiHtmlContainer.HTMLSource=tempUrl;
        end


        function delete(obj)
            message.unsubscribe(obj.StartUpToken);
            message.unsubscribe(obj.GetDataFromServerToken);
            delete(obj.UiHtmlContainer);
        end


        function outUUID=getUUID(obj)
            outUUID=obj.UUID;
        end


        function set.Title(obj,inVal)
            obj.Title=inVal;
            setTitle(obj,obj.Title);
        end


        function setTitle(obj,inTitle)
            msg.title=inTitle;

            message.publish(['/livetask/datacreation/servertitleupdate/'...
            ,obj.getUUID()],msg);
        end


        function set.YLabel(obj,inVal)
            obj.YLabel=inVal;
            setYLabel(obj,obj.YLabel);
        end


        function set.XLabel(obj,inVal)
            obj.XLabel=inVal;
            setXLabel(obj,obj.XLabel);
        end


        function set.YLim(obj,inVal)
            obj.YLim=inVal;
            setYLim(obj,obj.YLim);
        end


        function set.XLim(obj,inVal)
            obj.XLim=inVal;
            setXLim(obj,obj.XLim);
        end


        function set.XRulerType(obj,inVal)
            obj.XRulerType=inVal;
            setXRulerType(obj,inVal);
        end


        function setXRulerType(obj,inTypeChar)
            msg.type=inTypeChar;

            message.publish(['/livetask/datacreation/serverxrulerupdate/'...
            ,obj.getUUID()],msg);
        end


        function set.LineInterpolationType(obj,inType)
            obj.LineInterpolationType=inType;
            obj.setInterp(obj.LineInterpolationType);

        end


        function setInterp(obj,inVal)
            msg.interp=inVal;
            message.publish(['/livetask/datacreation/interp/'...
            ,obj.getUUID()],msg);
        end


        function setYRulerType(obj,inTypeStruct)
            msg.isEnum=false;

            if isfield(inTypeStruct,'isEnum')
                msg.isEnum=inTypeStruct.isEnum;
                msg.enumerationDef=inTypeStruct.enumerationDef;
                msg.enumerationName=inTypeStruct.enumerationName;
            end


            message.publish(['/livetask/datacreation/serveryrulerupdate/'...
            ,obj.getUUID()],msg);
        end


        function setYLabel(obj,inLabel)
            msg.label=inLabel;
            message.publish(['/livetask/datacreation/ylabel/'...
            ,obj.getUUID()],msg);
        end


        function setXLabel(obj,inLabel)
            msg.label=inLabel;
            message.publish(['/livetask/datacreation/xlabel/'...
            ,obj.getUUID()],msg);
        end


        function clearLineData(obj,childID,varargin)

            msg.childID=childID-1;

            if~isempty(varargin)
                msg.FORCE_CALL_UPDATE=varargin{1};
            end

            message.publish(['/livetask/datacreation/servercleardata/'...
            ,obj.getUUID()],msg);
        end


        function setLineData(obj,childID,dataStruct,varargin)
            msg.childID=childID;
            msg.Data=dataStruct;

            if isempty(msg.Data)
                msg.Data.x=[];
                msg.Data.y=[];
            end

            msg.Data.x=datacreation.internal.makeJsonSafe(msg.Data.x);
            msg.Data.y=datacreation.internal.makeJsonSafe(msg.Data.y);
            msg.FORCE_CALL_UPDATE=true;

            if~isempty(varargin)
                msg.FORCE_CALL_UPDATE=varargin{1};
            end

            message.publish(['/livetask/datacreation/serversetdata/'...
            ,obj.getUUID()],msg);
        end


        function outBool=getSTART_UP_COMPLETE(obj)
            outBool=obj.START_UP_COMPLETE;
        end


        function setDataType(obj,inDataType)

            enumObj=enumeration(inDataType);


            if~ischar(inDataType)||(~any(strcmp(inDataType,obj.ALLOWED_DATA_TYPES))&&...
                isempty(enumObj))
                error(message('datacreation:datacreation:scopeDataTypeError',inDataType));
            end

            obj.DataType=inDataType;

            msg.DataType=obj.DataType;

            message.publish(['/livetask/datacreation/setdatatype/'...
            ,obj.getUUID()],msg);

        end


        function setYLim(obj,yLims)
            msg.yLim=yLims;
            message.publish(['/livetask/datacreation/ylimitsupdate/'...
            ,obj.getUUID()],msg);
        end


        function setXLim(obj,xLims)
            msg.xLim=xLims;
            message.publish(['/livetask/datacreation/xlimitsupdate/'...
            ,obj.getUUID()],msg);
        end


        function setSelectedPoints(obj,selectedDataStruct)
            msg=selectedDataStruct;
            message.publish(['/livetask/datacreation/setselectedpoints/'...
            ,obj.getUUID()],msg);
        end

    end


    methods(Access=public)

        function onStartupMessage(obj,~)

            notify(obj,'StartUpComplete');
            obj.START_UP_COMPLETE=true;
        end


        function onDataFromClient(obj,inVal)
            inVal.Data.x=datacreation.internal.getMATLABValueFromConnectorData(inVal.Data.x);

            if iscell(inVal.Data.x)
                inVal.Data.x=cell2mat(inVal.Data.x);
            end

            inVal.Data.y=datacreation.internal.getMATLABValueFromConnectorData(inVal.Data.y);

            if iscell(inVal.Data.y)
                inVal.Data.y=cell2mat(inVal.Data.y);
            end

            theEvent=datacreation.internal.DrawScopeDataChangeEvent(inVal);
            notify(obj,'DataFromClientChange',theEvent);

        end


        function onSelectionFromClient(obj,inVal)
            theEvent=datacreation.internal.DrawScopeSelectionChangeEvent(inVal);
            notify(obj,'SelectionFromClientChange',theEvent);
        end


        function onLimitsFromClient(obj,inVal)
            obj.XLim=inVal.x;
            obj.YLim=inVal.y;
        end


        function outDataType=getDataType(obj)
            outDataType=obj.DataType;
        end


        function fitToView(obj)
            msg.fitToView=true;
            message.publish(['/livetask/datacreation/fittoview/'...
            ,obj.getUUID()],msg);
        end
    end


    methods(Access=protected)


        function subscribeToClientSideDraw(obj)


            obj.StartUpToken=message.subscribe(...
            ['/livetask/datacreation/startup/',obj.UUID],@(inVal)onStartupMessage(obj,inVal));

            obj.GetDataFromServerToken=message.subscribe(...
            ['/livetask/datacreation/senddatatoserver/',obj.UUID],...
            @(inVal)onDataFromClient(obj,inVal));

            obj.GetSelectionFromServerToken=message.subscribe(...
            ['/livetask/datacreation/sendselectiontoserver/',obj.UUID],...
            @(inVal)onSelectionFromClient(obj,inVal));

            obj.GetLimitsFromServerToken=message.subscribe(...
            ['/livetask/datacreation/sendlimitstoserver/',obj.UUID],...
            @(inVal)onLimitsFromClient(obj,inVal));
        end

    end


    methods(Access=public,Hidden)


        function outUiHtmlContainer=getUiHtml(obj)
            outUiHtmlContainer=obj.UiHtmlContainer;
        end
    end


    methods(Static,Hidden)


        function debugUrl=getDebugUrl()

            UUID=char(matlab.lang.internal.uuid());

            tempUrl=connector.getUrl('toolbox/shared/datacreation/index-debug.html');



            sep='?';
            if strfind(tempUrl,'?')>1
                sep='&';
            end

            debugUrl=strcat(tempUrl,sep,'UUID=',UUID,' ');
        end


        function releaseUrl=getReleaseUrl()

            UUID=char(matlab.lang.internal.uuid());

            tempUrl=connector.getUrl('toolbox/shared/datacreation/index.html');



            sep='?';
            if strfind(tempUrl,'?')>1
                sep='&';
            end

            releaseUrl=strcat(tempUrl,sep,'UUID=',UUID,' ');
        end

    end
end
