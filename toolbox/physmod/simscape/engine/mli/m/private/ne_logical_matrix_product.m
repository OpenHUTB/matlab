function Ap=ne_logical_matrix_product(B,C)



    B(isnan(B))=inf;
    C(isnan(C))=inf;
    Ap=logical(double(logical(B))*double(logical(C)));
