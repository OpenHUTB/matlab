



classdef Function<matlab.mixin.Copyable


    properties(Dependent,SetAccess=protected)
        Name char
        IsSpecified logical
        HasNDArrayArg logical
        HasDynamicArrayArg logical
        HasDynamicArrayOutputArg logical
    end


    properties
        LhsArgs legacycode.lct.spec.DataSet
        RhsArgs legacycode.lct.spec.DataSet
    end


    properties(SetAccess=protected,Hidden)

        Expression char=''


        SpecPos int32=[ones(4,1,'int32'),zeros(4,1,'int32')]
    end



    properties(Dependent,SetAccess=protected,Hidden)

LhsExpr
RhsExpr
EqExpr
ArgListExpr


LhsStartPos
EqStartPos
NameStartPos
ArgListStartPos
ArgListPos
    end


    methods




        function this=Function(specStr)


            narginchk(0,1);
            if nargin<1||isempty(specStr)
                specStr='';
            else
                validateattributes(specStr,{'char','string'},{'scalartext'});
                specStr=char(specStr);
            end


            this.LhsArgs=legacycode.lct.spec.DataSet('Arg');
            this.RhsArgs=legacycode.lct.spec.DataSet('Arg');


            this.Expression=strtrim(regexprep(specStr,'[\f\n\r\t\v]',''));


            if this.IsSpecified
                this.parse();
            end
        end




        function forEachArg(this,funHandle)


            if this.LhsArgs.Numel>0
                funHandle(this,this.LhsArgs.Items(1));
            end


            for ii=this.RhsArgs.Ids
                funHandle(this,this.RhsArgs.Items(ii));
            end
        end


        function out=get.HasNDArrayArg(this)
            out=false;

            if~this.IsSpecified
                return
            end

            this.forEachArg(@(f,a)visitArg(a.Data));

            function visitArg(dataSpec)


                if out||dataSpec.isExprArg()||dataSpec.isDWork()||(dataSpec.CArrayND.DWorkIdx<1)
                    return
                end
                out=true;
            end
        end

        function out=get.HasDynamicArrayArg(this)
            out=false;

            if~this.IsSpecified
                return
            end

            this.forEachArg(@(o,d)visitArg(d));
            function visitArg(argSpec)
                out=out||argSpec.Data.IsDynamicArray;
            end
        end

        function out=get.HasDynamicArrayOutputArg(this)
            out=false;

            if~this.IsSpecified
                return
            end

            this.forEachArg(@(f,a)visitArg(a.Data));

            function visitArg(dataSpec)
                if dataSpec.isOutput()
                    out=out||dataSpec.IsDynamicArray;
                end
            end
        end

        function out=get.IsSpecified(this)
            out=~isempty(this.Expression);
        end

        function out=get.LhsStartPos(this)
            out=this.SpecPos(1,1);
        end

        function out=get.EqStartPos(this)
            out=this.SpecPos(2,1);
        end

        function out=get.NameStartPos(this)
            out=this.SpecPos(3,1);
        end

        function out=get.ArgListStartPos(this)
            out=this.SpecPos(4,1);
        end

        function out=get.ArgListPos(this)
            out=this.SpecPos(4,:);
        end

        function out=get.LhsExpr(this)
            out=this.Expression(this.SpecPos(1,1):this.SpecPos(1,2));
        end

        function out=get.EqExpr(this)
            out=this.Expression(this.SpecPos(2,1):this.SpecPos(2,2));
        end

        function out=get.Name(this)
            out=this.Expression(this.SpecPos(3,1):this.SpecPos(3,2));
        end

        function out=get.ArgListExpr(this)
            out=this.Expression(this.SpecPos(4,1):this.SpecPos(4,2));
        end

        function out=get.RhsExpr(this)

            out=this.Expression(this.NameStartPos:numel(this.Expression));
        end
    end


    methods(Access=protected)




        function newObj=copyElement(this)

            newObj=copyElement@matlab.mixin.Copyable(this);


            newObj.LhsArgs=copy(this.LhsArgs);
            newObj.RhsArgs=copy(this.RhsArgs);
        end




        parse(this)




        validateArg(this,argSpec)

    end


    methods(Hidden)




        function throwError(this,id,varargin)
            legacycode.lct.spec.Common.error(id,this.Expression,varargin{:});
        end




        function checkIdentifierRadix(this,id,radix,numS)
            if isempty(radix)
                this.throwError('LCTSpecParserUnrecognizedToken',numS,numel(id));
            end
        end




        function checkIdentifierIdx(this,identifier,id,numS)
            if~isnumeric(id)||id<1
                this.throwError('LCTSpecParserBadDataId',numS,numel(identifier));
            end
        end




        function checkPositiveDimVal(this,id,val,numS)
            if val<=0
                this.throwError('LCTSpecParserBadDimSpec',numS,numel(id));
            end
        end





        function checkUniqueUsage(this,argSpec)

            if argSpec.Data.isOutput()&&this.LhsArgs.Numel>0
                if this.LhsArgs.Items.Data.Id==argSpec.Data.Id
                    throwError(this.LhsArgs.Items);
                end
            end


            if this.RhsArgs.Numel>0
                sameIdx=find(strcmp(argSpec.DataKind,{this.RhsArgs.Items(:).DataKind}));
                for idx=sameIdx
                    if this.RhsArgs.Items(idx).Data.Id==argSpec.Data.Id
                        throwError(this.RhsArgs.Items(idx));
                    end
                end
            end

            function throwError(refArgSpec)


                idPos1=refArgSpec.NameStartPos;
                idPos2=argSpec.NameStartPos;
                id=legacycode.lct.spec.Common.remWhiteSpaces(refArgSpec.NameExpr);


                numT=[numel(id),numel(id)];
                numS=[idPos1-1,idPos2-idPos1-numT(1)];




                msg=message('Simulink:tools:LCTErrorParseDuplicatedArgName');
                legacycode.lct.spec.Common.error('LCTErrorRethrowErrorWithSpec',...
                this.Expression,numS,numT,getString(msg));

            end
        end
    end
end


