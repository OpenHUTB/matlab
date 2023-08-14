



classdef ParseException<MException


    properties(SetAccess=protected)
        OrigId char=''
        Expr char=''
        PosOffset=0
        ExtraArgs={}
    end


    methods




        function this=ParseException(errId,expr,posOffset,varargin)


            narginchk(2,4);


            this@MException(['Simulink:tools:',errId],'');


            this.OrigId=errId;


            if~isempty(expr)
                validateattributes(expr,{'char','string'},{'scalartext'},2);
                this.Expr=char(expr);
            end


            if nargin>2
                validateattributes(posOffset,{'numeric'},{'scalar','nonempty','>=',0},3);
                this.PosOffset=posOffset;
            end
            if nargin>3&&~isempty(varargin)
                this.ExtraArgs=varargin;
            end

        end





        function out=getArgs(this)

            out={this.OrigId;this.Expr;this.PosOffset};

            if~isempty(this.ExtraArgs)
                out=[out;this.ExtraArgs(:)];
            end
        end

    end

end


