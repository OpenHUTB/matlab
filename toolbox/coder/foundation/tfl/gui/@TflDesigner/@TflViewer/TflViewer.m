function this=TflViewer(hType,hme)





    this=TflDesigner.TflViewer;
    this.MeObj=hme;

    if isa(hType,'coder.targetreg.internal.TargetRegistry')
        this.Type='TargetRegistry';


        hType.refreshCRL;

        this.Content=hType.getcopy;

    elseif isa(hType,'RTW.TflRegistry')
        this.Type='TflRegistry';
        this.Content=hType.copy;
        this.Description=hType.Description;

    elseif isa(hType,'RTW.TflControl')
        this.Type='TflControl';
        hme.UserData.IsMatlabCoder=hType.MatlabCoder;

    elseif isa(hType,'RTW.TflTable')
        this.Type='TflTable';
        this.Content=hType.getCopy;
        this.Version=hType.Version;

    elseif isstruct(hType)
        this.Type='TflTable';
        this.Content=hType;
        this.Version='0.0';

    elseif isa(hType,'RTW.TflCustomization')
        this.Type='TflCustomization';
        this.Key=hType.Key;
        this.Priority=hType.Priority;
        this.ArrayLayout=hType.ArrayLayout;
        try
            this.OutType=hType.ConceptualArgs(1).toString;
            if isempty(this.OutType)
                this.OutType='embedded';
            end
        catch %#ok<CTCH>
            this.OutType='';
        end

        try
            this.In1Type=hType.ConceptualArgs(2).toString;
            if isempty(this.In1Type)
                this.In1Type='embedded';
            end
        catch %#ok<CTCH>
            this.In1Type='';
        end

        try
            this.In2Type=hType.ConceptualArgs(3).toString;
            if isempty(this.In2Type)
                this.In2Type='embedded';
            end
        catch %#ok<CTCH>
            this.In2Type='';
        end

        this.NumIn=max(0,length(hType.ConceptualArgs)-1);
        this.Content=hType.copy;

    elseif isa(hType,'RTW.TflEntry')
        this.Type='TflEntry';
        this.Key=hType.Key;
        this.Priority=hType.Priority;
        this.UsageCount=hType.UsageCount;
        this.Implementation='';

        if~isa(hType,'RTW.TflBlockEntry')&&~isempty(hType.Implementation)
            this.Implementation=hType.Implementation.Name;
        end

        this.ArrayLayout=hType.ArrayLayout;
        try
            this.OutType=hType.ConceptualArgs(1).toString;
            if isempty(this.OutType)
                this.OutType='embedded';
            end
        catch %#ok<CTCH>
            this.OutType='';
        end

        try
            this.In1Type=hType.ConceptualArgs(2).toString;
            if isempty(this.In1Type)
                this.In1Type='embedded';
            end
        catch %#ok<CTCH>
            this.In1Type='';
        end

        try
            this.In2Type=hType.ConceptualArgs(3).toString;
            if isempty(this.In2Type)
                this.In2Type='embedded';
            end
        catch %#ok<CTCH>
            this.In2Type='';
        end

        this.NumIn=max(0,length(hType.ConceptualArgs)-1);
        this.Content=hType.copy;
    else
        this.Type='other';
    end


