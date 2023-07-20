classdef MappingHelper<handle



    properties





        builtIns;
    end

    methods

        function this=MappingHelper()







            this.builtIns={'customId',getString(message('Slvnv:slreq_import:PrimaryID')),'Id';...
            'summary',getString(message('Slvnv:slreq:Summary')),'Summary';...
            'description',getString(message('Slvnv:slreq_import:Description')),'Description';...
            'rationale',getString(message('Slvnv:slreq_import:Rationale')),'Rationale';...
            'keywords',getString(message('Slvnv:slreq:Keywords')),'Keywords';...
            'createdOn',getString(message('Slvnv:slreq:CreatedOn')),'CreatedOn';...
            'modifiedOn',getString(message('Slvnv:slreq:ModifiedOn')),'ModifiedOn';...
            'createdBy',getString(message('Slvnv:slreq:CreatedBy')),'CreatedBy';...
            'modifiedBy',getString(message('Slvnv:slreq:ModifiedBy')),'ModifiedBy'};

        end


        function out=getInternalNames(this)
            out=this.builtIns(:,1);
        end


        function out=getDisplayNames(this)
            out=this.builtIns(:,2);
        end

        function out=getDisplayName(this,idx)
            out=this.builtIns(idx,2);
        end


        function out=getDASPropertyNames(this)
            out=this.builtIns(:,3)';
        end


        function[out,idx]=toInternalName(this,displayName)
            out=displayName;

            idx=find(strcmpi(displayName,this.builtIns(:,2)));
            if~isempty(idx)

                out=this.builtIns{idx,1};
            end
        end


        function[out,idx]=toDisplayName(this,internalName)
            out=internalName;

            idx=find(strcmpi(internalName,this.builtIns(:,1)));
            if~isempty(idx)

                out=this.builtIns{idx,2};
            end
        end


        function out=toPropertyName(this,internalName)
            out=internalName;

            idx=find(strcmpi(internalName,this.builtIns(:,1)));
            if~isempty(idx)
                out=this.builtIns{idx,3};
            end
        end


        function out=isBuiltIn(this,attributeName)
            out=any(strcmp(attributeName,this.builtIns(:,1)'));
        end


        function type=getBuiltInTypeEnum(this,attributeName)

            switch(lower(attributeName))
            case 'summary'
                type=slreq.datamodel.AttributeTypeEnum.String;
            case 'description'
                type=slreq.datamodel.AttributeTypeEnum.Xhtml;
            case 'rationale'
                type=slreq.datamodel.AttributeTypeEnum.Xhtml;
            case 'customid'
                type=slreq.datamodel.AttributeTypeEnum.String;
            case{'modifiedon','createdon'}
                type=slreq.datamodel.AttributeTypeEnum.Date;
            case{'modifiedby','createdby'}
                type=slreq.datamodel.AttributeTypeEnum.String;
            case 'keywords'

                type=slreq.datamodel.AttributeTypeEnum.String;
            otherwise

                type=slreq.datamodel.AttributeTypeEnum.Any;
            end
        end
    end
end

