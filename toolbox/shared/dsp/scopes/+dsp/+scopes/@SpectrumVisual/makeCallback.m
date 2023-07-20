function cb=makeCallback(this,fcn,varargin)




    cb=@(~,~)fcn(this,varargin{:});
end
