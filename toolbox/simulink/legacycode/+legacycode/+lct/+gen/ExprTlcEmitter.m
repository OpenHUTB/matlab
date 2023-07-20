





classdef ExprTlcEmitter<legacycode.lct.gen.ExprEmitter


    properties(Constant,Access=protected)

        IntFmtFcn=@(val)sprintf('CAST("Number", %d)',val)


        DblFmtFcn=@(val)sprintf('CAST("Real", %g)',val)
    end

    properties(SetAccess=protected)
        DoTlcEval logical=false
    end


    methods




        function this=ExprTlcEmitter(varargin)


            narginchk(2,2);


            this@legacycode.lct.gen.ExprEmitter(varargin{:});


            this.Optimize=false;
        end

    end


    methods(Access=protected)




        function visitInt(this,val)

            this.sprintf(this.IntFmtFcn(val));
        end




        function visitDouble(this,val)

            this.sprintf(this.DblFmtFcn(val));
        end




        function visitParamValue(this,idx)



            dataSpec=this.LctSpecInfo.lookupData('Parameter',idx);
            apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'tlc');
            if this.DoTlcEval
                this.sprintf('%%<%s>',apiInfo.ValLiteral);
            else
                this.sprintf('%s',apiInfo.ValLiteral);
            end
        end




        function visitSizeFcn(this,radix,idx,val)

            dataRole=legacycode.lct.spec.Common.Radix2RoleMap(radix);
            dataSpec=this.LctSpecInfo.lookupData(dataRole,idx);


            exprStr=legacycode.lct.gen.ExprTlcEmitter.emitOneDim(...
            this.LctSpecInfo,dataSpec,val,this.DoTlcEval);
            this.sprintf('%s',exprStr);
        end




        function visitNumelFcn(this,radix,idx)

            dataRole=legacycode.lct.spec.Common.Radix2RoleMap(radix);
            dataSpec=this.LctSpecInfo.lookupData(dataRole,idx);



            apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'tlc');
            if this.DoTlcEval
                if dataSpec.IsDynamicArray
                    this.sprintf('%s',apiInfo.Width);
                else
                    this.sprintf('%%<%s>',apiInfo.Width);
                end
            else
                this.sprintf('%s',apiInfo.Width);
            end
        end
    end


    methods(Static)




        function allDimStr=emitAllDims(lctSpecInfo,dataSpec,doTlcEval)


            narginchk(2,3);

            if nargin<3
                doTlcEval=false;
            end


            allDimStr=cell(numel(dataSpec.Dimensions),1);


            for ii=1:numel(dataSpec.Dimensions)
                allDimStr{ii}=legacycode.lct.gen.ExprTlcEmitter.emitOneDim(...
                lctSpecInfo,dataSpec,ii,doTlcEval);
            end
        end











        function dimStr=emitOneDim(lctSpecInfo,dataSpec,aDim,doTlcEval)


            narginchk(3,4);

            if nargin<4
                doTlcEval=false;
            end

            if dataSpec.Dimensions(aDim)~=-1


                dimStr=legacycode.lct.gen.ExprTlcEmitter.IntFmtFcn(dataSpec.Dimensions(aDim));

            elseif isempty(dataSpec.DimsInfo)

                dimStr='1';

            else

                dimInfo=dataSpec.DimsInfo(aDim);


                if dimInfo.HasInfo

                    obj=legacycode.lct.gen.ExprTlcEmitter(dimInfo.Expr,lctSpecInfo);
                    obj.DoTlcEval=doTlcEval;
                    dimStr=obj.emit();
                else

                    apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'tlc');

                    if length(dataSpec.Dimensions)<2

                        dimStr=apiInfo.Width;
                    else

                        dimStr=sprintf('%s[%d]',apiInfo.Dims,aDim-1);
                    end
                    if doTlcEval
                        if dataSpec.IsDynamicArray
                            dimStr=sprintf('%s',dimStr);
                        else
                            dimStr=sprintf('%%<%s>',dimStr);
                        end
                    end
                end
            end
        end




        function str=emitExprArg(lctSpecInfo,dataSpec)

            if dataSpec.isExprArg()&&(numel(dataSpec.DimsInfo)==1)
                obj=legacycode.lct.gen.ExprTlcEmitter(dataSpec.DimsInfo.Expr,lctSpecInfo);
                str=obj.emit();
            else
                str='0';
            end
        end
    end

end
