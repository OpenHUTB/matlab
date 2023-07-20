function filt_design(obj)




    if any(strcmpi(obj.DesignMethod,...
        {'InverseChebyshev','Elliptic'}))||...
        strcmpi(obj.Implementation,'Transfer function')

        obj.Implementation='Transfer function';
        designData=filt_design_rat(obj);
    else

        designData=filt_design_lc(obj);
        designData.Topology=lower(sprintf('lc%s%s',...
        obj.ResponseType,...
        obj.Implementation(4:end)));
    end

    if isfield(designData,'Wp')
        designData.PassbandFrequency=designData.Wp/(2*pi);
        designData=rmfield(designData,'Wp');
    end
    if isfield(designData,'RpDB')
        designData.PassbandAttenuation=designData.RpDB;
        designData=rmfield(designData,'RpDB');
    end
    if isfield(designData,'Ws')
        designData.StopbandFrequency=designData.Ws/(2*pi);
        designData=rmfield(designData,'Ws');
    end
    obj.designData=designData;
end
