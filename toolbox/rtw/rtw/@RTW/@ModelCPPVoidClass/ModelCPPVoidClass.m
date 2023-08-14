







function h=ModelCPPVoidClass(varargin)










    h=RTW.ModelCPPVoidClass;

    if nargin==2
        if isempty(varargin{1})
            h.Name='ModelCPPVoidClass';
        else
            h.Name=varargin{1};
        end

        h.ModelHandle=varargin{2};

        h.setDefaultStepMethodName();
        h.setDefaultClassName();
        h.setDefaultNamespace();
    end

    h.PreConfigFlag=false;
    h.Description=DAStudio.message('RTW:fcnClass:voidclassdescription');

