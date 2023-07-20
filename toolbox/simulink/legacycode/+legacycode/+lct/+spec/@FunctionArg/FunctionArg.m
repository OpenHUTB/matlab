



classdef FunctionArg<legacycode.lct.util.IdObject


    properties(Hidden,SetAccess=?legacycode.lct.spec.Function)
        AccessKind legacycode.lct.spec.AccessKind
    end

    properties(SetAccess=protected)
        Qualifier char
    end


    properties
        Data legacycode.lct.spec.Data
    end


    properties(Dependent,SetAccess=protected)
DataKind
        PassedByValue logical
        IsReturn logical
    end


    properties(Hidden,Dependent,SetAccess=protected)
Identifier
AccessType
Type
DataId
DataTypeId
IsComplex
DimsInfo
    end


    properties(SetAccess=protected,Hidden)

        Expression char=''


        SpecPos int32=[ones(5,1,'int32'),zeros(5,1,'int32')]


        PosOffset int32=0
    end



    properties(Dependent,SetAccess=protected,Hidden)

TypeExpr
StarExpr
NameExpr
DimExpr
Expr


TypeStartPos
StarStartPos
NameStartPos
DimStartPos
ExprStartPos
    end


    methods




        function this=FunctionArg(specStr,posOffset)


            narginchk(0,2);

            if nargin<1||isempty(specStr)
                specStr='';
            else
                validateattributes(specStr,{'char','string'},{'scalartext'},1);
                specStr=char(specStr);
            end

            if nargin==2
                validateattributes(posOffset,{'numeric'},{'scalar','nonempty','>=',0},2);
                this.PosOffset=posOffset;
            end


            this.AccessKind=legacycode.lct.spec.AccessKind.Value;
            this.Data=legacycode.lct.spec.Data();
            this.Expression=specStr;


            if~isempty(this.Expression)
                this.parse();
            end
        end




        function val=get.DataKind(this)
            if~isempty(this.Data)
                val=char(this.Data.Kind);
            else
                val='';
            end
        end


        function val=get.Type(this)
            val=this.DataKind;
            if strcmpi(val,'ExprArg')
                val='SizeArg';
            end
        end

        function val=get.Identifier(this)
            if~isempty(this.Data)
                val=this.Data.Identifier;
            else
                val='';
            end
        end

        function val=get.DataId(this)
            if~isempty(this.Data)
                val=this.Data.Id;
            else
                val=0;
            end
        end

        function val=get.DataTypeId(this)
            if~isempty(this.Data)
                val=this.Data.DataTypeId;
            else
                val=0;
            end
        end

        function val=get.IsComplex(this)
            if~isempty(this.Data)
                val=this.Data.IsComplex;
            else
                val=false;
            end
        end

        function val=get.DimsInfo(this)
            if~isempty(this.Data)
                val=this.Data.DimsInfo;
            else
                val=legacycode.lct.spec.DimInfo.empty();
            end
        end

        function val=get.AccessType(this)
            if this.PassedByValue
                val='direct';
            else
                val='pointer';
            end
        end




        function val=get.IsReturn(this)
            val=this.AccessKind==legacycode.lct.spec.AccessKind.Return;
        end




        function val=get.PassedByValue(this)
            val=this.AccessKind==legacycode.lct.spec.AccessKind.Value||...
            this.IsReturn;
        end


        function out=get.TypeStartPos(this)
            out=this.PosOffset+this.SpecPos(1,1);
        end
        function out=get.StarStartPos(this)
            out=this.PosOffset+this.SpecPos(2,1);
        end
        function out=get.NameStartPos(this)
            out=this.PosOffset+this.SpecPos(3,1);
        end
        function out=get.DimStartPos(this)
            out=this.PosOffset+this.SpecPos(4,1);
        end
        function out=get.ExprStartPos(this)
            out=this.PosOffset+this.SpecPos(5,1);
        end

        function out=get.TypeExpr(this)
            out=this.Expression(this.SpecPos(1,1):this.SpecPos(1,2));
        end
        function out=get.StarExpr(this)
            out=this.Expression(this.SpecPos(2,1):this.SpecPos(2,2));
        end
        function out=get.NameExpr(this)
            out=this.Expression(this.SpecPos(3,1):this.SpecPos(3,2));
        end
        function out=get.DimExpr(this)
            out=this.Expression(this.SpecPos(4,1):this.SpecPos(4,2));
        end
        function out=get.Expr(this)
            out=this.Expression(this.SpecPos(5,1):this.SpecPos(5,2));
        end
    end


    methods(Access=protected)




        function extractDataTypeNameInfo(this)


            defObj=legacycode.lct.spec.Common.instance();


            tok=regexpi(this.TypeExpr,['(complex\s*<)?\s*(',defObj.NameExpr,')\s*(?:\>)?'],'tokens');
            if~isempty(tok)
                dtName=tok{1}{2};
                isCplx=~isempty(tok{1}{1});
            else
                dtName='';
                isCplx=false;
            end

            this.Data.DataTypeName=dtName;
            this.Data.IsComplex=isCplx;
        end




        parse(this)




        extractExprArgSpec(this)




        extractVoidArgSpec(this)




        extractArgSpec(this)

    end
end


