function plcladderlib(varargin)









    target='studio5000';
    if~isempty(varargin)
        target=varargin{1};
    end


    if plcfeature('PLCUseLinkedLDLib')
        open_system([target,'_plclib_test']);
    else
        open_system([target,'_plclib']);
    end
end



