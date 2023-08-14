function varargout=utPlotDatasetSDI(ds,dsLabel)



    ret=cell(1,nargout);


    if isempty(dsLabel)&&isscalar(ds)&&isempty(ds.Name)
        dsLabel='ans';
    end


    [ret{:}]=Simulink.sdi.plot(ds,dsLabel);
    varargout=ret;
end
