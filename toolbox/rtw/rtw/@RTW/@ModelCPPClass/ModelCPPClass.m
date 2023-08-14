function h=ModelCPPClass(varargin)









    h=RTW.ModelCPPClass;

    if nargin==2
        if isempty(varargin{1})
            h.Name='ModelCPPClass';
        else
            h.Name=varargin{1};
        end

        h.ModelHandle=varargin{2};
    end

    h.selRow=0;
    h.PreConfigFlag=false;
    h.Description=DAStudio.message('RTW:fcnClass:modelspecificdescription');
