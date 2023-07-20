function layoutsubspace(H,varargin)


















    nn=numnodes(H.BasicGraph_);
    layoutparams={};
    if nargin<=1
        dim=min(100,nn);
    else
        nvarargin=length(varargin);
        if rem(nvarargin,2)~=0
            error(message('MATLAB:graphfun:plot:ArgNameValueMismatch'));
        end
        layoutparams=varargin;
        for i=1:2:nvarargin
            name=validatestring(varargin{i},{'Dimension'});
            layoutparams{i}=name;
            validateattributes(varargin{i+1},{'numeric'},...
            {'scalar','nonnan','real','integer','>=',min(2,nn),'<=',nn});
            dim=varargin{i+1};
        end
    end

    G=constructUndirectedGraph(H);
    [x,y]=subspaceLayout(G,dim,2);

    H.Layout_='subspace';
    H.LayoutParameters_=layoutparams;
    setData(H,x,y);


    function G=constructUndirectedGraph(H)



        G=H.BasicGraph_;
        if H.IsDirected_
            A=adjacency(G);
            if~issymmetric(A)
                A=A+A';
            end
            G=matlab.internal.graph.MLGraph(A);
        end