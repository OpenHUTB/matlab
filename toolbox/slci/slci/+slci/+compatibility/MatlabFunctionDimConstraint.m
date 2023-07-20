


classdef MatlabFunctionDimConstraint<slci.compatibility.Constraint

    properties

        fSupportedDim={};
    end

    methods


        function out=getDescription(aObj)%#ok
            out='Matlab function data must be of a supported dimension';
        end


        function obj=MatlabFunctionDimConstraint(aSupportedDim)
            obj.setEnum('MatlabFunctionDim');
            obj.setFatal(false);
            obj.setSupportedDim(aSupportedDim);
        end


        function out=check(aObj)

            out=[];
            owner=aObj.getOwner();

            if isa(owner,'slci.matlab.EMData')
                dataDim=owner.getSize();
            else
                assert(isa(owner,'slci.ast.SFAst'));
                dataDim=owner.getDataDim();
            end
            isMissingDim=isscalar(dataDim)&&(dataDim==-1);

            if~isMissingDim&&~aObj.supportedDim(dataDim)
                out=slci.compatibility.Incompatibility(...
                aObj,...
                aObj.getID(),...
                aObj.ParentBlock().getName());
            end
        end


        function[SubTitle,Information,StatusText,RecAction]=...
            getSpecificMAStrings(aObj,varargin)

            if isa(aObj.getOwner(),'slci.matlab.EMData')
                ownerType='EMData';
            else
                assert(isa(aObj.getOwner(),'slci.ast.SFAst'));
                ownerType='Ast';
            end

            status=varargin{1};
            if status
                status='Pass';
            else
                status='Warn';
            end

            id=strrep(class(aObj),'slci.compatibility.','');
            listSupported=aObj.getListOfStrings(lower(aObj.fSupportedDim),false);
            blk_class_name=aObj.resolveBlockClassName;

            StatusText=DAStudio.message(['Slci:compatibility:',id,ownerType,status]);
            SubTitle=DAStudio.message(['Slci:compatibility:',id,ownerType,'SubTitle'],blk_class_name);

            Information=DAStudio.message(['Slci:compatibility:',id,ownerType,'Info'],...
            blk_class_name,listSupported);
            RecAction=DAStudio.message(['Slci:compatibility:',id,ownerType,'RecAction'],...
            listSupported);

        end


        function out=getID(aObj)
            dims=aObj.fSupportedDim;
            if any(strcmp('ND',dims))
                maxDim='ND';
            elseif any(strcmp('Matrix',dims))
                maxDim='Matrix';
            elseif any(strcmp('Vector',dims))
                maxDim='Vector';
            else
                assert(any(strcmp('Scalar',dims)));
                maxDim='Scalar';
            end
            out=[aObj.getEnum(),maxDim];
        end
    end

    methods(Access=private)

        function setSupportedDim(aObj,aDim)
            assert(all(ismember(aDim,...
            {'Empty','Scalar','Vector','Matrix','ND'})));
            aObj.fSupportedDim=aDim;
        end


        function flag=supportedDim(aObj,dim)
            dimstr=aObj.getDimension(dim);
            flag=any(strcmpi(dimstr,aObj.fSupportedDim));
        end


        function dimstr=getDimension(~,size)
            if any(size==0)
                dimstr='Empty';
            elseif all(size==1)
                dimstr='Scalar';
            elseif(numel(size)==1)...
                ||((numel(size)==2)...
                &&any(size==1))
                dimstr='Vector';
            elseif numel(size)==2
                dimstr='Matrix';
            else
                dimstr='ND';
            end
        end
    end


end
