function[indrows,deprows,T]=ne_findindrows(J,order)

































    numrows=length(order);
    numrowsJ=size(J,1);
    pm_assert(strcmp(class(J),'double')&&strcmp(class(order),'double'),'Wrong class J or order');



    A_unscaled=J(order,:);






    is_finite_ordered_row=~any(isinf(A_unscaled)|isnan(A_unscaled),2);
    if~all(is_finite_ordered_row)
        A_unscaled=A_unscaled(is_finite_ordered_row,:);
        order=order(is_finite_ordered_row);
    end

    rowscales=max(abs(A_unscaled),[],2);
    if size(rowscales,2)==0
        rowscales=sparse(size(rowscales,1),1);
    end
    rowscales(rowscales==0)=1;
    rowscale_mat=spdiags(1./rowscales,0,size(A_unscaled,1),size(A_unscaled,1));
    rowscale_mat_inv=spdiags(rowscales,0,size(A_unscaled,1),size(A_unscaled,1));
    A=rowscale_mat*A_unscaled;

    if~issparse(A)
        A=sparse(A);
    end

    [is_deprow,ind2dep]=ne_indcols_lu_c(A');
    deprows=find(is_deprow);
    indrows=find(~is_deprow);





    ind2dep_unscaled=rowscale_mat(indrows,indrows)*ind2dep*rowscale_mat_inv(deprows,deprows);


    indrows=order(indrows);
    deprows=order(deprows);



    if isempty(indrows)
        indrows=zeros(1,0);
    end
    if isempty(deprows)
        deprows=zeros(1,0);
    end

    numdep=length(deprows);
    T=sparse(numdep,numrowsJ);
    if~isempty(T)
        T(:,deprows)=speye(length(deprows));
        T(:,indrows)=-ind2dep_unscaled';
    end
end

