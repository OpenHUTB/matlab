function constraint=generateConstraintObject(varargin)





    if nargin==2&&(isa(varargin{1},'matlab.io.xml.dom.Element'))
        constraint=Advisor.authoring.internal.scanDOMNode(varargin{1});
        constraint.ID=varargin{2};
    end

end

