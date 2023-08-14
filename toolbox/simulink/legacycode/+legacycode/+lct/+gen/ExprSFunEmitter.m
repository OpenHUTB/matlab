





classdef ExprSFunEmitter<legacycode.lct.gen.ExprEmitter


    properties(SetAccess=protected,GetAccess=protected)
DefaultInitStr
    end


    methods




        function this=ExprSFunEmitter(varargin)


            narginchk(2,3);


            this@legacycode.lct.gen.ExprEmitter(varargin{1:2});


            this.Optimize=false;


            if nargin<3||isempty(varargin{3})
                this.DefaultInitStr='';
            else
                validateattributes(varargin{3},...
                {'char','string'},{'scalartext'},3);
                this.DefaultInitStr=char(varargin{3});
            end
        end

    end


    methods(Access=protected)




        function visitParamValue(this,idx)
            dataSpec=this.LctSpecInfo.lookupData('Parameter',idx);
            apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'sfun');
            this.sprintf('(int_T)%s',apiInfo.Val);
        end




        function visitSizeFcn(this,radix,idx,val)

            dataRole=legacycode.lct.spec.Common.Radix2RoleMap(radix);
            dataSpec=this.LctSpecInfo.lookupData(dataRole,idx);


            exprStr=legacycode.lct.gen.ExprSFunEmitter.emitOneDim(...
            this.LctSpecInfo,dataSpec,val,this.DefaultInitStr);
            this.sprintf('%s',exprStr);
        end




        function visitNumelFcn(this,radix,idx)

            dataRole=legacycode.lct.spec.Common.Radix2RoleMap(radix);
            dataSpec=this.LctSpecInfo.lookupData(dataRole,idx);

            if strcmpi(this.DefaultInitStr,'init')

                allDims=legacycode.lct.gen.ExprSFunEmitter.emitAllDims(...
                this.LctSpecInfo,dataSpec,this.DefaultInitStr);
                allDims=cellfun(@(x)sprintf('(%s)',x),allDims,'UniformOutput',false);
                this.sprintf('%s',strjoin(allDims,' * '));
            else

                apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'sfun');
                this.sprintf('%s',apiInfo.Width);
            end
        end
    end


    methods(Static)




        function allDimStr=emitAllDims(lctSpecInfo,dataSpec,defaultStr)


            narginchk(2,3);
            if nargin<3||isempty(defaultStr)
                defaultStr='';
            end


            allDimStr=cell(numel(dataSpec.Dimensions),1);


            for ii=1:numel(dataSpec.Dimensions)
                allDimStr{ii}=legacycode.lct.gen.ExprSFunEmitter.emitOneDim(...
                lctSpecInfo,dataSpec,ii,defaultStr);
            end
        end











        function dimStr=emitOneDim(lctSpecInfo,dataSpec,aDim,defaultStr)


            narginchk(3,4);
            if nargin<4||isempty(defaultStr)
                defaultStr='';
            end


            dimStr='';

            if dataSpec.Dimensions(aDim)~=-1


                dimStr=sprintf('%d',dataSpec.Dimensions(aDim));

            elseif isempty(dataSpec.DimsInfo)

                dimStr='1';

            else

                dimInfo=dataSpec.DimsInfo(aDim);


                if dimInfo.HasInfo

                    obj=legacycode.lct.gen.ExprSFunEmitter(dimInfo.Expr,lctSpecInfo,defaultStr);
                    dimStr=obj.emit();
                else





                    apiInfo=legacycode.lct.gen.CodeEmitter.getApiInfo(dataSpec,'sfun');



                    if dataSpec.isParameter()
                        if length(dataSpec.Dimensions)<2



                            dimStr=apiInfo.Width;
                        else



                            dimStr=apiInfo.Dims(aDim-1);
                        end

                    elseif dataSpec.isInput()
                        if strcmp(defaultStr,'init')


                            if dataSpec.IsDynamicArray
                                dimStr='SS_INT32_INF_DIM';
                            else
                                dimStr='DYNAMICALLY_SIZED';
                            end
                        else
                            if isempty(defaultStr)
                                if dataSpec.IsDynamicArray
                                    defaultStr='SS_INT32_INF_DIM';
                                else
                                    defaultStr='DYNAMICALLY_SIZED';
                                end
                            end
                            if aDim==1
                                if length(dataSpec.Dimensions)<2

                                    dimStr=apiInfo.Width;
                                else




                                    isTrueDynSize=lctSpecInfo.isTrueDynamicSize(dataSpec,aDim);

                                    if isTrueDynSize&&length(dataSpec.Dimensions)>2
                                        dimStr=sprintf('((%s >= 1) ? %s : %s)',...
                                        apiInfo.NumDims,apiInfo.Dims(0),defaultStr);
                                    else
                                        dimStr=apiInfo.Dims(0);
                                    end
                                end
                            else







                                isTrueDynSize=lctSpecInfo.isTrueDynamicSize(dataSpec,aDim);

                                if isTrueDynSize&&length(dataSpec.Dimensions)>2


                                    dimStr=sprintf('((%s >= %d) ? %s : %s)',...
                                    apiInfo.NumDims,aDim,apiInfo.Dims(aDim-1),defaultStr);
                                else


                                    dimStr=apiInfo.Dims(aDim-1);
                                end
                            end
                        end

                    else




                    end
                end
            end



            if contains(dimStr,'SS_INT32_INF_DIM')&&strcmpi(defaultStr,'init')
                dimStr='SS_INT32_INF_DIM';
            elseif contains(dimStr,'DYNAMICALLY_SIZED')&&strcmpi(defaultStr,'init')
                dimStr='DYNAMICALLY_SIZED';
            end
        end




        function str=emitExprArg(lctSpecInfo,dataSpec,defaultStr)

            if nargin<3
                defaultStr='init';
            end

            if dataSpec.isExprArg()&&(numel(dataSpec.DimsInfo)==1)
                obj=legacycode.lct.gen.ExprSFunEmitter(dataSpec.DimsInfo.Expr,lctSpecInfo,defaultStr);
                str=obj.emit();
            else
                str='0';
            end
        end
    end

end


