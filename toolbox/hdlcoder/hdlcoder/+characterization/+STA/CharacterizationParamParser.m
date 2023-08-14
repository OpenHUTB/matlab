classdef CharacterizationParamParser<handle




    properties
m_params
m_nextIteratorIndex
m_indexToName
m_paramMap
m_modelDependentNextIndex
m_modelDependentToGlobalIndex
m_indexToCount
m_modelDependentIterator
m_modelIndependentNextIndex
m_modelIndependentToGlobalIndex
m_modelIndependentIterator
m_globalToLocalIndex
m_nameToIndex
m_paramList
    end

    methods
        function self=CharacterizationParamParser(params)
            self.m_params=params;
            self.init();
        end

        function init(self)
            self.m_nextIteratorIndex=1;
            self.m_indexToName=containers.Map('KeyType','double','ValueType','any');
            self.m_paramMap=containers.Map('KeyType','char','ValueType','any');
            self.m_modelDependentNextIndex=1;
            self.m_modelDependentToGlobalIndex=containers.Map('KeyType','double','ValueType','double');
            self.m_indexToCount=containers.Map('KeyType','double','ValueType','double');
            self.m_modelIndependentNextIndex=1;
            self.m_modelIndependentToGlobalIndex=containers.Map('KeyType','double','ValueType','double');
            self.m_globalToLocalIndex=containers.Map('KeyType','double','ValueType','any');
            self.m_nameToIndex=containers.Map('KeyType','char','ValueType','double');
            self.m_paramList={};
            self.parseParamSpec(self.m_params);
            self.createIterators();
        end

        function iter=getModelDependentIterator(self)
            iter=self.m_modelDependentIterator;
        end

        function iter=getModelIndependentIterator(self)
            iter=self.m_modelIndependentIterator;
        end


        function pvpairs=getModelDependentParamSettings(self,tuple)
            pvpairs=containers.Map();
            for i=1:numel(self.m_paramList)

                pname=self.m_paramList{i};
                param=self.m_paramMap(pname);
                if(param.regenerateModel==false)
                    continue;
                end
                gindex=self.m_nameToIndex(pname);
                vpair=self.m_globalToLocalIndex(gindex);

                if(vpair{2}~=true)
                    error('param building failed');
                end
                lindex=vpair{1};
                vindex=tuple{lindex};
                pvpairs(pname)={param.values{vindex},param.type};
            end
        end


        function pvpairs=getModelIndependentParamSettings(self,tuple1,tuple2)
            pvpairs=containers.Map();
            for i=1:numel(self.m_paramList)

                pname=self.m_paramList{i};
                param=self.m_paramMap(pname);
                if(param.regenerateModel==true)
                    continue;
                end
                gindex=self.m_nameToIndex(pname);
                vpair=self.m_globalToLocalIndex(gindex);
                lindex=vpair{1};
                if(vpair{2}==true)
                    vindex=tuple1{lindex};
                else
                    vindex=tuple2{lindex};
                end
                pvpairs(pname)={param.values{vindex},param.type};
            end
        end


        function paramList=getParamOrder(self)
            paramList=self.m_paramList;
        end

        function pvpairs=getParamPVPairs(self,map1,map2)
            pvpairs={};
            for i=1:numel(self.m_paramList)
                pname=self.m_paramList{i};
                param=self.m_paramMap(pname);
                if param.doNotOutput==true
                    continue;
                end
                if map1.isKey(pname)
                    value=map1(pname);
                else
                    value=map2(pname);
                end
                pvpairs{end+1}=pname;
                pvpairs{end+1}=value{1};
            end
        end

        function pvpairs=getParamPVPairsforLog(self,map1,map2)
            pvpairs={};
            paramList=self.m_paramMap.keys;
            for i=1:numel(paramList)
                if map1.isKey(paramList{i})
                    value=map1(paramList{i});
                    pvpairs{end+1}=paramList{i};
                    pvpairs{end+1}=value{1};
                end

                if~map1.isKey(paramList{i})&&map2.isKey(paramList{i})
                    value=map2(paramList{i});
                    pvpairs{end+1}=paramList{i};
                    pvpairs{end+1}=value{1};
                end
            end
        end

        function params=getParamSpecForOutput(self)
            params={};
            for i=1:numel(self.m_paramList)
                pname=self.m_paramList{i};
                param=self.m_paramMap(pname);
                if param.doNotOutput==true
                    continue;
                end
                params{end+1}=pname;

            end
        end

        function parseParamSpec(self,paramSpec)
            for i=1:numel(paramSpec)
                param=paramSpec(i);
                if iscell(param.name)
                    self.parseMultiParamSpec(param);
                else
                    self.parseSingleParamSpec(param);
                end
            end
        end


        function parseSingleParamSpec(self,param)
            index=self.createIterator(numel(param.values));
            self.addParam(param);
            self.bindIndex(param.name,index);
        end

        function parseMultiParamSpec(self,params)
            paramStructs=struct([]);
            fields=fieldnames(params);
            for i=1:numel(fields)
                fieldname=fields{i};
                values=params.(fieldname);
                for j=1:numel(values)
                    paramStructs(j).(fieldname)=values{j};
                end
            end

            index=self.createIterator(numel(paramStruct(1).values));
            for i=1:nulem(paramStructs)
                self.addParam(paramStruct(i));
                self.bindIndex(paramStruct.name,index);
            end
        end

        function addParam(self,param)
            self.m_paramMap(param.name)=param;
            self.m_paramList{end+1}=param.name;
        end

        function index=createIterator(self,count)
            index=self.m_nextIteratorIndex;
            self.m_nextIteratorIndex=self.m_nextIteratorIndex+1;
            self.m_indexToCount(index)=count;
        end

        function bindIndex(self,name,index)
            self.m_nameToIndex(name)=index;
            if self.m_indexToName.isKey(index)
                x=self.m_indexToName(index);
                x{end+1}=name;
                self.m_indexToName(index)=x;
                return
            end
            self.m_indexToName(index)={name};
        end

        function createIterators(self)
            self.createParamIterators();
        end

        function createParamIterators(self)

            for i=1:self.m_nextIteratorIndex-1
                isModelSpec=false;
                params=self.m_indexToName(i);
                for j=1:numel(params)
                    if self.m_paramMap(params{j}).regenerateModel==true
                        isModelSpec=true;
                        break;
                    end
                end
                self.bindGlobalToLocalIndex(i,isModelSpec);
            end

            self.createModelDependentIterator();
            self.createModelIndependentIterator();
        end

        function bindGlobalToLocalIndex(self,gIndex,isModelDependent)
            if isModelDependent
                self.m_modelDependentToGlobalIndex(self.m_modelDependentNextIndex)=gIndex;
                self.m_globalToLocalIndex(gIndex)={self.m_modelDependentNextIndex,true};
                self.m_modelDependentNextIndex=self.m_modelDependentNextIndex+1;
            else
                self.m_modelIndependentToGlobalIndex(self.m_modelIndependentNextIndex)=gIndex;
                self.m_globalToLocalIndex(gIndex)={self.m_modelIndependentNextIndex,false};
                self.m_modelIndependentNextIndex=self.m_modelIndependentNextIndex+1;
            end
        end

        function createModelDependentIterator(self)
            ranges={};
            for i=1:self.m_modelDependentNextIndex-1
                gIndex=self.m_modelDependentToGlobalIndex(i);
                maxValue=self.m_indexToCount(gIndex);
                ranges{end+1}=[1,maxValue,1];
            end
            if~isempty(ranges)
                self.m_modelDependentIterator=characterization.STA.MultiIterator('characterization.STA.StepIterator',ranges{1:end});
            else
                ranges={};
                ranges{end+1}=[1,1,1];
                self.m_modelDependentIterator=characterization.STA.MultiIterator('characterization.STA.StepIterator',ranges);
            end

        end

        function createModelIndependentIterator(self)
            ranges={};
            for i=1:self.m_modelIndependentNextIndex-1
                gIndex=self.m_modelIndependentToGlobalIndex(i);
                maxValue=self.m_indexToCount(gIndex);
                ranges{end+1}=[1,maxValue,1];
            end

            if~isempty(ranges)
                self.m_modelIndependentIterator=characterization.STA.MultiIterator('characterization.STA.StepIterator',ranges{1:end});
            else
                ranges={};
                ranges{end+1}=[1,1,1];
                self.m_modelIndependentIterator=characterization.STA.MultiIterator('characterization.STA.StepIterator',ranges);
            end

        end


        function toolDep=hasToolDependentParams(self)

            toolDep=false;
            values=self.m_paramMap.values();
            for i=1:numel(values)

                if values{i}.toolDepedentParam==true
                    toolDep=true;
                    return;
                end
            end

        end

    end

end
