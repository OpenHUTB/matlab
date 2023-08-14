function hDoc=exportScript(obj)




    sw=StringWriter;
    addcr(sw,'% Build a cascade (row vector) of RF elements')
    writeMissingNportFiles(obj)
    for i=1:length(obj.Elements)
        elem=obj.Elements(i);
        vn=sprintf('elements(%d)',i);
        exportScript(elem,sw,vn)
    end

    addcr(sw,'')
    addcr(sw,'% Construct an rfbudget object')
    addcr(sw,'b = rfbudget( ...')
    addcr(sw,'    Elements=elements, ...')

    if isscalar(obj.InputFrequency)
        [y,e]=engunits(obj.InputFrequency);
        val=sprintf('%.15g',y);
        if e~=1
            val=sprintf('%se%d',val,round(log10(1/e)));
        end
        addcr(sw,'    InputFrequency=%s, ...',val)
    else
        [y,e]=engunits(obj.InputFrequency);
        val=cell(numel(obj.InputFrequency),1);
        for i=1:numel(obj.InputFrequency)
            val{i}=sprintf('%.15g',y(i));
            if e~=1
                val{i}=sprintf('%se%d',val{i,1},round(log10(1/e)));
            end
        end
        add(sw,'    InputFrequency=[')
        for i=1:numel(obj.InputFrequency)-1
            add(sw,'%s; ',val{i})
        end
        addcr(sw,'%s], ...',val{end})
    end


    addcr(sw,'    AvailableInputPower=%.15g, ...',obj.AvailableInputPower)

    [y,e]=engunits(obj.SignalBandwidth);
    val=sprintf('%.15g',y);
    if e~=1
        val=sprintf('%se%d',val,round(log10(1/e)));
    end
    addcr(sw,'    SignalBandwidth=%s, ...',val)

    addcr(sw,'    Solver=''%s'', ...',obj.Solver)
    if strcmp(obj.Solver,'HarmonicBalance')
        if~isempty(obj.HarmonicOrder)
            addcr(sw,'    HarmonicOrder=%d, ...',obj.HarmonicOrder)
        end
    end

    addcr(sw,'    AutoUpdate=%d);',obj.AutoUpdate)

    if nargout<1
        matlab.desktop.editor.newDocument(sw.string);
    else
        hDoc=matlab.desktop.editor.newDocument(sw.string);
    end
