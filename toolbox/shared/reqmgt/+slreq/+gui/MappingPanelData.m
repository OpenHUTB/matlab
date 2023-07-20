classdef MappingPanelData<handle



    properties

        dataImportNode;


        dasReqIndex;







        dasReqs;


        highlightedProperties;


        mappingMessage;


        mappingHelper;
    end

    methods


        function this=MappingPanelData()
            this.dataImportNode=[];
            this.dasReqIndex=[];
            this.dasReqs={};
            this.highlightedProperties={};
            this.mappingMessage='';

            this.mappingHelper=slreq.internal.MappingHelper();
        end


        function init(this,dataImportNode)

            assert(~isempty(dataImportNode));



            if isempty(this.dataImportNode)||~any(this.dataImportNode==dataImportNode)
                this.dataImportNode=dataImportNode;
                this.dasReqIndex=[];


                this.highlightedProperties={};
                this.mappingMessage='';
            end


            this.dasReqs=[];


            if isempty(this.dasReqIndex)


                this.dasReqIndex=1;
            end


            if isempty(this.dasReqs)
                reqData=slreq.data.ReqData.getInstance();
                this.dasReqs=reqData.collectDASObjects(this.dataImportNode,false);
            end
        end

        function out=getHighlightedProperties(this)
            out=this.highlightedProperties;
        end

        function clearHighlightedProperties(this)
            this.highlightedProperties={};
        end

        function clearMessages(this)
            this.mappingMessage='';
        end


        function out=highlightProperty(this,propName)
            if~any(strcmp(this.highlightedProperties,propName))
                this.highlightedProperties{end+1}=propName;
                out=true;
            else
                out=false;
            end
        end

        function out=hasNextRequirement(this)
            out=false;
            if~isempty(this.dasReqs)&&~isempty(this.dasReqIndex)
                nextIndex=this.dasReqIndex+1;
                out=nextIndex<=length(this.dasReqs);
            end
        end

        function out=getNextRequirement(this)
            out=[];
            if~isempty(this.dasReqs)&&~isempty(this.dasReqIndex)
                nextIndex=this.dasReqIndex+1;
                if nextIndex<=length(this.dasReqs)
                    this.dasReqIndex=nextIndex;
                    out=this.dasReqs{nextIndex};
                end
            end
        end

        function out=hasPrevRequirement(this)
            out=false;
            if~isempty(this.dasReqs)&&~isempty(this.dasReqIndex)
                nextIndex=this.dasReqIndex-1;
                out=(nextIndex>=1);
            end
        end

        function out=getPrevRequirement(this)
            out=[];
            if~isempty(this.dasReqs)&&~isempty(this.dasReqIndex)
                nextIndex=this.dasReqIndex-1;
                if nextIndex>=1
                    this.dasReqIndex=nextIndex;
                    out=this.dasReqs{nextIndex};
                end
            end
        end


        function out=getRequirementID(this)
            out='';

            dasReq=this.getCurrentRequirement();




            if~isempty(dasReq)

                out=dasReq.Id;


            end
        end

        function out=getCurrentRequirement(this)
            out=[];

            if~isempty(this.dasReqs)&&~isempty(this.dasReqIndex)&&this.dasReqIndex>=1&&this.dasReqIndex<=length(this.dasReqs)
                out=this.dasReqs{this.dasReqIndex};
            end
        end


        function out=getDASPropertyNames(this)
            out=this.mappingHelper.getDASPropertyNames();
        end


        function[out,idx]=toInternalName(this,displayName)
            [out,idx]=this.mappingHelper.toInternalName(displayName);
        end


        function[out,idx]=toDisplayName(this,internalName)
            [out,idx]=this.mappingHelper.toDisplayName(internalName);
        end


        function out=toPropertyName(this,internalName)
            out=this.mappingHelper.toPropertyName(internalName);
        end

        function type=getBuiltInTypeEnum(this,attributeName)
            type=this.mappingHelper.getBuiltInTypeEnum(attributeName);
        end

        function out=getInternalNames(this)
            out=this.mappingHelper.getInternalNames();
        end

        function out=getDisplayNames(this)
            out=this.mappingHelper.getDisplayNames();
        end

        function out=getDisplayName(this,idx)
            out=this.mappingHelper.getDisplayName(idx);
        end
    end
end

