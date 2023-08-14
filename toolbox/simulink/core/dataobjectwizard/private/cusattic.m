function varargout=cusattic(method,varargin)








mlock
    persistent USERDATA

    [USERDATA,varargout{1:nargout}]=feval(method,USERDATA,varargin{1:end});




    function userdata=clean(userdata)
        clear userdata;
        userdata='';





        function[StateVar,returnVal]=AtticData(StateVar,varargin)






            returnVal=[];
            switch(nargin)
            case(2)
                if isempty(varargin{1})

                    returnVal=StateVar;
                else
                    if isfield(StateVar,varargin{1})
                        returnVal=eval(['StateVar.',varargin{1}]);
                    end
                end
            case(3)
                if ischar(varargin{1})
                    eval(['StateVar.',varargin{1},' =  varargin{2};']);
                end
            end
            return;
