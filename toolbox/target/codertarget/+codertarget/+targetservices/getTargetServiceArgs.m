function out=getTargetServiceArgs(hObj,returnType)






    if nargin<2
        returnType='value';
    else
        assert(ismember(returnType,{'value','datatype'}));
    end
    if isa(hObj,'Simulink.ConfigSet')
        hCS=hObj;
    elseif isa(hObj,'char')||isa(hObj,'double')
        hCS=getActiveConfigSet(hObj);
    else



        assert(false);
    end
    type=codertarget.attributes.getExtModeData('TransportType',hCS);
    switch type
    case 'tcp/ip'
        if isequal(returnType,'value')
            if codertarget.attributes.supportTargetServicesFeature(hCS,'RTIOStreamAppSvc')
                offset=0;
            else
                offset=1;
            end
            out=num2str(str2double(codertarget.attributes.getExtModeData('Port',hCS))+offset);
        else
            out='uint16_t';
        end
    case 'serial'
        out=' ';
    end
end