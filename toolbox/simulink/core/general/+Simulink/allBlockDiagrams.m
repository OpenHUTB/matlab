function blockDiagrams=allBlockDiagrams(varargin)



























    if nargin==0
        blockDiagrams=Simulink.internal.allBlockDiagrams('');
    elseif nargin==1
        blockDiagrams=Simulink.internal.allBlockDiagrams(varargin{1});
    else
        DAStudio.error('Simulink:Commands:TooManyInputArgs');
    end
end