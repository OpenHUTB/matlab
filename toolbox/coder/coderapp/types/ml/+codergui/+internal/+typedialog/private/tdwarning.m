function tdwarning(msgKeyToken,varargin)




    warning(['CoderTypeDialog:',msgKeyToken],message(['coderApp:typeDialog:',msgKeyToken],varargin{:}).getString());
end
