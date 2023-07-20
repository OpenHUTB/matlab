function printMsg(id,varargin)
    Simulink.output.info(message(id,varargin{:}).string);
end