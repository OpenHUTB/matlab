



classdef TranslationMessage<handle

    properties(Constant,Access=protected)
        Id2CodeId=containers.Map(...
        {'sldv_sfcn:il2cgel:runTimeErrorInUserCode','sldv_sfcn:il2cgel:nonEliminatedNaN','sldv_sfcn:il2cgel:nonEliminatedInf'},...
        {'sldv_sfcn:il2cgel:runTimeErrorInCode','sldv_sfcn:il2cgel:nonEliminatedCodeNaN','sldv_sfcn:il2cgel:nonEliminatedCodeInf'}...
        )
    end

    properties(GetAccess=public)

Type




DisplayType
Id
Params
    end

    properties(Access=private)
        LocationInfo=[]
    end

    properties(Constant=true)
        InternalErrorType='internalError'
        TranslationErrorType='error'
        ErrorType='error'
        WarningType='warning'
    end

    properties(Constant=true)


        LocationNone=0

        LocationFunction=1


        LocationIrScope=2


        LocationSource=3
    end

    methods
        function obj=TranslationMessage(msgType,msgId,msgParams)
            if nargin<3
                msgParams={};
            end

            obj.Type=msgType;
            obj.Id=msgId;
            obj.Params=msgParams;

            if strcmp(msgType,obj.TranslationErrorType)
                obj.DisplayType=obj.WarningType;
            elseif strcmp(msgType,obj.InternalErrorType)
                obj.DisplayType=obj.ErrorType;
            else
                obj.DisplayType=obj.Type;
            end
        end

        function msgString=getString(obj)
            msg=message(obj.Id,obj.Params{:});
            msgString=msg.getString();

            switch obj.getLocationType()
            case obj.LocationFunction
                msg=message('sldv_sfcn:sldv_sfcn:functionLocation',...
                obj.LocationInfo.Value,...
                msgString);
                msgString=msg.getString();
            case obj.LocationSource
                msg=message('sldv_sfcn:sldv_sfcn:sourceLocation',...
                obj.LocationInfo.Value.File,...
                obj.LocationInfo.Value.Line,...
                msgString);
                msgString=msg.getString();
            end
        end

        function setLocationFromIr(obj,irScope,irFunction)
            if~isempty(irFunction)
                functionName=irFunction;
                obj.setLocation(obj.LocationFunction,functionName);
            elseif~isempty(irScope)
                obj.setLocation(obj.LocationIrScope,irScope);
            end
        end



        function setSourceLocation(obj,sourceFile,sourceLine)
            obj.setLocation(obj.LocationSource,struct('File',sourceFile,'Line',sourceLine));
        end

        function hasInfo=hasLocationInfo(obj)

            hasInfo=obj.getLocationType()~=obj.LocationNone;
        end
    end

    methods(Hidden=true)
        function fixXilIds(obj)
            for ii=1:numel(obj)
                if obj(ii).Id2CodeId.isKey(obj(ii).Id)
                    obj(ii).Id=obj(ii).Id2CodeId(obj(ii).Id);
                end
            end
        end

        function showMessage(obj,testComp)
            for ii=1:numel(obj)
                messageString=obj(ii).getString();
                sldv.code.internal.showString(testComp,obj(ii).DisplayType,messageString);
            end
        end
    end

    methods(Access=private)
        function locationType=getLocationType(obj)
            if isempty(obj.LocationInfo)
                locationType=obj.LocationNone;
            else
                locationType=obj.LocationInfo.Type;
            end
        end

        function setLocation(obj,locationType,locationValue)
            obj.LocationInfo=struct('Type',locationType,...
            'Value',locationValue);
        end
    end
end
