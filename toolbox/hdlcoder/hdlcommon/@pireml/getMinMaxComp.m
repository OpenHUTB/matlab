function minmaxComp=getMinMaxComp(hN,hInSignals,hOutSignals,...
    compName,opName,isDSPBlk,outputMode)



    if strcmpi(opName,'min')
        if isDSPBlk
            if strcmpi(outputMode,'Value')
                ipf='hdleml_min';
            elseif strcmpi(outputMode,'Value and Index')
                ipf='hdleml_min_valandidx_tree';
            else
                ipf='hdleml_min_idxonly';
            end
        else
            ipf='hdleml_min';
        end
        params={};

    elseif strcmpi(opName,'max')
        if isDSPBlk
            if strcmpi(outputMode,'Value')
                ipf='hdleml_max';
            elseif strcmpi(outputMode,'Value and Index')
                ipf='hdleml_max_valandidx_tree';
            else
                ipf='hdleml_max_idxonly';
            end
        else
            ipf='hdleml_max';
        end
        params={};

    end


    minmaxComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EMLFileName',ipf,...
    'EMLParams',params);


end

