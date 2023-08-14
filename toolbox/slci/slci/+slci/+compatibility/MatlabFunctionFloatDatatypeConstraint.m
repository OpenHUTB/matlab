


classdef MatlabFunctionFloatDatatypeConstraint<...
    slci.compatibility.MatlabFunctionDatatypeConstraint

    methods


        function out=getDescription(aObj)%#ok
            out=['Matlab function data must be of type '...
            ,'''single'' or''double'' '];
        end


        function obj=MatlabFunctionFloatDatatypeConstraint
            obj.setEnum('MatlabFunctionFloatDatatype');
            obj.setFatal(false);
            obj.fSupportedTypes={'single','double'};
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();
            children=owner.getChildren();

            datatypes=cellfun(@getDataType,children,...
            'UniformOutput',false);
            datatypes=unique(datatypes);

            datatypes(cellfun(@isempty,datatypes))=[];
            if isempty(datatypes)||numel(datatypes)>1


                return;
            end

            dataType=datatypes{1};

            isSupported=any(strcmp(dataType,aObj.fSupportedTypes));
            if~isSupported
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getEnum(),...
                aObj.resolveBlockClassName,...
                aObj.ParentBlock().getName());
            end

        end


        function[SubTitle,Information,StatusText,RecAction]=...
            getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            id=strrep(class(aObj),'slci.compatibility.','');
            if status
                status='Pass';
            else
                status='Warn';
            end
            if isa(aObj.getOwner(),'slci.matlab.EMData')
                ownerType='EMData';
            else
                assert(isa(aObj.getOwner(),'slci.ast.SFAst'));
                ownerType='Ast';
            end
            blk_class_name=aObj.resolveBlockClassName;
            StatusText=DAStudio.message(['Slci:compatibility:',id,ownerType,status],blk_class_name);
            RecAction=DAStudio.message(['Slci:compatibility:',id,ownerType,'RecAction']);
            SubTitle=DAStudio.message(['Slci:compatibility:',id,ownerType,'SubTitle'],blk_class_name);
            Information=DAStudio.message(['Slci:compatibility:',id,ownerType,'Info'],blk_class_name);
        end

    end

end