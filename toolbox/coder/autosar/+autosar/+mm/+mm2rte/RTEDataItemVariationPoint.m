classdef RTEDataItemVariationPoint<handle




    properties(Access='private')
        VppName;
        AccessType;
        AccessInfo;
    end

    methods(Access='private')
        function prefixedPbConstExpr=prefixPbConstNames(~,pbConstExpr)


            pbConstExpr=sprintf('%s',pbConstExpr);
            expressions=split(pbConstExpr,'&&');
            prefixedExprs=arrayfun(@(x)insertAfter(strtrim(x),int8(startsWith(strtrim(x),'(')),'rtP_'),expressions);
            prefixedPbConstExpr='';
            for k=1:length(prefixedExprs)
                if k~=1
                    prefixedPbConstExpr=strcat(prefixedPbConstExpr," && ");
                end
                prefixedPbConstExpr=strcat(prefixedPbConstExpr,prefixedExprs(k));
            end
        end
    end

    methods(Access='public')
        function this=RTEDataItemVariationPoint(vppName,accesssType,...
            accessInfo)
            this.VppName=vppName;
            this.AccessType=accesssType;
            this.AccessInfo=accessInfo;
        end

        function write(this,writerHFile)
            switch(this.AccessType)
            case 'VariationPointConditionAccess'
                defineName=sprintf('Rte_SysCon_%s',this.VppName);
                writerHFile.wLine('#ifndef %s',defineName);
                writerHFile.wLine('#define %s (%s)',defineName,this.AccessInfo.CondExpr);
                writerHFile.wLine('#endif');
            case 'VariationPointValueAccess'
                sysConstValue=double(this.AccessInfo.SysConstValue);
                writerHFile.wLine('#define %s %d%s',...
                this.AccessInfo.SysConstName,...
                sysConstValue);
                writerHFile.wLine('#define Rte_SysCon_%s %s',...
                this.AccessInfo.SysConstName,...
                this.AccessInfo.SysConstName);
            case 'PostBuildVariationCondition'

                funcName=sprintf('Rte_PbCon_%s%s',this.VppName,'()');
                writerHFile.wLine('boolean %s;',funcName);
            case 'PostBuildDefinition'

                writerHFile.wLine('extern sint32 rtP_%s;',this.AccessInfo.PbConstName);
            otherwise
                assert(false,'Unsupported access type "%s".',this.AccessType);
            end
        end

        function writeValue(this,writerCFile)
            switch(this.AccessType)
            case 'VariationPointConditionAccess'

            case 'VariationPointValueAccess'

            case 'PostBuildVariationCondition'

                funcName=sprintf('Rte_PbCon_%s%s',this.VppName,'()');
                writerCFile.wLine('boolean %s',funcName);
                writerCFile.wLine('{');



                pbCondExpr=this.prefixPbConstNames(this.AccessInfo.pbCondExpr);

                writerCFile.wLine('return (%s)%s',pbCondExpr{1:1},';');
                writerCFile.wLine('}');
            case 'PostBuildDefinition'

                pbConstValue=double(this.AccessInfo.PbConstValue);
                writerCFile.wLine('sint32 rtP_%s = %d;',...
                this.AccessInfo.PbConstName,...
                pbConstValue);
            otherwise
                assert(false,'Unsupported access type "%s".',this.AccessType);
            end
        end
    end
end
