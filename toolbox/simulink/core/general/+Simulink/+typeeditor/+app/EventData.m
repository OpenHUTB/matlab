classdef(ConstructOnLoad)EventData<event.EventData






    properties(Hidden)
mBusName
mElemName
mElemIdx
mIsConnType
        mOperation char{mustBeEventType(mOperation)}='BusElementChanged'
mPropName
mPropValue
mElemObj
mSourceName
    end

    methods
        function this=EventData(operation,varargin)

            p=inputParser;
            isCharOrStr=@(x)ischar(x)||isstring(x)||iscellstr(x);
            isCharOrNumeric=@(x)isCharOrStr(x)||isnumeric(x);
            isElem=@(x)isa(x,'Simulink.BusElement')||isa(x,'Simulink.ConnectionElement');
            addRequired(p,'Operation',isCharOrStr);
            addParameter(p,'BusName','',isCharOrStr);
            addParameter(p,'ElemName','',isCharOrNumeric);
            addParameter(p,'ElemIdx',-1,@isnumeric);
            addParameter(p,'IsConnType',false,@islogical);
            addParameter(p,'PropName','',isCharOrStr);
            addParameter(p,'PropValue','',isCharOrStr);
            addParameter(p,'ElemObj',Simulink.BusElement.empty,isElem);
            addParameter(p,'SourceName','',isCharOrStr);
            parse(p,operation,varargin{:});


            this.mOperation=p.Results.Operation;
            this.mBusName=p.Results.BusName;
            this.mElemName=p.Results.ElemName;
            this.mElemIdx=p.Results.ElemIdx;
            this.mIsConnType=p.Results.IsConnType;
            this.mPropName=p.Results.PropName;
            this.mPropValue=p.Results.PropValue;
            this.mElemObj=p.Results.ElemObj;
            this.mSourceName=p.Results.SourceName;
        end
    end
end

function mustBeEventType(var)
    mustBeMember(var,unique(vertcat(events(Simulink.typeeditor.app.Source),...
    events(Simulink.typeeditor.app.Root))));
end