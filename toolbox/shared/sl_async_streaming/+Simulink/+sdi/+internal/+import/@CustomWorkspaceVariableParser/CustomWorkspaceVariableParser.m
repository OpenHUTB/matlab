classdef CustomWorkspaceVariableParser<Simulink.sdi.internal.import.VariableParser




    properties
CustomImporter
    end


    methods


        function ret=supportsType(this,obj)
            ret=this.CustomImporter.supportsVariable(obj);
        end

        function ret=getFullBlockPath(this)
            ret=this.CustomImporter.getBlockPath();
            if~isa(ret,'Simulink.SimulationData.BlockPath')
                ret=Simulink.SimulationData.BlockPath(ret);
            end
        end

        function ret=getSignalLabel(this)
            ret=char(this.CustomImporter.getName());
        end

        function ret=getDescription(this)
            ret=char(this.CustomImporter.getSignalDescription());
        end

        function ret=getPortIndex(this)
            ret=this.CustomImporter.getPortIndex();
        end

        function ret=getSampleDims(this)
            ret=this.CustomImporter.getSampleDimensions();
        end

        function ret=getInterpolation(this)
            ret=char(this.CustomImporter.getInterpolation());
        end

        function ret=isEventBasedSignal(this)
            ret=this.CustomImporter.isEventBasedSignal();
        end

        function ret=getUnit(this)
            ret=char(this.CustomImporter.getUnit());
        end

        function ret=getTimeValues(this)
            ret=this.CustomImporter.getTimeValues();
        end

        function ret=getDataValues(this)
            ret=this.CustomImporter.getDataValues();
        end

        function ret=getChildren(this)
            importers=this.CustomImporter.getChildren();
            ret=cell(size(importers));
            for idx=1:numel(importers)
                ret{idx}=Simulink.sdi.internal.import.CustomWorkspaceVariableParser;
                ret{idx}.CustomImporter=importers{idx};
                ret{idx}.Parent=this;
                ret{idx}.WorkspaceParser=this.WorkspaceParser;
            end
        end


        function ret=getBlockSource(this)
            bp=this.getFullBlockPath();
            ret=Simulink.sdi.internal.import.DatasetElementParser.concatMdlRefBlockPath(bp);
        end

        function ret=getModelSource(this)
            ret='';
            bp=this.getFullBlockPath();
            if bp.getLength()>0
                bpath=bp.getBlock(1);
                ret=Simulink.SimulationData.BlockPath.getModelNameForPath(bpath);
            end
        end

        function[logName,sigName,propName]=getCustomExportNames(this)
            logName=this.getSignalLabel();
            sigName=logName;
            propName='';
        end

        function ret=getTimeDim(this)
            dims=getSampleDims(this);
            ret=1;
            if length(dims)>1
                ret=length(dims)+1;
            end
        end

        function ret=isHierarchical(this)
            children=this.CustomImporter.getChildren();
            ret=~isempty(children);
        end


        function ret=getRootSource(this)
            ret=this.CustomImporter.VariableName;
        end

        function ret=allowSelectiveChildImport(~)
            ret=true;
        end

        function ret=isVirtualNode(~)
            ret=false;
        end

        function ret=getTimeSource(~)
            ret='';
        end

        function ret=getDataSource(this)
            ret=[this.CustomImporter.VariableName,'.Data'];
        end

        function ret=getSID(~)
            ret='';
        end

        function ret=getHierarchyReference(~)
            ret='';
        end

        function ret=getDomainType(~)
            ret='';
        end

        function ret=getMetaData(~)
            ret=[];
        end

        function ret=getRepresentsRun(~)
            ret=false;
        end

        function setRunMetaData(~,~,~)
        end

    end

end
