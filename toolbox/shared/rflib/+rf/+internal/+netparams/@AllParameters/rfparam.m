function data=rfparam(obj,m,n)

    narginchk(3,3)
    validateattributes(m,{'numeric'},...
    {'integer','scalar','positive','<=',obj.NumPorts},'rfparam','I',2)
    validateattributes(n,{'numeric'},...
    {'integer','scalar','positive','<=',obj.NumPorts},'rfparam','J',3)

    data=squeeze(obj.Parameters(m,n,:));