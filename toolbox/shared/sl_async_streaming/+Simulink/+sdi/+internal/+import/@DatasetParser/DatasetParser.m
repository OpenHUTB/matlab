classdef DatasetParser<Simulink.sdi.internal.import.VariableParser





    methods


        function ret=supportsType(~,obj)
            bIsValidType=...
            isa(obj,'Simulink.SimulationData.Dataset')||...
            isa(obj,'Simulink.SimulationData.DatasetRef');
            ret=...
            bIsValidType&&...
            getLength(obj)>0&&...
            isscalar(obj);
        end


        function ret=getRootSource(this)
            ret=this.VariableName;
        end


        function ret=getTimeSource(~)
            ret='';
        end


        function ret=getDataSource(~)
            ret='';
        end


        function ret=getBlockSource(~)
            ret='';
        end


        function ret=getSID(~)
            ret='';
        end


        function ret=getModelSource(~)
            ret='';
        end


        function ret=getSignalLabel(this)
            ret=char(this.VariableValue.Name);
            if isempty(ret)
                ret=this.VariableName;
            end
        end


        function ret=getPortIndex(~)
            ret=[];
        end


        function ret=getHierarchyReference(~)
            ret='';
        end


        function ret=getTimeDim(~)
            ret=[];
        end


        function ret=getSampleDims(~)
            ret=[];
        end


        function ret=getInterpolation(~)
            ret='';
        end


        function ret=getUnit(~)
            ret='';
        end


        function ret=getMetaData(~)
            ret=[];
        end


        function ret=getTimeValues(~)
            ret=[];
        end


        function ret=getDataValues(~)
            ret=[];
        end


        function ret=isHierarchical(~)
            ret=true;
        end


        function ret=getChildren(this)




            loadIntoMemory(this.VariableValue);



            if isa(this.VariableValue,'Simulink.SimulationData.DatasetRef')
                len=getLength(this.VariableValue);
                elements=cell(1,len);
                for idx=1:len
                    elements{idx}=get(this.VariableValue,idx);
                end
            else
                storage=getStorage(this.VariableValue);
                elements=utGetElements(storage);
                len=numel(elements);
            end


            ret={};
            for idx=1:len
                varName=sprintf('%s.getElement(%d)',this.VariableName,idx);



                if isa(elements{idx},'Simulink.SimulationData.Dataset')
                    ret{end+1}=Simulink.sdi.internal.import.DatasetParser;%#ok<AGROW> 
                elseif isa(elements{idx},'Simulink.SimulationData.Element')
                    ret{end+1}=Simulink.sdi.internal.import.DatasetElementParser;%#ok<AGROW> 
                else
                    vars=struct('VarName',varName,'VarValue',elements{idx});
                    curParser=parseVariables(this.WorkspaceParser,vars);
                    if~isempty(curParser)
                        startIdx=numel(ret)+1;
                        ret=[ret,curParser];%#ok<AGROW> 
                        for idx2=startIdx:numel(ret)
                            ret{idx2}.Parent=this;
                        end
                    end
                    continue
                end

                ret{end}.Parent=this;
                ret{end}.VariableName=varName;
                ret{end}.VariableValue=elements{idx};
                ret{end}.TimeSourceRule='';
                ret{end}.WorkspaceParser=this.WorkspaceParser;
                ret{end}.Metadata=[];
            end

        end


        function ret=allowSelectiveChildImport(~)
            ret=true;
        end


        function ret=isVirtualNode(~)
            ret=false;
        end


        function ret=getRepresentsRun(~)
            ret=false;
        end


        function setRunMetaData(~,~,~)
        end
    end
end
