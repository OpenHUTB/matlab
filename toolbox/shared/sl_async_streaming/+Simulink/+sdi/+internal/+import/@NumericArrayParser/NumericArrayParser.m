classdef NumericArrayParser<Simulink.sdi.internal.import.VariableParser



    properties
SignalIndex
    end


    methods


        function ret=supportsType(this,var)
            ret=false;
            bIsTransposed=false;
            bGlobalTime=false;


            if~isnumeric(var)||~ismatrix(var)||isempty(var)||isscalar(var)
                return
            end


            if strcmpi(this.TimeSourceRule,'model based')
                timeLen=length(this.WorkspaceParser.GlobalTimeVectorValue);
                dataSz=size(var);
                ret=timeLen==dataSz(1);
                bGlobalTime=true;


            elseif strcmpi(this.TimeSourceRule,'scope')
                ret=~iscolumn(var)&&isreal(var)&&issorted(var(:,1));

            elseif strcmpi(this.TimeSourceRule,'siganalyzer')
                ret=~iscolumn(var)&&issorted(var(:,1));

            elseif strcmpi(this.TimeSourceRule,'MATFile')&&isa(var,'double')&&isreal(var)
                ret=~isrow(var)&&issorted(var(1,:));
                bIsTransposed=true;
            end





            if ret
                sz=size(var);
                if bGlobalTime
                    numChannels=sz(2);
                elseif bIsTransposed
                    numChannels=sz(1)-1;
                else
                    numChannels=sz(2)-1;
                end
                if numChannels>8000
                    ret=false;
                end
            end
        end


        function ret=usingGlobalTime(this)
            ret=...
            strcmpi(this.TimeSourceRule,'model based')&&...
            ~isempty(this.WorkspaceParser.GlobalTimeVectorValue);
        end


        function ret=getRootSource(this)
            ret=this.VariableName;
            if strcmpi(this.TimeSourceRule,'MATFile')
                ret=[ret,''''];
            end
        end


        function ret=getTimeSource(this)
            if~isHierarchical(this)
                if usingGlobalTime(this)
                    ret=this.WorkspaceParser.GlobalTimeVectorName;
                else
                    ret=[getRootSource(this),'(:,1)'];
                end
            else
                ret='';
            end
        end


        function ret=getDataSource(this)
            ret='';
            if~isHierarchical(this)
                if isempty(this.SignalIndex)
                    sigIdx=1;
                else
                    sigIdx=this.SignalIndex;
                end
                if usingGlobalTime(this)||strcmpi(this.TimeSourceRule,'siganalyzer')
                    colIdx=sigIdx;
                else


                    colIdx=sigIdx+1;
                end
                ret=sprintf('%s(:,%d)',getRootSource(this),colIdx);
            end
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
            if isempty(this.SignalIndex)
                ret=this.VariableName;
            else
                ret=getDataSource(this);
            end
        end


        function ret=getPortIndex(~)
            ret=[];
        end


        function ret=getHierarchyReference(~)
            ret='';
        end


        function ret=getTimeDim(~)
            ret=1;
        end


        function ret=getSampleDims(~)
            ret=1;
        end


        function ret=getInterpolation(this)
            if strcmp(this.TimeSourceRule,'siganalyzer')
                ret='linear';
            else
                ret='zoh';
            end
        end


        function ret=getUnit(~)
            ret='';
        end


        function ret=getMetaData(~)
            ret=[];
        end


        function ret=getTimeMetadataMode(this)
            if strcmp(this.TimeSourceRule,'siganalyzer')
                if isempty(this.Parent)
                    ret='samples';
                else



                    ret=getTimeMetadataMode(this.Parent);
                end
            else
                ret='';
            end
        end


        function ret=getTimeValues(this)
            if usingGlobalTime(this)
                ret=this.WorkspaceParser.GlobalTimeVectorValue;
            elseif strcmpi(this.TimeSourceRule,'MATFile')
                ret=(this.VariableValue(1,:))';
            else
                ret=this.VariableValue(:,1);
            end
        end


        function ret=getDataValues(this)
            ret=[];
            if~isHierarchical(this)
                if isempty(this.SignalIndex)
                    sigIdx=1;
                else
                    sigIdx=this.SignalIndex;
                end
                if usingGlobalTime(this)
                    colIdx=sigIdx;
                else
                    colIdx=sigIdx+1;
                end
                if strcmpi(this.TimeSourceRule,'MATFile')
                    ret=(this.VariableValue(colIdx,:))';
                else
                    ret=this.VariableValue(:,colIdx);
                end
            end
            if strcmp(this.TimeSourceRule,'siganalyzer')
                ret=double(ret);
            end
        end


        function ret=isHierarchical(this)
            ret=false;
            if isempty(this.SignalIndex)
                sz=size(this.VariableValue);
                if usingGlobalTime(this)
                    ret=sz(2)>1;
                elseif strcmpi(this.TimeSourceRule,'MATFile')
                    ret=sz(1)>2;
                else
                    ret=sz(2)>2;
                end
            end
        end


        function ret=getChildren(this)
            ret={};
            if isHierarchical(this)
                isTransposed=strcmpi(this.TimeSourceRule,'MATFile');
                sz=size(this.VariableValue);
                if usingGlobalTime(this)
                    numChannels=sz(2);
                elseif isTransposed
                    numChannels=sz(1)-1;
                else
                    numChannels=sz(2)-1;
                end
                ret=cell(1,numChannels);
                for idx=1:numChannels
                    ret{idx}=Simulink.sdi.internal.import.NumericArrayParser;
                    ret{idx}.Parent=this;
                    ret{idx}.VariableName=this.VariableName;
                    ret{idx}.VariableBlockPath=this.VariableBlockPath;
                    ret{idx}.VariableSignalName=this.VariableSignalName;
                    ret{idx}.VariableValue=this.VariableValue;
                    ret{idx}.SignalIndex=idx;
                    ret{idx}.TimeSourceRule=this.TimeSourceRule;
                    ret{idx}.WorkspaceParser=this.WorkspaceParser;
                end
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
