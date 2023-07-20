function index=findrepeats(p,tol)

    diffval=diff(p);
    index=abs(diffval)<tol;

