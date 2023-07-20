function h=ModelCPPDefaultClass(varargin)









    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    h=RTW.ModelCPPDefaultClass;

    if nargin==2
        if isempty(varargin{1})
            h.Name='ModelCPPDefaultClass';
        else
            h.Name=varargin{1};
        end

        h.ModelHandle=varargin{2};

        h.setDefaultStepMethodName();
        h.setDefaultClassName();
        h.setDefaultNamespace();
    end

    h.PreConfigFlag=false;
    h.Description=DAStudio.message('RTW:fcnClass:defaultclassdescription');
