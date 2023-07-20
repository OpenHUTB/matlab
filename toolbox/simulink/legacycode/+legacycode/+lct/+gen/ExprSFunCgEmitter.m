





classdef ExprSFunCgEmitter<legacycode.lct.gen.ExprEmitter


    methods




        function this=ExprSFunCgEmitter(varargin)


            narginchk(2,2);


            this@legacycode.lct.gen.ExprEmitter(varargin{:});


            this.Optimize=false;
        end

    end


    methods(Access=protected)




        function visitParamValue(this,idx)
            dataSpec=this.LctSpecInfo.lookupData('Parameter',idx);
            apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'cgir');
            this.sprintf('(int_T)%s',apiInfo.Val);
        end




        function visitSizeFcn(this,radix,idx,val)

            dataRole=legacycode.lct.spec.Common.Radix2RoleMap(radix);
            dataSpec=this.LctSpecInfo.lookupData(dataRole,idx);


            exprStr=legacycode.lct.gen.ExprSFunCgEmitter.emitOneDim(...
            this.LctSpecInfo,dataSpec,val);
            this.sprintf('%s',exprStr);
        end




        function visitNumelFcn(this,radix,idx)

            dataRole=legacycode.lct.spec.Common.Radix2RoleMap(radix);
            dataSpec=this.LctSpecInfo.lookupData(dataRole,idx);


            apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'cgir');
            this.sprintf('%s',apiInfo.Width);
        end
    end


    methods(Static)




        function allDimStr=emitAllDims(lctSpecInfo,dataSpec)


            allDimStr=cell(numel(dataSpec.Dimensions),1);


            for ii=1:numel(dataSpec.Dimensions)
                allDimStr{ii}=legacycode.lct.gen.ExprSFunCgEmitter.emitOneDim(...
                lctSpecInfo,dataSpec,ii);
            end
        end











        function dimStr=emitOneDim(lctSpecInfo,dataSpec,aDim)


            narginchk(3,3);

            if dataSpec.Dimensions(aDim)~=-1


                dimStr=sprintf('%d',dataSpec.Dimensions(aDim));

            elseif isempty(dataSpec.DimsInfo)

                dimStr='1';

            else

                dimInfo=dataSpec.DimsInfo(aDim);


                if dimInfo.HasInfo

                    obj=legacycode.lct.gen.ExprSFunCgEmitter(dimInfo.Expr,lctSpecInfo);
                    dimStr=obj.emit();
                else





                    apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'cgir');

                    if length(dataSpec.Dimensions)<2

                        dimStr=apiInfo.Width;
                    else

                        dimStr=apiInfo.Dims(aDim-1);
                    end
                end
            end
        end




        function str=emitExprArg(lctSpecInfo,dataSpec)

            if dataSpec.isExprArg()&&(numel(dataSpec.DimsInfo)==1)
                obj=legacycode.lct.gen.ExprSFunCgEmitter(dataSpec.DimsInfo.Expr,lctSpecInfo);
                str=obj.emit();
            else
                str='0';
            end
        end
    end

end
