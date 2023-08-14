classdef(Sealed)ParentChildMatch<handle






    properties(Access=private)
MyParamsMap
    end


    methods(Access=private)


        function this=ParentChildMatch

            this.MyParamsMap=containers.Map('KeyType','char','ValueType','any');

            myStaticData=configset.internal.getConfigSetStaticData();


            paramObjects=myStaticData.getParamObjects();


            for i=1:length(paramObjects)
                paramObj=paramObjects{i};


                if~isempty(paramObj)&&~isempty(paramObj.ModelRef)
                    paramName=paramObj.Name;
                    compName=paramObj.Component;


                    if isKey(this.MyParamsMap,compName)
                        this.MyParamsMap(compName)=[this.MyParamsMap(compName);paramName];
                    else
                        this.MyParamsMap(compName)={paramName};
                    end
                end
            end




            defaultComponents={'ConfigSet'
'Data Import/Export'
'Diagnostics'
'Model Referencing'
'Simulink Coverage'
            'Solver'};
            for count=1:numel(defaultComponents)
                compName=defaultComponents{count};
                if~isKey(this.MyParamsMap,compName)
                    this.MyParamsMap(compName)={};
                end
            end

        end


        function result=getParamListForComponent(obj,compName)
            result={};
            if isKey(obj.MyParamsMap,compName)
                result=obj.MyParamsMap(compName);
            end
        end


        function result=getListOfComponents(obj)
            result=obj.MyParamsMap.keys();
        end


        function result=getParamObject(~,paramName,compName)

            param=[compName,':',paramName];
            myStaticData=configset.internal.getConfigSetStaticData();
            try
                paramObj=myStaticData.getParam(param);
                result=paramObj.ModelRef;
            catch ME
                DAStudio.error('Simulink:slbuild:paramNotInDataModel',param);
            end
        end
    end


    methods(Static)

        function obj=getInstance()
            persistent localObj;
            if isempty(localObj)||~isvalid(localObj)
                localObj=Simulink.ModelReference.internal.configset.ParentChildMatch;
            end
            obj=localObj;
        end


        function result=getParamsList(compName)
            result={};
            obj=Simulink.ModelReference.internal.configset.ParentChildMatch.getInstance();
            if isvalid(obj)
                result=obj.getParamListForComponent(compName);
            end
        end


        function result=getComponentList()
            result={};
            obj=Simulink.ModelReference.internal.configset.ParentChildMatch.getInstance();
            if isvalid(obj)
                result=obj.getListOfComponents();
            end
        end


        function result=getParamStaticDataObject(paramName,compName)
            result=[];
            obj=Simulink.ModelReference.internal.configset.ParentChildMatch.getInstance();
            if isvalid(obj)
                result=obj.getParamObject(paramName,compName);
            end
        end

    end
end
