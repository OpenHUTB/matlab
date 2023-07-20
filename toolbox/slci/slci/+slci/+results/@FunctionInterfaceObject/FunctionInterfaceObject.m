classdef FunctionInterfaceObject<slci.results.SourceObject




    properties(Access=protected)
        fName;






        fSubstatusMap;
        fType;




        fVerificationImpl;
    end

    methods(Access=public,Hidden=true)


        function obj=FunctionInterfaceObject(aKey,aName,aType)
            if nargin==0

                DAStudio.error('Slci:results:DefaultConstructorError',...
                'FUNCTION INTERFACE');
            end
            slci.results.FunctionInterfaceObject.validateKey(aKey);
            obj=obj@slci.results.SourceObject(aKey);
            akeys={'DEFINED','NUMARG','ARGTYPE','ARGNAME','RETURNTYPE'};
            avalues={'UNKNOWN','UNKNOWN','UNKNOWN',...
            'UNKNOWN','UNKNOWN'};
            obj.fSubstatusMap=containers.Map(akeys,avalues);
            obj.setName(aName);
            obj.setType(aType);
        end

        function setName(obj,aName)
            obj.fName=aName;
        end

        function aName=getName(obj)
            aName=obj.fName;
        end

        function setType(obj,aType)
            obj.fType=aType;
        end

        function aType=getType(obj)
            aType=obj.fType;
        end

        function verificationInfo=getVerificationInfo(obj)
            verificationInfo=obj.fVerificationImpl;
        end

    end

    methods(Access=public,Hidden=true)


        function addEngineVerSubstatus(obj,aStatus)
            verInfo=obj.getVerificationInfo();
            verInfo.addEngineSubstatus(aStatus);
        end



        function setStatus(obj,aStatus)
            if any(strcmp(obj.fReportConfig.getTopVerStatusList(),aStatus))
                obj.Status=aStatus;
            else
                DAStudio.error('Slci:results:InvalidStatus',aStatus);
            end
        end

        function setSubstatus(obj,aSubstatusType,aSubstatus)
            if~isKey(obj.fSubstatusMap,aSubstatusType)
                obj.fSubstatusMap(aSubstatusType)=aSubstatus;
            else
                oldSubstatus=obj.fSubstatusMap(aSubstatusType);
                if strcmp(oldSubstatus,'UNKNOWN')
                    obj.fSubstatusMap(aSubstatusType)=aSubstatus;
                else
                    DAStudio.error('Slci:results:ConflictingFunctionInterfaceStatus',obj.getKey());
                end
            end
        end


        function computeStatus(obj,varargin)
            vs=values(obj.fSubstatusMap);
            aggStatus=obj.fReportConfig.defaultStatus;
            for k=1:numel(vs)
                aSubstatus=vs{k};
                aggStatus=obj.fReportConfig.getHeaviestStatus(aSubstatus,...
                aggStatus);
            end




            obj.setStatus(obj.fReportConfig.getTopVerStatus(aggStatus));
        end

        function aSubstatus=getSubstatus(obj,aSubstatusType)
            aSubstatus=obj.fSubstatusMap(aSubstatusType);
        end


        function dispName=getDispName(obj)
            switch obj.getType()
            case 'systemReset'
                dispType='system reset';
            case 'systemInitialize'
                dispType='system initialize';
            otherwise
                dispType=obj.getType();
            end
            dispName=[dispType,' function interface'];
        end
    end


    methods(Access=protected)


        function checkTraceObj(obj,aTraceObj)%#ok
            if~isa(aTraceObj,'slci.results.CodeObject')
                DAStudio.error('Slci:results:ErrorTraceObjects',...
                'FUNCTION INTERFACE',class(aTraceObj));
            end
        end

    end

    methods(Static=true,Access=protected,Hidden=true)

        function validateKey(aKey)
            if(isempty(aKey)||~ischar(aKey))
                DAStudio.error('Slci:results:InvalidKey','FUNCTIONINTERFACE');
            end
        end

    end

    methods(Static,Hidden,Access=public)


        function key=constructKey(aSysName,aType,aSampleTime)
            key=[aSysName,'_',num2str(aSampleTime),'_',aType];
        end

    end


end
