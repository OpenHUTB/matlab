function this=Options(model)




    if nargin>0
        model=convertStringsToChars(model);
    end

    this=Sldv.Options;

    if nargin==1
        try
            [sldvcc,activeCS]=sldvprivate('configcomp_get',model);
            this.sldvcc=sldvcc;
            this.activeCS=activeCS;
            this.modelH=get_param(model,'Handle');
        catch Mex %#ok<NASGU>
            this.sldvcc=[];
            this.activeCS=[];
            this.modelH=0;
        end
    else
        this.initprivatedata;





















        this.DetectActiveLogic='off';
    end

    if this.checkslavtcchandle
        this.extproductTag=sldvcc.productTag;

        L(1)=handle.listener(this.sldvcc,'ObjectBeingDestroyed',@slavtccDestroyed);
        L(1).CallbackTarget=this;
        this.sldvccListener=L(1);
    end

    this.setPropertyGroups;

    if slavteng('feature','PathBasedTestgen')~=0
        isMCDCwithExtension=strcmp(this.ModelCoverageObjectives,'EnhancedMCDC');
        if isMCDCwithExtension
            this.PathBasedTestGeneration='on';
        end
    end

