


classdef FiOperatorMapper<handle

    properties
templatePath
        userPath;
        userFcnMap;
mappingTable
fiTemplateManager
doubleToSingle
    end

    methods
        function this=FiOperatorMapper(templatePath,userPath,userFcnMap,doubleToSingle)
            if nargin==3
                doubleToSingle=false;
            end
            this.templatePath=templatePath;
            this.userPath=userPath;
            this.userFcnMap=userFcnMap;
            this.mappingTable=containers.Map();
            this.fiTemplateManager=coder.internal.FiTemplateManager(templatePath);
            this.doubleToSingle=doubleToSingle;
        end

        function beginSession(this)
            this.fiTemplateManager.beginSession(this.userPath);
            this.mappingTable=coder.internal.FiOperatorMapper.getMappingTable(this.doubleToSingle);

            if~isempty(this.userFcnMap)
                keys=this.userFcnMap.keys;
                for ii=1:length(keys)
                    nodeName=keys{ii};
                    replacement=this.userFcnMap(nodeName);
                    if strcmp(replacement,this.getMapping(nodeName,false))


                    elseif(isempty(replacement))


                    else
                        this.addMapping(nodeName,replacement);
                    end
                end
            end
        end

        function mapping=getMapping(this,operatorKind,isUsed)
            if isempty(this.mappingTable)
                this.mappingTable=coder.internal.FiOperatorMapper.getMappingTable(this.doubleToSingle);
            end

            opKind=lower(operatorKind);
            if this.mappingTable.isKey(opKind)
                mapping=this.mappingTable(opKind);
                if(isUsed)
                    this.fiTemplateManager.useFunction(mapping);
                end
            else
                mapping='';
            end
        end

        function fcns=getReplacementFcnsUsed(this)
            fcns=this.fiTemplateManager.getReplacementFcnsUsed();
        end

        function deps=getFunctionDependencies(this,fcn)
            deps=this.fiTemplateManager.getFunctionDependencies(fcn);
        end

        function code=getLibraryCode(this,fcnUsed)
            if nargin<2
                code=this.fiTemplateManager.getLibraryCode();
            else
                code=this.fiTemplateManager.getLibraryCode(fcnUsed);
            end
        end

        function addMapping(this,key,mapping)
            this.mappingTable(lower(key))=mapping;
        end

        function removeUserFcnMapping(this,key)




            assert(this.userFcnMap.isKey(key));

            this.userFcnMap.remove(key);
            this.mappingTable.remove(key);
        end
    end

    methods(Static)
        function mappingTable=getMappingTable(doubleToSingle)
            mappingTable=containers.Map();

            if doubleToSingle


                mappingTable(lower('SINGLE_CONST'))='single_const';
                return;
            end

            div_rep_fcnName='fi_div';
            dotDiv_rep_fcnName='fi_dotdiv';










            mappingTable(lower('DIVIDE'))=div_rep_fcnName;
            mappingTable(lower('DOTDIV'))=dotDiv_rep_fcnName;

            mappingTable(lower('MRDIVIDE'))=div_rep_fcnName;
            mappingTable(lower('RDIVIDE'))=dotDiv_rep_fcnName;
            mappingTable(lower('DIVIDE_BY_POW2'))='fi_div_by_shift';
            mappingTable(lower('UMINUS'))='fi_uminus';
            mappingTable(lower('BITAND'))='fi_bitand';
            mappingTable(lower('BITOR'))='fi_bitor';
            mappingTable(lower('BITXOR'))='fi_bitxor';
            mappingTable(lower('FI2INT'))='fi_toint';
            mappingTable(lower('PROMOTE_TO_SIGNED'))='fi_signed';
            mappingTable(lower('COMPLEX'))='complexx';


            mappingTable(lower('ZEROS'))='zerosx';
            mappingTable(lower('ONES'))='onesx';
            mappingTable(lower('EYE'))='eyex';


            mappingTable(lower('TRUE'))='truex';
            mappingTable(lower('FALSE'))='falsex';


            mappingTable(lower('REPMAT'))='repmatx';
            mappingTable(lower('RESHAPE'))='reshapex';
            mappingTable(lower('PERMUTE'))='permutex';


            mappingTable(lower('SORT'))='sortx';
            mappingTable(lower('SHIFTDIM'))='shiftdimx';
            mappingTable(lower('SUB2IND'))='sub2indx';


            assert(strcmp(mappingTable(lower('MRDIVIDE')),mappingTable(lower('DIVIDE'))));
            assert(strcmp(mappingTable(lower('RDIVIDE')),mappingTable(lower('DOTDIV'))));
        end
    end
end


