function con=reshape(con,varargin)







    try
        con.Expr1=reshape(con.Expr1,varargin{:});
        con.Expr2=reshape(con.Expr2,varargin{:});



        con.Size=size(con.Expr1);
        con.IndexNamesStore=con.Expr1.IndexNames;
    catch E

        throw(E);
    end