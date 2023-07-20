classdef SimscapeSeriesParser<Simulink.sdi.internal.import.VariableParser



    methods


        function ret=supportsType(~,obj)
            ret=...
            isa(obj,'simscape.logging.Node')&&...
            ~numChildren(obj);
        end


        function ret=getRootSource(this)
            ret=this.VariableName;
        end


        function ret=getTimeSource(this)
            ret=[this.VariableName,'.series.time'];
        end


        function ret=getDataSource(this)
            ret=[this.VariableName,'.series.values'];
        end


        function ret=getBlockSource(this)
            ret='';
            if~isempty(this.Parent)&&isa(this.Parent,'Simulink.sdi.internal.import.SimscapeNodeParser')
                ret=getBlockSource(this.Parent);
            end
        end


        function ret=getSID(this)
            ret='';
            if~isempty(this.Parent)&&isa(this.Parent,'Simulink.sdi.internal.import.SimscapeNodeParser')
                ret=getSID(this.Parent);
            end
        end


        function ret=getModelSource(this)
            ret='';
            if~isempty(this.Parent)&&isa(this.Parent,'Simulink.sdi.internal.import.SimscapeNodeParser')
                ret=getModelSource(this.Parent);
            end
        end


        function ret=getSignalLabel(this)
            ret=this.VariableValue.id;
        end


        function ret=getPortIndex(~)
            ret=[];
        end


        function ret=getHierarchyReference(this)
            ret='';
            if~isempty(this.Parent)&&isa(this.Parent,'Simulink.sdi.internal.import.SimscapeNodeParser')
                ret=getHierarchyReference(this.Parent);
            end
        end


        function ret=getTimeDim(this)
            dims=getSampleDims(this);
            nDims=numel(dims);
            if nDims>1
                ret=nDims+1;
            else
                ret=1;
            end
        end


        function ret=getSampleDims(this)




            ret=this.VariableValue.series.dimension;
            assert(numel(ret)==2,'The dimension size is incorrect');
            if ret(1)==1
                ret=ret(2);
            elseif ret(2)==1
                ret=ret(1);
            end
        end


        function ret=getInterpolation(~)
            ret='linear';
        end


        function ret=getUnit(this)
            ret=this.VariableValue.series.unit;
            try

                deltaRet=['delta',ret];
                if isequal(this.VariableValue.series.conversion,'relative')&&...
                    pm_isunit(deltaRet)&&...
                    pm_commensurate(ret,deltaRet)
                    linear=pm_unit(ret,deltaRet);
                    if isequal(linear(1),1)
                        ret=deltaRet;
                    end
                end
            catch e %#ok<NASGU>

            end
        end


        function ret=getMetaData(~)
            ret=[];
        end


        function ret=getTimeValues(this)
            ret=time(this.VariableValue.series);
        end


        function ret=getDataValues(this)
            dims=getSampleDims(this);
            if numel(dims)>1
                ret=reshape((this.VariableValue.series.values)',...
                [dims,this.VariableValue.series.points]);
            else
                ret=values(this.VariableValue.series);
            end
        end


        function ret=getTimeAndDataForSignalConstruction(this)


            if useLazyConstruction(this)
                ret.Time=0;
                ret.Data=0;
            else
                ret=getTimeAndDataForSignalConstruction@Simulink.sdi.internal.import.VariableParser(this);
            end
        end


        function ret=useLazyConstruction(this)
            if strcmp(this.VariableValue.loggingMode,'disk')&&...
                prod(getSampleDims(this))==1
                ret=this.WorkspaceParser.EnableLazyImport;
            else
                ret=false;
            end
        end


        function ret=isHierarchical(~)
            ret=false;
        end


        function ret=getChildren(~)
            ret={};
        end


        function ret=allowSelectiveChildImport(~)
            ret=false;
        end


        function ret=isVirtualNode(~)
            ret=false;
        end


        function ret=getRepresentsRun(~)
            ret=false;
        end


        function setRunMetaData(~,~,~)
        end


        function ret=getDomainType(~)
            ret='ssc_var';
        end


        function ret=getDescription(this)
            ret=getDescription(this.VariableValue);
        end
    end
end
