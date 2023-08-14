function output=printfProfilerLink(cmd,text,varargin)





    output=sprintf(['<a href="matlab: ',cmd,'">',text,'</a>'],varargin{:});
end